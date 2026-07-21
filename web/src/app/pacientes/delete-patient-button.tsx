"use client";

import { useRef, useTransition } from "react";
import { deletePatient } from "./actions";

export default function DeletePatientButton({
  patientId,
  patientName,
}: {
  patientId: string;
  patientName: string;
}) {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [pending, startTransition] = useTransition();

  return (
    <>
      <button
        type="button"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          dialogRef.current?.showModal();
        }}
        title="Eliminar paciente"
        className="rounded-full p-2 text-gray-400 transition-[background-color,color,transform] duration-150 ease-[var(--ease-out)] hover:bg-red-50 hover:text-red-500 active:scale-90"
      >
        <TrashIcon className="h-5 w-5" />
      </button>

      <dialog
        ref={dialogRef}
        className="w-full max-w-md rounded-3xl p-6 backdrop:bg-black/40"
      >
        <h3 className="font-display text-lg font-bold text-text-dark">
          ¿Eliminar paciente?
        </h3>
        <p className="mt-2 text-sm text-gray-600">
          Se eliminará permanentemente a &quot;{patientName || "(sin nombre)"}
          &quot; junto con su historia clínica, odontograma, plan de
          tratamiento, sesiones, pagos y consentimientos. Esta acción no se
          puede deshacer.
        </p>
        <div className="mt-5 flex justify-end gap-3">
          <button
            type="button"
            onClick={() => dialogRef.current?.close()}
            className="rounded-xl px-4 py-2 text-sm font-medium text-primary transition-transform duration-150 ease-[var(--ease-out)] active:scale-95"
          >
            Cancelar
          </button>
          <button
            type="button"
            disabled={pending}
            onClick={() =>
              startTransition(async () => {
                await deletePatient(patientId);
                dialogRef.current?.close();
              })
            }
            className="rounded-xl bg-red-500 px-4 py-2 text-sm font-semibold text-white transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-95 disabled:opacity-60 disabled:active:scale-100"
          >
            {pending ? "Eliminando…" : "Eliminar"}
          </button>
        </div>
      </dialog>
    </>
  );
}

function TrashIcon({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2}
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden
    >
      <polyline points="3 6 5 6 21 6" />
      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
    </svg>
  );
}
