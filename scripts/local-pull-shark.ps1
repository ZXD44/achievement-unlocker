<#
.SYNOPSIS
    Local Batch Pull Request and Auto-Merge Generator for Pull Shark
.PARAMETER Count
    Number of PRs to create and merge
#>
param(
    [int]$Count = 5
)

$ErrorActionPreference = "Stop"

Write-Host "Starting Pull Shark batch generator ($Count iterations)..." -ForegroundColor Cyan

for ($i = 1; $i -le $Count; $i++) {
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $branchName = "shark-local-$timestamp-$i"
    
    Write-Host "[$i/$Count] Creating branch $branchName..."
    git checkout -b $branchName main | Out-Null
    
    $logLine = "Local Pull Shark checkpoint #$i at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"
    Add-Content -Path "PULL_SHARK_LOG.txt" -Value $logLine
    git add PULL_SHARK_LOG.txt
    git commit -m "chore: local pull shark record $i [skip ci]" | Out-Null
    
    Write-Host "[$i/$Count] Pushing branch..."
    git push origin $branchName | Out-Null
    
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "[$i/$Count] Creating PR via gh CLI..."
        $prUrl = gh pr create --base main --head $branchName --title "feat: pull shark step $i" --body "Batch progression test $i"
        gh pr merge $prUrl --merge --delete-branch
        Write-Host "[$i/$Count] Merged: $prUrl" -ForegroundColor Green
    } else {
        Write-Host "[$i/$Count] Branch pushed to remote. Open and merge PR on GitHub or install gh CLI." -ForegroundColor Yellow
    }
    
    git checkout main | Out-Null
    git pull origin main | Out-Null
}

Write-Host "Done!" -ForegroundColor Green
