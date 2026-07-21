-- Ejecutar en el SQL Editor de tu proyecto Supabase.
-- Crea las tablas espejo de SQLite local + Row Level Security
-- (cada usuario autenticado solo ve y modifica sus propios pacientes).

create table if not exists patients (
  id text primary key,
  user_id uuid references auth.users not null,
  institucion text, unidad_operativa text, cod_uo text,
  parroquia text, canton text, provincia text,
  numero_historia_clinica text,
  apellido_paterno text, apellido_materno text,
  primer_nombre text, segundo_nombre text, cedula text,
  direccion text, barrio text, zona text, telefono text,
  fecha_nacimiento text, lugar_nacimiento text, nacionalidad text,
  grupo_cultural text, edad int, sexo text, estado_civil text,
  instruccion text, fecha_admision text, ocupacion text,
  empresa text, tipo_seguro text, referido_de text,
  contacto_emergencia_nombre text, contacto_emergencia_parentesco text,
  contacto_emergencia_direccion text, contacto_emergencia_telefono text,
  updated_at timestamptz default now()
);

create table if not exists clinical_history (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  motivo_consulta text, enfermedad_actual text,
  antecedentes jsonb, antecedentes_detalle text,
  presion_arterial text, frecuencia_cardiaca text,
  temperatura text, frecuencia_respiratoria text,
  examen_estomatognatico jsonb,
  updated_at timestamptz default now()
);

create table if not exists tooth_marks (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  tooth_number int, surface text, symbol text,
  movilidad int, recesion boolean, color text,
  freehand_strokes jsonb,
  updated_at timestamptz default now()
);

create table if not exists treatment_plan (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  diagnostico text, detalle text, piezas text, costo numeric,
  updated_at timestamptz default now()
);

create table if not exists treatment_sessions (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  numero_sesion int, fecha text,
  diagnosticos_complicaciones text, procedimientos text,
  prescripciones text, profesional_codigo text,
  updated_at timestamptz default now()
);

create table if not exists payments (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  fecha text, tratamiento_realizado text,
  debe numeric, haber numeric, saldo numeric,
  updated_at timestamptz default now()
);

create table if not exists consents (
  id text primary key,
  user_id uuid references auth.users not null,
  patient_id text references patients(id) on delete cascade,
  propositos text, terapia_procedimientos text,
  resultados_esperados text, riesgos text, profesional_nombre text,
  items_aceptados jsonb,
  firma_paciente_base64_png text, firma_profesional_base64_png text,
  fecha text,
  updated_at timestamptz default now()
);

-- Row Level Security: cada usuario solo ve/edita sus propias filas
alter table patients enable row level security;
alter table clinical_history enable row level security;
alter table tooth_marks enable row level security;
alter table treatment_plan enable row level security;
alter table treatment_sessions enable row level security;
alter table payments enable row level security;
alter table consents enable row level security;

create policy "own rows" on patients for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on clinical_history for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on tooth_marks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on treatment_plan for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on treatment_sessions for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on payments for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own rows" on consents for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- NOTA: aquí las columnas están en snake_case (convención de Postgres) pero
-- el modelo Dart usa camelCase. SupabaseService.syncNow() en la app envía
-- las llaves tal como están en SQLite (camelCase); ajusta los nombres de
-- columnas arriba a camelCase entre comillas, o normaliza las llaves en
-- Dart antes de subir, según prefieras trabajar.
