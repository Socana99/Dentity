"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type LoginState = { error: string | null };

export async function signIn(
  _prevState: LoginState,
  formData: FormData
): Promise<LoginState> {
  const supabase = await createClient();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  if (error) return { error: error.message };

  redirect("/pacientes");
}

export async function signUp(
  _prevState: LoginState,
  formData: FormData
): Promise<LoginState> {
  const supabase = await createClient();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  const { data, error } = await supabase.auth.signUp({ email, password });
  if (error) return { error: error.message };

  // Si la confirmación de correo está desactivada, signUp ya devuelve una
  // sesión activa (el usuario queda logueado de inmediato). Si está
  // activada, data.session viene null hasta que confirme el correo.
  if (data.session) redirect("/pacientes");

  return { error: "Revisa tu correo para confirmar la cuenta." };
}
