<#
.SYNOPSIS
    GraphQL Q&A Discussions automation helper.
#>
param(
    [int]$Count = 4,
    [string]$Owner = "ZXD44",
    [string]$Repo = "gitops-workflow-lab",
    [string]$AltToken = $env:ALT_GH_TOKEN
)

$ErrorActionPreference = "Stop"
if (-not $AltToken) { throw "ALT_GH_TOKEN is required" }
$MainToken = (gh auth token).Trim()
if (-not $MainToken) { throw "Main gh auth token is empty" }

function Invoke-GraphQL {
    param([string]$Token, [string]$Query, [hashtable]$Variables = @{})
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept"        = "application/vnd.github+json"
        "User-Agent"    = "GitOps-Workflow-Lab"
    }
    $body = @{ query = $Query; variables = $Variables } | ConvertTo-Json -Depth 6 -Compress
    $res = Invoke-RestMethod -Method POST -Uri "https://api.github.com/graphql" -Headers $headers -ContentType "application/json; charset=utf-8" -Body $body
    if ($res.errors) { throw ($res.errors | ConvertTo-Json -Compress) }
    return $res.data
}

$repoData = Invoke-GraphQL -Token $MainToken -Query @'
query($owner: String!, $repo: String!) {
  repository(owner: $owner, name: $repo) {
    id
    discussionCategories(first: 20) { nodes { id name isAnswerable } }
  }
}
'@ -Variables @{ owner = $Owner; repo = $Repo }

$repoId = $repoData.repository.id
$qaCat = $repoData.repository.discussionCategories.nodes | Where-Object { $_.isAnswerable -eq $true } | Select-Object -First 1
if (-not $qaCat) { throw "No answerable Q&A category found" }

$ts = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
for ($i = 1; $i -le $Count; $i++) {
    $d = Invoke-GraphQL -Token $AltToken -Query @'
mutation($repoId: ID!, $catId: ID!, $title: String!, $body: String!) {
  createDiscussion(input: {repositoryId: $repoId, categoryId: $catId, title: $title, body: $body}) {
    discussion { id number }
  }
}
'@ -Variables @{ repoId = $repoId; catId = $qaCat.id; title = "Q&A #$i ($ts): CI/CD Architecture"; body = "Automated workflow verification question #$i." }

    $c = Invoke-GraphQL -Token $MainToken -Query @'
mutation($discId: ID!, $body: String!) {
  addDiscussionComment(input: {discussionId: $discId, body: $body}) { comment { id } }
}
'@ -Variables @{ discId = $d.createDiscussion.discussion.id; body = "Verified response #$i: use idempotent retries with backoff." }

    Invoke-GraphQL -Token $AltToken -Query @'
mutation($commentId: ID!) {
  markDiscussionCommentAsAnswer(input: {id: $commentId}) { discussion { id } }
}
'@ -Variables @{ commentId = $c.addDiscussionComment.comment.id } | Out-Null

    Write-Host "[$i/$Count] Resolved Discussion #$($d.createDiscussion.discussion.number)"
    Start-Sleep -Milliseconds 500
}
