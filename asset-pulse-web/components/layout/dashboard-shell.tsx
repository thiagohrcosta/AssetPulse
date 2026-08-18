"use client";

import { useState, type ReactNode } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";

import { useAuth } from "@/context/auth-context";
import {
  AlertIcon,
  BillingIcon,
  CloseIcon,
  DashboardIcon,
  LogoutIcon,
  MenuIcon,
  PartsIcon,
  SearchIcon,
} from "@/components/icons";

interface NavItem {
  href: string;
  label: string;
  icon: (props: { className?: string }) => ReactNode;
  soon?: boolean;
}

const NAV_ITEMS: NavItem[] = [
  { href: "/dashboard", label: "Dashboard", icon: DashboardIcon },
  { href: "/parts", label: "Parts", icon: PartsIcon },
  { href: "/subscription", label: "Subscription", icon: BillingIcon },
  { href: "#", label: "Alerts", icon: AlertIcon, soon: true },
];

function SidebarContent({ pathname }: { pathname: string }) {
  const { user, company, logout } = useAuth();

  return (
    <div className="flex h-full flex-col bg-brand-navy-dark text-white">
      <div className="px-5 pb-6 pt-6">
        <Image src="/white-logo.png" alt="AssetPulse" width={200} height={112} priority className="h-auto w-37.5" />
      </div>

      <nav className="flex-1 space-y-1 px-3">
        {NAV_ITEMS.map((item) => {
          const active = !item.soon && pathname.startsWith(item.href);
          const Icon = item.icon;

          if (item.soon) {
            return (
              <span
                key={item.label}
                className="flex cursor-not-allowed items-center justify-between gap-3 rounded-xl px-3 py-2.5 text-sm text-white/35"
              >
                <span className="flex items-center gap-3">
                  <Icon className="size-4.5" />
                  {item.label}
                </span>
                <span className="rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-medium uppercase tracking-wide">
                  Soon
                </span>
              </span>
            );
          }

          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition ${
                active ? "bg-brand-red text-white" : "text-white/70 hover:bg-white/5 hover:text-white"
              }`}
            >
              <Icon className="size-4.5" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-white/10 p-3">
        <div className="flex items-center gap-3 rounded-xl px-2 py-2">
          <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-white/10 text-sm font-semibold uppercase">
            {user?.full_name?.charAt(0) ?? "?"}
          </span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium text-white">{user?.full_name ?? "—"}</p>
            <p className="truncate text-xs text-white/50">{company?.name ?? user?.email}</p>
          </div>
          <button
            type="button"
            onClick={logout}
            aria-label="Log out"
            className="flex size-8 shrink-0 items-center justify-center rounded-lg text-white/60 transition hover:bg-white/10 hover:text-white"
          >
            <LogoutIcon className="size-4.5" />
          </button>
        </div>
      </div>
    </div>
  );
}

interface DashboardShellProps {
  title: string;
  description?: string;
  actions?: ReactNode;
  search?: {
    value: string;
    onChange: (value: string) => void;
    placeholder?: string;
  };
  children: ReactNode;
}

export function DashboardShell({ title, description, actions, search, children }: DashboardShellProps) {
  const pathname = usePathname();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  return (
    <div className="flex min-h-screen w-full bg-paper-muted dark:bg-black">
      <aside className="hidden w-64 shrink-0 lg:block">
        <div className="fixed h-screen w-64">
          <SidebarContent pathname={pathname} />
        </div>
      </aside>

      {mobileNavOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <button
            type="button"
            aria-label="Close menu"
            className="absolute inset-0 bg-black/50"
            onClick={() => setMobileNavOpen(false)}
          />
          <div className="relative z-10 h-full w-64">
            <SidebarContent pathname={pathname} />
            <button
              type="button"
              onClick={() => setMobileNavOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-6 flex size-8 items-center justify-center rounded-lg text-white/70 hover:bg-white/10"
            >
              <CloseIcon className="size-5" />
            </button>
          </div>
        </div>
      )}

      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex items-center gap-3 border-b border-zinc-200 bg-paper/80 px-4 py-3 backdrop-blur sm:px-6 dark:border-zinc-800 dark:bg-black/80">
          <button
            type="button"
            onClick={() => setMobileNavOpen(true)}
            aria-label="Open menu"
            className="flex size-9 shrink-0 items-center justify-center rounded-lg text-zinc-600 hover:bg-zinc-100 lg:hidden dark:text-zinc-300 dark:hover:bg-zinc-900"
          >
            <MenuIcon className="size-5" />
          </button>

          {search ? (
            <label className="relative flex-1 sm:max-w-sm">
              <SearchIcon className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-zinc-400" />
              <input
                type="search"
                value={search.value}
                onChange={(e) => search.onChange(e.target.value)}
                placeholder={search.placeholder ?? "Search…"}
                className="w-full rounded-lg border border-zinc-300 bg-paper py-2 pl-9 pr-3 text-sm text-zinc-900 outline-none transition focus:border-brand-navy focus:ring-1 focus:ring-brand-navy dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-50"
              />
            </label>
          ) : (
            <div className="flex-1" />
          )}
        </header>

        <main className="flex-1 px-4 py-6 sm:px-6 sm:py-8">
          <div className="mx-auto flex max-w-6xl flex-col gap-6">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">{title}</h1>
                {description && (
                  <p className="mt-1 text-sm text-zinc-500 dark:text-zinc-400">{description}</p>
                )}
              </div>
              {actions && <div className="flex items-center gap-2">{actions}</div>}
            </div>

            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
