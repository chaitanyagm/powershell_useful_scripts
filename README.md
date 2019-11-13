# powershell_useful_scripts

## PowerShell remote management

### To invoke powershell cmds on remote machines
```
Invoke-Command -Computername $RemoteComputer -ScriptBlock { Get-ChildItem "C:\Program Files" }
```
