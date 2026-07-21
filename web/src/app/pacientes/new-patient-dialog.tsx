"use client";

import { useActionState, useEffect, useRef } from "react";
import { createPatient, type NewPatientState } from "./actions";

const initialState: NewPatientState = { error: null };

export default function NewPatientDialog() {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const formRef = useRef<HTMLFormElement>(null);
  const [state, action, pending] = useActionState(
    createPatient,
    initialState
  );
  const wasPending = useRef(false);

  // Cierra el modal y limpia el formulario justo cuando una creación
  // recién terminó sin error (pending pasó de true a false).
  useEffect(() => {
    if (wasPending.current && !pending && state.error === null) {
      formRef.current?.reset();
      dialogRef.current?.close();
    }
    wasPending.current = pending;
  }, [pending, state]);

  return (
    <>
      <button
        onClick={() => dialogRef.current?.showModal()}
        className="fixed bottom-8 right-8 flex items-center gap-2 rounded-full bg-coral px-6 py-4 font-semibold text-white shadow-lg transition-transform duration-150 ease-[var(--ease-out)] hover:scale-105 active:scale-95"
      >
        <PlusIcon className="h-5 w-5" />
        Nuevo paciente
      </button>

      <dialog
        ref={dialogRef}
        className="w-full max-w-sm rounded-[28px] p-0 backdrop:bg-black/40"
        onClose={() => formRef.current?.reset()}
      >
        <div className="flex flex-col items-center px-7 pb-6 pt-8">
          <div className="flex h-24 w-24 items-center justify-center rounded-[28%] bg-gradient-to-br from-primary to-lavender">
            <PersonAddIcon className="h-10 w-10 text-white" />
          </div>

          <form
            ref={formRef}
            action={action}
            className="mt-5 flex w-full flex-col gap-2.5 text-center"
          >
            <input
              name="nombres"
              required
              placeholder="Nombres"
              className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-center font-display text-lg font-extrabold text-text-dark outline-none placeholder:font-sans placeholder:text-base placeholder:font-normal placeholder:text-gray-400 focus:ring-2 focus:ring-primary"
            />
            <input
              name="apellidos"
              required
              placeholder="Apellidos"
              className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-center font-display text-lg font-extrabold text-text-dark outline-none placeholder:font-sans placeholder:text-base placeholder:font-normal placeholder:text-gray-400 focus:ring-2 focus:ring-primary"
            />
            <p className="mt-1 text-xs font-semibold tracking-wide text-gray-400">
              CÉDULA DEL PACIENTE
            </p>
            <input
              name="cedula"
              required
              inputMode="numeric"
              placeholder="0000000000"
              className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3 text-center text-text-dark outline-none focus:ring-2 focus:ring-primary"
            />

            {state.error && (
              <p className="text-sm text-red-500">{state.error}</p>
            )}

            <button
              type="submit"
              disabled={pending}
              className="mt-3 rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] py-3.5 font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
            >
              {pending ? "Creando…" : "Crear paciente"}
            </button>
            <button
              type="button"
              onClick={() => dialogRef.current?.close()}
              className="py-2 text-sm text-gray-500 transition-transform duration-150 ease-[var(--ease-out)] active:scale-95"
            >
              Cancelar
            </button>
          </form>
        </div>
      </dialog>
    </>
  );
}

function PlusIcon({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2.5}
      strokeLinecap="round"
      className={className}
      aria-hidden
    >
      <line x1="12" y1="5" x2="12" y2="19" />
      <line x1="5" y1="12" x2="19" y2="12" />
    </svg>
  );
}

function PersonAddIcon({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="currentColor"
      className={className}
      aria-hidden
    >
      <path d="M9 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0 2c-3.3 0-8 1.7-8 5v2h11.5a6 6 0 0 1-.5-2.4c0-2 1-3.8 2.6-4.9C13 14.3 10.9 14 9 14Zm9-3v3h-3v2h3v3h2v-3h3v-2h-3V9h-2Z" />
    </svg>
  );
}
