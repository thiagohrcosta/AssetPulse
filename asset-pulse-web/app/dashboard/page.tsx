"use client";
// Client Component: reads the logged-in user/company from the AuthContext
// (localStorage-backed) and offers a logout action — both client-only.

import { useEffect, useState } from "react";
import Link from "next/link";

import { useAuth } from "@/context/auth-context";
import { ApiError, getSubscription, listCompanies } from "@/lib/api";
import type { Subscription } from "@/lib/types";
import { ProtectedRoute } from "@/components/protected-route";

function DashboardContent() {
  const { user, company, token, logout, setCompany } = useAuth();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [subscriptionError, setSubscriptionError] = useState<string | null>(null);

  // The auth context only holds a `company` once some screen has resolved
  // and cached it via setCompany (see company/new and subscription pages) —
  // login/register never populate it. Hydrate it here too so a user who
  // already has a company but lands straight on the dashboard still sees it.
  useEffect(() => {
    if (!token || company) return;

    let cancelled = false;
    listCompanies(token)
      .then((companies) => {
        const activeCompany = companies.at(-1) ?? null;
        if (!cancelled && activeCompany) setCompany(activeCompany);
      })
      .catch(() => {
        // No company to resolve (or request failed) — leave the
        // "No company on file" state as-is.
      });

    return () => {
      cancelled = true;
    };
  }, [token, company, setCompany]);

  useEffect(() => {
    if (!token || !company) return;

    let cancelled = false;
    getSubscription(token, company.id)
      .then((data) => {
        if (!cancelled) setSubscription(data);
      })
      .catch((err) => {
        if (!cancelled) {
          setSubscriptionError(err instanceof ApiError ? err.message : "Unavailable");
        }
      });

    return () => {
      cancelled = true;
    };
  }, [token, company]);

  return (
    <main className="flex flex-1 flex-col items-center bg-zinc-50 px-4 py-12 dark:bg-black">
      <div className="w-full max-w-2xl">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
              Welcome{user ? `, ${user.full_name}` : ""}
            </h1>
            <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">{user?.email}</p>
          </div>
          <div className="flex items-center gap-2">
            <Link
              href="/parts"
              className="rounded-lg border border-zinc-300 px-3 py-2 text-sm font-medium text-zinc-700 transition hover:bg-zinc-100 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-900"
            >
              Parts
            </Link>
            <button
              onClick={logout}
              className="rounded-lg border border-zinc-300 px-3 py-2 text-sm font-medium text-zinc-700 transition hover:bg-zinc-100 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-900"
            >
              Log out
            </button>
          </div>
        </div>

        <div className="mt-8 rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-950">
          <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Company</h2>
          {company ? (
            <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">{company.name}</p>
          ) : (
            <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">No company on file.</p>
          )}
        </div>

        <div className="mt-4 rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-950">
          <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Subscription</h2>
          {subscriptionError && (
            <p className="mt-1 text-sm text-red-600 dark:text-red-400">{subscriptionError}</p>
          )}
          {!subscriptionError && subscription && (
            <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
              Status: <strong>{subscription.status}</strong>
              {subscription.plan ? ` — ${subscription.plan}` : ""}
              {subscription.trial_ends_at &&
                ` — trial ends ${new Date(subscription.trial_ends_at).toLocaleDateString()}`}
            </p>
          )}
        </div>

        <p className="mt-8 text-center text-sm text-zinc-400">
          This is a placeholder — asset management screens land in the next iteration.
        </p>
      </div>
    </main>
  );
}

export default function DashboardPage() {
  return (
    <ProtectedRoute>
      <DashboardContent />
    </ProtectedRoute>
  );
}
