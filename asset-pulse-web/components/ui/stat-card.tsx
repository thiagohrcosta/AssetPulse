import type { ReactNode } from "react";

interface StatCardProps {
  label: string;
  value: ReactNode;
  icon: ReactNode;
  hint?: string;
}

export function StatCard({ label, value, icon, hint }: StatCardProps) {
  return (
    <div className="flex items-start gap-3 rounded-2xl border border-zinc-200 bg-paper p-4 dark:border-zinc-800 dark:bg-zinc-950">
      <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-brand-navy/5 text-brand-navy dark:bg-white/10 dark:text-white">
        {icon}
      </div>
      <div className="min-w-0">
        <p className="text-xs font-medium text-zinc-500 dark:text-zinc-400">{label}</p>
        <p className="mt-0.5 text-xl font-semibold text-zinc-900 dark:text-zinc-50">{value}</p>
        {hint && <p className="mt-0.5 text-xs text-zinc-400 dark:text-zinc-500">{hint}</p>}
      </div>
    </div>
  );
}
