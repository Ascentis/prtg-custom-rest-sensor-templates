 $s = New-PSSession -ComputerName $args[0]
Invoke-Command -Session $s -ScriptBlock { 
    function Get-VolumesFreeSpaceStdDev {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$True)]
            [string]$volsToProcess
        )
    
        # Let's calculate the percentage array
        $vols = Get-Volume | Where-Object {
            $_.FileSystemLabel -match $volsToProcess
        } | foreach { $_.SizeRemaining / $_.Size }
        # Let's obtain the average/mean of the free space array produced above
        $volFreeMean = $vols | Measure-Object -Average
        # Now we will calculate the sum of the differences between each element and the mean squared
        $sumOfSquaresDiff = $vols | ForEach { 
            $diff = $_ - $volFreeMean.Average
            [math]::Pow($diff, 2)
        } | Measure-Object -Sum
        # Now we can calculate the standard deviation of the free spaces
        $stdDev = [math]::Sqrt($sumOfSquaresDiff.Sum / $volFreeMean.Count)

        return $stdDev
    }

    $VolsFreeSpaceStdDev = Get-VolumesFreeSpaceStdDev ("^Volume.|^RepVolume$")
    $CLVolsFreeSpaceStdDev = Get-VolumesFreeSpaceStdDev ("^CLVol.")
    $SANVolsFreeSpaceStdDev = Get-VolumesFreeSpaceStdDev ("^SANVol.")

    Write-Output "{"
        Write-Output "`"prtg`": {"
            Write-Output "`"result`": [" 
                Write-Output "{"
                Write-Output "`"channel`": `"S2D Dev Volumes`","
                Write-Output "`"value`": $($VolsFreeSpaceStdDev * 100),"
                Write-Output "`"float`": 1," 
                Write-Output "`"Unit`": `"Percent`""
                Write-Output "},"

                Write-Output "{"
                Write-Output "`"channel`": `"CrazyLab Volumes`","
                Write-Output "`"value`": $($CLVolsFreeSpaceStdDev * 100),"
                Write-Output "`"float`": 1," 
                Write-Output "`"Unit`": `"Percent`""
                Write-Output "},"

                Write-Output "{"
                Write-Output "`"channel`": `"SAN Volumes`","
                Write-Output "`"value`": $($SANVolsFreeSpaceStdDev * 100),"
                Write-Output "`"float`": 1," 
                Write-Output "`"Unit`": `"Percent`""
                Write-Output "}"
            Write-Output "]"
        Write-Output "}"
    Write-Output "}"
} 
 
