"use client";

import { useEffect, type ReactNode } from "react";
import { useRouter } from "next/navigation";

import { useAuth } from "@/context/auth-context";

/**
 * Wrap any page that requires a logged-in user. `useAuth`'s session comes
 * from useSyncExternalStore (see context/auth-context.tsx), so
 * `isAuthenticated` is already correct by the first committed render —
 * no separate hydration flag needed here.
 */
export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isAuthenticated) {
      router.replace("/login");
    }
  }, [isAuthenticated, router]);

  if (!isAuthenticated) {
    return (
      <div className="flex flex-1 items-center justify-center py-32 text-sm text-zinc-500 dark:text-zinc-400">
        Loading...
      </div>
    );
  }

  return <>{children}</>;
}
