"use client";

import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useSyncExternalStore,
  type ReactNode,
} from "react";

import {
  loginUser,
  registerUser,
  type LoginPayload,
  type RegisterPayload,
} from "@/lib/api";
import type { Company, User } from "@/lib/types";

const STORAGE_KEY = "asset-pulse:auth";
// Dispatched locally right after every write so this tab's own subscribers
// re-render immediately — the native "storage" event only fires in *other*
// tabs, never the one that made the change.
const LOCAL_CHANGE_EVENT = "asset-pulse:auth-changed";

interface StoredAuth {
  token: string;
  user: User;
  company: Company | null;
}

// The JWT only ever lives in the browser (this API is stateless/bearer-
// token auth, not cookie-based — see ApplicationController), so it's read
// through useSyncExternalStore rather than useEffect+setState: that's what
// lets the very first client render already reflect localStorage without
// a flash of "logged out" content, and it keeps this in sync across tabs.
function subscribe(onStoreChange: () => void) {
  window.addEventListener("storage", onStoreChange);
  window.addEventListener(LOCAL_CHANGE_EVENT, onStoreChange);
  return () => {
    window.removeEventListener("storage", onStoreChange);
    window.removeEventListener(LOCAL_CHANGE_EVENT, onStoreChange);
  };
}

function getSnapshot() {
  return window.localStorage.getItem(STORAGE_KEY);
}

function getServerSnapshot() {
  return null;
}

function parseStoredAuth(raw: string | null): StoredAuth | null {
  if (!raw) return null;
  try {
    return JSON.parse(raw) as StoredAuth;
  } catch {
    return null;
  }
}

function writeStoredAuth(next: StoredAuth | null) {
  if (next) {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  } else {
    window.localStorage.removeItem(STORAGE_KEY);
  }
  window.dispatchEvent(new Event(LOCAL_CHANGE_EVENT));
}

interface AuthContextValue {
  user: User | null;
  token: string | null;
  company: Company | null;
  isAuthenticated: boolean;
  register: (payload: RegisterPayload) => Promise<User>;
  login: (payload: LoginPayload) => Promise<User>;
  logout: () => void;
  setCompany: (company: Company) => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const storedRaw = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
  const stored = useMemo(() => parseStoredAuth(storedRaw), [storedRaw]);

  const register = useCallback(async (payload: RegisterPayload) => {
    const { token, user } = await registerUser(payload);
    writeStoredAuth({ token, user, company: null });
    return user;
  }, []);

  const login = useCallback(async (payload: LoginPayload) => {
    const { token, user } = await loginUser(payload);
    writeStoredAuth({ token, user, company: null });
    return user;
  }, []);

  const logout = useCallback(() => {
    writeStoredAuth(null);
  }, []);

  // Reads the current value straight from the store instead of closing
  // over `stored` from render, so this stays correct even if called a long
  // time after the component that created it last rendered.
  const setCompany = useCallback((nextCompany: Company) => {
    const current = parseStoredAuth(getSnapshot());
    if (current) {
      writeStoredAuth({ ...current, company: nextCompany });
    }
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      user: stored?.user ?? null,
      token: stored?.token ?? null,
      company: stored?.company ?? null,
      isAuthenticated: Boolean(stored?.token && stored?.user),
      register,
      login,
      logout,
      setCompany,
    }),
    [stored, register, login, logout, setCompany]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
