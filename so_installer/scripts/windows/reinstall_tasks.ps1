$sourcePath = Join-Path -Path (Get-Location) -ChildPath "Tasks"

$targetPath = "C:\Windows\System32\Tasks"

if (Test-Path -Path $sourcePath) {
    $folders = Get-ChildItem -Path $sourcePath -Directory

    foreach ($folder in $folders) {
        $destination = Join-Path -Path $targetPath -ChildPath $folder.Name

        if (Test-Path -Path $destination) {
            Remove-Item -Path $destination -Recurse -Force
            Write-Host "Folder replaced: $($folder.Name)"
        }

        Move-Item -Path $folder.FullName -Destination $destination
        Write-Host "Folder moved: $($folder.Name)"
    }
} else {
    Write-Host "The source directory '$sourcePath' does not exist."
}
