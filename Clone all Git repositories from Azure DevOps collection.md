# Script to clone all Git repositories from your Azure DevOps collection

## 1. Create a new PowerShell script file
In the directory where you want to clone all repositories, create a new CloneAllRepos.ps1 script file with the following contents:
```
# Read configuration file
Get-Content "CloneAllRepos.config" | foreach-object -begin {$h=@{}} -process { 
    $k = [regex]::split($_,'='); 
    if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { 
        $h.Add($k[0], $k[1]) 
    } 
}
$url = $h.Get_Item("Url")
$username = $h.Get_Item("Username")
$password = $h.Get_Item("Password")

# Retrieve list of all repositories
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
$headers = @{
    "Authorization" = ("Basic {0}" -f $base64AuthInfo)
    "Accept" = "application/json"
}

Add-Type -AssemblyName System.Web
$gitcred = ("{0}:{1}" -f  [System.Web.HttpUtility]::UrlEncode($username),$password)

$resp = Invoke-WebRequest -Headers $headers -Uri ("{0}/_apis/git/repositories?api-version=1.0" -f $url)
$json = convertFrom-JSON $resp.Content

# Clone or pull all repositories
$initpath = get-location
foreach ($entry in $json.value) { 
    $name = $entry.name 
    Write-Host $name

    $url = $entry.remoteUrl -replace "://", ("://{0}@" -f $gitcred)
    if(!(Test-Path -Path $name)) {
        git clone $url
    } else {
        set-location $name
        git pull
        set-location $initpath
    }
}
```

## 2. Create configuration file
Now, create a _**CloneAllRepos.config**_ file alongside your ps1 script with your configuration:
```
[General]
Url=https://myproject.visualstudio.com/defaultcollection
Username=user@domain.com
Password=YourAccessToken
```
If you use two-factor authentication, you need to generate a password on the Azure DevOps site: Go to **User Settings > Security > Personal access tokens**, create an access token and use it as password in the configuration file.

## 3. Execute script
To execute the script in the Windows or PowerShell command prompt, run the following command:
```
powershell -ExecutionPolicy Bypass -File ./CloneAllRepos.ps1
```

If you’d like to execute the script without bypassing the policy in each call, you have to enable script execution globally:
```
Set-ExecutionPolicy Unrestricted
```

Now, you can execute the script in the PowerShell command line in this way:
```
./CloneAllRepos.ps1
```
