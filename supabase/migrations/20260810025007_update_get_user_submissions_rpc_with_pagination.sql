-- Add pagination to get_user_submissions_with_stats RPC

DROP FUNCTION IF EXISTS public.get_user_submissions_with_stats(uuid);

CREATE OR REPLACE FUNCTION public.get_user_submissions_with_stats(p_user_id uuid, p_limit integer DEFAULT 20, p_offset integer DEFAULT 0)
 RETURNS TABLE(
    id uuid, 
    exam_id uuid, 
    user_id uuid, 
    score numeric, 
    submitted_at timestamp with time zone, 
    unanswered_count integer, 
    answers jsonb, 
    exam_rank integer, 
    disqualified boolean, 
    started_at timestamp with time zone, 
    completed_at timestamp with time zone, 
    time_taken_seconds integer, 
    device_info jsonb, 
    app_version text, 
    ip_address text, 
    is_auto_submitted boolean, 
    exam_title text, 
    total_participants bigint
 )
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        es.id,
        es.exam_id,
        es.user_id,
        es.score,
        es.submitted_at,
        es.unanswered_count,
        es.answers,
        es.exam_rank,
        es.disqualified,
        es.started_at,
        es.completed_at,
        es.time_taken_seconds,
        es.device_info,
        es.app_version,
        es.ip_address,
        es.is_auto_submitted,
        e.title as exam_title,
        (SELECT COUNT(*) FROM public.exam_submissions es2 WHERE es2.exam_id = es.exam_id) as total_participants
    FROM public.exam_submissions es
    JOIN public.exams e ON e.id = es.exam_id
    WHERE es.user_id = p_user_id
    ORDER BY es.submitted_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$function$;
