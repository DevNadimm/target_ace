-- Security Migration: Server-Side Battle Exam Submission & Score Calculation RPC

CREATE OR REPLACE FUNCTION public.submit_battle_exam_secure(
    p_exam_id UUID,
    p_user_id UUID,
    p_answers JSONB,
    p_disqualified BOOLEAN DEFAULT FALSE,
    p_started_at TIMESTAMPTZ DEFAULT NULL,
    p_completed_at TIMESTAMPTZ DEFAULT NULL,
    p_time_taken_seconds INT DEFAULT 0,
    p_device_info JSONB DEFAULT '{}'::jsonb,
    p_app_version TEXT DEFAULT NULL,
    p_is_auto_submitted BOOLEAN DEFAULT FALSE
)
RETURNS JSONB AS $$
DECLARE
    v_per_question_mark NUMERIC(5,2) := 1.0;
    v_negative_mark NUMERIC(5,2) := 0.25;
    v_correct_count INT := 0;
    v_wrong_count INT := 0;
    v_unanswered_count INT := 0;
    v_total_questions INT := 0;
    v_raw_score NUMERIC(5,2) := 0.0;
    v_max_score NUMERIC(5,2) := 0.0;
    v_final_score NUMERIC(5,2) := 0.0;
    v_processed_answers JSONB := '[]'::jsonb;
    v_submission_record public.exam_submissions%ROWTYPE;
BEGIN
    -- 1. Fetch exam configuration (per question mark and negative mark)
    SELECT 
        COALESCE(per_question_mark, 1.0),
        COALESCE(negative_mark, 0.25)
    INTO 
        v_per_question_mark, 
        v_negative_mark
    FROM public.exams
    WHERE id = p_exam_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Exam not found with id %', p_exam_id;
    END IF;

    -- 2. Calculate correct, wrong, unanswered from authoritative questions table
    WITH exam_q AS (
        SELECT q.id AS question_id, q.correct_option
        FROM public.questions q
        JOIN public.exam_questions eq ON eq.question_id = q.id
        WHERE eq.exam_id = p_exam_id
    ),
    client_ans AS (
        SELECT 
            (elem->>'question_id')::UUID AS question_id,
            COALESCE(elem->>'selected', '') AS selected
        FROM jsonb_array_elements(COALESCE(p_answers, '[]'::jsonb)) AS elem
    ),
    eval AS (
        SELECT 
            eq.question_id,
            eq.correct_option,
            COALESCE(ca.selected, '') AS selected,
            CASE 
                WHEN ca.selected IS NULL OR ca.selected = '' THEN 'unanswered'
                WHEN UPPER(TRIM(ca.selected)) = UPPER(TRIM(eq.correct_option)) THEN 'correct'
                ELSE 'wrong'
            END AS eval_status
        FROM exam_q eq
        LEFT JOIN client_ans ca ON ca.question_id = eq.question_id
    )
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE eval_status = 'correct'),
        COUNT(*) FILTER (WHERE eval_status = 'wrong'),
        COUNT(*) FILTER (WHERE eval_status = 'unanswered'),
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'question_id', question_id,
                    'selected', selected,
                    'correct', correct_option,
                    'is_correct', (eval_status = 'correct')
                )
            ),
            '[]'::jsonb
        )
    INTO 
        v_total_questions,
        v_correct_count,
        v_wrong_count,
        v_unanswered_count,
        v_processed_answers
    FROM eval;

    IF v_total_questions = 0 THEN
        -- Fallback if exam_questions junction isn't present, check directly on questions
        WITH direct_q AS (
            SELECT q.id AS question_id, q.correct_option
            FROM public.questions q
            WHERE q.exam_id = p_exam_id
        ),
        client_ans AS (
            SELECT 
                (elem->>'question_id')::UUID AS question_id,
                COALESCE(elem->>'selected', '') AS selected
            FROM jsonb_array_elements(COALESCE(p_answers, '[]'::jsonb)) AS elem
        ),
        eval AS (
            SELECT 
                dq.question_id,
                dq.correct_option,
                COALESCE(ca.selected, '') AS selected,
                CASE 
                    WHEN ca.selected IS NULL OR ca.selected = '' THEN 'unanswered'
                    WHEN UPPER(TRIM(ca.selected)) = UPPER(TRIM(dq.correct_option)) THEN 'correct'
                    ELSE 'wrong'
                END AS eval_status
            FROM direct_q dq
            LEFT JOIN client_ans ca ON ca.question_id = dq.question_id
        )
        SELECT 
            COUNT(*),
            COUNT(*) FILTER (WHERE eval_status = 'correct'),
            COUNT(*) FILTER (WHERE eval_status = 'wrong'),
            COUNT(*) FILTER (WHERE eval_status = 'unanswered'),
            COALESCE(
                jsonb_agg(
                    jsonb_build_object(
                        'question_id', question_id,
                        'selected', selected,
                        'correct', correct_option,
                        'is_correct', (eval_status = 'correct')
                    )
                ),
                '[]'::jsonb
            )
        INTO 
            v_total_questions,
            v_correct_count,
            v_wrong_count,
            v_unanswered_count,
            v_processed_answers
        FROM eval;
    END IF;

    -- 3. Compute score
    v_raw_score := (v_correct_count * v_per_question_mark) - (v_wrong_count * v_negative_mark);
    v_max_score := v_total_questions * v_per_question_mark;

    IF p_disqualified THEN
        v_final_score := 0.0;
    ELSIF v_max_score > 0 THEN
        v_final_score := LEAST(GREATEST(((v_raw_score / v_max_score) * 100.0), 0.0), 100.0);
    ELSE
        v_final_score := 0.0;
    END IF;

    -- 4. Upsert into public.exam_submissions
    INSERT INTO public.exam_submissions (
        exam_id,
        user_id,
        score,
        correct_count,
        wrong_count,
        unanswered_count,
        answers,
        disqualified,
        is_auto_submitted,
        started_at,
        completed_at,
        time_taken_seconds,
        device_info,
        app_version
    ) VALUES (
        p_exam_id,
        p_user_id,
        v_final_score,
        v_correct_count,
        v_wrong_count,
        v_unanswered_count,
        COALESCE(v_processed_answers, '[]'::jsonb),
        p_disqualified,
        p_is_auto_submitted,
        p_started_at,
        COALESCE(p_completed_at, NOW()),
        p_time_taken_seconds,
        p_device_info,
        p_app_version
    )
    ON CONFLICT (exam_id, user_id) DO UPDATE SET
        score = EXCLUDED.score,
        correct_count = EXCLUDED.correct_count,
        wrong_count = EXCLUDED.wrong_count,
        unanswered_count = EXCLUDED.unanswered_count,
        answers = EXCLUDED.answers,
        disqualified = EXCLUDED.disqualified,
        is_auto_submitted = EXCLUDED.is_auto_submitted,
        completed_at = EXCLUDED.completed_at,
        time_taken_seconds = EXCLUDED.time_taken_seconds,
        device_info = EXCLUDED.device_info,
        app_version = EXCLUDED.app_version
    RETURNING * INTO v_submission_record;

    RETURN row_to_json(v_submission_record)::jsonb;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.submit_battle_exam_secure TO authenticated;
