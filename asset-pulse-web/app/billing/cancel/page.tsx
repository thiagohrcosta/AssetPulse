// Server Component: purely static copy, no client state needed.

import Link from "next/link";

export default function BillingCancelPage() {
  return (
    <main className="flex flex-1 items-center justify-center bg-zinc-50 px-4 py-12 dark:bg-black">
      <div className="w-full max-w-md rounded-2xl border border-zinc-200 bg-white p-8 text-center shadow-sm dark:border-zinc-800 dark:bg-zinc-950">
        <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
          Checkout canceled
        </h1>
        <p className="mt-2 text-sm text-zinc-500 dark:text-zinc-400">
          No payment was made. You can pick a plan whenever you&apos;re ready.
        </p>
        <Link
          href="/subscription"
          className="mt-6 inline-flex items-center justify-center rounded-lg bg-zinc-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
        >
          Back to plans
        </Link>
      </div>
    </main>
  );
}
