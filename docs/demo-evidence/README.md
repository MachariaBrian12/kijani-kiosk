# Demo evidence package

Pre-generated logs for capstone submission (offline, no AWS).

| File | Contents |
|------|----------|
| `01-npm-test.log` | Unit tests passing |
| `02-fault-handling.log` | Invalid receipt rejected |
| `03-validate-all.log` | Pipeline run summary |
| `pipeline-run.log` | Full offline pipeline incl. **approval reason** |
| `DEMO-EVIDENCE.html` | Open in browser → screenshot for LMS |

## View evidence page

```bash
open docs/demo-evidence/DEMO-EVIDENCE.html
```

Screenshot the page (or print to PDF via browser) for your pipeline demo deliverable.

## Regenerate on your Mac (full log)

```bash
cd ~/kijani-kiosk
APPROVAL_REASON="Your reason here" ./scripts/run-pipeline-offline-demo.sh
./scripts/generate-demo-evidence-html.sh
open docs/demo-evidence/DEMO-EVIDENCE.html
```

## Jenkins UI (optional extra)

If Jenkins is running, also capture the **Production approval** screen from the web UI. Port 8080 on this machine may not be Jenkins — check your Jenkins URL.
