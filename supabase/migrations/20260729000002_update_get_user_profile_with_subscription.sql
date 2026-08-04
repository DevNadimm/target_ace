-- Update RPC to fetch user profile, active group title, locked_until and latest approved subscription in a single database call

CREATE OR REPLACE FUNCTION public.get_user_profile_with_subscription(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_profile JSONB;
    v_subscription JSONB;
BEGIN
    -- Query User Profile with active group title and locked_until joined
    SELECT jsonb_set(
        jsonb_set(
            to_jsonb(p.*),
            '{active_group_title}',
            to_jsonb(COALESCE(bg.title, 'Not Selected'))
        ),
        '{locked_until}',
        to_jsonb(COALESCE(gm.locked_until::text, ''))
    ) INTO v_profile
    FROM public.profiles p
    LEFT JOIN public.battle_groups bg ON bg.id = p.group_id
    LEFT JOIN public.group_memberships gm ON gm.user_id = p.id AND gm.group_id = p.group_id AND gm.is_active = true
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
