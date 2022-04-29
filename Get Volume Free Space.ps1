 $s = New-PSSession -ComputerName $args[0]
try {
    Invoke-Command -Session $s -ArgumentList $args[1] -ScriptBlock {  
        param($volumeFilter)        
        
        $currentGetVolume = Get-Volume | Where-Object { $_.FileSystemLabel -match $volumeFilter }
        $currentGetVolume | ConvertTo-Json | Out-File past_get_volume.json

        $prtg = [pscustomobject]@{
            prtg = [pscustomobject]@{
                result = [pscustomobject]@()
            }
        }

        $currentGetVolume | ForEach {                        
            $channel = [pscustomobject]@{ 
                channel = $_.FileSystemLabel; 
                value = $_.SizeRemaining;
                float = 1;
                Unit = "BytesDisk";
                VolumeSize = "Giga";
                LimitMinWarning = "53687091200";
                LimitMinError = "21474836480";
                LimitMode = 1
            }  
            
            $prtg.prtg.result += $channel
        }
        $prtg | ConvertTo-Json -Depth 3 
    }
} finally {
    Remove-PSSession $s
} 
