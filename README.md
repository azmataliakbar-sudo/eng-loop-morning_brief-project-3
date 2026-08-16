# morning_brief

Project 3 from the Loop Engineering crash course.

## Run

```powershell
.\brief.ps1
```

Run it twice. The second run should find 0 new TODOs.

## What it does

- Reads `progress.md` (the spine).
- Scans `src` for `TODO` comments.
- Reports only new TODOs.
- Updates `progress.md` with the date and findings.
- Appends `DONE-N at <time>` to `task-done.txt`.
- Creates `SUMMARYN.md`.
