$taskFolders = @("\Own", "\Sophia")

foreach ($folderPath in $taskFolders) {
    try {
        $folder = (New-Object -ComObject Schedule.Service).GetFolder($folderPath)

        $tasks = $folder.GetTasks(0)
        foreach ($task in $tasks) {
            $folder.DeleteTask($task.Name, 0)
        }

        $parentPath = [System.IO.Path]::GetDirectoryName($folderPath.TrimStart('\'))
        if ([string]::IsNullOrEmpty($parentPath)) {
            $parent = (New-Object -ComObject Schedule.Service).GetFolder("\")
        } else {
            $parent = (New-Object -ComObject Schedule.Service).GetFolder("\" + $parentPath)
        }

        $parent.DeleteFolder($folderPath, 0)
        Write-Host "Carpeta eliminada: $folderPath"
    } catch {
        Write-Host "Carpeta no encontrada o error al eliminar: $folderPath"
    }
}
