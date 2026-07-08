# Earlier Build — Audit & Provenance

Last updated: 2026-07-08

Purpose: document what came from the earlier build vs. the 2026-07-06 verification
session, and flag anything that is **not required** — **without deleting anything**. The
earlier build is kept as-is.

## Headline finding

**The earlier build is clean and functional — almost everything in it is required.**
There is no committed build junk (no `node_modules`, no `.next/`, no `dist/`; 289 tracked
files total). `pubspec.lock` is correctly committed (Flutter recommends it for apps). I
did **not** find dead code, mock/stub data, or duplicate scaffolding worth removing.

## Provenance — what changed and when

Commit `c1cece4` (Initial commit) is the earlier build. On top of it:

### Commit `6c92d96` — 2026-07-06 verification session
Two kinds of change landed in this one commit:

**A. Edits made in the 2026-07-06 session (intentional):**
| File | Change |
|---|---|
| `packages/scraper/src/ai/claude-normaliser.ts` | model → `claude-sonnet-5`, thinking disabled |
| `.../screens/splash_screen.dart` | lint fixes |
| `.../home/screens/home_screen.dart` | lint fixes |
| `.../profile/screens/subscription_screen.dart` | lint fixes |
| `docs/API.md`, `ARCHITECTURE.md`, `SCRAPER.md` | new docs |
| `docs/BUILD_PROGRESS.md` | session log |

**B. Pre-existing uncommitted changes from the earlier build (swept into the same commit,
not authored in the 2026-07-06 session):**
| File | Lines |
|---|---|
| `.../onboarding/screens/store_selection_screen.dart` | 211 |
| `.../onboarding/screens/category_selection_screen.dart` | 198 |
| `apps/mobile/lib/main.dart` | 16 |
| `.../auth/.../register_screen.dart` | 13 |
| `.../onboarding/providers/onboarding_provider.dart` | 20 |
| `.../auth/.../login_screen.dart` | 6 |
| `.../core/services/supabase_service.dart` | 5 |
| `.../core/services/ad_service.dart` | 2 |
| `.../core/services/notification_service.dart` | 1 |

These (Group B) were already modified in the working folder before the session began.
They are part of the working build (the clean `flutter analyze` included them). **Nothing
was overwritten or discarded** — they are preserved in the commit history. Review any with
`git show 6c92d96 -- <path>`.

### Commit `9098d4a` — added `docs/TESTING.md`.

## Not required (candidates only — NOT removed)

After scanning, the only genuine candidate is minor and intentionally **kept**:

| Item | Why it's a candidate | Decision |
|---|---|---|
| `apps/mobile/lib/features/auth/data/auth_repository.dart` | 1-line barrel that only re-exports `auth_provider.dart` — adds an indirection with no logic | **Kept.** It satisfies the required `features/*/data/` folder convention and is harmless. Remove only if you drop that convention. |

Things that *looked* redundant but are **required** (verified, keeping):
- `apps/admin/lib/data.ts` — **not** mock data; runs real Supabase queries, imported by all
  8 admin pages.
- The 15 one-line scraper files (`woolworths.ts` … `ikea-au.ts`) — each registers a
  retailer via the factory; all used by the scheduler.
- All iOS/Android/macOS/Linux platform scaffolding under `apps/mobile/` — required by
  Flutter to build for each target.

## Bottom line

Nothing was deleted. The earlier build stands as-is. The only bookkeeping caveat is that
Group B (pre-existing onboarding-screen work, ~400 lines) shares commit `6c92d96` with the
session's own edits — if you want those isolated in history, say so and they can be split
out; otherwise no action is needed.
