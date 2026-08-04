-- Phase 3 Migration: Scalability, Performance Indexes & Atomic Dashboard Summary RPC

-- 1. Performance Indexes for Fast Exam Submissions & Latest Performance Lookups
CREATE INDEX IF NOT EXISTS idx_exam_submissions_user_completed 
ON public.exam_submissions(user_id, completed_at DESC);

CREATE INDEX IF NOT EXISTS idx_exam_submissions_exam_score_time 
ON public.exam_submissions(exam_id, score DESC, time_taken_seconds ASC);

CREATE INDEX IF NOT EXISTS idx_exam_submissions_exam_user 
ON public.exam_submissions(exam_id, user_id);

-- 2. Single Atomic RPC for High-Performance Dashboard Loading
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
    v_latest_performance JSONB := NULL;
    v_last_exam_title TEXT := NULL;
    v_last_exam_id UUID := NULL;
    
    rec_active RECORD;
    rec_latest_sub RECORD;
    rec_profile RECORD;
    v_latest_exam_id UUID;
    v_total_participants INT := 0;
    v_user_rank INT := 0;
    v_score_sum NUMERIC(10,2) := 0.0;
BEGIN
    -- A. Active Exam Resolution
    SELECT * INTO rec_active
    FROM public.exams
    WHERE group_id = target_group_id
      AND start_time >= (NOW() - INTERVAL '3 hours')
    ORDER BY start_time ASC
    LIMIT 1;

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

    -- B. User Overall Stats
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

        -- Group Rank RPC call logic
        v_group_rank := public.get_user_group_rank(target_user_id, target_group_id);
        
        -- Global Rank RPC call logic
        v_global_rank := public.get_user_global_rank(target_user_id);

        -- Streak Metrics
        SELECT streak_count, highest_streak
        INTO v_streak_count, v_highest_streak
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
            
            -- Count participants
            SELECT COUNT(*)::INT INTO v_total_participants
            FROM public.exam_submissions
            WHERE exam_id = v_latest_exam_id;

            -- Fetch rank from leaderboards cache
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
        'latest_performance', v_latest_performance
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
