$ErrorActionPreference = "Continue"

$root = "C:\Users\Administrator\total-agent-memory"
$logDir = Join-Path $root "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$env:TAM_MEMORY_DIR = "C:\Users\Administrator\.tam"
$env:PYTHONIOENCODING = "utf-8"
$authPath = "C:\Users\Administrator\.codex\auth.json"
if (Test-Path -LiteralPath $authPath) {
    $auth = Get-Content -LiteralPath $authPath -Raw | ConvertFrom-Json
    if ($auth.OPENAI_API_KEY) {
        $env:MEMORY_LLM_PROVIDER = "openai"
        $env:MEMORY_LLM_API_BASE = "https://api.0029.org/v1"
        $env:MEMORY_LLM_API_KEY = [string]$auth.OPENAI_API_KEY
        $env:MEMORY_LLM_MODEL = "gpt-5.4-mini"
        $env:MEMORY_TRIPLE_PROVIDER = "openai"
        $env:MEMORY_ENRICH_PROVIDER = "openai"
        $env:MEMORY_REPR_PROVIDER = "openai"
        $env:MEMORY_TRIPLE_DRAIN_LIMIT = "5"
        $env:MEMORY_ENRICH_DRAIN_LIMIT = "5"
    }
}

$python = Join-Path $root ".venv\Scripts\python.exe"
$script = Join-Path $root "src\tools\run_reflection.py"
$stdout = Join-Path $logDir "reflection.out.log"
$stderr = Join-Path $logDir "reflection.err.log"

Set-Location $root
$proc = Start-Process -FilePath $python -ArgumentList @($script, "--scope=auto") -WorkingDirectory $root -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
exit $proc.ExitCode
