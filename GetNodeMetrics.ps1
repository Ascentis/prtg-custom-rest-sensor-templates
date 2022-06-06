$s = New-PSSession -ComputerName $args[0]
try {
    Invoke-Command -Session $s -ScriptBlock {            
        $perf = Get-ClusterNode | Get-ClusterPerf       

        $prtg = [pscustomobject]@{
            prtg = [pscustomobject]@{
                result = [pscustomobject]@()
            }
        }
        $perf | ForEach-Object {
            $_ | ForEach-Object {        
                $serverName = $_.ObjectDescription.SubString($_.ObjectDescription.IndexOf('-') + 1, $_.ObjectDescription.Length - $_.ObjectDescription.IndexOf('-') - 1)       
                $metricName =  $_.MetricId.SubString(0, $_.MetricId.IndexOf(","))
                if ($metricName -in ("ClusterNode.Cpu.Usage", "ClusterNode.Memory.Available", "NetAdapter.Bandwidth.Total", "ClusterNode.SblCache.Iops.Read.HitRate", "ClusterNode.Storage.Degraded")) {
                    $channelName = $serverName + "." + $metricName
                    Switch ($_.Unit) { 
                        2 {                 
                            $unit = "SpeedDisk"
                          }
                        3 {                 
                            $unit = "TimeResponse"                
                          }
                        4 { 
                            $unit = "BytesDisk"
                          }
                        5 { 
                            $unit = "Percent"                
                          }
                        7 {
                            $unit = "SpeedNet"
                          }
                        default { 
                            $unit = "Custom" 
                          } 
                    }
                    $channel = [pscustomobject]@{ 
                        channel = $channelName;
                        value = $_.Value;
                        Unit = $unit;
                        float = 1;
                        SpeedSize = "MegaBit"; 
                    }
                    $prtg.prtg.result += $channel
                }        
            }
        }

        $prtg | ConvertTo-Json -Depth 3 
    }
} finally {
    Remove-PSSession $s
} 
