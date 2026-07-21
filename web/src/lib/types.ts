export type Patient = {
  id: string;
  user_id: string;
  institucion: string | null;
  unidad_operativa: string | null;
  cod_uo: string | null;
  parroquia: string | null;
  canton: string | null;
  provincia: string | null;
  numero_historia_clinica: string | null;
  apellido_paterno: string | null;
  apellido_materno: string | null;
  primer_nombre: string | null;
  segundo_nombre: string | null;
  cedula: string | null;
  direccion: string | null;
  barrio: string | null;
  zona: string | null;
  telefono: string | null;
  fecha_nacimiento: string | null;
  lugar_nacimiento: string | null;
  nacionalidad: string | null;
  grupo_cultural: string | null;
  edad: number | null;
  sexo: string | null;
  estado_civil: string | null;
  instruccion: string | null;
  fecha_admision: string | null;
  ocupacion: string | null;
  empresa: string | null;
  tipo_seguro: string | null;
  referido_de: string | null;
  contacto_emergencia_nombre: string | null;
  contacto_emergencia_parentesco: string | null;
  contacto_emergencia_direccion: string | null;
  contacto_emergencia_telefono: string | null;
  updated_at: string;
};

export type ClinicalHistory = {
  id: string;
  patient_id: string;
  motivo_consulta: string | null;
  enfermedad_actual: string | null;
  antecedentes: Record<string, boolean> | null;
  antecedentes_detalle: string | null;
  presion_arterial: string | null;
  frecuencia_cardiaca: string | null;
  temperatura: string | null;
  frecuencia_respiratoria: string | null;
  examen_estomatognatico: Record<string, string> | null;
};

export const ANTECEDENTES_LABELS: Record<string, string> = {
  alergiaAntibiotico: "Alergia a antibiótico",
  alergiaAnestesia: "Alergia a anestesia",
  hemorragias: "Hemorragias",
  vihSida: "VIH/SIDA",
  tuberculosis: "Tuberculosis",
  asma: "Asma",
  diabetes: "Diabetes",
  hipertension: "Hipertensión",
  enfCardiaca: "Enf. cardiaca",
  otro: "Otro",
};

export const EXAMEN_LABELS: Record<string, string> = {
  labios: "Labios",
  mejillas: "Mejillas",
  maxilarSuperior: "Maxilar superior",
  maxilarInferior: "Maxilar inferior",
  lengua: "Lengua",
  paladar: "Paladar",
  piso: "Piso",
  carrillos: "Carrillos",
  glandulasSalivales: "Glándulas salivales",
  oroFaringe: "Oro faringe",
  atm: "A.T.M.",
  ganglios: "Ganglios",
};

export type OdontoSymbol =
  | "caries"
  | "obturado"
  | "extraccionIndicada"
  | "perdidaPorCaries"
  | "perdidaOtraCausa"
  | "sellanteNecesario"
  | "sellanteRealizado"
  | "endodoncia"
  | "corona"
  | "protesisFija"
  | "protesisRemovible"
  | "protesisTotal"
  | "ninguno";

export const ODONTO_SYMBOL_LABELS: Record<OdontoSymbol, string> = {
  ninguno: "Sin marca",
  caries: "Caries",
  obturado: "Obturado",
  extraccionIndicada: "Extracción indicada",
  perdidaPorCaries: "Pérdida por caries",
  perdidaOtraCausa: "Pérdida por otra causa",
  sellanteNecesario: "Sellante necesario",
  sellanteRealizado: "Sellante realizado",
  endodoncia: "Endodoncia",
  corona: "Corona",
  protesisFija: "Prótesis fija",
  protesisRemovible: "Prótesis removible",
  protesisTotal: "Prótesis total",
};

// Notación FDI: 4 cuadrantes de 8 piezas cada uno (adulto).
export const FDI_QUADRANTS: [number, number[]][] = [
  [1, [18, 17, 16, 15, 14, 13, 12, 11]],
  [2, [21, 22, 23, 24, 25, 26, 27, 28]],
  [4, [48, 47, 46, 45, 44, 43, 42, 41]],
  [3, [31, 32, 33, 34, 35, 36, 37, 38]],
];

export type ToothMark = {
  id: string;
  patient_id: string;
  tooth_number: number;
  surface: string;
  symbol: OdontoSymbol;
  movilidad: number;
  recesion: boolean;
  color: string;
};

export type TreatmentPlanItem = {
  id: string;
  patient_id: string;
  diagnostico: string | null;
  detalle: string | null;
  piezas: string | null;
  costo: number | null;
};

export type TreatmentSession = {
  id: string;
  patient_id: string;
  numero_sesion: number;
  fecha: string;
  diagnosticos_complicaciones: string | null;
  procedimientos: string | null;
  prescripciones: string | null;
  profesional_codigo: string | null;
};

export type PaymentRecord = {
  id: string;
  patient_id: string;
  fecha: string;
  tratamiento_realizado: string | null;
  debe: number | null;
  haber: number | null;
  saldo: number | null;
};

export type ConsentRecord = {
  id: string;
  patient_id: string;
  propositos: string | null;
  terapia_procedimientos: string | null;
  resultados_esperados: string | null;
  riesgos: string | null;
  profesional_nombre: string | null;
  items_aceptados: Record<string, boolean> | null;
  firma_paciente_base64_png: string | null;
  firma_profesional_base64_png: string | null;
  fecha: string;
};

export const CONSENT_ITEMS: Record<string, string> = {
  A: "El profesional me ha informado sobre los motivos y propósitos del tratamiento",
  B: "El profesional me ha explicado las actividades esenciales del tratamiento",
  C: "Consiento a que se realicen las intervenciones/procedimientos necesarios",
  D: "Consiento a que me administren la anestesia propuesta",
  E: "Entiendo que hay garantía de calidad de los medios, no de resultados",
  F: "He comprendido los beneficios y riesgos de complicaciones",
  G: "Se garantiza respeto a mi intimidad, creencias y confidencialidad",
  H: "Puedo anular este consentimiento cuando lo considere necesario",
  I: "Declaro haber entregado información completa y fidedigna",
};

export function nombreCompleto(p: Patient): string {
  return [p.apellido_paterno, p.apellido_materno, p.primer_nombre, p.segundo_nombre]
    .filter(Boolean)
    .join(" ")
    .trim();
}

export function initials(p: Patient): string {
  const a = p.apellido_paterno?.[0] ?? "";
  const b = p.primer_nombre?.[0] ?? "";
  const i = (a + b).toUpperCase();
  return i || "?";
}

const AVATAR_PALETTE = [
  "#A7C7E7", // seed
  "#F4A261", // coral
  "#C5A3E0", // lavender
  "#6366F1",
  "#EC4899",
  "#10B981",
];

export function avatarColorFor(seedText: string): string {
  if (!seedText) return AVATAR_PALETTE[0];
  return AVATAR_PALETTE[seedText.charCodeAt(0) % AVATAR_PALETTE.length];
}

/** Separa "Santiago Paul" -> ["Santiago", "Paul"], igual que en la app móvil. */
export function splitName(text: string): [string, string] {
  const parts = text.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return ["", ""];
  if (parts.length === 1) return [parts[0], ""];
  return [parts[0], parts.slice(1).join(" ")];
}
