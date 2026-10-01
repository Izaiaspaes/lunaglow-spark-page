CREATE TYPE public.app_role AS ENUM ('admin','moderator','user');

CREATE OR REPLACE FUNCTION public.update_updated_at_column() RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

CREATE TABLE public.cycle_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, cycle_start_date DATE NOT NULL, cycle_end_date DATE, cycle_length INTEGER, period_length INTEGER, flow_intensity TEXT CHECK (flow_intensity IN ('leve','moderado','intenso')), symptoms TEXT[], notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.sleep_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, sleep_date DATE NOT NULL, bedtime TIME, wake_time TIME, sleep_duration_hours DECIMAL(4,2), sleep_quality INTEGER CHECK (sleep_quality BETWEEN 1 AND 5), notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(user_id, sleep_date));
CREATE TABLE public.mood_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, mood_date DATE NOT NULL, mood_level INTEGER CHECK (mood_level BETWEEN 1 AND 5), mood_type TEXT CHECK (mood_type IN ('feliz','ansiosa','triste','irritada','calma','energizada','cansada')), notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(user_id, mood_date, mood_type));
CREATE TABLE public.energy_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, energy_date DATE NOT NULL, energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5), time_of_day TEXT CHECK (time_of_day IS NULL OR time_of_day IN ('manha','tarde','noite')), notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(user_id, energy_date, time_of_day));
CREATE TABLE public.wellness_plans (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, plan_type TEXT CHECK (plan_type IN ('sono','meditacao','nutricao','exercicio','geral')), plan_content JSONB NOT NULL, ai_recommendations TEXT NOT NULL, valid_from DATE NOT NULL DEFAULT CURRENT_DATE, valid_until DATE, is_active BOOLEAN DEFAULT true, completed_at TIMESTAMPTZ, archived_at TIMESTAMPTZ, status TEXT DEFAULT 'active' CHECK (status IN ('active','completed','archived')), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['cycle_tracking','sleep_tracking','mood_tracking','energy_tracking','wellness_plans'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY "Own select" ON public.%I FOR SELECT USING (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own insert" ON public.%I FOR INSERT WITH CHECK (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own update" ON public.%I FOR UPDATE USING (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own delete" ON public.%I FOR DELETE USING (auth.uid() = user_id)', t);
  END LOOP;
END $$;
CREATE TRIGGER update_cycle_tracking_updated_at BEFORE UPDATE ON public.cycle_tracking FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_sleep_tracking_updated_at BEFORE UPDATE ON public.sleep_tracking FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_wellness_plans_updated_at BEFORE UPDATE ON public.wellness_plans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE INDEX idx_cycle_tracking_user_date ON public.cycle_tracking(user_id, cycle_start_date DESC);
CREATE INDEX idx_sleep_tracking_user_date ON public.sleep_tracking(user_id, sleep_date DESC);
CREATE INDEX idx_mood_tracking_user_date ON public.mood_tracking(user_id, mood_date DESC);
CREATE INDEX idx_energy_tracking_user_date ON public.energy_tracking(user_id, energy_date DESC);
CREATE INDEX idx_wellness_plans_user_active ON public.wellness_plans(user_id, is_active, valid_from DESC);
CREATE INDEX idx_wellness_plans_status ON public.wellness_plans(status);

CREATE TABLE public.user_roles (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL, role app_role NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), UNIQUE (user_id, role));
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role) RETURNS BOOLEAN LANGUAGE SQL STABLE SECURITY DEFINER SET search_path = public AS $$ SELECT EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = _user_id AND role = _role) $$;
CREATE OR REPLACE FUNCTION public.handle_new_user_role() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$ BEGIN INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'user'); RETURN NEW; END; $$;
CREATE TRIGGER on_auth_user_created_role AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_role();
CREATE POLICY "Users can view their own roles" ON public.user_roles FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all roles" ON public.user_roles FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert roles" ON public.user_roles FOR INSERT TO authenticated WITH CHECK (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update roles" ON public.user_roles FOR UPDATE TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete roles" ON public.user_roles FOR DELETE TO authenticated USING (public.has_role(auth.uid(), 'admin'));
CREATE OR REPLACE FUNCTION public.make_user_admin(_email TEXT) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$ DECLARE _user_id UUID; BEGIN SELECT id INTO _user_id FROM auth.users WHERE email = _email; IF _user_id IS NOT NULL THEN INSERT INTO public.user_roles (user_id, role) VALUES (_user_id, 'admin') ON CONFLICT (user_id, role) DO NOTHING; END IF; END; $$;
REVOKE EXECUTE ON FUNCTION public.make_user_admin(TEXT) FROM PUBLIC, anon, authenticated;

CREATE TABLE public.admin_notifications (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, title TEXT NOT NULL, message TEXT NOT NULL, type TEXT NOT NULL CHECK (type IN ('new_user','system_alert','critical_metric','general')), severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info','warning','error','success')), read BOOLEAN NOT NULL DEFAULT false, related_user_id UUID, metadata JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view all notifications" ON public.admin_notifications FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update notifications" ON public.admin_notifications FOR UPDATE USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can insert notifications" ON public.admin_notifications FOR INSERT WITH CHECK (has_role(auth.uid(), 'admin'));
CREATE INDEX idx_admin_notifications_read ON public.admin_notifications(read);
CREATE INDEX idx_admin_notifications_created_at ON public.admin_notifications(created_at DESC);
CREATE OR REPLACE FUNCTION public.notify_admins_new_user() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$ BEGIN INSERT INTO public.admin_notifications (title, message, type, severity, related_user_id, metadata) VALUES ('Novo Usuário Cadastrado', 'Um novo usuário se cadastrou na plataforma: ' || NEW.email, 'new_user', 'info', NEW.id, jsonb_build_object('email', NEW.email, 'created_at', NEW.created_at)); RETURN NEW; END; $$;
CREATE TRIGGER on_auth_user_created_notify_admins AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.notify_admins_new_user();
ALTER PUBLICATION supabase_realtime ADD TABLE public.admin_notifications;

CREATE TABLE public.invites (id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, code text NOT NULL UNIQUE, email text, created_by uuid NOT NULL, used_by uuid, used_at timestamptz, expires_at timestamptz NOT NULL, max_uses integer NOT NULL DEFAULT 1, current_uses integer NOT NULL DEFAULT 0, created_at timestamptz NOT NULL DEFAULT now(), is_active boolean NOT NULL DEFAULT true);
ALTER TABLE public.invites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can view all invites" ON public.invites FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can create invites" ON public.invites FOR INSERT WITH CHECK (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can update invites" ON public.invites FOR UPDATE USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can delete invites" ON public.invites FOR DELETE USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Anyone can validate invites" ON public.invites FOR SELECT USING (is_active = true AND expires_at > now());
CREATE INDEX idx_invites_code ON public.invites(code);

CREATE TABLE public.reminders (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL, tracking_type TEXT NOT NULL CHECK (tracking_type IN ('ciclo','sono','humor','energia')), reminder_time TIME NOT NULL, days_of_week INTEGER[] NOT NULL DEFAULT ARRAY[0,1,2,3,4,5,6], is_active BOOLEAN NOT NULL DEFAULT true, message TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.symptom_predictions (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, prediction_date DATE NOT NULL, predicted_phase TEXT NOT NULL, predicted_symptoms JSONB NOT NULL DEFAULT '[]', confidence_score INTEGER NOT NULL CHECK (confidence_score BETWEEN 0 AND 100), recommendations JSONB NOT NULL DEFAULT '[]', created_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.work_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL, work_date DATE NOT NULL, routine_type TEXT NOT NULL CHECK (routine_type IN ('fixed','variable','shift')), hours_worked NUMERIC NOT NULL CHECK (hours_worked BETWEEN 0 AND 24), shift_type TEXT CHECK (shift_type IN ('day','night','mixed','off')), workload_level TEXT NOT NULL CHECK (workload_level IN ('light','moderate','heavy','exhausting')), mood_impact_level TEXT NOT NULL CHECK (mood_impact_level IN ('low','medium','high','very_high')), daily_message TEXT, notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(user_id, work_date));
CREATE TABLE public.nutrition_tracking (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL, nutrition_date DATE NOT NULL, meal_type TEXT, foods_consumed TEXT, portion_size TEXT, notes TEXT, nutrition_quality INTEGER, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.push_subscriptions (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL, subscription_data JSONB NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now(), UNIQUE(user_id, subscription_data));
CREATE TABLE public.journal_entries (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL, entry_text TEXT NOT NULL, ai_summary TEXT, ai_patterns TEXT, ai_suggestions JSONB DEFAULT '[]', ai_correlations TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.beauty_analyses (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL, photo_url TEXT NOT NULL, analysis_type TEXT NOT NULL, ai_analysis JSONB NOT NULL, skin_tone_detected TEXT, face_shape TEXT, recommendations JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.closet_items (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, photo_url TEXT NOT NULL, item_type TEXT NOT NULL, category TEXT, colors TEXT[], season TEXT[], occasion TEXT[], ai_description TEXT, ai_tags TEXT[], created_at TIMESTAMPTZ DEFAULT now(), updated_at TIMESTAMPTZ DEFAULT now());
CREATE TABLE public.outfit_suggestions (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, item_ids UUID[], outfit_name TEXT, occasion TEXT, season TEXT, ai_description TEXT, ai_styling_tips TEXT, created_at TIMESTAMPTZ DEFAULT now());

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['reminders','symptom_predictions','work_tracking','nutrition_tracking','push_subscriptions','journal_entries','beauty_analyses','closet_items','outfit_suggestions'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY "Own select" ON public.%I FOR SELECT TO authenticated USING (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own insert" ON public.%I FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own update" ON public.%I FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id)', t);
    EXECUTE format('CREATE POLICY "Own delete" ON public.%I FOR DELETE TO authenticated USING (auth.uid() = user_id)', t);
  END LOOP;
END $$;
CREATE TRIGGER update_reminders_updated_at BEFORE UPDATE ON public.reminders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_work_tracking_updated_at BEFORE UPDATE ON public.work_tracking FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_nutrition_tracking_updated_at BEFORE UPDATE ON public.nutrition_tracking FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_push_subscriptions_updated_at BEFORE UPDATE ON public.push_subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_journal_entries_updated_at BEFORE UPDATE ON public.journal_entries FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_beauty_analyses_updated_at BEFORE UPDATE ON public.beauty_analyses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_closet_items_updated_at BEFORE UPDATE ON public.closet_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE INDEX idx_symptom_predictions_user_date ON public.symptom_predictions(user_id, prediction_date DESC);
CREATE INDEX idx_work_tracking_user_date ON public.work_tracking(user_id, work_date DESC);

CREATE TABLE public.profiles (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, full_name TEXT, avatar_url TEXT, phone TEXT, theme TEXT DEFAULT 'default' CHECK (theme IN ('default','sunset','ocean','forest','lavender','rose')), subscription_plan text DEFAULT 'free' CHECK (subscription_plan IN ('free','premium','premium_plus')), privacy_mode boolean DEFAULT false, encryption_enabled boolean DEFAULT false, tour_completed boolean DEFAULT false, notification_preferences jsonb DEFAULT jsonb_build_object('reminders',true,'cycle_phase_changes',true,'partner_updates',true,'wellness_plans',true,'predictions',true), created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can update any profile" ON public.profiles FOR UPDATE TO authenticated USING (has_role(auth.uid(), 'admin')) WITH CHECK (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins can view all profiles" ON public.profiles FOR SELECT TO authenticated USING (has_role(auth.uid(), 'admin'));
CREATE OR REPLACE FUNCTION public.handle_new_user_profile() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$ BEGIN INSERT INTO public.profiles (user_id, full_name) VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))); RETURN NEW; END; $$;
CREATE TRIGGER on_auth_user_created_profile AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE OR REPLACE FUNCTION public.protect_subscription_plan() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NEW.subscription_plan IS DISTINCT FROM OLD.subscription_plan AND auth.uid() IS NOT NULL AND NOT public.has_role(auth.uid(), 'admin') THEN
    NEW.subscription_plan := OLD.subscription_plan;
  END IF;
  RETURN NEW;
END; $$;
CREATE TRIGGER protect_subscription_plan BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.protect_subscription_plan();

CREATE OR REPLACE FUNCTION public.get_users_with_profiles() RETURNS TABLE(user_id uuid, email text, full_name text, phone text, subscription_plan text, created_at timestamptz, roles jsonb) LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  IF NOT public.has_role(auth.uid(), 'admin') THEN RAISE EXCEPTION 'forbidden'; END IF;
  RETURN QUERY SELECT au.id, au.email::text, p.full_name, p.phone, COALESCE(p.subscription_plan,'free'), au.created_at,
    COALESCE(jsonb_agg(jsonb_build_object('role', ur.role)) FILTER (WHERE ur.role IS NOT NULL), '[]'::jsonb)
  FROM auth.users au LEFT JOIN public.profiles p ON p.user_id = au.id LEFT JOIN public.user_roles ur ON ur.user_id = au.id
  GROUP BY au.id, au.email, p.full_name, p.phone, p.subscription_plan, au.created_at ORDER BY au.created_at DESC;
END; $$;

CREATE POLICY "Avatar auth read" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'avatars');
CREATE POLICY "Avatar own insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Avatar own update" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Avatar own delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Beauty own insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'beauty-analysis' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Beauty own select" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'beauty-analysis' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Beauty own delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'beauty-analysis' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Closet own select" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'closet-items' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Closet own insert" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'closet-items' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Closet own delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'closet-items' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE TABLE public.newsletter_subscribers (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, email TEXT NOT NULL UNIQUE, subscribed_at TIMESTAMPTZ NOT NULL DEFAULT now(), is_active BOOLEAN NOT NULL DEFAULT true, source TEXT DEFAULT 'blog', metadata JSONB DEFAULT '{}');
ALTER TABLE public.newsletter_subscribers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can subscribe to newsletter" ON public.newsletter_subscribers FOR INSERT WITH CHECK (length(email) BETWEEN 3 AND 255);
CREATE POLICY "Admins view subscribers" ON public.newsletter_subscribers FOR SELECT USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins update subscribers" ON public.newsletter_subscribers FOR UPDATE USING (has_role(auth.uid(), 'admin'));
CREATE POLICY "Admins delete subscribers" ON public.newsletter_subscribers FOR DELETE USING (has_role(auth.uid(), 'admin'));

CREATE TABLE public.partner_relationships (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, owner_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, partner_email TEXT NOT NULL, partner_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, invite_token TEXT UNIQUE NOT NULL, status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','accepted','declined','revoked')), invited_at TIMESTAMPTZ NOT NULL DEFAULT now(), accepted_at TIMESTAMPTZ, sharing_settings JSONB NOT NULL DEFAULT '{"cycle": true, "symptoms": true, "mood": true, "energy": true}', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(owner_user_id, partner_email));
ALTER TABLE public.partner_relationships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their relationships" ON public.partner_relationships FOR SELECT USING (auth.uid() = owner_user_id OR auth.uid() = partner_user_id);
CREATE POLICY "Users can create relationships" ON public.partner_relationships FOR INSERT WITH CHECK (auth.uid() = owner_user_id);
CREATE POLICY "Users can update their relationships" ON public.partner_relationships FOR UPDATE USING (auth.uid() = owner_user_id OR auth.uid() = partner_user_id);
CREATE POLICY "Users can delete their relationships" ON public.partner_relationships FOR DELETE USING (auth.uid() = owner_user_id);
CREATE TABLE public.partner_notifications (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, relationship_id UUID NOT NULL REFERENCES public.partner_relationships(id) ON DELETE CASCADE, notification_type TEXT NOT NULL CHECK (notification_type IN ('phase_change','tip','support_reminder')), title TEXT NOT NULL, message TEXT NOT NULL, phase TEXT, read BOOLEAN NOT NULL DEFAULT false, created_at TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE public.partner_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Partners can view their notifications" ON public.partner_notifications FOR SELECT USING (EXISTS (SELECT 1 FROM public.partner_relationships pr WHERE pr.id = relationship_id AND pr.partner_user_id = auth.uid() AND pr.status = 'accepted'));
CREATE POLICY "Partners can update their notifications" ON public.partner_notifications FOR UPDATE USING (EXISTS (SELECT 1 FROM public.partner_relationships pr WHERE pr.id = relationship_id AND pr.partner_user_id = auth.uid() AND pr.status = 'accepted'));
CREATE INDEX idx_partner_relationships_owner ON public.partner_relationships(owner_user_id);
CREATE INDEX idx_partner_relationships_partner ON public.partner_relationships(partner_user_id);
CREATE INDEX idx_partner_notifications_relationship ON public.partner_notifications(relationship_id);
CREATE TRIGGER update_partner_relationships_updated_at BEFORE UPDATE ON public.partner_relationships FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
ALTER PUBLICATION supabase_realtime ADD TABLE public.partner_relationships;
ALTER PUBLICATION supabase_realtime ADD TABLE public.partner_notifications;

CREATE TABLE public.user_onboarding_data (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE, full_name TEXT, social_name TEXT, preferred_name TEXT, age INTEGER, profession TEXT, current_city TEXT, current_country TEXT, birth_date DATE, birth_time TIME, birth_city TEXT, birth_country TEXT, birth_coordinates JSONB, weight NUMERIC, height NUMERIC, body_shapes TEXT[], skin_tone TEXT, skin_types TEXT[], eye_color TEXT, hair_color TEXT, hair_type TEXT, hair_length TEXT, nail_preference TEXT, favorite_color TEXT, hobbies TEXT[], personal_interests TEXT, self_love_notes TEXT, current_care_routines TEXT[], care_improvement_goals TEXT[], most_explored_life_area TEXT, life_area_to_improve TEXT, main_app_goal TEXT, content_preferences TEXT[], notification_frequency TEXT, work_routine_type TEXT CHECK (work_routine_type IN ('fixed','variable','shift')), completed_at TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
ALTER TABLE public.user_onboarding_data ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Own select" ON public.user_onboarding_data FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Own insert" ON public.user_onboarding_data FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own update" ON public.user_onboarding_data FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own delete" ON public.user_onboarding_data FOR DELETE USING (auth.uid() = user_id);
CREATE TRIGGER update_user_onboarding_data_updated_at BEFORE UPDATE ON public.user_onboarding_data FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.testimonials (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, user_name TEXT NOT NULL, user_age INTEGER, user_avatar_url TEXT, testimonial_text TEXT NOT NULL, is_featured BOOLEAN NOT NULL DEFAULT false, display_order INTEGER NOT NULL DEFAULT 0, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), created_by UUID REFERENCES auth.users(id));
CREATE TABLE public.announcement_banners (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), title TEXT NOT NULL, message TEXT NOT NULL, banner_type TEXT NOT NULL DEFAULT 'info', is_active BOOLEAN NOT NULL DEFAULT true, link_url TEXT, link_text TEXT, start_date TIMESTAMPTZ NOT NULL DEFAULT now(), end_date TIMESTAMPTZ, display_order INTEGER NOT NULL DEFAULT 0, created_by UUID, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.discount_coupons (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, code TEXT NOT NULL UNIQUE, discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage','fixed_amount')), discount_value NUMERIC NOT NULL CHECK (discount_value > 0), max_uses INTEGER NOT NULL DEFAULT 1 CHECK (max_uses > 0), current_uses INTEGER NOT NULL DEFAULT 0 CHECK (current_uses >= 0), valid_from TIMESTAMPTZ NOT NULL DEFAULT now(), valid_until TIMESTAMPTZ NOT NULL, is_active BOOLEAN NOT NULL DEFAULT true, applies_to TEXT[], description TEXT, created_by UUID, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.price_settings (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, plan_type TEXT NOT NULL CHECK (plan_type IN ('premium','premium_plus')), currency TEXT NOT NULL CHECK (currency IN ('brl','usd')), billing_period TEXT NOT NULL CHECK (billing_period IN ('monthly','yearly')), price DECIMAL(10,2) NOT NULL CHECK (price >= 0), stripe_price_id TEXT NOT NULL, is_active BOOLEAN NOT NULL DEFAULT true, is_promotion BOOLEAN NOT NULL DEFAULT false, promotion_start_date TIMESTAMPTZ, promotion_end_date TIMESTAMPTZ, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now(), created_by UUID REFERENCES auth.users(id), UNIQUE(plan_type, currency, billing_period, is_active));
CREATE TABLE public.wellness_plan_templates (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, description TEXT NOT NULL, template_type TEXT NOT NULL, base_recommendations JSONB NOT NULL DEFAULT '[]', is_active BOOLEAN NOT NULL DEFAULT true, display_order INTEGER NOT NULL DEFAULT 0, created_by UUID, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());
CREATE TABLE public.user_suggestions (id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY, email TEXT NOT NULL, suggestion TEXT NOT NULL, category TEXT, status TEXT DEFAULT 'pending', is_reviewed BOOLEAN DEFAULT false, admin_notes TEXT, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now());

DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['testimonials','announcement_banners','discount_coupons','price_settings','wellness_plan_templates','user_suggestions'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY "Admins select" ON public.%I FOR SELECT USING (has_role(auth.uid(), ''admin''))', t);
    EXECUTE format('CREATE POLICY "Admins insert" ON public.%I FOR INSERT WITH CHECK (has_role(auth.uid(), ''admin''))', t);
    EXECUTE format('CREATE POLICY "Admins update" ON public.%I FOR UPDATE USING (has_role(auth.uid(), ''admin''))', t);
    EXECUTE format('CREATE POLICY "Admins delete" ON public.%I FOR DELETE USING (has_role(auth.uid(), ''admin''))', t);
    EXECUTE format('CREATE TRIGGER update_%s_updated_at BEFORE UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column()', t, t);
  END LOOP;
END $$;
CREATE POLICY "Anyone can view featured testimonials" ON public.testimonials FOR SELECT USING (is_featured = true);
CREATE POLICY "Anyone can view active banners" ON public.announcement_banners FOR SELECT USING (is_active = true AND start_date <= now() AND (end_date IS NULL OR end_date >= now()));
CREATE POLICY "Anyone can validate active coupons" ON public.discount_coupons FOR SELECT USING (is_active = true AND valid_from <= now() AND valid_until >= now() AND current_uses < max_uses);
CREATE POLICY "Anyone can view active prices" ON public.price_settings FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view active templates" ON public.wellness_plan_templates FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can submit suggestions" ON public.user_suggestions FOR INSERT WITH CHECK (length(suggestion) BETWEEN 1 AND 5000 AND length(email) BETWEEN 3 AND 255);
CREATE OR REPLACE FUNCTION public.validate_coupon_dates() RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$ BEGIN IF NEW.valid_until <= NEW.valid_from THEN RAISE EXCEPTION 'valid_until must be after valid_from'; END IF; RETURN NEW; END; $$;
CREATE TRIGGER validate_coupon_dates_trigger BEFORE INSERT OR UPDATE ON public.discount_coupons FOR EACH ROW EXECUTE FUNCTION public.validate_coupon_dates();

DO $$ DECLARE t text; BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname='public' LOOP
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO authenticated', t);
    EXECUTE format('GRANT ALL ON public.%I TO service_role', t);
  END LOOP;
END $$;
GRANT SELECT ON public.invites, public.testimonials, public.announcement_banners, public.discount_coupons, public.price_settings, public.wellness_plan_templates TO anon;
GRANT INSERT ON public.newsletter_subscribers, public.user_suggestions TO anon;