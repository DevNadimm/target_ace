-- Phase 4 Migration: Atomic Daily Streak Tracker & Weekly Active Days Calculation

-- 1. Add Streak Tracking Columns to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS last_active_date DATE,
ADD COLUMN IF NOT EXISTS weekly_reset_date DATE,
ADD COLUMN IF NOT EXISTS weekly_active_days TEXT[] DEFAULT ARRAY[]::text[];

-- 2. Automatic Streak Updater Trigger Function
CREATE OR REPLACE FUNCTION public.update_user_streak_on_submission()
RETURNS TRIGGER AS $$
DECLARE
    v_completed_date DATE;
    v_last_active DATE;
    v_streak INT := 0;
    v_highest INT := 0;
    v_weekly_reset DATE;
    v_active_days TEXT[] := ARRAY[]::text[];
    v_monday DATE;
    v_iso_dow INT;
    v_day_name TEXT;
BEGIN
    IF NEW.user_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Extract completion date (in UTC)
    v_completed_date := (COALESCE(NEW.completed_at, NEW.submitted_at, NOW()) AT TIME ZONE 'UTC')::date;

    -- Get current profile streak stats
    SELECT 
        last_active_date,
        streak_count,
        highest_streak,
        weekly_reset_date,
        weekly_active_days
    INTO 
        v_last_active,
        v_streak,
        v_highest,
        v_weekly_reset,
        v_active_days
    FROM public.profiles
    WHERE id = NEW.user_id;

    v_streak := COALESCE(v_streak, 0);
    v_highest := COALESCE(v_highest, 0);
    v_active_days := COALESCE(v_active_days, ARRAY[]::text[]);

    -- Calculate Monday of the current week
    v_iso_dow := EXTRACT(ISODOW FROM v_completed_date)::INT; -- 1 = Mon, 7 = Sun
    v_monday := v_completed_date - ((v_iso_dow - 1) * INTERVAL '1 day')::date;

    -- Reset weekly active days array if a new week has started
    IF v_weekly_reset IS NULL OR v_weekly_reset < v_monday THEN
        v_weekly_reset := v_monday;
        v_active_days := ARRAY[]::text[];
    END IF;

    -- Determine day name string
    CASE v_iso_dow
        WHEN 1 THEN v_day_name := 'Mon';
        WHEN 2 THEN v_day_name := 'Tue';
        WHEN 3 THEN v_day_name := 'Wed';
        WHEN 4 THEN v_day_name := 'Thu';
        WHEN 5 THEN v_day_name := 'Fri';
        WHEN 6 THEN v_day_name := 'Sat';
        WHEN 7 THEN v_day_name := 'Sun';
    END CASE;

    -- Append day name if not already in weekly_active_days
    IF NOT (v_day_name = ANY(v_active_days)) THEN
        v_active_days := array_append(v_active_days, v_day_name);
    END IF;

    -- Calculate Streak Count
    IF v_last_active IS NULL THEN
        v_streak := 1;
    ELSIF v_last_active = v_completed_date THEN
        -- Already active today, streak count remains unchanged
        v_streak := GREATEST(v_streak, 1);
    ELSIF v_last_active = (v_completed_date - INTERVAL '1 day')::date THEN
        -- Consecutive active day
        v_streak := v_streak + 1;
    ELSIF v_last_active < (v_completed_date - INTERVAL '1 day')::date THEN
        -- Streak broken, reset to 1
        v_streak := 1;
    END IF;

    v_highest := GREATEST(v_highest, v_streak);

    -- Update profiles table
    UPDATE public.profiles
    SET 
        streak_count = v_streak,
        highest_streak = v_highest,
        last_active_date = v_completed_date,
        weekly_reset_date = v_weekly_reset,
        weekly_active_days = v_active_days
    WHERE id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on exam submission
DROP TRIGGER IF EXISTS on_submission_update_streak ON public.exam_submissions;

CREATE TRIGGER on_submission_update_streak
    AFTER INSERT OR UPDATE ON public.exam_submissions
    FOR EACH ROW EXECUTE FUNCTION public.update_user_streak_on_submission();

-- 3. Update get_user_dashboard_summary RPC to include weekly_active_days
CREATE OR REPLACE FUNCTION public.get_user_dashboard_summary(
    target_user_id UUID,
    target_group_id TEXT
)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    v_active_exam JSONB := NULL;
    v_has_submitted_active BOOLEAN := FALSE;
    v_total_battles INT := 0;
    v_average_score NUMERIC(5,2) := 0.0;
    v_total_correct INT := 0;
    v_total_wrong INT := 0;
    v_group_rank INT := 0;
    v_global_rank INT := 0;
    v_streak_count INT := 0;
    v_highest_streak INT := 0;
    v_weekly_active_days TEXT[] := ARRAY[]::text[];
    v_latest_performance JSONB := NULL;
    
    rec_active RECORD;
    rec_latest_sub RECORD;
    v_latest_exam_id UUID;
    v_total_participants INT := 0;
    v_user_rank INT := 0;
    v_score_sum NUMERIC(10,2) := 0.0;
BEGIN
    -- A. Active Exam Resolution (Select next unended exam or fallback to recent)
    SELECT * INTO rec_active
    FROM public.exams
    WHERE group_id = target_group_id
      AND (start_time + (duration_minutes || ' minutes')::interval) > NOW()
    ORDER BY start_time ASC
    LIMIT 1;

    IF rec_active.id IS NULL THEN
        SELECT * INTO rec_active
        FROM public.exams
        WHERE group_id = target_group_id
        ORDER BY start_time DESC
        LIMIT 1;
    END IF;

    IF rec_active.id IS NOT NULL THEN
        v_active_exam := jsonb_build_object(
            'id', rec_active.id,
            'title', rec_active.title,
            'goal_id', rec_active.goal_id,
            'group_id', rec_active.group_id,
            'start_time', rec_active.start_time,
            'duration_minutes', rec_active.duration_minutes,
            'total_questions', rec_active.total_questions,
            'status', rec_active.status,
            'per_question_mark', rec_active.per_question_mark,
            'negative_mark', rec_active.negative_mark
        );

        IF target_user_id IS NOT NULL THEN
            SELECT EXISTS(
                SELECT 1 FROM public.exam_submissions
                WHERE exam_id = rec_active.id AND user_id = target_user_id
            ) INTO v_has_submitted_active;
        END IF;
    END IF;

    -- B. User Overall Stats & Streak Metrics
    IF target_user_id IS NOT NULL THEN
        SELECT 
            COUNT(*)::INT,
            COALESCE(SUM(score), 0.0),
            COALESCE(SUM(correct_count), 0)::INT,
            COALESCE(SUM(wrong_count), 0)::INT
        INTO v_total_battles, v_score_sum, v_total_correct, v_total_wrong
        FROM public.exam_submissions
        WHERE user_id = target_user_id;

        IF v_total_battles > 0 THEN
            v_average_score := v_score_sum / v_total_battles;
        END IF;

        v_group_rank := public.get_user_group_rank(target_user_id, target_group_id);
        v_global_rank := public.get_user_global_rank(target_user_id);

        SELECT 
            COALESCE(streak_count, 0),
            COALESCE(highest_streak, 0),
            COALESCE(weekly_active_days, ARRAY[]::text[])
        INTO 
            v_streak_count,
            v_highest_streak,
            v_weekly_active_days
        FROM public.profiles
        WHERE id = target_user_id;
    END IF;

    -- C. Latest Submission Performance
    IF target_user_id IS NOT NULL THEN
        SELECT 
            es.*,
            e.title AS exam_title
        INTO rec_latest_sub
        FROM public.exam_submissions es
        JOIN public.exams e ON es.exam_id = e.id
        WHERE es.user_id = target_user_id
        ORDER BY COALESCE(es.completed_at, es.submitted_at) DESC
        LIMIT 1;

        IF rec_latest_sub.exam_id IS NOT NULL THEN
            v_latest_exam_id := rec_latest_sub.exam_id;
            
            SELECT COUNT(*)::INT INTO v_total_participants
            FROM public.exam_submissions
            WHERE exam_id = v_latest_exam_id;

            SELECT rank INTO v_user_rank
            FROM public.leaderboards
            WHERE exam_id = v_latest_exam_id AND user_id = target_user_id;

            IF (v_user_rank IS NULL OR v_user_rank = 0) AND v_total_participants > 0 THEN
                SELECT (COUNT(*) + 1)::INT INTO v_user_rank
                FROM public.exam_submissions
                WHERE exam_id = v_latest_exam_id AND score > rec_latest_sub.score;
            END IF;

            v_latest_performance := jsonb_build_object(
                'exam_title', rec_latest_sub.exam_title,
                'completed_at', COALESCE(rec_latest_sub.completed_at, rec_latest_sub.submitted_at),
                'score', ROUND(rec_latest_sub.score),
                'score_out_of', 100,
                'correct_count', rec_latest_sub.correct_count,
                'wrong_count', rec_latest_sub.wrong_count,
                'time_taken_seconds', COALESCE(rec_latest_sub.time_taken_seconds, 0),
                'rank', COALESCE(v_user_rank, 1),
                'total_participants', COALESCE(v_total_participants, 1)
            );
        END IF;
    END IF;

    -- D. Build Final Combined JSON
    result := jsonb_build_object(
        'active_exam', v_active_exam,
        'has_submitted_active', v_has_submitted_active,
        'total_battles', v_total_battles,
        'average_score', v_average_score,
        'total_correct', v_total_correct,
        'total_wrong', v_total_wrong,
        'group_rank', COALESCE(v_group_rank, 0),
        'global_rank', COALESCE(v_global_rank, 0),
        'streak_count', COALESCE(v_streak_count, 0),
        'highest_streak', COALESCE(v_highest_streak, 0),
        'weekly_active_days', to_jsonb(v_weekly_active_days),
        'latest_performance', v_latest_performance
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
