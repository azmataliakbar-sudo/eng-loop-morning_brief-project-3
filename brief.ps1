$progressFile = "progress.md"
$doneFile = "task-done.txt"
$srcDir = "src"

$startedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$now = $startedAt

$content = Get-Content $progressFile -Raw

# 1. How many TODOs were already seen before this run?
$seen = @()
if ($content -match '(?ms)## Seen TODOs\s*\n(?<block>.*?)\n## History') {
    $block = $Matches['block']
    if ($block -and $block.Trim().Length -gt 0) {
        $seen = $block.Trim() -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }
}
$historyBeforeCount = @($seen).Count

# 2. Find every TODO in src right now.
$files = Get-ChildItem -Path $srcDir -Recurse -Filter "*.js"
$allTODOs = @()
foreach ($f in $files) {
    $lineNum = 0
    foreach ($line in (Get-Content $f.FullName)) {
        $lineNum++
        if ($line -match 'TODO') {
            $allTODOs += "$($f.FullName):${lineNum}: $($line.Trim())"
        }
    }
}

# 3. Which ones are new?
$newTODOs = @($allTODOs | Where-Object { $seen -notcontains $_ })
$newCount = @($newTODOs).Count

# 4. Build a plain, true report of what happened.
if ($newCount -gt 0) {
    $action = "recorded $newCount new TODO(s) to the spine"
} else {
    $action = "recorded nothing new (the spine already knew every TODO)"
}

$historyLine = "- $now : history-before=$historyBeforeCount : new-found=$newCount : $action"

# 5. Keep all previous history lines, then add the new one.
$oldHistory = @()
if ($content -match '(?ms)## History\s*\n(?<h>.*)') {
    $h = $Matches['h']
    if ($h) {
        $oldHistory = $h.Trim() -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }
}
$newHistory = @($oldHistory) + @($historyLine)

# 6. Update the seen list.
$updatedSeen = @($seen) + @($newTODOs) | Where-Object { $_ -ne '' } | Sort-Object -Unique

$newContent = @"
# Morning Brief Progress

## Seen TODOs

$($updatedSeen -join "`r`n")

## History

$($newHistory -join "`r`n")
"@
Set-Content -Path $progressFile -Value $newContent

# 6. Append DONE-N to task-done.txt.
$existingDones = 0
if (Test-Path $doneFile) {
    $existingDones = (Get-Content $doneFile | Where-Object { $_ -match '^DONE-' }).Count
}
$nextDone = $existingDones + 1
"DONE-$nextDone at $now" | Add-Content -Path $doneFile

# 7. Write the numbered SUMMARY.
$existingSummaries = Get-ChildItem -Filter "SUMMARY*.md" -ErrorAction SilentlyContinue
$nextSummary = $existingSummaries.Count + 1
$summaryFile = "SUMMARY$nextSummary.md"

$summaryLines = @(
    "Run: $nextSummary"
    "Started: $startedAt"
    "Finished: $now"
    "History before this run: $historyBeforeCount TODO(s)"
    "New TODOs found this run: $newCount"
    "Action: $action"
)

if ($newCount -gt 0) {
    $summaryLines += "New TODOs recorded:"
    $summaryLines += $newTODOs | ForEach-Object { "  - $_" }
} else {
    $summaryLines += "New TODOs recorded: none"
}

$summaryLines += "Spine (history line just written):"
$summaryLines += "  $historyLine"

Set-Content -Path $summaryFile -Value $summaryLines

# 8. Print the full story in the console.
Write-Output "===== Morning Brief ====="
Write-Output "Run: $nextSummary"
Write-Output "History before this run: $historyBeforeCount TODO(s) already seen"
Write-Output "New TODOs found this run: $newCount"
Write-Output "Action: $action"
Write-Output "Wrote task-done.txt -> DONE-$nextDone"
Write-Output "Wrote $summaryFile"
Write-Output "========================"
