"use client";
// Client Component: redirecting an already-authenticated visitor straight
// to /dashboard depends on the localStorage-backed auth session, so that
// part can't be resolved on the server. Everyone else just sees the
// marketing page below — no forced redirect.

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import Link from "next/link";

import { useAuth } from "@/context/auth-context";
import {
  ArrowRightIcon,
  BellIcon,
  CheckIcon,
  GaugeIcon,
  GithubIcon,
  PulseIcon,
} from "@/components/icons";

const HERO_FEATURES = [
  {
    icon: GaugeIcon,
    title: "Real-time tracking",
    description: "Live updates across every part, every host unit.",
  },
  {
    icon: BellIcon,
    title: "Instant alerts",
    description: "Get notified the moment a part needs attention.",
  },
  {
    icon: PulseIcon,
    title: "Actionable insights",
    description: "Make data-driven decisions with confidence.",
  },
];

const SDK_HIGHLIGHTS = [
  {
    title: "Semantic resources",
    description: "client.parts.list(), client.hostUnits.create(...) — not raw URLs.",
  },
  {
    title: "Validate-before-send",
    description: "Zod schemas mirror the backend's constraints, so a missing field fails locally, not after a round trip.",
  },
  {
    title: "Automatic environment resolution",
    description: "The same code targets localhost in development and your production API — no if statements.",
  },
  {
    title: "One typed error class",
    description: "AssetPulseApiError, whether the failure was validation, network, or the API itself.",
  },
];

const CAPABILITIES = [
  {
    title: "Part lifecycle tracking",
    description: "Follow every part from install to replacement, with a full event history.",
  },
  {
    title: "Host unit visibility",
    description: "See exactly which vehicle or unit each part is assigned to, at a glance.",
  },
  {
    title: "Team-ready from day one",
    description: "One company, one source of truth — accessible to everyone on your team.",
  },
  {
    title: "Built to grow with you",
    description: "Start on a free trial, upgrade whenever your fleet does.",
  },
];

export default function Home() {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated) router.replace("/dashboard");
  }, [isAuthenticated, router]);

  return (
    <main className="flex flex-1 flex-col bg-paper dark:bg-black">
      <header className="sticky top-0 z-30 border-b border-zinc-200 bg-paper/80 backdrop-blur dark:border-zinc-800 dark:bg-black/80">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3 sm:px-6">
          <Image src="/logo.png" alt="AssetPulse" width={180} height={101} priority className="h-auto w-32.5" />
          <div className="flex items-center gap-2">
            <Link
              href="/login"
              className="rounded-lg px-3 py-2 text-sm font-medium text-zinc-700 transition hover:bg-zinc-100 dark:text-zinc-300 dark:hover:bg-zinc-900"
            >
              Sign in
            </Link>
            <Link
              href="/register"
              className="inline-flex items-center gap-1.5 rounded-lg bg-brand-red px-4 py-2 text-sm font-medium text-white transition hover:bg-brand-red-dark"
            >
              Get started
            </Link>
          </div>
        </div>
      </header>

      <section className="mx-auto w-full max-w-6xl px-4 pb-16 pt-12 sm:px-6 sm:pt-20">
        <div className="grid grid-cols-1 items-center gap-12 lg:grid-cols-2">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-zinc-200 px-3 py-1 text-xs font-medium text-zinc-600 dark:border-zinc-800 dark:text-zinc-400">
              <span className="size-1.5 rounded-full bg-brand-red" />
              Automotive parts tracking, built for the USA
            </span>

            <h1 className="mt-5 text-4xl font-bold tracking-tight text-zinc-900 sm:text-5xl dark:text-zinc-50">
              Track every part.
              <br />
              <span className="text-brand-red">Anywhere in the USA.</span>
            </h1>

            <p className="mt-5 max-w-lg text-base text-zinc-600 dark:text-zinc-400">
              AssetPulse is the most reliable platform to monitor and track automotive parts in
              real time. From warehouse to workshop, we give you full visibility and control.
            </p>

            <div className="mt-8 flex flex-wrap items-center gap-3">
              <Link
                href="/register"
                className="inline-flex items-center gap-2 rounded-lg bg-brand-red px-5 py-3 text-sm font-semibold text-white transition hover:bg-brand-red-dark"
              >
                Start tracking now
                <ArrowRightIcon className="size-4" />
              </Link>
              <Link
                href="/login"
                className="inline-flex items-center gap-2 rounded-lg border border-zinc-300 px-5 py-3 text-sm font-semibold text-zinc-700 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-900"
              >
                Sign in
              </Link>
            </div>

            <dl className="mt-10 grid grid-cols-3 gap-6 border-t border-zinc-200 pt-6 dark:border-zinc-800">
              {HERO_FEATURES.map((feature) => (
                <div key={feature.title}>
                  <div className="flex size-9 items-center justify-center rounded-lg bg-brand-red/10 text-brand-red">
                    <feature.icon className="size-4.5" />
                  </div>
                  <dt className="mt-3 text-sm font-semibold text-zinc-900 dark:text-zinc-50">
                    {feature.title}
                  </dt>
                  <dd className="mt-1 text-xs text-zinc-500 dark:text-zinc-400">
                    {feature.description}
                  </dd>
                </div>
              ))}
            </dl>
          </div>

          <div className="relative">
            <div className="absolute -inset-4 -z-10 rounded-3xl bg-linear-to-br from-brand-navy/10 via-transparent to-brand-red/10 blur-2xl" />
            <div className="overflow-hidden rounded-2xl border border-zinc-200 bg-paper shadow-xl dark:border-zinc-800 dark:bg-zinc-950">
              <div className="flex items-center gap-1.5 border-b border-zinc-200 bg-zinc-50 px-4 py-3 dark:border-zinc-800 dark:bg-zinc-900">
                <span className="size-2.5 rounded-full bg-zinc-300 dark:bg-zinc-700" />
                <span className="size-2.5 rounded-full bg-zinc-300 dark:bg-zinc-700" />
                <span className="size-2.5 rounded-full bg-zinc-300 dark:bg-zinc-700" />
              </div>
              <div className="space-y-4 p-6">
                <div className="grid grid-cols-3 gap-3">
                  {["Parts tracked", "Host units", "Active"].map((label) => (
                    <div
                      key={label}
                      className="rounded-xl border border-zinc-200 bg-zinc-50 p-3 dark:border-zinc-800 dark:bg-zinc-900"
                    >
                      <div className="h-2 w-10 rounded bg-zinc-300 dark:bg-zinc-700" />
                      <div className="mt-3 h-3 w-14 rounded bg-brand-navy/70 dark:bg-white/40" />
                      <p className="mt-2 text-[10px] text-zinc-400">{label}</p>
                    </div>
                  ))}
                </div>
                <div className="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
                  <div className="mb-3 h-2 w-24 rounded bg-zinc-200 dark:bg-zinc-800" />
                  <div className="flex items-end gap-2">
                    {[40, 65, 35, 80, 55, 90, 60].map((h, i) => (
                      <div
                        key={i}
                        style={{ height: `${h}px` }}
                        className={`w-full rounded-t ${i === 5 ? "bg-brand-red" : "bg-brand-navy/70 dark:bg-white/30"}`}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="border-t border-zinc-200 bg-paper-muted py-16 dark:border-zinc-800 dark:bg-zinc-950">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="max-w-xl">
            <h2 className="text-2xl font-bold text-zinc-900 sm:text-3xl dark:text-zinc-50">
              Everything you need to track automotive parts
            </h2>
            <p className="mt-2 text-sm text-zinc-500 dark:text-zinc-400">
              One platform for your whole team, from onboarding to day-to-day operations.
            </p>
          </div>

          <div className="mt-10 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {CAPABILITIES.map((item) => (
              <div
                key={item.title}
                className="rounded-2xl border border-zinc-200 bg-paper p-5 dark:border-zinc-800 dark:bg-black"
              >
                <h3 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">{item.title}</h3>
                <p className="mt-2 text-sm text-zinc-500 dark:text-zinc-400">{item.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="border-t border-zinc-200 bg-paper py-16 dark:border-zinc-800 dark:bg-black">
        <div className="mx-auto max-w-6xl px-4 sm:px-6">
          <div className="grid grid-cols-1 items-center gap-10 lg:grid-cols-2">
            <div>
              <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">
                Build on the AssetPulse SDK
              </h2>
              <p className="mt-2 max-w-md text-sm text-zinc-500 dark:text-zinc-400">
                The same TypeScript client that powers this app&apos;s Parts screen — open
                source and ready to integrate into your own tools.
              </p>

              <ul className="mt-6 flex flex-col gap-3">
                {SDK_HIGHLIGHTS.map((item) => (
                  <li key={item.title} className="flex items-start gap-2.5 text-sm">
                    <span className="mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full bg-brand-red/10 text-brand-red">
                      <CheckIcon className="size-3" />
                    </span>
                    <span className="text-zinc-600 dark:text-zinc-400">
                      <strong className="font-semibold text-zinc-900 dark:text-zinc-50">
                        {item.title}
                      </strong>{" "}
                      — {item.description}
                    </span>
                  </li>
                ))}
              </ul>

              <div className="mt-7 flex items-center gap-3">
                <a
                  href="https://www.npmjs.com/package/@thiagohrcosta/assetpulse-sdk"
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-2 rounded-lg border border-zinc-300 px-4 py-2.5 text-sm font-semibold text-zinc-700 transition hover:bg-zinc-50 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-900"
                >
                  npm package
                </a>
                <a
                  href="https://github.com/thiagohrcosta/assetpulse-sdk"
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-2 rounded-lg bg-brand-navy px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-brand-navy-light"
                >
                  <GithubIcon className="size-4" />
                  GitHub
                </a>
              </div>
            </div>

            <div className="mx-auto w-full max-w-sm overflow-hidden rounded-2xl border border-zinc-200 dark:border-zinc-800">
              <Image
                src="/assetpulse-sdk.png"
                alt="AssetPulse TypeScript SDK"
                width={1536}
                height={1024}
                className="h-auto w-full"
              />
            </div>
          </div>
        </div>
      </section>

      <section className="bg-brand-navy-dark py-16 text-white">
        <div className="mx-auto flex max-w-6xl flex-col items-center gap-4 px-4 text-center sm:px-6">
          <h2 className="text-2xl font-bold sm:text-3xl">Ready to see it in action?</h2>
          <p className="max-w-md text-sm text-white/70">
            Create your account, set up your company, and start tracking in minutes — free trial
            included.
          </p>
          <Link
            href="/register"
            className="mt-2 inline-flex items-center gap-2 rounded-lg bg-brand-red px-6 py-3 text-sm font-semibold text-white transition hover:bg-brand-red-dark"
          >
            Start tracking now
            <ArrowRightIcon className="size-4" />
          </Link>
        </div>
      </section>

      <footer className="border-t border-zinc-200 py-8 dark:border-zinc-800">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-4 sm:flex-row sm:px-6">
          <Image src="/logo.png" alt="AssetPulse" width={140} height={79} className="h-auto w-27.5 opacity-80" />
          <p className="text-xs text-zinc-400">
            &copy; {new Date().getFullYear()} AssetPulse. Tracking what moves America.
          </p>
        </div>

        <div className="mx-auto mt-6 max-w-6xl border-t border-zinc-200 px-4 pt-6 text-center sm:px-6 dark:border-zinc-800">
          <p className="text-xs text-zinc-400">
            Built by{" "}
            <a
              href="https://thiago-vercel.vercel.app/"
              target="_blank"
              rel="noreferrer"
              className="font-medium text-zinc-600 hover:text-brand-red hover:underline dark:text-zinc-300"
            >
              Thiago Costa
            </a>{" "}
            —{" "}
            <a
              href="https://github.com/thiagohrcosta"
              target="_blank"
              rel="noreferrer"
              className="hover:text-brand-red hover:underline"
            >
              GitHub
            </a>{" "}
            ·{" "}
            <a
              href="https://thiago-vercel.vercel.app/"
              target="_blank"
              rel="noreferrer"
              className="hover:text-brand-red hover:underline"
            >
              Portfolio
            </a>
          </p>
        </div>
      </footer>
    </main>
  );
}
