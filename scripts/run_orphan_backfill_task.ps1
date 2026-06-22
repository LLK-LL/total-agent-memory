$ErrorActionPreference = "Continue"

$root = "C:\Users\Administrator\total-agent-memory"
$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$env:TAM_MEMORY_DIR = "C:\Users\Administrator\.tam"
$env:PYTHONIOENCODING = "utf-8"

$python = Join-Path $root ".venv\Scripts\python.exe"
$script = Join-Path $root "src\tools\backfill_orphan_edges.py"
$stdout = Join-Path $logDir "orphan_backfill.out.log"
$stderr = Join-Path $logDir "orphan_backfill.err.log"

Set-Location $root
$proc = Start-Process -FilePath $python -ArgumentList @($script, "--min-mentions=1", "--limit=500", "--trigger-now") -WorkingDirectory $root -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
exit $proc.ExitCode
