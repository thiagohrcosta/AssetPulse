// Server Component: purely static confirmation copy, no client state or
// auth-scoped data is read here, so there is no reason to ship this as
// client JS.

import Link from "next/link";

export default function BillingSuccessPage() {
  return (
    <main className="flex flex-1 items-center justify-center bg-paper-muted px-4 py-12 dark:bg-black">
      <div className="w-full max-w-md rounded-2xl border border-zinc-200 bg-paper p-8 text-center shadow-sm dark:border-zinc-800 dark:bg-zinc-950">
        <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
          Payment confirmed
        </h1>
        <p className="mt-2 text-sm text-zinc-500 dark:text-zinc-400">
          Your subscription is being activated. Stripe sends us a confirmation in the
          background, so it may take a few seconds to show up on your dashboard.
        </p>
        <Link
          href="/dashboard"
          className="mt-6 inline-flex items-center justify-center rounded-lg bg-zinc-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
        >
          Go to dashboard
        </Link>
      </div>
    </main>
  );
}
