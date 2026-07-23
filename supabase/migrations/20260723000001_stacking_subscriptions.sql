-- Migration: Update handle_subscription_status_update trigger to support subscription stacking correctly with pending/rejected states.

-- Drop the old AFTER trigger
DROP TRIGGER IF EXISTS on_subscription_status_update ON public.subscriptions;

-- Create the updated trigger function supporting stacking
CREATE OR REPLACE FUNCTION public.handle_subscription_status_update()
RETURNS TRIGGER AS $$
DECLARE
    plan_days INT;
    current_expiry TIMESTAMPTZ;
    new_start TIMESTAMPTZ;
    new_end TIMESTAMPTZ;
    max_expiry TIMESTAMPTZ;
BEGIN
    -- Only calculate and set dates when status changes to 'approved'
    IF NEW.status = 'approved' AND (TG_OP = 'INSERT' OR OLD.status IS NULL OR OLD.status != 'approved') THEN
        -- Get the plan duration (default to 30 days if not found)
        SELECT duration_days INTO plan_days 
        FROM public.plans 
        WHERE id = NEW.plan_id;
        
        IF plan_days IS NULL THEN
            IF NEW.plan_id = 'yearly' THEN
                plan_days := 365;
            ELSE
                plan_days := 30;
            END IF;
        END IF;

        -- Get user's current premium expiry date
        SELECT premium_expires_at INTO current_expiry 
        FROM public.profiles 
        WHERE id = NEW.user_id;

        -- Calculate stacked start and end dates
        IF current_expiry IS NOT NULL AND current_expiry > NOW() THEN
            new_start := current_expiry;
        ELSE
            new_start := NOW();
        END IF;
        
        new_end := new_start + (plan_days || ' days')::INTERVAL;

        -- Set the start and end dates on the subscription record
        NEW.start_date := new_start;
        NEW.end_date := new_end;
        NEW.verified_at := NOW();
    END IF;
    
    -- Dynamically update the user's profile with the max end_date of all approved subscriptions
    -- Exclude the current subscription record if it is not currently approved
    SELECT MAX(end_date) INTO max_expiry
    FROM public.subscriptions
    WHERE user_id = NEW.user_id 
      AND status = 'approved'
      AND id != COALESCE(NEW.id, -1);

    IF NEW.status = 'approved' THEN
        IF max_expiry IS NULL OR NEW.end_date > max_expiry THEN
            max_expiry := NEW.end_date;
        END IF;
    END IF;

    -- Update profiles table with the calculated max_expiry
    IF max_expiry IS NOT NULL AND max_expiry > NOW() THEN
        UPDATE public.profiles
        SET is_premium = TRUE,
            premium_expires_at = max_expiry
        WHERE id = NEW.user_id;
    ELSE
        UPDATE public.profiles
        SET is_premium = FALSE,
            premium_expires_at = max_expiry
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Re-create the trigger as a BEFORE trigger so it can modify the NEW row values
CREATE TRIGGER on_subscription_status_update
    BEFORE INSERT OR UPDATE OF status ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.handle_subscription_status_update();
