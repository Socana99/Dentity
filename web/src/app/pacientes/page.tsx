import Image from "next/image";
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { logout } from "./actions";
import { initials, nombreCompleto, avatarColorFor, type Patient } from "@/lib/types";
import NewPatientDialog from "./new-patient-dialog";
import DeletePatientButton from "./delete-patient-button";

export const dynamic = "force-dynamic";

export default async function PacientesPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const { q } = await searchParams;
  const supabase = await createClient();

  let query = supabase
    .from("patients")
    .select(
      "id,apellido_paterno,apellido_materno,primer_nombre,segundo_nombre,cedula,numero_historia_clinica,updated_at"
    )
    .order("apellido_paterno", { ascending: true });

  if (q) {
    query = query.or(
      `apellido_paterno.ilike.%${q}%,apellido_materno.ilike.%${q}%,cedula.ilike.%${q}%,numero_historia_clinica.ilike.%${q}%`
    );
  }

  const { data: patients, error } = await query.returns<Patient[]>();

  return (
    <main className="min-h-screen bg-bg pb-28">
      <div className="sticky top-0 z-10 rounded-b-[1.75rem] bg-gradient-to-br from-[#7FAAD6] to-primary pb-5 text-white shadow-md backdrop-blur-md">
        <div className="flex items-center justify-between px-6 pt-5">
          <div className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-white p-1.5">
              <Image
                src="/dentity-logo.svg"
                alt="Dentity"
                width={24}
                height={13}
                className="h-auto w-full"
              />
            </div>
            <span className="font-display text-xl font-extrabold tracking-tight">
              Dentity
            </span>
          </div>
          <form action={logout}>
            <button
              type="submit"
              title="Cerrar sesión"
              className="rounded-full p-2 transition-[background-color,transform] duration-150 ease-[var(--ease-out)] hover:bg-white/15 active:scale-90"
            >
              <LogoutIcon className="h-5 w-5" />
            </button>
          </form>
        </div>

        <form className="relative mt-4 px-6">
          <SearchIcon className="pointer-events-none absolute left-9 top-1/2 h-5 w-5 -translate-y-1/2 text-primary" />
          <input
            type="text"
            name="q"
            defaultValue={q ?? ""}
            placeholder="Buscar por nombre, cédula o N° historia clínica"
            className="w-full rounded-2xl bg-white py-3.5 pl-12 pr-4 text-text-dark shadow-sm outline-none focus:ring-2 focus:ring-white/70"
          />
        </form>
      </div>

      <div className="mx-auto max-w-3xl px-6 py-6">
        {error && (
          <p className="mt-6 text-sm text-red-500">
            Error cargando pacientes: {error.message}
          </p>
        )}

        {!error && (!patients || patients.length === 0) && (
          <div className="mt-16 flex flex-col items-center text-center text-gray-400">
            <FolderIcon className="h-14 w-14" />
            <p className="mt-3 text-gray-600">
              No hay pacientes registrados todavía
            </p>
            <p className="mt-1 text-sm">
              Toca &quot;Nuevo paciente&quot; para empezar
            </p>
          </div>
        )}

        <ul className="mt-6 flex flex-col gap-3">
          {patients?.map((p) => {
            const name = nombreCompleto(p);
            return (
              <li key={p.id} className="animate-list-item">
                <Link
                  href={`/pacientes/${p.id}`}
                  className="flex items-center gap-4 rounded-2xl bg-white p-4 shadow-sm transition-[box-shadow,transform] duration-150 ease-[var(--ease-out)] hover:shadow-md active:scale-[0.99]"
                >
                  <span
                    className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full font-bold text-white"
                    style={{ backgroundColor: avatarColorFor(p.apellido_paterno ?? "") }}
                  >
                    {initials(p)}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate font-semibold text-text-dark">
                      {name || "(Sin nombre aún)"}
                    </span>
                    <span className="block text-xs text-gray-500">
                      HC: {p.numero_historia_clinica || "—"} · Cédula:{" "}
                      {p.cedula || "—"}
                    </span>
                  </span>
                  <DeletePatientButton patientId={p.id} patientName={name} />
                  <ChevronIcon className="h-5 w-5 text-gray-300" />
                </Link>
              </li>
            );
          })}
        </ul>
      </div>

      <NewPatientDialog />
    </main>
  );
}

function LogoutIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden>
      <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
      <polyline points="16 17 21 12 16 7" />
      <line x1="21" y1="12" x2="9" y2="12" />
    </svg>
  );
}

function SearchIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden>
      <circle cx="11" cy="11" r="8" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" />
    </svg>
  );
}

function FolderIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden>
      <path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7Z" />
    </svg>
  );
}

function ChevronIcon({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" className={className} aria-hidden>
      <polyline points="9 18 15 12 9 6" />
    </svg>
  );
}
