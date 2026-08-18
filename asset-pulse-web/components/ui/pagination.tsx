import { ChevronLeftIcon, ChevronRightIcon } from "@/components/icons";

interface PaginationProps {
  page: number;
  pageCount: number;
  onPageChange: (page: number) => void;
  /** Total item count, shown as "Showing X–Y of Z" when both are given. */
  totalItems?: number;
  pageSize?: number;
}

// Windows the page numbers around the current page so this stays usable
// even with a couple hundred rows behind it, instead of rendering a button
// per page.
function pageWindow(page: number, pageCount: number): (number | "…")[] {
  const window = new Set<number>([1, pageCount, page, page - 1, page + 1]);
  const sorted = [...window].filter((p) => p >= 1 && p <= pageCount).sort((a, b) => a - b);

  const result: (number | "…")[] = [];
  sorted.forEach((p, i) => {
    if (i > 0 && p - (sorted[i - 1] as number) > 1) result.push("…");
    result.push(p);
  });
  return result;
}

export function Pagination({ page, pageCount, onPageChange, totalItems, pageSize }: PaginationProps) {
  if (pageCount <= 1) return null;

  const from = totalItems && pageSize ? (page - 1) * pageSize + 1 : null;
  const to = totalItems && pageSize ? Math.min(page * pageSize, totalItems) : null;

  return (
    <div className="flex flex-col items-center justify-between gap-3 border-t border-zinc-200 px-4 py-3 sm:flex-row dark:border-zinc-800">
      {from !== null && to !== null && (
        <p className="text-xs text-zinc-500 dark:text-zinc-400">
          Showing <span className="font-medium text-zinc-700 dark:text-zinc-300">{from}–{to}</span> of{" "}
          <span className="font-medium text-zinc-700 dark:text-zinc-300">{totalItems}</span>
        </p>
      )}

      <nav className="flex items-center gap-1" aria-label="Pagination">
        <button
          type="button"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
          aria-label="Previous page"
          className="inline-flex size-8 items-center justify-center rounded-lg text-zinc-500 transition hover:bg-zinc-100 disabled:cursor-not-allowed disabled:opacity-40 dark:text-zinc-400 dark:hover:bg-zinc-900"
        >
          <ChevronLeftIcon className="size-4" />
        </button>

        {pageWindow(page, pageCount).map((entry, i) =>
          entry === "…" ? (
            <span key={`ellipsis-${i}`} className="px-1.5 text-xs text-zinc-400">
              …
            </span>
          ) : (
            <button
              key={entry}
              type="button"
              onClick={() => onPageChange(entry)}
              aria-current={entry === page ? "page" : undefined}
              className={`inline-flex size-8 items-center justify-center rounded-lg text-xs font-medium transition ${
                entry === page
                  ? "bg-brand-navy text-white dark:bg-white dark:text-brand-navy"
                  : "text-zinc-600 hover:bg-zinc-100 dark:text-zinc-400 dark:hover:bg-zinc-900"
              }`}
            >
              {entry}
            </button>
          )
        )}

        <button
          type="button"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= pageCount}
          aria-label="Next page"
          className="inline-flex size-8 items-center justify-center rounded-lg text-zinc-500 transition hover:bg-zinc-100 disabled:cursor-not-allowed disabled:opacity-40 dark:text-zinc-400 dark:hover:bg-zinc-900"
        >
          <ChevronRightIcon className="size-4" />
        </button>
      </nav>
    </div>
  );
}
