"use server";

import { randomUUID } from "crypto";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type SaveState = { error: string | null; ok: boolean };
const OK: SaveState = { error: null, ok: true };

function fail(message: string): SaveState {
  return { error: message, ok: false };
}

async function currentUserId() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  return user?.id ?? null;
}

// ---------------------------------------------------------------------
// Admisión — actualiza directamente la fila de patients.
// ---------------------------------------------------------------------
const ADMISSION_TEXT_FIELDS = [
  "institucion",
  "unidad_operativa",
  "cod_uo",
  "parroquia",
  "canton",
  "provincia",
  "numero_historia_clinica",
  "apellido_paterno",
  "apellido_materno",
  "primer_nombre",
  "segundo_nombre",
  "cedula",
  "direccion",
  "barrio",
  "telefono",
  "lugar_nacimiento",
  "nacionalidad",
  "grupo_cultural",
  "instruccion",
  "ocupacion",
  "empresa",
  "tipo_seguro",
  "referido_de",
  "contacto_emergencia_nombre",
  "contacto_emergencia_parentesco",
  "contacto_emergencia_direccion",
  "contacto_emergencia_telefono",
] as const;

export async function updateAdmission(
  patientId: string,
  _prevState: SaveState,
  formData: FormData
): Promise<SaveState> {
  const supabase = await createClient();
  const update: Record<string, unknown> = {};
  for (const key of ADMISSION_TEXT_FIELDS) {
    update[key] = String(formData.get(key) ?? "");
  }
  update.sexo = String(formData.get("sexo") ?? "F");
  update.estado_civil = String(formData.get("estado_civil") ?? "SOL");
  const edad = Number(formData.get("edad"));
  update.edad = Number.isFinite(edad) ? edad : 0;

  const { error } = await supabase
    .from("patients")
    .update(update)
    .eq("id", patientId);
  if (error) return fail(error.message);

  revalidatePath(`/pacientes/${patientId}`);
  revalidatePath("/pacientes");
  return OK;
}

// ---------------------------------------------------------------------
// Historia clínica — un registro por paciente (se actualiza in place).
// ---------------------------------------------------------------------
export async function saveClinicalHistory(
  patientId: string,
  existingId: string | null,
  _prevState: SaveState,
  formData: FormData
): Promise<SaveState> {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return fail("Sesión expirada, vuelve a iniciar sesión.");

  const antecedentes: Record<string, boolean> = {};
  for (const key of formData.keys()) {
    if (key.startsWith("antecedente_")) {
      antecedentes[key.replace("antecedente_", "")] = true;
    }
  }
  const examen: Record<string, string> = {};
  for (const [key, value] of formData.entries()) {
    if (key.startsWith("examen_")) {
      examen[key.replace("examen_", "")] = String(value);
    }
  }

  const row = {
    patient_id: patientId,
    user_id: userId,
    motivo_consulta: String(formData.get("motivo_consulta") ?? ""),
    enfermedad_actual: String(formData.get("enfermedad_actual") ?? ""),
    antecedentes,
    antecedentes_detalle: String(formData.get("antecedentes_detalle") ?? ""),
    presion_arterial: String(formData.get("presion_arterial") ?? ""),
    frecuencia_cardiaca: String(formData.get("frecuencia_cardiaca") ?? ""),
    temperatura: String(formData.get("temperatura") ?? ""),
    frecuencia_respiratoria: String(formData.get("frecuencia_respiratoria") ?? ""),
    examen_estomatognatico: examen,
  };

  const { error } = existingId
    ? await supabase.from("clinical_history").update(row).eq("id", existingId)
    : await supabase.from("clinical_history").insert({ id: randomUUID(), ...row });
  if (error) return fail(error.message);

  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}

// ---------------------------------------------------------------------
// Odontograma — una marca por pieza dental (simplificado: sin trazo libre,
// que en la app móvil es específico del lápiz sobre tablet).
// ---------------------------------------------------------------------
export async function saveToothMark(
  patientId: string,
  toothNumber: number,
  existingId: string | null,
  data: {
    symbol: string;
    movilidad: number;
    recesion: boolean;
    color: string;
  }
): Promise<SaveState & { id: string | null }> {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return { ...fail("Sesión expirada, vuelve a iniciar sesión."), id: null };

  const row = {
    patient_id: patientId,
    user_id: userId,
    tooth_number: toothNumber,
    surface: "general",
    symbol: data.symbol,
    movilidad: data.movilidad,
    recesion: data.recesion,
    color: data.color,
  };
  const newId = existingId ?? randomUUID();

  const { error } = existingId
    ? await supabase.from("tooth_marks").update(row).eq("id", existingId)
    : await supabase.from("tooth_marks").insert({ id: newId, ...row });
  if (error) return { ...fail(error.message), id: null };

  revalidatePath(`/pacientes/${patientId}`);
  return { ...OK, id: newId };
}

// ---------------------------------------------------------------------
// Plan de tratamiento — filas independientes.
// ---------------------------------------------------------------------
export async function addTreatmentItem(patientId: string) {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return { ...fail("Sesión expirada, vuelve a iniciar sesión."), id: null };

  const id = randomUUID();
  const { error } = await supabase.from("treatment_plan").insert({
    id,
    patient_id: patientId,
    user_id: userId,
    diagnostico: "",
    detalle: "",
    piezas: "",
    costo: 0,
  });
  if (error) return { ...fail(error.message), id: null };
  revalidatePath(`/pacientes/${patientId}`);
  return { ...OK, id };
}

export async function updateTreatmentItem(
  id: string,
  patientId: string,
  fields: { diagnostico: string; detalle: string; piezas: string; costo: number }
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("treatment_plan")
    .update(fields)
    .eq("id", id);
  if (error) return fail(error.message);
  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}

export async function deleteTreatmentItem(id: string, patientId: string) {
  const supabase = await createClient();
  const { error } = await supabase.from("treatment_plan").delete().eq("id", id);
  if (error) return fail(error.message);
  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}

// ---------------------------------------------------------------------
// Sesiones de tratamiento.
// ---------------------------------------------------------------------
export async function addSession(patientId: string, numeroSesion: number) {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return { ...fail("Sesión expirada, vuelve a iniciar sesión."), id: null };

  const id = randomUUID();
  const fecha = new Date().toISOString();
  const { error } = await supabase.from("treatment_sessions").insert({
    id,
    patient_id: patientId,
    user_id: userId,
    numero_sesion: numeroSesion,
    fecha,
    diagnosticos_complicaciones: "",
    procedimientos: "",
    prescripciones: "",
    profesional_codigo: "",
  });
  if (error) return { ...fail(error.message), id: null };
  revalidatePath(`/pacientes/${patientId}`);
  return { ...OK, id, fecha };
}

export async function updateSession(
  id: string,
  patientId: string,
  fields: {
    fecha: string;
    diagnosticos_complicaciones: string;
    procedimientos: string;
    prescripciones: string;
    profesional_codigo: string;
  }
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("treatment_sessions")
    .update(fields)
    .eq("id", id);
  if (error) return fail(error.message);
  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}

// ---------------------------------------------------------------------
// Pagos.
// ---------------------------------------------------------------------
export async function addPayment(patientId: string, previousSaldo: number) {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return { ...fail("Sesión expirada, vuelve a iniciar sesión."), id: null };

  const id = randomUUID();
  const fecha = new Date().toISOString();
  const { error } = await supabase.from("payments").insert({
    id,
    patient_id: patientId,
    user_id: userId,
    fecha,
    tratamiento_realizado: "",
    debe: 0,
    haber: 0,
    saldo: previousSaldo,
  });
  if (error) return { ...fail(error.message), id: null };
  revalidatePath(`/pacientes/${patientId}`);
  return { ...OK, id, fecha };
}

export async function updatePayment(
  id: string,
  patientId: string,
  fields: { fecha: string; tratamiento_realizado: string; debe: number; haber: number }
) {
  const supabase = await createClient();
  const { error } = await supabase
    .from("payments")
    .update({ ...fields, saldo: fields.debe - fields.haber })
    .eq("id", id);
  if (error) return fail(error.message);
  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}

// ---------------------------------------------------------------------
// Consentimiento informado — un registro por paciente.
// ---------------------------------------------------------------------
export async function saveConsent(
  patientId: string,
  existingId: string | null,
  data: {
    propositos: string;
    terapia_procedimientos: string;
    resultados_esperados: string;
    riesgos: string;
    profesional_nombre: string;
    items_aceptados: Record<string, boolean>;
    firma_paciente_base64_png: string;
    firma_profesional_base64_png: string;
  }
): Promise<SaveState> {
  const supabase = await createClient();
  const userId = await currentUserId();
  if (!userId) return fail("Sesión expirada, vuelve a iniciar sesión.");

  const row = {
    patient_id: patientId,
    user_id: userId,
    ...data,
    fecha: new Date().toISOString(),
  };

  const { error } = existingId
    ? await supabase.from("consents").update(row).eq("id", existingId)
    : await supabase.from("consents").insert({ id: randomUUID(), ...row });
  if (error) return fail(error.message);

  revalidatePath(`/pacientes/${patientId}`);
  return OK;
}
