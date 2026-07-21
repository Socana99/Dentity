"use client";

import Image from "next/image";
import { useActionState } from "react";
import { signIn, signUp, type LoginState } from "./actions";

const initialState: LoginState = { error: null };

export default function LoginPage() {
  const [signInState, signInAction, signInPending] = useActionState(
    signIn,
    initialState
  );
  const [signUpState, signUpAction, signUpPending] = useActionState(
    signUp,
    initialState
  );

  const pending = signInPending || signUpPending;
  const message = signInState.error ?? signUpState.error;
  const isConfirmationNotice = message?.startsWith("Revisa tu correo");

  return (
    <main className="flex min-h-screen items-center justify-center bg-gradient-to-b from-primary to-primary/85 px-6 py-12">
      <div className="w-full max-w-sm">
        <div className="flex flex-col items-center text-center">
          <div className="flex h-20 w-20 items-center justify-center rounded-full bg-white p-3">
            <Image
              src="/dentity-logo.svg"
              alt="Dentity"
              width={56}
              height={30}
              className="h-auto w-full"
              priority
            />
          </div>
          <h1 className="mt-4 font-display text-3xl font-extrabold tracking-tight text-white">
            Dentity
          </h1>
          <p className="mt-1 text-white/85">Historia clínica dental digital</p>
        </div>

        <div className="mt-7 rounded-[28px] bg-white p-6 shadow-xl">
          <h2 className="font-display text-xl font-extrabold text-text-dark">
            Iniciar sesión
          </h2>
          <p className="mt-1.5 text-sm text-gray-500">
            Accede a tu historia clínica dental
          </p>

          <form action={signInAction} className="mt-5 flex flex-col gap-3">
            <label className="block">
              <span className="sr-only">Correo</span>
              <input
                type="email"
                name="email"
                required
                placeholder="Correo"
                className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3.5 text-text-dark outline-none placeholder:text-gray-400 focus:border-primary focus:ring-2 focus:ring-primary"
              />
            </label>
            <label className="block">
              <span className="sr-only">Contraseña</span>
              <input
                type="password"
                name="password"
                required
                placeholder="Contraseña"
                className="w-full rounded-2xl border border-gray-200 bg-gray-50 px-4 py-3.5 text-text-dark outline-none placeholder:text-gray-400 focus:border-primary focus:ring-2 focus:ring-primary"
              />
            </label>

            {message && (
              <p
                className={`text-sm ${
                  isConfirmationNotice ? "text-primary" : "text-red-500"
                }`}
              >
                {message}
              </p>
            )}

            <button
              type="submit"
              disabled={pending}
              className="mt-2 rounded-2xl bg-gradient-to-r from-[#BA8BFF] to-[#D9B4FF] py-3.5 font-semibold text-white shadow-md transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
            >
              {signInPending ? "Ingresando…" : "Iniciar sesión"}
            </button>
            <button
              type="submit"
              formAction={signUpAction}
              disabled={pending}
              className="rounded-2xl bg-lavender py-3.5 font-semibold text-text-dark transition-[opacity,transform] duration-150 ease-[var(--ease-out)] active:scale-[0.98] disabled:opacity-60 disabled:active:scale-100"
            >
              {signUpPending ? "Creando…" : "Crear cuenta"}
            </button>
          </form>
        </div>
      </div>
    </main>
  );
}
