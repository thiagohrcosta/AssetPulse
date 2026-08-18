"use client";
// Client Component: controlled form, file input, and a mutation gated by
// the JWT held in the AuthContext — nothing here can run on the server.

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";

import { useAuth } from "@/context/auth-context";
import { ApiError, createCompany, type CompanyPayload } from "@/lib/api";
import { ProtectedRoute } from "@/components/protected-route";
import { Field } from "@/components/ui/field";
import { SubmitButton } from "@/components/ui/submit-button";
import { ErrorBanner } from "@/components/ui/error-banner";
import { AuthSplitLayout } from "@/components/layout/auth-split-layout";
import { StepIndicator } from "@/components/layout/step-indicator";

const initialForm: Omit<CompanyPayload, "logo"> = {
  name: "",
  registration_number: "",
  address_zip_code: "",
  address_street: "",
  address_number: "",
  address_city: "",
  address_complement: "",
  address_state: "",
};

function NewCompanyForm() {
  const { token, setCompany } = useAuth();
  const router = useRouter();
  const [form, setForm] = useState(initialForm);
  const [logo, setLogo] = useState<File | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  function update<K extends keyof typeof initialForm>(key: K, value: string) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!token) return;
    setError(null);
    setPending(true);

    try {
      const company = await createCompany(token, {
        ...form,
        address_complement: form.address_complement || undefined,
        logo,
      });
      setCompany(company);
      // Company exists now — next stop is picking a plan (trial/basic/premium).
      router.push("/subscription");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not create the company.");
    } finally {
      setPending(false);
    }
  }

  return (
    <AuthSplitLayout eyebrow={<StepIndicator current={2} />}>
      <div className="rounded-2xl border border-zinc-200 bg-paper p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-950">
        <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
          Set up your company
        </h1>
        <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
          Step 2 of 3 — company details. You&apos;ll choose a plan next.
        </p>

        <form onSubmit={handleSubmit} className="mt-6 flex flex-col gap-4">
          <ErrorBanner message={error} />

          <Field
            id="name"
            label="Company name"
            required
            value={form.name}
            onChange={(e) => update("name", e.target.value)}
          />
          <Field
            id="registration_number"
            label="Registration number (CNPJ)"
            required
            value={form.registration_number}
            onChange={(e) => update("registration_number", e.target.value)}
          />

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

          <label htmlFor="logo" className="flex flex-col gap-1.5 text-sm">
            <span className="font-medium text-zinc-700 dark:text-zinc-300">
              Logo <span className="text-zinc-400">(optional, PNG/JPEG/WEBP, max 5MB)</span>
            </span>
            <input
              id="logo"
              type="file"
              accept="image/png,image/jpeg,image/webp"
              onChange={(e) => setLogo(e.target.files?.[0] ?? null)}
              className="text-sm text-zinc-600 file:mr-3 file:rounded-lg file:border-0 file:bg-brand-navy file:px-3 file:py-2 file:text-sm file:font-medium file:text-white dark:text-zinc-400 dark:file:bg-zinc-50 dark:file:text-brand-navy"
            />
          </label>

          <SubmitButton pending={pending} pendingLabel="Saving…" className="mt-2">
            Continue
          </SubmitButton>
        </form>
      </div>
    </AuthSplitLayout>
  );
}

export default function NewCompanyPage() {
  return (
    <ProtectedRoute>
      <NewCompanyForm />
    </ProtectedRoute>
  );
}
