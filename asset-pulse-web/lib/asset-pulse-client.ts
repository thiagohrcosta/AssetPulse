import { AssetPulseClient } from "@thiagohrcosta/assetpulse-sdk";

// Thin factory around the SDK: the app's own lib/api.ts (fetch + zod) keeps
// covering auth/companies/plans/subscriptions, but resources the SDK
// already models (parts, host units, lifecycle events) should go through
// AssetPulseClient instead of hand-rolled fetch calls — that's what it's
// for. Token/companyId come from the AuthContext (see useAuth), never
// stored on the client itself, so a fresh instance is cheap to build
// per-render/effect.
export function createAssetPulseClient(token: string, companyId: number): AssetPulseClient {
  return new AssetPulseClient({ token, companyId });
}
