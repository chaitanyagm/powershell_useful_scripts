# Powershell Useful Scripts

## PowerShell Frequently useful commands
### Get PowerShell Version
```
Get-Host | Select-Object Version
```
or
```
$PSVersionTable
```
### Command output / Console / log a string 
```
Write-Host ("Hello-World")
```

### Command output / Console / log in a new line 
```
Write-Host ("Hello `n World")
```

## PowerShell remote management
Thanks to [this article](https://4sysops.com/archives/use-powershell-invoke-command-to-run-scripts-on-remote-computers/) from where I've got these commands from.

### To invoke powershell cmds on remote machines
```
Invoke-Command -Computername $RemoteComputer -ScriptBlock { Get-ChildItem "C:\Program Files" }
```

### To invoke powershell cmds on multiple remote machines
```
Invoke-Command -ComputerName PC1,PC2,PC3 -FilePath C:\myFolder\myScript.ps1
```

### Test commection first & invoke powershell cmds on multiple remote machines
```
If (Test-Connection -ComputerName $RemoteComputers -Quiet)
{
     Invoke-Command -ComputerName $RemoteComputers -ScriptBlock {Get-ChildItem “C:\Program Files”}
}
```
```
# If invoke fails, failed computer will be added to a txt file
$RemoteComputers = @("PC1","PC2")
ForEach ($Computer in $RemoteComputers)
{
     Try
         {
             Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ChildItem "C:\Program Files"} -ErrorAction Stop
         }
     Catch
         {
             Add-Content Unavailable-Computers.txt $Computer
         }
}
```

