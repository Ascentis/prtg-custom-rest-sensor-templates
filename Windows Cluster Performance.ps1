$s = New-PSSession -ComputerName $args[0]
Invoke-Command -Session $s -ScriptBlock {
	$o = Get-ClusterPerf
	Write-Output "{"
	Write-Output "`"prtg`": {"
	Write-Output "`"result`": ["
    $first = $true
	foreach ($metric in $o) {
        if ($first -ne $true) { 
            Write-Output ","            
        }
        $first = $false
		Write-Output "{"
		Write-Output "`"channel`": `"$($metric.MetricId.SubString(0, $metric.MetricId.IndexOf(",")))`","				
        Switch ($metric.Unit) {
            2 {                 
                Write-Output "`"value`": $($metric.Value),"
                Write-Output "`"float`": 1,"
                Write-Output "`"Unit`": `"SpeedDisk`","
                Write-Output "`"SpeedSize`": `"MegaByte`","
                Write-Output "`"VolumeSize`": `"MegaByte`""
              }
            3 {                 
                Write-Output "`"value`": $($metric.Value * 1000),"
                Write-Output "`"float`": 1,"
                Write-Output "`"Unit`": `"TimeResponse`""                
              }
            4 { 
                Write-Output "`"value`": $($metric.Value),"                
                Write-Output "`"float`": 1,"
                Write-Output "`"Unit`": `"BytesDisk`","
                Write-Output "`"VolumeSize`": `"TeraByte`""
              }
            5 { 
                Write-Output "`"value`": $($metric.Value),"                
                Write-Output "`"float`": 1,"
                Write-Output "`"Unit`": `"Percent`""                
              }
            default { 
                Write-Output "`"value`": $($metric.Value),"
                Write-Output "`"float`": 1" 
              }
        }
		Write-Output "}"
	}	
	Write-Output "]"
	Write-Output "}"
	Write-Output "}"
} 
Remove-PSSession $s