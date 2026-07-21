"use server";

import { randomUUID } from "crypto";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { splitName } from "@/lib/types";

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/login");
}

export type NewPatientState = { error: string | null };

/**
 * Crea un paciente con solo lo mínimo (nombres, apellidos, cédula), igual
 * que el diálogo rápido de la app móvil. El resto de la ficha se completa
 * después. Redirige a la ficha del paciente recién creado.
 */
export async function createPatient(
  _prevState: NewPatientState,
  formData: FormData
): Promise<NewPatientState> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "Sesión expirada, vuelve a iniciar sesión." };

  const nombres = String(formData.get("nombres") ?? "");
  const apellidos = String(formData.get("apellidos") ?? "");
  const cedula = String(formData.get("cedula") ?? "").trim();

  if (!nombres.trim() || !apellidos.trim() || !cedula) {
    return { error: "Completa nombres, apellidos y cédula." };
  }

  const [primerNombre, segundoNombre] = splitName(nombres);
  const [apellidoPaterno, apellidoMaterno] = splitName(apellidos);

  const { error } = await supabase.from("patients").insert({
    id: randomUUID(),
    user_id: user.id,
    primer_nombre: primerNombre,
    segundo_nombre: segundoNombre,
    apellido_paterno: apellidoPaterno,
    apellido_materno: apellidoMaterno,
    cedula,
  });

  if (error) return { error: error.message };

  revalidatePath("/pacientes");
  return { error: null };
}

const CHILD_TABLES = [
  "clinical_history",
  "tooth_marks",
  "treatment_plan",
  "treatment_sessions",
  "payments",
  "consents",
] as const;

/**
 * Borra un paciente y todo lo asociado (historia clínica, odontograma,
 * plan, sesiones, pagos, consentimientos) — igual que en la app móvil.
 */
export async function deletePatient(patientId: string) {
  const supabase = await createClient();

  for (const table of CHILD_TABLES) {
    await supabase.from(table).delete().eq("patient_id", patientId);
  }
  const { error } = await supabase
    .from("patients")
    .delete()
    .eq("id", patientId);

  if (error) throw new Error(error.message);
  revalidatePath("/pacientes");
}
