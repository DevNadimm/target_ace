-- Update get_user_dashboard_summary and get_user_profile_with_subscription RPCs to properly resolve UX subscription statuses.

-- 1. Update get_user_dashboard_summary
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
    
    v_is_premium BOOLEAN := FALSE;
    v_premium_expires_at TIMESTAMPTZ := NULL;
    v_current_plan_name TEXT := 'Free Member';
    v_subscription_status TEXT := 'none';
    
    rec_active RECORD;
    rec_latest_sub RECORD;
    rec_profile RECORD;
    rec_sub RECORD;
    v_latest_exam_id UUID;
    v_total_participants INT := 0;
    v_user_rank INT := 0;
    v_score_sum NUMERIC(10,2) := 0.0;
    v_weekly_active_days JSONB := '[]'::jsonb;
    v_unread_notifications_count INT := 0;
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

    -- B. User Overall Stats & Profile Subscription Info
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

        -- Streak Metrics & Premium Info
        SELECT streak_count, highest_streak, is_premium, premium_expires_at, COALESCE(to_jsonb(weekly_active_days), '[]'::jsonb)
        INTO v_streak_count, v_highest_streak, v_is_premium, v_premium_expires_at, v_weekly_active_days
        FROM public.profiles
        WHERE id = target_user_id;

        -- Fetch Unread Notifications Count
        SELECT COUNT(*)::INT INTO v_unread_notifications_count
        FROM public.notifications
        WHERE user_id = target_user_id AND is_read = FALSE;

        -- Fetch Latest Subscription overall
        SELECT plan_name, plan_id, status INTO rec_sub
        FROM public.subscriptions
        WHERE user_id = target_user_id
        ORDER BY created_at DESC
        LIMIT 1;

        -- Determine Subscription status
        IF v_is_premium AND (v_premium_expires_at IS NULL OR v_premium_expires_at > NOW()) THEN
            IF rec_sub.plan_id = 'free_trial' OR rec_sub.plan_name = 'Free Trial' THEN
                v_subscription_status := 'trial';
                v_current_plan_name := COALESCE(rec_sub.plan_name, 'Free Trial');
            ELSE
                v_subscription_status := 'active';
                v_current_plan_name := COALESCE(rec_sub.plan_name, 'Pro Access');
            END IF;
        ELSE
            IF rec_sub.status = 'pending' THEN
                v_subscription_status := 'pending_verification';
                v_current_plan_name := COALESCE(rec_sub.plan_name, 'Pro Access');
            ELSIF v_premium_expires_at IS NOT NULL AND v_premium_expires_at <= NOW() THEN
                v_subscription_status := 'expired';
                v_current_plan_name := COALESCE(rec_sub.plan_name, 'Pro Access');
            ELSE
                v_subscription_status := 'none';
                v_current_plan_name := 'Free Member';
            END IF;
        END IF;
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
        'weekly_active_days', v_weekly_active_days,
        'unread_notifications_count', COALESCE(v_unread_notifications_count, 0),
        'latest_performance', v_latest_performance,
        'is_premium', v_is_premium,
        'premium_expires_at', v_premium_expires_at,
        'plan_name', v_current_plan_name,
        'subscription_status', v_subscription_status
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 2. Update get_user_profile_with_subscription to return latest subscription overall
CREATE OR REPLACE FUNCTION public.get_user_profile_with_subscription(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_profile JSONB;
    v_subscription JSONB;
BEGIN
    -- Query User Profile
    SELECT to_jsonb(p.*) INTO v_profile
    FROM public.profiles p
    WHERE p.id = p_user_id;

    -- Query latest subscription overall (not just approved)
    SELECT to_jsonb(s.*) INTO v_subscription
    FROM public.subscriptions s
    WHERE s.user_id = p_user_id
    ORDER BY s.created_at DESC
    LIMIT 1;

    RETURN jsonb_build_object(
        'profile', v_profile,
        'subscription', v_subscription
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
