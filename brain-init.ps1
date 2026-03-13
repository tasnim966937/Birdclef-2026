<#
.SYNOPSIS
    Initialize Cursor Brain in the current project directory.
.DESCRIPTION
    Creates a brain/ folder with template files and a .cursor/rules/brain.mdc
    rule that gives the AI persistent memory across sessions.
.EXAMPLE
    brain-init
    Run in any project directory to set up the brain system.
#>

$projectDir = Get-Location

$brainDir = Join-Path $projectDir "brain"
$sessionsDir = Join-Path $brainDir "sessions"
$cursorRulesDir = Join-Path (Join-Path $projectDir ".cursor") "rules"
$ruleFile = Join-Path $cursorRulesDir "brain.mdc"

# Safety check: don't overwrite existing brain
if ((Test-Path (Join-Path $brainDir "progress.md")) -and (Test-Path $ruleFile)) {
    Write-Host "Brain already exists in this project." -ForegroundColor Yellow
    Write-Host "  brain/         -> $(Resolve-Path $brainDir)" -ForegroundColor DarkGray
    Write-Host "  brain.mdc rule -> $(Resolve-Path $ruleFile)" -ForegroundColor DarkGray
    exit 0
}

Write-Host "Initializing Cursor Brain..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Force -Path $brainDir | Out-Null
New-Item -ItemType Directory -Force -Path $sessionsDir | Out-Null
New-Item -ItemType Directory -Force -Path $cursorRulesDir | Out-Null

# --- brain.mdc rule ---
if (-not (Test-Path $ruleFile)) {
@"
---
description: Cursor Brain - persistent project memory across sessions. Reads brain/ on conversation start, supports update/search/stats/ask/recent commands.
alwaysApply: true
---

# Cursor Brain

You have access to a persistent memory system in the ``brain/`` folder of this project.

## On Conversation Start

1. Check if ``brain/`` folder exists in the project root.
2. If it does NOT exist, inform the user: "No brain folder found. Say **brain init** to create one, or run ``brain-init`` in your terminal."
3. If it exists, silently read these files (do NOT announce that you are reading them):
   - ``brain/progress.md`` (current project snapshot — always read this first)
   - The 2-3 most recent files in ``brain/sessions/`` (sorted by filename descending)
   - ``brain/project-context.md`` only if ``progress.md`` is empty or has only template placeholders
4. Use this context to inform your responses naturally. Do not mention the brain system unless the user asks about it.

## Commands

### "update brain"
1. OVERWRITE ``brain/progress.md`` entirely with a fresh snapshot containing:
   - **Current Status**: What the project state is right now
   - **Recently Completed**: What was accomplished in this session
   - **Next Steps**: What should be done next
   - **Active Issues**: Any unresolved problems or blockers
2. If significant decisions were made, APPEND to ``brain/decisions.md`` using this format:
   ``````
   ## YYYY-MM-DD: [Decision Title]
   **Choice**: What was chosen
   **Over**: What alternatives were considered
   **Because**: The rationale
   ``````

### "closing for today" or "update brain, closing for today"
1. Do everything from "update brain" above.
2. Additionally, WRITE or APPEND to ``brain/sessions/YYYY-MM-DD.md``:
   - **Summary**: 2-3 sentence overview of the day's work
   - **Files Modified**: List of files created or changed
   - **Key Changes**: What was built, fixed, or refactored
   - **Problems Solved**: Issues encountered and how they were resolved
   - **Open Questions**: Unresolved items for next session

### "brain search [query]"
Read through ALL files in ``brain/`` including all session files and decisions. Find and present entries relevant to the query with source file references.

### "brain stats"
Report: number of session files and their date range, number of decisions logged, last-updated date of progress.md, and an estimate of total brain content size.

### "brain recent"
Read and summarize the last 3-5 session files from ``brain/sessions/``.

### "brain ask [question]"
Read all brain files and answer the question using only the stored context. Cite which brain file each piece of the answer came from.

### "brain init"
Create the ``brain/`` folder with template files (``README.md``, ``project-context.md``, ``progress.md``, ``decisions.md``, ``sessions/``) if it does not already exist. Then ask the user to describe their project so you can fill in ``project-context.md``.

## Growth Rules

- ``progress.md`` is always OVERWRITTEN, not appended. It should never exceed ~50 lines.
- ``decisions.md`` is append-only. If it exceeds 100 entries, move older entries to ``brain/decisions-archive.md``.
- Session files are individual daily files. Only the last 2-3 are read on conversation start. Older ones are available via "brain search" and "brain recent".
- ``project-context.md`` is written once and updated only when the project fundamentally changes.
"@ | Set-Content -Path $ruleFile -Encoding UTF8
    Write-Host "  Created .cursor/rules/brain.mdc" -ForegroundColor Green
} else {
    Write-Host "  .cursor/rules/brain.mdc already exists, skipping" -ForegroundColor DarkGray
}

# --- brain/README.md ---
$readmePath = Join-Path $brainDir "README.md"
if (-not (Test-Path $readmePath)) {
@"
# Brain - Persistent Project Memory

This folder is your project's persistent memory for Cursor IDE. It stores context across sessions so the AI knows what you did before, what decisions were made, and where you left off.

## How It Works

A Cursor rule (``.cursor/rules/brain.mdc``) automatically reads this folder at the start of every conversation and uses it to inform responses.

## Files

| File | Purpose | Growth |
|------|---------|--------|
| ``project-context.md`` | Project name, stack, goals, structure | Written once, rarely updated |
| ``progress.md`` | Current status, recent work, next steps | Overwritten each update (never grows) |
| ``decisions.md`` | Key decisions with rationale | Append-only, archived when large |
| ``sessions/YYYY-MM-DD.md`` | Daily session summaries | One file per day |

## Commands

Say any of these in a Cursor chat:

- **"update brain"** — Save current progress snapshot
- **"closing for today"** — Full update + write daily session log
- **"brain search [query]"** — Search all stored context
- **"brain stats"** — Show brain health and metrics
- **"brain recent"** — Show last few session summaries
- **"brain ask [question]"** — Ask a question answered from stored context
"@ | Set-Content -Path $readmePath -Encoding UTF8
    Write-Host "  Created brain/README.md" -ForegroundColor Green
}

# --- brain/project-context.md ---
$contextPath = Join-Path $brainDir "project-context.md"
if (-not (Test-Path $contextPath)) {
@"
# Project Context

## Project Name
<!-- What is this project called? -->

## Description
<!-- One paragraph: what does this project do? -->

## Tech Stack
<!-- Languages, frameworks, databases, tools -->

## Project Structure
<!-- Key folders and their purposes -->

## Goals
<!-- What are you building toward? -->

## Conventions
<!-- Any coding standards, naming conventions, or patterns to follow -->
"@ | Set-Content -Path $contextPath -Encoding UTF8
    Write-Host "  Created brain/project-context.md" -ForegroundColor Green
}

# --- brain/progress.md ---
$progressPath = Join-Path $brainDir "progress.md"
if (-not (Test-Path $progressPath)) {
@"
# Progress

## Current Status
<!-- What state is the project in right now? -->

## Recently Completed
<!-- What was just done? -->

## Next Steps
<!-- What should be done next? -->

## Active Issues
<!-- Any unresolved problems or blockers? -->
"@ | Set-Content -Path $progressPath -Encoding UTF8
    Write-Host "  Created brain/progress.md" -ForegroundColor Green
}

# --- brain/decisions.md ---
$decisionsPath = Join-Path $brainDir "decisions.md"
if (-not (Test-Path $decisionsPath)) {
@"
# Decisions Log

<!-- Append new decisions at the top. Format:

## YYYY-MM-DD: [Decision Title]
**Choice**: What was chosen
**Over**: What alternatives were considered
**Because**: The rationale

-->
"@ | Set-Content -Path $decisionsPath -Encoding UTF8
    Write-Host "  Created brain/decisions.md" -ForegroundColor Green
}

# --- brain/sessions/.gitkeep ---
$gitkeepPath = Join-Path $sessionsDir ".gitkeep"
if (-not (Test-Path $gitkeepPath)) {
    New-Item -ItemType File -Force -Path $gitkeepPath | Out-Null
    Write-Host "  Created brain/sessions/" -ForegroundColor Green
}

Write-Host ""
Write-Host "Cursor Brain initialized!" -ForegroundColor Green
Write-Host ""
Write-Host "Structure:" -ForegroundColor White
Write-Host "  .cursor/rules/brain.mdc   <- AI rule (reads brain on every chat)" -ForegroundColor DarkGray
Write-Host "  brain/project-context.md  <- Describe your project here" -ForegroundColor DarkGray
Write-Host "  brain/progress.md         <- Auto-updated status snapshot" -ForegroundColor DarkGray
Write-Host "  brain/decisions.md        <- Decision log" -ForegroundColor DarkGray
Write-Host "  brain/sessions/           <- Daily session logs" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next: Open a Cursor chat and the AI will read your brain automatically." -ForegroundColor Cyan
Write-Host "Say 'update brain' to save progress, 'closing for today' to log a session." -ForegroundColor Cyan
