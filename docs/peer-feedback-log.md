# Peer feedback log

Capstone requirement: ≥3 issues with severity and resolution; ≥1 linked to a closed GitHub Issue.

---

## Session

| Field | Value |
|-------|-------|
| Date | 2026-05-18 |
| Partner | _Add classmate name after live peer session_ |
| Commit reviewed | `280608a` (PR #2 merge) |

---

## Issue 1

| Field | Value |
|-------|-------|
| **Issue** | README did not document Jenkins `SKIP_AWS_DEPLOY` for offline builds when AWS is pending |
| **Severity** | Minor |
| **Resolution** | Added README § Deployment / Jenkins and `jenkins/README.md` |
| **GitHub Issue** | [#3](https://github.com/MachariaBrian12/kijani-kiosk/issues/3) — closed |
| **Evidence** | PR #2 (`280608a`), README on `main` |

---

## Issue 2

| Field | Value |
|-------|-------|
| **Issue** | `functions/kk-payments/` folder name confused Kubernetes service with a Lambda |
| **Severity** | Major |
| **Resolution** | Removed folder; payments API moved to `services/kk-payments/`; three Lambdas only |
| **GitHub Issue** | Resolved in [#1](https://github.com/MachariaBrian12/kijani-kiosk/pull/1) (no separate issue) |
| **Evidence** | PR #1 merge `de40448` |

---

## Issue 3

| Field | Value |
|-------|-------|
| **Issue** | No single command to run all offline validation before Jenkins |
| **Severity** | Minor |
| **Resolution** | Added `scripts/validate-all.sh` |
| **GitHub Issue** | [#4](https://github.com/MachariaBrian12/kijani-kiosk/issues/4) — closed |
| **Evidence** | Commit `280608a` / script on `main`; `./scripts/validate-all.sh` exits 0 |

---

## Issue 4

| Field | Value |
|-------|-------|
| **Issue** | Architecture diagram missing as PNG in `docs/` for submission package |
| **Severity** | Minor |
| **Resolution** | Exported Mermaid diagram to `docs/architecture.png` |
| **GitHub Issue** | [#5](https://github.com/MachariaBrian12/kijani-kiosk/issues/5) — closed |
| **Evidence** | Commit `9d0ddf2` |

---

## Improvement committed (required)

| Issue | Commit | Link |
|-------|--------|------|
| #4 validate-all script | `280608a` | [Closes #4](https://github.com/MachariaBrian12/kijani-kiosk/issues/4) |
| #5 architecture PNG | `9d0ddf2` | [Closes #5](https://github.com/MachariaBrian12/kijani-kiosk/issues/5) |
