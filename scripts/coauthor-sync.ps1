<#
.SYNOPSIS
    Co-authored commit and PR attribution verification runner.
#>
param(
    [int]$Count = 5,
    [string]$Owner = "ZXD44",
    [string]$Repo = "gitops-workflow-lab",
    [string]$CoAuthor = "octocat <583231+octocat@users.noreply.github.com>"
)

$ErrorActionPreference = "Stop"
$token = (gh auth token).Trim()
if (-not $token) { throw "gh auth token is empty" }

$headers = @{
    "Authorization"        = "Bearer $token"
    "Accept"               = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
    "User-Agent"           = "GitOps-Workflow-Lab"
}
$baseUrl = "https://api.github.com/repos/$Owner/$Repo"

$logPath = "logs/coauthor-sync.md"
for ($i = 1; $i -le $Count; $i++) {
    $ts = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $branch = "ci/coauthor-$ts-$i"

    $mainSha = (Invoke-RestMethod -Uri "$baseUrl/git/ref/heads/main" -Headers $headers).object.sha
    $file = Invoke-RestMethod -Uri "$baseUrl/contents/${logPath}?ref=main" -Headers $headers
    $oldText = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($file.content))
    $newText = $oldText + "`n- Co-author sync check #$i ($ts)"

    Invoke-RestMethod -Method POST -Uri "$baseUrl/git/refs" -Headers $headers -ContentType "application/json" -Body (@{
        ref = "refs/heads/$branch"
        sha = $mainSha
    } | ConvertTo-Json) | Out-Null

    $msg = "feat(sync): co-author attribution check #$i`n`nCo-authored-by: $CoAuthor"
    Invoke-RestMethod -Method PUT -Uri "$baseUrl/contents/$logPath" -Headers $headers -ContentType "application/json" -Body (@{
        message = $msg
        content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($newText))
        sha     = $file.sha
        branch  = $branch
    } | ConvertTo-Json) | Out-Null

    $pr = Invoke-RestMethod -Method POST -Uri "$baseUrl/pulls" -Headers $headers -ContentType "application/json" -Body (@{
        title = "feat(sync): co-author attribution check #$i"
        head  = $branch
        base  = "main"
    } | ConvertTo-Json)

    Start-Sleep -Milliseconds 600
    Invoke-RestMethod -Method PUT -Uri "$baseUrl/pulls/$($pr.number)/merge" -Headers $headers -ContentType "application/json" -Body (@{
        merge_method = "merge"
    } | ConvertTo-Json) | Out-Null

    try { Invoke-RestMethod -Method DELETE -Uri "$baseUrl/git/refs/heads/$branch" -Headers $headers | Out-Null } catch {}
    Write-Host "[$i/$Count] Merged PR #$($pr.number)"
    Start-Sleep -Milliseconds 600
}
