'use server';

import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { safeReturnPath } from '@/lib/portal/navigation';
import { loginErrors } from '@/lib/portal/login-messages';

export async function signIn(formData: FormData) {
  const email = String(formData.get('email') ?? '');
  const password = String(formData.get('password') ?? '');
  const returnTo = safeReturnPath(String(formData.get('returnTo') ?? '/'));
  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) redirect(`/login?legacy=1&error=${encodeURIComponent(loginErrors.credentials)}&returnTo=${encodeURIComponent(returnTo)}`);
  redirect(returnTo);
}
