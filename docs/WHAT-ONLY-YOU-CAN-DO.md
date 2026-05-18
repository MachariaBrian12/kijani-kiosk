# What only you can do (≈30 minutes)

Everything else is in the repo. These three items need **you**:

1. **Open evidence page and screenshot or Loom (10 min)**
   ```bash
   cd ~/kijani-kiosk && git pull
   open docs/demo-evidence/DEMO-EVIDENCE.html
   ```
   Record Loom while scrolling, or screenshot the approval section.

2. **Peer review — add classmate name (15 min)**
   - Partner runs `./scripts/validate-all.sh`
   - Edit `docs/peer-feedback-log.md` → fill **Partner:** name
   - `git commit -m "docs: peer review partner name" && git push`

3. **Paste into LMS (5 min)**
   - Use `docs/SUBMISSION.md` copy block
   - Add Loom link or upload screenshots from `docs/demo-evidence/`
