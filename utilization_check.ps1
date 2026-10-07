# PowerShell script: CPU, RAM, and Disk Utilization

while ($true) {
    # --- CPU Usage ---
    $cpu = Get-Counter '\Processor(_Total)\% Processor Time'
    $cpuUsage = [math]::Round($cpu.CounterSamples.CookedValue,2)

    # --- Memory Usage ---
    $mem = Get-Counter '\Memory\Available MBytes'
    $totalMem = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB
    $usedMem = $totalMem - $mem.CounterSamples.CookedValue
    $memPercent = [math]::Round(($usedMem / $totalMem) * 100,2)

    # --- Disk Usage ---
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    $diskInfo = foreach ($disk in $disks) {
        $sizeGB = [math]::Round($disk.Size / 1GB,2)
        $freeGB = [math]::Round($disk.FreeSpace / 1GB,2)
        $usedGB = $sizeGB - $freeGB
        $percentUsed = [math]::Round(($usedGB / $sizeGB) * 100,2)

        "Drive $($disk.DeviceID): $percentUsed% used ($usedGB GB / $sizeGB GB)"
    }

    # --- Output Dashboard ---
    Clear-Host
    Write-Host "===== System Resource Utilization ====="
    Write-Host "CPU Usage: $cpuUsage %"
    Write-Host "Memory Usage: $memPercent % ($([math]::Round($usedMem,0)) MB / $([math]::Round($totalMem,0)) MB)"
    Write-Host "Disk Usage:"
    $diskInfo | ForEach-Object { Write-Host "   $_" }
    Write-Host "======================================="
    
    Start-Sleep -Seconds 5
}
