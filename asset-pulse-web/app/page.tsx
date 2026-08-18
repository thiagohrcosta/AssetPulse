"use client";
// Client Component: the only thing this route does is decide where to send
// the visitor based on the localStorage-backed auth session, so it can't
// be resolved on the server.

import { useEffect } from "react";
import { useRouter } from "next/navigation";

import { useAuth } from "@/context/auth-context";

export default function Home() {
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    router.replace(isAuthenticated ? "/dashboard" : "/register");
  }, [isAuthenticated, router]);

  return null;
}
