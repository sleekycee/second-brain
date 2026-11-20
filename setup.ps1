# Second brain setup for Claude Code and Codex (Windows PowerShell 5.1+ or PowerShell 7).
# Usage: powershell -ExecutionPolicy Bypass -File .\setup.ps1 [-BrainDir <folder>] [-WithHook]
# Default folder: <home>\secondbrain  (kept out of Documents so OneDrive does not sync it)
#   -WithHook   also install the optional Claude Code nudge hook (needs Python 3)
# Safe to run twice: existing files are never overwritten.
param(
    [string]$BrainDir = (Join-Path $HOME 'secondbrain'),
    [switch]$WithHook
)
$ErrorActionPreference = 'Stop'

$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Utf8 = New-Object System.Text.UTF8Encoding $false   # no BOM: keeps JSON and markdown clean

New-Item -ItemType Directory -Force -Path $BrainDir, $ClaudeDir | Out-Null
$BrainDir = (Resolve-Path -LiteralPath $BrainDir).Path.TrimEnd('\', '/')
$HomeDir = $HOME.TrimEnd('\', '/')

# Path as written into the files: ~/... when the brain is under the home folder.
if ($BrainDir.StartsWith($HomeDir + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    $Shown = '~' + $BrainDir.Substring($HomeDir.Length)
} else {
    $Shown = $BrainDir
}
$Shown = $Shown -replace '\\', '/'
if ($Shown -match '\s') {
    Write-Host "Pick a brain folder with no spaces in its path: $Shown" -ForegroundColor Red
    exit 1
}

# 1. Copy the template, filling in the brain path. Never overwrite.
$TemplateDir = Join-Path $Here 'template'
Get-ChildItem -LiteralPath $TemplateDir -Recurse -File -Force | ForEach-Object {
    $rel = $_.FullName.Substring($TemplateDir.Length + 1)
    $dest = Join-Path $BrainDir $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
    if (Test-Path -LiteralPath $dest) {
        Write-Host "kept     $rel"
    } else {
        $text = [IO.File]::ReadAllText($_.FullName).Replace('__BRAIN__', $Shown).Replace('__TODAY__', (Get-Date -Format 'yyyy-MM-dd'))
        [IO.File]::WriteAllText($dest, $text, $Utf8)
        Write-Host "created  $rel"
    }
}

# A brain set up before the wiki rules existed keeps its own CLAUDE.md. Say how to upgrade it.
if (-not [IO.File]::ReadAllText((Join-Path $BrainDir 'CLAUDE.md')).Contains('wiki.md')) {
    Write-Host "note     your CLAUDE.md predates the wiki rules. To add them, tell your agent:"
    Write-Host "         `"Upgrade my second brain's CLAUDE.md to the wiki version from the second-brain repo.`""
}

# 2. Load the brain in every Claude Code session.
$Global = Join-Path $ClaudeDir 'CLAUDE.md'
if (-not (Test-Path -LiteralPath $Global)) { [IO.File]::WriteAllText($Global, '', $Utf8) }
foreach ($f in 'CLAUDE.md', 'index.md') {
    $line = "@$Shown/$f"
    if (@([IO.File]::ReadAllLines($Global)) -notcontains $line) {
        [IO.File]::AppendAllText($Global, "`n$line`n", $Utf8)
    }
}
Write-Host "imports  $Global"

# 2b. Codex, if installed. AGENTS.md has no import syntax, so add a pointer instead.
$CodexDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
if (Test-Path -LiteralPath $CodexDir -PathType Container) {
    $Agents = Join-Path $CodexDir 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $Agents)) { [IO.File]::WriteAllText($Agents, '', $Utf8) }
    $BrainFwd = $BrainDir -replace '\\', '/'
    if (-not [IO.File]::ReadAllText($Agents).Contains("$BrainFwd/CLAUDE.md")) {
        [IO.File]::AppendAllText($Agents, "`n## Second brain`n`nMy second brain is at $BrainFwd/. At the start of every session, read $BrainFwd/CLAUDE.md and $BrainFwd/index.md and follow them.`n", $Utf8)
    }
    Write-Host "codex    $Agents"
}

# 3. Let any session read and write the brain without permission prompts,
#    and register the optional nudge hook when asked.
$HookCmd = ''
if ($WithHook) {
    $Python = @('python3', 'python', 'py') | Where-Object { Get-Command $_ -ErrorAction SilentlyContinue } | Select-Object -First 1
    if (-not $Python) {
        Write-Warning 'Python 3 not found, so the nudge hook was skipped. Install Python and run this again with -WithHook.'
    } else {
        $HooksDir = Join-Path $ClaudeDir 'hooks'
        New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
        $HookFile = Join-Path $HooksDir 'brain-nudge.py'
        Copy-Item -LiteralPath (Join-Path $Here 'extras/brain-nudge.py') -Destination $HookFile -Force
        # Forward slashes: valid on Windows and safe in both bash and PowerShell hook shells.
        $HookCmd = "$Python `"$($HookFile -replace '\\', '/')`" `"$($BrainDir -replace '\\', '/')`""
    }
}
$Settings = Join-Path $ClaudeDir 'settings.json'
try {
    $obj = [pscustomobject]@{}
    if ((Test-Path -LiteralPath $Settings) -and (Get-Item -LiteralPath $Settings).Length -gt 0) {
        $obj = [IO.File]::ReadAllText($Settings) | ConvertFrom-Json   # invalid JSON throws, file left untouched
        Copy-Item -LiteralPath $Settings -Destination "$Settings.bak" -Force
    }
    if (-not $obj.PSObject.Properties['permissions']) {
        $obj | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{})
    }
    $perm = $obj.permissions
    if (-not $perm.PSObject.Properties['additionalDirectories']) {
        $perm | Add-Member -NotePropertyName additionalDirectories -NotePropertyValue @()
    }
    $changed = $false
    $dirs = @($perm.additionalDirectories)
    if ($dirs -notcontains $BrainDir) {
        $perm.additionalDirectories = @($dirs + $BrainDir)
        $changed = $true
    }
    if ($HookCmd) {
        if (-not $obj.PSObject.Properties['hooks']) {
            $obj | Add-Member -NotePropertyName hooks -NotePropertyValue ([pscustomobject]@{})
        }
        $hooks = $obj.hooks
        if (-not $hooks.PSObject.Properties['Stop']) {
            $hooks | Add-Member -NotePropertyName Stop -NotePropertyValue @()
        }
        $stops = @($hooks.Stop)
        $installed = $false
        foreach ($group in $stops) {
            foreach ($h in @($group.hooks)) {
                if ("$($h.command)" -like '*brain-nudge.py*') {
                    if (-not $installed -and $h.command -cne $HookCmd) {
                        $h.command = $HookCmd   # already installed: repoint it at this brain
                        $changed = $true
                    }
                    $installed = $true
                }
            }
        }
        if (-not $installed) {
            $entry = [pscustomobject]@{ hooks = @([pscustomobject]@{ type = 'command'; command = $HookCmd; timeout = 10 }) }
            $hooks.Stop = @($stops + $entry)
            $changed = $true
        }
    }
    if ($changed) {
        $tmp = "$Settings.tmp"
        [IO.File]::WriteAllText($tmp, ($obj | ConvertTo-Json -Depth 100) + "`n", $Utf8)
        Move-Item -LiteralPath $tmp -Destination $Settings -Force
    }
    Write-Host "allowed  $Settings"
    if ($HookCmd) { Write-Host "hook     $HookFile" }
} catch {
    Write-Warning "Could not update $Settings automatically: $($_.Exception.Message)"
    Write-Warning "Add `"$BrainDir`" to permissions.additionalDirectories in that file by hand."
    if ($HookCmd) { Write-Warning 'The nudge hook was not registered. See the README to add it by hand.' }
}

Write-Host ""
Write-Host "Second brain ready at $Shown"
Write-Host "Next: open a NEW agent session in any folder and say:"
Write-Host "  run the setup interview"
