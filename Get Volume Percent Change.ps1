 $s = New-PSSession -ComputerName $args[0]
try {
    Invoke-Command -Session $s -ArgumentList $args[1] -ScriptBlock {  
        param($volumeFilter)
        function GetVolumeData {
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory=$True)]
                [string]$VolumeName,
                [Parameter(Mandatory=$True)]
                $getVolumeData
            )

            if ($pastGetVolume -eq "") {
                return ""
            }

            $getVolumeData | ForEach {
                if ($_.FileSystemLabel -eq $VolumeName) {
                    return $_
                }
            }
            return ""
        }

        if (Test-Path -Path past_get_volume.json) {
            $pastGetVolume = Get-Content -Path past_get_volume.json | ConvertFrom-Json
        } else {
            $pastGetVolume = ""
        }


        $currentGetVolume = Get-Volume | Where-Object { $_.FileSystemLabel -match $volumeFilter }
        $currentGetVolume | ConvertTo-Json | Out-File past_get_volume.json

        $prtg = [pscustomobject]@{
            prtg = [pscustomobject]@{
                result = [pscustomobject]@()
            }
        }

        $currentGetVolume | ForEach {
            $pastGetVolumeVolume = GetVolumeData $_.FileSystemLabel $pastGetVolume
            if ($pastGetVolumeVolume -ne "") {
                $changeSizeRemaining = 100 * ($_.SizeRemaining - $pastGetVolumeVolume.SizeRemaining) / $pastGetVolumeVolume.SizeRemaining
                $channel = [pscustomobject]@{ 
                    channel = $_.FileSystemLabel; 
                    value = $changeSizeRemaining;
                    float = 1;
                    Unit = "Percent"
                }        
            } else {
                $channel = [pscustomobject]@{ 
                    channel = $_.FileSystemLabel; 
                    value = 0;
                    float = 1;
                    Unit = "Percent"
                }
            }
            $prtg.prtg.result += $channel
        }
        $prtg | ConvertTo-Json -Depth 3 
    }
} finally {
    Remove-PSSession $s
} 
