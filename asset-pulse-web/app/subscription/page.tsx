"use client";
// Client Component: the plan a company can subscribe to depends on the
// JWT-scoped `current_user`/company held in the AuthContext (localStorage,
// no cookie), and picking a plan triggers a mutation + redirect — none of
// that is renderable on the server here.

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";

import { useAuth } from "@/context/auth-context";
import {
  ApiError,
  createCheckoutSession,
  getSubscription,
  listCompanies,
  listPlans,
  startTrial,
} from "@/lib/api";
import type { Company, Plan, Subscription } from "@/lib/types";
import { ProtectedRoute } from "@/components/protected-route";
import { SubmitButton } from "@/components/ui/submit-button";
import { ErrorBanner } from "@/components/ui/error-banner";

function formatPrice(plan: Plan) {
  const amount = plan.amount.toLocaleString("en-US", {
    style: "currency",
    currency: plan.currency.toUpperCase(),
  });
  return `${amount} / ${plan.interval}`;
}

function SubscriptionForm() {
  const { token, company, setCompany } = useAuth();
  const router = useRouter();

  const [resolvedCompany, setResolvedCompany] = useState<Company | null>(company);
  const [plans, setPlans] = useState<Plan[] | null>(null);
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  // Which action is in flight, so only that button shows a pending state.
  const [pendingAction, setPendingAction] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;

    // `cancelled` guards against setting state after the effect re-runs or
    // the component unmounts (e.g. token changes mid-flight) — the async
    // work itself stays inline in the effect rather than behind a named
    // function reference passed as its dependency.
    let cancelled = false;

    (async () => {
      setLoading(true);
      setError(null);

      try {
        let activeCompany = company;
        if (!activeCompany) {
          const companies = await listCompanies(token);
          activeCompany = companies.at(-1) ?? null;
          if (!activeCompany) {
            router.replace("/company/new");
            return;
          }
          setCompany(activeCompany);
        }
        if (cancelled) return;
        setResolvedCompany(activeCompany);

        // Independent reads — fetch in parallel rather than one after another.
        const [planList, currentSubscription] = await Promise.all([
          listPlans(token),
          getSubscription(token, activeCompany.id),
        ]);
        if (cancelled) return;
        setPlans(planList);
        setSubscription(currentSubscription);
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof ApiError ? err.message : "Could not load subscription plans.");
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
    // company/setCompany/router are stable-enough across this page's lifetime;
    // re-running on token change covers the only case that matters.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

  async function handleTrial() {
    if (!token || !resolvedCompany) return;
    setError(null);
    setPendingAction("trial");
    try {
      await startTrial(token, resolvedCompany.id);
      router.push("/dashboard");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not start the trial.");
      setPendingAction(null);
    }
  }

  async function handleCheckout(planSlug: string) {
    if (!token || !resolvedCompany) return;
    setError(null);
    setPendingAction(planSlug);
    try {
      const origin = window.location.origin;
      const { checkout_url } = await createCheckoutSession(token, resolvedCompany.id, {
        plan_slug: planSlug,
        success_url: `${origin}/billing/success?company_id=${resolvedCompany.id}`,
        cancel_url: `${origin}/subscription`,
      });
      window.location.assign(checkout_url);
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "Could not start checkout.");
      setPendingAction(null);
    }
  }

  const alreadySubscribed = subscription != null && subscription.status !== "none";

  return (
    <main className="flex flex-1 flex-col items-center bg-zinc-50 px-4 py-12 dark:bg-black">
      <div className="w-full max-w-4xl">
        <div className="text-center">
          <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
            Choose your plan
          </h1>
          <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
            Step 3 of 3 — pick a free trial or a paid plan for{" "}
            {resolvedCompany ? <strong>{resolvedCompany.name}</strong> : "your company"}.
          </p>
        </div>

        <div className="mt-6">
          <ErrorBanner message={error} />
        </div>

        {loading && (
          <p className="mt-10 text-center text-sm text-zinc-500 dark:text-zinc-400">
            Loading plans…
          </p>
        )}

        {!loading && alreadySubscribed && (
          <div className="mt-10 rounded-2xl border border-zinc-200 bg-white p-6 text-center dark:border-zinc-800 dark:bg-zinc-950">
            <p className="text-sm text-zinc-600 dark:text-zinc-400">
              This company already has a subscription (status:{" "}
              <strong>{subscription?.status}</strong>).
            </p>
            <button
              onClick={() => router.push("/dashboard")}
              className="mt-4 inline-flex items-center justify-center rounded-lg bg-zinc-900 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-zinc-700 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
            >
              Go to dashboard
            </button>
          </div>
        )}

        {!loading && !alreadySubscribed && (
          <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-3">
            <div className="flex flex-col rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-950">
              <h2 className="text-lg font-semibold text-zinc-900 dark:text-zinc-50">
                Free trial
              </h2>
              <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                7 days, full access, no credit card required.
              </p>
              <p className="mt-4 text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
                $0 <span className="text-sm font-normal text-zinc-500">/ 7 days</span>
              </p>
              <SubmitButton
                type="button"
                onClick={handleTrial}
                pending={pendingAction === "trial"}
                pendingLabel="Starting…"
                disabled={pendingAction !== null}
                className="mt-6"
              >
                Start free trial
              </SubmitButton>
            </div>

            {plans?.map((plan) => (
              <div
                key={plan.id}
                className="flex flex-col rounded-2xl border border-zinc-200 bg-white p-6 dark:border-zinc-800 dark:bg-zinc-950"
              >
                <h2 className="text-lg font-semibold capitalize text-zinc-900 dark:text-zinc-50">
                  {plan.name}
                </h2>
                <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                  {plan.ai_enabled ? "Includes AI-powered insights." : "Core asset management."}
                </p>
                <p className="mt-4 text-2xl font-semibold text-zinc-900 dark:text-zinc-50">
                  {formatPrice(plan)}
                </p>
                <SubmitButton
                  type="button"
                  onClick={() => handleCheckout(plan.slug)}
                  pending={pendingAction === plan.slug}
                  pendingLabel="Redirecting…"
                  disabled={pendingAction !== null}
                  className="mt-6"
                >
                  Subscribe to {plan.name}
                </SubmitButton>
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  );
}

export default function SubscriptionPage() {
  return (
    <ProtectedRoute>
      <SubscriptionForm />
    </ProtectedRoute>
  );
}
