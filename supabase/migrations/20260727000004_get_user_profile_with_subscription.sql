-- Create RPC to fetch user profile and latest approved subscription in a single database call

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

    -- Query latest approved subscription
    SELECT to_jsonb(s.*) INTO v_subscription
    FROM public.subscriptions s
    WHERE s.user_id = p_user_id AND s.status = 'approved'
    ORDER BY s.created_at DESC
    LIMIT 1;

    RETURN jsonb_build_object(
        'profile', v_profile,
        'subscription', v_subscription
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
