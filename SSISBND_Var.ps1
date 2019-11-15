git clone https://user:token@dev.azure.com/proj/test/_git/test 

& cd test

# git checkout branchname

&"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.com" "C:\path\to\slnfile.sln"  /Rebuild

# $Source = "\\192.168.x.x\somefile.txt"
# $Dest   = "C:\Users\user\somefile.txt"
# $Username = "username"
# $Password = "password"

# $WebClient = New-Object System.Net.WebClient
# $WebClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)

# $WebClient.DownloadFile($Source, $Dest)

# #####

# $cred = get-credential #fill you credential in the pop-up window

# Invoke-Command -ComputerName mycomputer -ScriptBlock { 
#     ## PS Script here in this block
# Variables
$ProjectFilePath = "C:\path\to\ispacfile\file.ispac"
$SSISDBServerEndpoint = "servername"
$SSISDBServerAdminUserName = "user"
$SSISDBServerAdminPassword = "password"
$SSISFolderName = "SSISDBFolder"
$SSISDescription = "SSISDBFolder"

Write-Host "**********************************************************"
Write-Host "*******************  Script starts  **********************"
Write-Host "**********************************************************"

# Load the IntegrationServices Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;

# Store the IntegrationServices Assembly namespace to avoid typing it every time
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"

Write-Host "Connecting to SSIS Instance server ..."

# Create a connection to the server
$sqlConnectionString = "Data Source=" + $SSISDBServerEndpoint + ";User ID="+ $SSISDBServerAdminUserName +";Password="+ $SSISDBServerAdminPassword + ";Initial Catalog=SSISDB"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString

Write-Host "slq connection set:" $sqlConnection

# Create the Integration Services object
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection

Write-Host "Integration Services object set:" $integrationServices

# Get the catalog
$catalog = $integrationServices.Catalogs['SSISDB']
Write-Host "The catalog is:" $catalog

$ssisFolder = $catalog.Folders.Item($SSISFolderName)
Write-Host "SSIS Folder is:" $ssisFolder

# Verify if we have already this folder
if (!$ssisFolder)
{
    write-host "Create folder on Catalog SSIS instance"
    $folder = New-Object Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder($catalog, $SSISFolderName, $SSISDescription) 
	write-host "New folder on catalog:" $folder
    $folder.Create()
    $ssisFolder = $catalog.Folders.Item($SSISFolderName)
	write-host "Newly created SSIS folder:" $ssisFolder
}

write-host "Enumerating all folders in the project code"

$folders = ls -Path $ProjectFilePath -File
write-host "The folders in the project code are:" $folders

# If we have some folders to treat
if ($folders.Count -gt 0)
{
	#Treat one by one them
    foreach ($filefolder in $folders)
    {
		write-host "File folder:" $filefolder
        $projects = ls -Path $filefolder.FullName -File -Filter *.ispac
		write-host "Projects:" $projects
        if ($projects.Count -gt 0)
        {
            foreach($projectfile in $projects)
            {
				write-host "Project File:" $projectfile
				write-host "ISPAC File ==> "$projectfile.Name.Replace(".ispac", "")
                write-host "Project File Name Fullname ==> "$projectfile.FullName
				
				$projectfilename = $projectfile.Name.Replace(".ispac", "")
				$ssisProject = $ssisFolder.Projects.Item($projectfilename)
                write-host "SSIS project:" $ssisProject
                # Dropping old project 
                if(![string]::IsNullOrEmpty($ssisProject))
                {
                    write-host "Drop Old SSIS Project ==> "$ssisProject.Name
                    $ssisProject.Drop()
                }

                Write-Host "Deploying " $projectfilename " project ..."

                # Read the project file, and deploy it to the folder
                [byte[]] $projectFileContent = [System.IO.File]::ReadAllBytes($projectfile.FullName)
				write-host "Project File Content:" $projectfile.FullName
                $ssisFolder.DeployProject($projectfilename, $projectFileContent)
            }
        }
    }
}

Write-Host "All done."
# } -credential $cred
