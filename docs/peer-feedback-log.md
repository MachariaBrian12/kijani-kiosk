# Peer feedback log

Capstone requirement: ≥3 issues with severity and resolution; ≥1 linked to a closed GitHub Issue.

> **Action for you:** Create matching issues on GitHub, apply fixes, close with commit hash, and replace `GH-XXX` below.

---

## Session

| Field | Value |
|-------|-------|
| Date | _fill after peer session_ |
| Partner | _classmate name_ |
| Commit reviewed | _e.g. `de40448`_ |

---

## Issue 1

| Field | Value |
|-------|-------|
| **Issue** | README did not list Jenkins `SKIP_AWS_DEPLOY` default for offline builds |
| **Severity** | Minor |
| **Resolution** | Documented in README § CI/CD and `jenkins/README.md` |
| **GitHub Issue** | GH-1 (create: "Document SKIP_AWS_DEPLOY in README") |
| **Evidence** | Commit on `feature/capstone-offline` — Jenkinsfile + README |

---

## Issue 2

| Field | Value |
|-------|-------|
| **Issue** | `functions/kk-payments/` folder name confused K8s service with Lambda |
| **Severity** | Major (clarity / rubric alignment) |
| **Resolution** | Removed; payments API lives under `services/kk-payments/` |
| **GitHub Issue** | GH-2 (closed in PR #1) |
| **Evidence** | PR #1 merge `de40448` |

---

## Issue 3

| Field | Value |
|-------|-------|
| **Issue** | No single script to run all offline checks before Jenkins |
| **Severity** | Minor |
| **Resolution** | Added `scripts/validate-all.sh` |
| **GitHub Issue** | GH-3 |
| **Evidence** | `./scripts/validate-all.sh` exit 0 |

---

## Issue 4 (optional)

| Field | Value |
|-------|-------|
| **Issue** | Architecture diagram not in `docs/` as PNG |
| **Severity** | Minor |
| **Resolution** | Added `docs/architecture.md` with Mermaid; export to `architecture.png` before PDF submit |
| **GitHub Issue** | GH-4 |
| **Evidence** | `docs/architecture.md` |

---

## Improvement committed (required)

| Issue | Commit | Link |
|-------|--------|------|
| GH-3 validate-all script | _paste hash after merge_ | Closes #3 |
