<#
.SYNOPSIS
    Rate-limit-resilient REST API Pull Request lifecycle runner.
#>
param(
    [int]$Count = 10,
    [int]$DelayMs = 1500,
    [string]$Owner = "ZXD44",
    [string]$Repo = "gitops-workflow-lab"
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

function Invoke-GhApi {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null
    )
    $maxRetries = 6
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            $params = @{
                Method      = $Method
                Uri         = $Uri
                Headers     = $headers
                ContentType = "application/json; charset=utf-8"
            }
            if ($null -ne $Body) {
                $params.Body = ($Body | ConvertTo-Json -Depth 5 -Compress)
            }
            return Invoke-RestMethod @params
        } catch {
            $status = $null
            if ($_.Exception.Response) {
                $status = [int]$_.Exception.Response.StatusCode
            }
            if ($status -in @(403, 429)) {
                $wait = 30 * $attempt
                Write-Warning "Rate limited ($status) on $Uri. Sleeping ${wait}s (attempt $attempt/$maxRetries)..."
                Start-Sleep -Seconds $wait
            } elseif ($status -in @(405, 409, 422, 500, 502, 503) -and $attempt -lt $maxRetries) {
                Start-Sleep -Seconds (2 * $attempt)
            } else {
                throw
            }
        }
    }
    throw "Exhausted retries on $Method $Uri"
}

$tickPath = "logs/runner-tick.txt"
$merged = 0
for ($i = 1; $i -le $Count; $i++) {
    $ts = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $branch = "ci/lifecycle-$ts-$i"

    $mainRef = Invoke-GhApi -Method "GET" -Uri "$baseUrl/git/ref/heads/main"
    $mainSha = $mainRef.object.sha

    $tickFile = Invoke-GhApi -Method "GET" -Uri "$baseUrl/contents/${tickPath}?ref=main"
    $tickSha = $tickFile.sha

    Invoke-GhApi -Method "POST" -Uri "$baseUrl/git/refs" -Body @{
        ref = "refs/heads/$branch"
        sha = $mainSha
    } | Out-Null

    $contentB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("tick $i $ts"))
    Invoke-GhApi -Method "PUT" -Uri "$baseUrl/contents/$tickPath" -Body @{
        message = "chore(ci): lifecycle tick #$i [skip ci]"
        content = $contentB64
        sha     = $tickSha
        branch  = $branch
    } | Out-Null

    $pr = Invoke-GhApi -Method "POST" -Uri "$baseUrl/pulls" -Body @{
        title = "chore(ci): lifecycle tick #$i"
        head  = $branch
        base  = "main"
        body  = "Automated CI lifecycle verification #$i."
    }

    Start-Sleep -Milliseconds 600
    Invoke-GhApi -Method "PUT" -Uri "$baseUrl/pulls/$($pr.number)/merge" -Body @{
        merge_method = "merge"
    } | Out-Null

    try {
        Invoke-GhApi -Method "DELETE" -Uri "$baseUrl/git/refs/heads/$branch" | Out-Null
    } catch {
        # Branch may already be auto-deleted
    }

    $merged++
    if ($i % 25 -eq 0 -or $i -eq $Count) {
        Write-Host "[$merged/$Count] Merged PR #$($pr.number)"
    }
    Start-Sleep -Milliseconds $DelayMs
}

Write-Host "Completed $merged / $Count lifecycle PRs."
