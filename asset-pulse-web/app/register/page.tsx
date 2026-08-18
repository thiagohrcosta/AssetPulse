"use client";
// Client Component: this is a controlled form (state per keystroke, submit
// handler, client-side redirect) and the auth session lives in
// localStorage — there is no cookie for a Server Component to read, so
// there is nothing here that could be rendered on the server instead.

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

import { useAuth } from "@/context/auth-context";
import { ApiError, type RegisterPayload } from "@/lib/api";
import { Field } from "@/components/ui/field";
import { SubmitButton } from "@/components/ui/submit-button";
import { ErrorBanner } from "@/components/ui/error-banner";

const initialForm: RegisterPayload = {
  email: "",
  password: "",
  password_confirmation: "",
  full_name: "",
  document_number: "",
  address_zip_code: "",
  address_street: "",
  address_number: "",
  address_city: "",
  address_complement: "",
  address_state: "",
};

export default function RegisterPage() {
  const { register } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState<RegisterPayload>(initialForm);
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  function update<K extends keyof RegisterPayload>(key: K, value: RegisterPayload[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setPending(true);

    try {
      await register({
        ...form,
        address_complement: form.address_complement || undefined,
      });
      // Authenticated — move straight into onboarding: the company still
      // needs to be created before a subscription can be started.
      router.push("/company/new");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not create your account.");
    } finally {
      setPending(false);
    }
  }

  return (
    <main className="flex flex-1 items-center justify-center bg-zinc-50 px-4 py-12 dark:bg-black">
      <div className="w-full max-w-xl rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-950">
        <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
          Create your account
        </h1>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Step 1 of 3 — account details. Next you&apos;ll set up your company and choose a plan.
        </p>

        <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-5">
          <ErrorBanner message={error} />

          <section className="flex flex-col gap-4">
            <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">
              Login credentials
            </h2>
            <Field
              id="email"
              label="Email"
              type="email"
              required
              autoComplete="email"
              value={form.email}
              onChange={(e) => update("email", e.target.value)}
            />
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field
                id="password"
                label="Password"
                type="password"
                required
                minLength={6}
                autoComplete="new-password"
                value={form.password}
                onChange={(e) => update("password", e.target.value)}
              />
              <Field
                id="password_confirmation"
                label="Confirm password"
                type="password"
                required
                minLength={6}
                autoComplete="new-password"
                value={form.password_confirmation}
                onChange={(e) => update("password_confirmation", e.target.value)}
              />
            </div>
          </section>

          <section className="flex flex-col gap-4">
            <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">
              Personal information
            </h2>
            <Field
              id="full_name"
              label="Full name"
              required
              autoComplete="name"
              value={form.full_name}
              onChange={(e) => update("full_name", e.target.value)}
            />
            <Field
              id="document_number"
              label="Document number (CPF/CNPJ)"
              required
              value={form.document_number}
              onChange={(e) => update("document_number", e.target.value)}
            />
          </section>

          <section className="flex flex-col gap-4">
            <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Address</h2>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field
                id="address_zip_code"
                label="ZIP code"
                required
                inputMode="numeric"
                value={form.address_zip_code}
                onChange={(e) => update("address_zip_code", e.target.value)}
              />
              <Field
                id="address_state"
                label="State"
                required
                value={form.address_state}
                onChange={(e) => update("address_state", e.target.value)}
              />
            </div>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-[2fr_1fr]">
              <Field
                id="address_street"
                label="Street"
                required
                value={form.address_street}
                onChange={(e) => update("address_street", e.target.value)}
              />
              <Field
                id="address_number"
                label="Number"
                required
                inputMode="numeric"
                value={form.address_number}
                onChange={(e) => update("address_number", e.target.value)}
              />
            </div>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Field
                id="address_city"
                label="City"
                required
                value={form.address_city}
                onChange={(e) => update("address_city", e.target.value)}
              />
              <Field
                id="address_complement"
                label="Complement"
                value={form.address_complement}
                onChange={(e) => update("address_complement", e.target.value)}
              />
            </div>
          </section>

          <SubmitButton pending={pending} pendingLabel="Creating account…" className="mt-2">
            Create account
          </SubmitButton>
        </form>

        <p className="mt-6 text-center text-sm text-zinc-500 dark:text-zinc-400">
          Already have an account?{" "}
          <Link href="/login" className="font-medium text-zinc-900 underline dark:text-zinc-50">
            Log in
          </Link>
        </p>
      </div>
    </main>
  );
}
