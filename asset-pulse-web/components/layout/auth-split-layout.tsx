import Image from "next/image";
import Link from "next/link";
import type { ReactNode } from "react";

import { CheckIcon } from "@/components/icons";

const FEATURES = [
  "Real-time tracking across every part you ship",
  "Instant alerts the moment something needs attention",
  "Actionable insights to keep fleets moving",
];

interface AuthSplitLayoutProps {
  children: ReactNode;
  /** Rendered above the form card, e.g. a <StepIndicator />. */
  eyebrow?: ReactNode;
}

// Shared "logo on the left, form on the right" shell for every auth screen
// (login, register, and the onboarding steps that follow it) so the brand
// panel and its copy only live in one place.
export function AuthSplitLayout({ children, eyebrow }: AuthSplitLayoutProps) {
  return (
    <main className="flex flex-1 lg:grid lg:grid-cols-2">
      <section className="relative hidden flex-col justify-between overflow-hidden bg-brand-navy-dark px-12 py-12 text-white lg:flex">
        <div
          className="absolute inset-0 opacity-40"
          style={{
            background:
              "radial-gradient(circle at 20% 20%, var(--color-brand-navy-light), transparent 55%), radial-gradient(circle at 80% 85%, var(--color-brand-red-dark), transparent 45%)",
          }}
          aria-hidden
        />

        <Link href="/" className="relative z-10 inline-flex w-fit">
          <Image src="/white-logo.png" alt="AssetPulse" width={220} height={124} priority className="h-auto w-50" />
        </Link>

        <div className="relative z-10 max-w-md">
          <h2 className="text-3xl font-bold text-balance">
            Track every part. <span className="text-brand-red">Anywhere in the USA.</span>
          </h2>
          <p className="mt-3 text-sm text-white/70">
            The most reliable platform to monitor and track automotive parts in real time — from
            warehouse to workshop.
          </p>

          <ul className="mt-8 flex flex-col gap-3">
            {FEATURES.map((feature) => (
              <li key={feature} className="flex items-start gap-2.5 text-sm text-white/85">
                <span className="mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full bg-white/10">
                  <CheckIcon className="size-3" />
                </span>
                {feature}
              </li>
            ))}
          </ul>
        </div>

        <p className="relative z-10 text-xs text-white/40">
          &copy; {new Date().getFullYear()} AssetPulse. Tracking what moves America.
        </p>
      </section>

      <section className="flex flex-1 flex-col items-center justify-center bg-paper-muted px-4 py-10 dark:bg-black">
        <Link href="/" className="mb-8 inline-flex lg:hidden">
          <Image src="/logo.png" alt="AssetPulse" width={180} height={101} priority className="h-auto w-40" />
        </Link>

        <div className="w-full max-w-md">
          {eyebrow}
          {children}
        </div>
      </section>
    </main>
  );
}
