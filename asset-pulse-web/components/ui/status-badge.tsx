// Status roles are fixed and never doubled as chart series colors (see
// app/globals.css: --color-status-*). Meaning is always carried by the
// label text, never by the dot color alone.
const STATUS_MAP: Record<string, { label: string; dot: string }> = {
  installed: { label: "Installed", dot: "bg-status-good" },
  in_repair: { label: "In repair", dot: "bg-status-warning" },
  removed: { label: "Removed", dot: "bg-status-serious" },
  scrapped: { label: "Scrapped", dot: "bg-status-critical" },
};

export function StatusBadge({ status }: { status: string }) {
  const entry = STATUS_MAP[status] ?? { label: status, dot: "bg-zinc-400" };

  return (
    <span className="inline-flex items-center gap-1.5 rounded-full bg-zinc-100 px-2.5 py-1 text-xs font-medium text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300">
      <span className={`size-1.5 rounded-full ${entry.dot}`} aria-hidden />
      {entry.label}
    </span>
  );
}
