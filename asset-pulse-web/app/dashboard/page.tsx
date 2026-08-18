"use client";
// Client Component: reads the logged-in user/company from the AuthContext
// (localStorage-backed) and pulls the current company's parts/host units
// through the SDK — both client-only concerns.

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import type { HostUnit, Part } from "@thiagohrcosta/assetpulse-sdk";

import { useAuth } from "@/context/auth-context";
import {
  ApiError,
  getSubscription,
  listCompanies,
  listPartTypeReferences,
} from "@/lib/api";
import type { PartTypeReference, Subscription } from "@/lib/types";
import { createAssetPulseClient } from "@/lib/asset-pulse-client";
import { ProtectedRoute } from "@/components/protected-route";
import { DashboardShell } from "@/components/layout/dashboard-shell";
import { StatCard } from "@/components/ui/stat-card";
import { StatusBadge } from "@/components/ui/status-badge";
import { DonutChart, type DonutSegment } from "@/components/ui/donut-chart";
import { BillingIcon, BoxesIcon, PartsIcon, WrenchIcon } from "@/components/icons";

function DashboardContent() {
  const { user, company, token, setCompany } = useAuth();
  const [subscription, setSubscription] = useState<Subscription | null>(null);
  const [subscriptionError, setSubscriptionError] = useState<string | null>(null);
  const [parts, setParts] = useState<Part[] | null>(null);
  const [hostUnits, setHostUnits] = useState<HostUnit[] | null>(null);
  const [partTypeReferences, setPartTypeReferences] = useState<PartTypeReference[] | null>(null);

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

  useEffect(() => {
    if (!token || !company) return;

    let cancelled = false;
    const client = createAssetPulseClient(token, company.id);

    Promise.all([client.parts.list(), client.hostUnits.list()])
      .then(([partsData, hostUnitsData]) => {
        if (cancelled) return;
        setParts(partsData);
        setHostUnits(hostUnitsData);
      })
      .catch(() => {
        // Leave both as null — the stat cards below just show "—".
      });

    return () => {
      cancelled = true;
    };
  }, [token, company]);

  useEffect(() => {
    if (!token) return;

    let cancelled = false;
    listPartTypeReferences(token)
      .then((data) => {
        if (!cancelled) setPartTypeReferences(data);
      })
      .catch(() => {});

    return () => {
      cancelled = true;
    };
  }, [token]);

  const installedCount = parts?.filter((p) => p.status === "installed").length ?? null;
  const needsAttentionCount =
    parts?.filter((p) => p.status === "in_repair" || p.status === "removed").length ?? null;

  // Parts by type, capped to the top 3 (folded into "Other" beyond that) —
  // a donut/pie only validates a fixed categorical palette three slots deep,
  // see the dataviz skill's palette notes.
  const typeSegments: DonutSegment[] = useMemo(() => {
    if (!parts || !partTypeReferences) return [];

    const nameById = new Map(partTypeReferences.map((ref) => [ref.id, ref.part_type]));
    const counts = new Map<string, number>();
    for (const part of parts) {
      const name = nameById.get(part.part_type_reference_id) ?? "Unknown";
      counts.set(name, (counts.get(name) ?? 0) + 1);
    }

    const sorted = [...counts.entries()].sort((a, b) => b[1] - a[1]);
    const top = sorted.slice(0, 3);
    const otherTotal = sorted.slice(3).reduce((sum, [, count]) => sum + count, 0);

    const palette = ["text-chart-1", "text-chart-2", "text-chart-3"];
    const segments: DonutSegment[] = top.map(([label, value], i) => ({
      label,
      value,
      colorClassName: palette[i] ?? "text-chart-other",
    }));
    if (otherTotal > 0) segments.push({ label: "Other", value: otherTotal, colorClassName: "text-chart-other" });
    return segments;
  }, [parts, partTypeReferences]);

  const recentParts = useMemo(
    () =>
      parts
        ? [...parts]
            .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
            .slice(0, 5)
        : null,
    [parts]
  );

  return (
    <DashboardShell
      title={`Welcome${user ? `, ${user.full_name.split(" ")[0]}` : ""}`}
      description={company ? company.name : user?.email}
    >
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          label="Parts tracked"
          value={parts ? parts.length : "—"}
          icon={<PartsIcon className="size-5" />}
        />
        <StatCard
          label="Installed"
          value={installedCount ?? "—"}
          icon={<BoxesIcon className="size-5" />}
        />
        <StatCard
          label="Needs attention"
          value={needsAttentionCount ?? "—"}
          icon={<WrenchIcon className="size-5" />}
          hint="In repair or removed"
        />
        <StatCard
          label="Host units"
          value={hostUnits ? hostUnits.length : "—"}
          icon={<BillingIcon className="size-5" />}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-5">
        <div className="rounded-2xl border border-zinc-200 bg-paper p-6 lg:col-span-2 dark:border-zinc-800 dark:bg-zinc-950">
          <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Parts by type</h2>
          {parts && partTypeReferences ? (
            typeSegments.length > 0 ? (
              <div className="mt-6">
                <DonutChart segments={typeSegments} centerValue={parts.length} centerLabel="Total parts" />
              </div>
            ) : (
              <p className="mt-6 text-sm text-zinc-400">No parts yet.</p>
            )
          ) : (
            <p className="mt-6 text-sm text-zinc-400">Loading…</p>
          )}
        </div>

        <div className="rounded-2xl border border-zinc-200 bg-paper p-6 lg:col-span-3 dark:border-zinc-800 dark:bg-zinc-950">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Recent parts</h2>
            <Link href="/parts" className="text-xs font-medium text-brand-red hover:underline">
              View all
            </Link>
          </div>

          <div className="mt-4 overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="text-xs uppercase text-zinc-400">
                <tr>
                  <th className="pb-2 font-medium">Serial</th>
                  <th className="pb-2 font-medium">Manufacturer</th>
                  <th className="pb-2 font-medium">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
                {recentParts === null && (
                  <tr>
                    <td colSpan={3} className="py-6 text-center text-zinc-400">
                      Loading…
                    </td>
                  </tr>
                )}
                {recentParts?.length === 0 && (
                  <tr>
                    <td colSpan={3} className="py-6 text-center text-zinc-400">
                      No parts yet.
                    </td>
                  </tr>
                )}
                {recentParts?.map((part) => (
                  <tr key={part.id} className="text-zinc-700 dark:text-zinc-300">
                    <td className="py-2.5 font-medium text-zinc-900 dark:text-zinc-50">
                      {part.serial_number}
                    </td>
                    <td className="py-2.5">{part.manufacturer}</td>
                    <td className="py-2.5">
                      <StatusBadge status={part.status} />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div className="rounded-2xl border border-zinc-200 bg-paper p-6 dark:border-zinc-800 dark:bg-zinc-950">
          <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Company</h2>
          {company ? (
            <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">{company.name}</p>
          ) : (
            <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">No company on file.</p>
          )}
        </div>

        <div className="rounded-2xl border border-zinc-200 bg-paper p-6 dark:border-zinc-800 dark:bg-zinc-950">
          <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-50">Subscription</h2>
          {subscriptionError && (
            <p className="mt-1 text-sm text-red-600 dark:text-red-400">{subscriptionError}</p>
          )}
          {!subscriptionError && subscription && (
            <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
              Status: <strong className="text-zinc-900 dark:text-zinc-50">{subscription.status}</strong>
              {subscription.plan ? ` — ${subscription.plan}` : ""}
              {subscription.trial_ends_at &&
                ` — trial ends ${new Date(subscription.trial_ends_at).toLocaleDateString()}`}
            </p>
          )}
          {!subscriptionError && !subscription && (
            <p className="mt-1 text-sm text-zinc-400">Loading…</p>
          )}
        </div>
      </div>
    </DashboardShell>
  );
}

export default function DashboardPage() {
  return (
    <ProtectedRoute>
      <DashboardContent />
    </ProtectedRoute>
  );
}
