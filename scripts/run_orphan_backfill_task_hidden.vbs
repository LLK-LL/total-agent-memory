Set shell = CreateObject("WScript.Shell")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Users\Administrator\total-agent-memory\scripts\run_orphan_backfill_task.ps1"""
code = shell.Run(cmd, 0, True)
WScript.Quit code
