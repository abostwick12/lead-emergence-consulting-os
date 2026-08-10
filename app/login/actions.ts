'use server';

import { redirect } from 'next/navigation';
import { createSupabaseServerClient } from '@/lib/supabase/server';
import { safeReturnPath } from '@/lib/portal/navigation';

export async function signIn(formData: FormData) {
  const email = String(formData.get('email') ?? '');
  const password = String(formData.get('password') ?? '');
  const returnTo = safeReturnPath(String(formData.get('returnTo') ?? '/'));
  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) redirect(`/login?error=${encodeURIComponent('Unable to sign in with those credentials.')}&returnTo=${encodeURIComponent(returnTo)}`);
  redirect(returnTo);
}
