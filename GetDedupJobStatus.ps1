$s = New-PSSession -ComputerName $args[0]
try {
    $nodes = Invoke-Command -Session $s -ScriptBlock {  
        $nodes = [pscustomobject]@()
        Get-ClusterNode | ForEach-Object {
            $nodes += $_.Name            
        }         
        
        return $nodes       
    }
    $volumes = Invoke-Command -Session $s -ScriptBlock {  
        $volumes = [pscustomobject]@()
        Get-Volume | Where-Object -Property FileSystem -EQ "CSVFS" | ForEach-Object {            
            $volumes += $_.FileSystemLabel            
        }         
        
        return $volumes       
    }
}
finally {
    Remove-PSSession $s
} 

$dedupJobs = [pscustomobject]@()
$nodes | ForEach-Object {
    $s = New-PSSession -ComputerName $_
    try {
        $jobs = Invoke-Command -Session $s -ScriptBlock {            
            return Get-DedupJob
        }
        $dedupJobs += $jobs
    }
    finally {
        Remove-PSSession $s
    }
}

$prtg = [pscustomobject]@{
    prtg = [pscustomobject]@{
        result = [pscustomobject]@()
    }
}

$volumePrefix = "c:\ClusterStorage\"
$i = 0 
$volumes | ForEach-Object {    
    $volumeName = [string]$_      
    $fullVolumeName = $volumePrefix + $volumeName     
     
    $filteredDedupJobs = [pscustomobject]@() 
    $filteredDedupJobs += $dedupJobs | Where-Object -Property Volume -Contains $fullVolumeName  

    if ($filteredDedupJobs.Count -gt 0) {
        $measure = $filteredDedupJobs | Measure-Object -Property Progress -Average
        $percentComplete = $measure.Average
    }
    else {
        $percentComplete = -2 - $i++        
    }

    $channel = [pscustomobject]@{                                                 
        channel = $volumeName;
        value   = $percentComplete;
        float   = 1;            
        Unit    = "Percent";
    }
    $prtg.prtg.result += $channel
}

$prtg | ConvertTo-Json -Depth 3
 
 
