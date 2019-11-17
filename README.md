# Powershell Useful Commands

## PowerShell Frequently useful commands
### Get PowerShell Version
```
Get-Host | Select-Object Version
```
or
```
$PSVersionTable
```
### Get Hostory
```
$Get-History
```
or
```
# to not show the repetitive commands inside your command history
$Get-History | Get-Unique 
```

### Command output / Console / log a string 
```
Write-Host ("Hello-World")
```

### Command output / Console / log in a new line 
```
Write-Host ("Hello `n World")
```

### Search for a Folder inside a dir 
```
Get-ChildItem dir\path\Where\a\file\to\be\found -Filter *matchingPattern* -Directory
```

### Search to get matched Folder inside a dir & its sub dir 
```
Get-ChildItem dir\path\Where\a\file\to\be\found -Recurse *expression to match* -Directory
```

### Get all the properties of a matched Folder / File 
```
Get-ChildItem pathOfTheFile -Recurse *expression to match* | Format-List * -force
```

### Find all available options of a Folder / File 
```
Get-ChildItem pathOfTheFile -Recurse *expression to match* | Get-Member
```

### To get one of the properties EG: FullName of a matched Folder / File 
```
(Get-ChildItem pathOfTheFile -Filter *expression to match**).FullName 
```

##
##
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

