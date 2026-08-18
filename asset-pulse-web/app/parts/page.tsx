"use client";
// Client Component: parts listing for the active company, backed by
// @thiagohrcosta/assetpulse-sdk's PartsResource instead of a hand-rolled fetch call —
// see lib/asset-pulse-client.ts.

import { useEffect, useMemo, useState, type FormEvent } from "react";
import type { HostUnit, Part, PartCreateInput, PartListFilters } from "@thiagohrcosta/assetpulse-sdk";
import { AssetPulseApiError } from "@thiagohrcosta/assetpulse-sdk";

import { useAuth } from "@/context/auth-context";
import { createAssetPulseClient } from "@/lib/asset-pulse-client";
import { ApiError, listCompanies, listPartTypeReferences } from "@/lib/api";
import type { PartTypeReference } from "@/lib/types";
import { ProtectedRoute } from "@/components/protected-route";
import { DashboardShell } from "@/components/layout/dashboard-shell";
import { ErrorBanner } from "@/components/ui/error-banner";
import { Field } from "@/components/ui/field";
import { SubmitButton } from "@/components/ui/submit-button";
import { StatusBadge } from "@/components/ui/status-badge";
import { Pagination } from "@/components/ui/pagination";
import { PlusIcon } from "@/components/icons";

const STATUS_OPTIONS: NonNullable<PartListFilters["status"]>[] = [
  "installed",
  "in_repair",
  "removed",
  "scrapped",
];

// Anything longer than this gets paginated instead of dumped on the page as
// one long list.
const PAGE_SIZE = 15;

function PartsContent() {
  const { token, company, setCompany } = useAuth();
  const [statusFilter, setStatusFilter] = useState<PartListFilters["status"] | "">("");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [parts, setParts] = useState<Part[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  // Bumped after a successful create so the list effect below refetches
  // from the server (respecting whatever status filter is active) instead
  // of hand-merging the new row into local state.
  const [refreshToken, setRefreshToken] = useState(0);

  const [partTypeReferences, setPartTypeReferences] = useState<PartTypeReference[] | null>(null);
  const [hostUnits, setHostUnits] = useState<HostUnit[] | null>(null);
  const [showNewPartForm, setShowNewPartForm] = useState(false);

  // Same hydration fallback as the dashboard: login/register don't
  // populate `company` in the auth context, only screens that already
  // resolved one do.
  useEffect(() => {
    if (!token || company) return;

    let cancelled = false;
    listCompanies(token)
      .then((companies) => {
        const activeCompany = companies.at(-1) ?? null;
        if (!cancelled && activeCompany) setCompany(activeCompany);
      })
      .catch(() => {});

    return () => {
      cancelled = true;
    };
  }, [token, company, setCompany]);

  useEffect(() => {
    if (!token || !company) return;

    let cancelled = false;
    const client = createAssetPulseClient(token, company.id);
    const filters: PartListFilters = statusFilter ? { status: statusFilter } : {};

    client.parts
      .list(filters)
      .then((data) => {
        if (cancelled) return;
        setParts(data);
        setError(null);
      })
      .catch((err) => {
        if (!cancelled) {
          setError(err instanceof AssetPulseApiError ? err.message : "Failed to load parts");
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [token, company, statusFilter, refreshToken]);

  // Reference data for the "New part" form. part_type_references is global
  // (see lib/api.ts), host_units is per-company via the SDK — both are
  // fetched once the pieces they depend on are available, independent of
  // the parts list/filter above.
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

  useEffect(() => {
    if (!token || !company) return;

    let cancelled = false;
    createAssetPulseClient(token, company.id)
      .hostUnits.list()
      .then((data) => {
        if (!cancelled) setHostUnits(data);
      })
      .catch(() => {});

    return () => {
      cancelled = true;
    };
  }, [token, company]);

  // The status filter is server-side (see the effect above); search is a
  // client-side pass over whatever page of that result came back.
  const filteredParts = useMemo(() => {
    if (!parts) return null;
    const term = search.trim().toLowerCase();
    if (!term) return parts;
    return parts.filter(
      (part) =>
        part.serial_number.toLowerCase().includes(term) ||
        part.manufacturer.toLowerCase().includes(term) ||
        part.model.toLowerCase().includes(term)
    );
  }, [parts, search]);

  const pageCount = filteredParts ? Math.max(1, Math.ceil(filteredParts.length / PAGE_SIZE)) : 1;

  // Changing the status filter or search term can move the previously-viewed
  // page out of range, so snap back to page 1 whenever either changes. This
  // adjusts state during render (React's documented pattern for "reset state
  // when a prop changes") rather than in an effect, which would cost an
  // extra render pass.
  const filterKey = `${statusFilter}:${search.trim().toLowerCase()}`;
  const [lastFilterKey, setLastFilterKey] = useState(filterKey);
  if (filterKey !== lastFilterKey) {
    setLastFilterKey(filterKey);
    setPage(1);
  }

  const pagedParts = filteredParts?.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE) ?? null;

  async function handleCreatePart(input: PartCreateInput) {
    if (!token || !company) return;

    const client = createAssetPulseClient(token, company.id);
    const part = await client.parts.create(input);
    setShowNewPartForm(false);
    // The new part may not match the active status filter (defaults to
    // "installed") or belong on the currently loaded page, so refetch from
    // the server instead of assuming it should appear locally.
    setRefreshToken((value) => value + 1);
    return part;
  }

  return (
    <DashboardShell
      title="Parts"
      description={company ? company.name : "Loading company…"}
      search={{ value: search, onChange: setSearch, placeholder: "Search by serial, manufacturer, model…" }}
      actions={
        <>
          <select
            value={statusFilter}
            onChange={(event) => setStatusFilter(event.target.value as PartListFilters["status"] | "")}
            className="rounded-lg border border-zinc-300 bg-paper px-3 py-2 text-sm text-zinc-900 outline-none focus:border-brand-navy focus:ring-1 focus:ring-brand-navy dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-50"
          >
            <option value="">All statuses</option>
            {STATUS_OPTIONS.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>

          <button
            type="button"
            onClick={() => setShowNewPartForm((value) => !value)}
            className="inline-flex items-center gap-1.5 rounded-lg bg-brand-navy px-3 py-2 text-sm font-medium text-white transition hover:bg-brand-navy-light dark:bg-zinc-50 dark:text-brand-navy dark:hover:bg-zinc-200"
          >
            <PlusIcon className="size-4" />
            {showNewPartForm ? "Cancel" : "New part"}
          </button>
        </>
      }
    >
      <ErrorBanner message={error} />

      {showNewPartForm && (
        <NewPartForm
          partTypeReferences={partTypeReferences}
          hostUnits={hostUnits}
          onCreate={handleCreatePart}
        />
      )}

      <div className="overflow-hidden rounded-2xl border border-zinc-200 bg-paper dark:border-zinc-800 dark:bg-zinc-950">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="border-b border-zinc-200 text-xs uppercase text-zinc-500 dark:border-zinc-800 dark:text-zinc-400">
              <tr>
                <th className="px-4 py-3 font-medium">Serial number</th>
                <th className="px-4 py-3 font-medium">Manufacturer</th>
                <th className="px-4 py-3 font-medium">Model</th>
                <th className="px-4 py-3 font-medium">Host unit</th>
                <th className="px-4 py-3 font-medium">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100 dark:divide-zinc-900">
              {loading && (
                <tr>
                  <td colSpan={5} className="px-4 py-6 text-center text-zinc-400">
                    Loading…
                  </td>
                </tr>
              )}

              {!loading && pagedParts?.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-4 py-6 text-center text-zinc-400">
                    No parts found.
                  </td>
                </tr>
              )}

              {!loading &&
                pagedParts?.map((part) => (
                  <tr key={part.id} className="text-zinc-700 dark:text-zinc-300">
                    <td className="px-4 py-3 font-medium text-zinc-900 dark:text-zinc-50">
                      {part.serial_number}
                    </td>
                    <td className="px-4 py-3">{part.manufacturer}</td>
                    <td className="px-4 py-3">{part.model}</td>
                    <td className="px-4 py-3">{part.host_unit_id ?? "—"}</td>
                    <td className="px-4 py-3">
                      <StatusBadge status={part.status} />
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>

        {!loading && filteredParts && (
          <Pagination
            page={page}
            pageCount={pageCount}
            onPageChange={setPage}
            totalItems={filteredParts.length}
            pageSize={PAGE_SIZE}
          />
        )}
      </div>
    </DashboardShell>
  );
}

interface NewPartFormProps {
  partTypeReferences: PartTypeReference[] | null;
  hostUnits: HostUnit[] | null;
  onCreate: (input: PartCreateInput) => Promise<Part | undefined>;
}

// Status isn't collected here — Api::V1::PartsController defaults a new
// part to "installed" (see Part#status enum), and there's no reason to
// second-guess that on creation; use the status filter's dropdown, once a
// part exists, to see how that plays out.
function NewPartForm({ partTypeReferences, hostUnits, onCreate }: NewPartFormProps) {
  const [partTypeReferenceId, setPartTypeReferenceId] = useState("");
  const [serialNumber, setSerialNumber] = useState("");
  const [manufacturer, setManufacturer] = useState("");
  const [model, setModel] = useState("");
  const [hostUnitId, setHostUnitId] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSubmitting(true);

    try {
      await onCreate({
        part_type_reference_id: Number(partTypeReferenceId),
        serial_number: serialNumber,
        manufacturer,
        model,
        host_unit_id: hostUnitId ? Number(hostUnitId) : undefined,
      });
      setPartTypeReferenceId("");
      setSerialNumber("");
      setManufacturer("");
      setModel("");
      setHostUnitId("");
    } catch (err) {
      setError(
        err instanceof AssetPulseApiError || err instanceof ApiError
          ? err.message
          : "Failed to create part"
      );
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="rounded-2xl border border-zinc-200 bg-paper p-6 dark:border-zinc-800 dark:bg-zinc-950"
    >
      <div className="mb-4">
        <ErrorBanner message={error} />
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <label htmlFor="part_type_reference_id" className="flex flex-col gap-1.5 text-sm">
          <span className="font-medium text-zinc-700 dark:text-zinc-300">
            Part type<span className="text-red-500"> *</span>
          </span>
          <select
            id="part_type_reference_id"
            required
            value={partTypeReferenceId}
            onChange={(event) => setPartTypeReferenceId(event.target.value)}
            className="rounded-lg border border-zinc-300 bg-paper px-3 py-2 text-zinc-900 outline-none focus:border-brand-navy focus:ring-1 focus:ring-brand-navy dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-50"
          >
            <option value="" disabled>
              {partTypeReferences ? "Select a part type" : "Loading…"}
            </option>
            {partTypeReferences?.map((reference) => (
              <option key={reference.id} value={reference.id}>
                {reference.part_type} ({reference.typical_lifespan_days}d)
              </option>
            ))}
          </select>
        </label>

        <label htmlFor="host_unit_id" className="flex flex-col gap-1.5 text-sm">
          <span className="font-medium text-zinc-700 dark:text-zinc-300">Host unit</span>
          <select
            id="host_unit_id"
            value={hostUnitId}
            onChange={(event) => setHostUnitId(event.target.value)}
            className="rounded-lg border border-zinc-300 bg-paper px-3 py-2 text-zinc-900 outline-none focus:border-brand-navy focus:ring-1 focus:ring-brand-navy dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-50"
          >
            <option value="">Unassigned</option>
            {hostUnits?.map((hostUnit) => (
              <option key={hostUnit.id} value={hostUnit.id}>
                {hostUnit.vin} — {hostUnit.description}
              </option>
            ))}
          </select>
        </label>

        <Field
          id="serial_number"
          label="Serial number"
          required
          value={serialNumber}
          onChange={(event) => setSerialNumber(event.target.value)}
        />
        <Field
          id="manufacturer"
          label="Manufacturer"
          required
          value={manufacturer}
          onChange={(event) => setManufacturer(event.target.value)}
        />
        <Field
          id="model"
          label="Model"
          required
          value={model}
          onChange={(event) => setModel(event.target.value)}
        />
      </div>

      <SubmitButton pending={submitting} pendingLabel="Creating…" className="mt-6">
        Create part
      </SubmitButton>
    </form>
  );
}

export default function PartsPage() {
  return (
    <ProtectedRoute>
      <PartsContent />
    </ProtectedRoute>
  );
}
