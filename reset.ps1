Set-Content -Path "progress.md" -Value "# Morning Brief Progress`r`n`r`n## Seen TODOs`r`n`r`n## History`r`n"
if (Test-Path "task-done.txt") { Remove-Item "task-done.txt" }
Get-ChildItem -Filter "SUMMARY*.md" -ErrorAction SilentlyContinue | Remove-Item
Write-Output "Reset morning_brief. Run .\brief.ps1 to start."
