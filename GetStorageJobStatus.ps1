$s = New-PSSession -ComputerName $args[0]

try {
    Invoke-Command -Session $s -ScriptBlock {  
        $storageJobs = Get-StorageJob | Where-Object { $_.JobState -ne "Completed" }
        $totalSize = 0
        $totalComplete = 0

        $storageJobs | ForEach-Object {
            $totalSize += $_.BytesTotal
            $totalComplete += $_.BytesProcessed            
        }

        $prtg = [pscustomobject]@{
            prtg = [pscustomobject]@{
                result = [pscustomobject]@()
            }
        }

        if ($totalSize -ne 0) {
            $percentComplete = 100 * $totalComplete / $totalSize
        } else {
            $percentComplete = 100
        }

        $channelHealth = [pscustomobject]@{                                                 
            channel = "Health percentage"; 
            value = $percentComplete;
            float = 1;            
            Unit = "Percent";
            LimitMinWarning = 99
            LimitMinError = 95
            LimitMode = 1
        }  
        $channelJobCount = [pscustomobject]@{                                                 
            channel = "Jobs count"; 
            value = $storageJobs.Count;
            float = 0;            
            Unit = "Count";
            LimitMaxWarning = 1;
            LimitMaxError = 5;
            LimitMode = 1;
        } 
        $channelToProcess = [pscustomobject]@{                                                 
            channel = "Bytes to process"; 
            value = $totalSize - $totalComplete;
            float = 0;            
            Unit = "BytesDisk";
            LimitMaxWarning = 107374182400;
            LimitMaxError = 536870912000;
            LimitMode = 1;
        }  
            
        $prtg.prtg.result += $channelHealth  
        $prtg.prtg.result += $channelJobCount
        $prtg.prtg.result += $channelToProcess

        $prtg | ConvertTo-Json -Depth 3
    }
} finally {
    Remove-PSSession $s
} 
 
