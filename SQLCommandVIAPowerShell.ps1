param(
        [string] $dataSource = "sqlserver",
        [string] $database = "daname",
        [string] $sqlCommand = "SELECT TOP (2) [rollnumber]
            , [marks]
            FROM [SampleDB].[dbo].[Student_SQL]"
    )

$connectionString = "Data Source=$dataSource; " +
        "Integrated Security=SSPI; " +
        "Initial Catalog=$database"

$connection = new-object system.data.SqlClient.SQLConnection($connectionString)
$command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
$connection.Open()

$adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
$dataset = New-Object System.Data.DataSet
$adapter.Fill($dataSet) | Out-Null

$connection.Close()
$dataSet.Tables
