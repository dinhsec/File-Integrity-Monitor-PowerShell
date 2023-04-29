Write-Host "Powershell File Integrity Monitor`n"
Write-Host "1) Calculate Baseline Hashes"
Write-Host "2) Monitor files with existing baseline"

# Global Variables
$response = ''
$files = Get-ChildItem -Path .\Downloads\FIM\Documents
$existingHashes = Get-Content -Path .\Downloads\FIM\baselines.txt
$baselineContent = Get-Content -Path .\Downloads\FIM\baselines.txt
$baselinesDict = @{}

# Prompts user for input
while ($response -ne 1 -and $response -ne 2) {
    $response = Read-Host -Prompt "Please enter 1 or 2"
    
    if ($response -ne 1 -and $response -ne 2) {
        Write-Host "Please enter a valid option"
    }
}


# Function calculates the file hash of a file using SHA512
Function CalcFileHash($filepath) {
    $fileHash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $fileHash
}

# Function gets content from the baselines.txt file and places them into a dictionary
Function GetBaselines {
    foreach ($f in $baselineContent) {
        $baselinesDict.Add($f.Split(",")[0], $f.Split(",")[1])
    }
    return $baselinesDict
}

if ($response -eq 1) {
    Write-Host "`nCalculating file hashes for baseline"
    
    # Iterates through each file in the files folder
    foreach ($f in $files) {
        $hash = CalcFileHash($f.FullName)
        $hash = "$($hash.Path),$($hash.Hash)"
        
        # Checks if the hash for the corresponding file already exists
        if ($hash -inotin $existingHashes) {
            Write-Host "Appending new baseline for $($f.FullName)" -ForegroundColor Green
            $hash | Out-File -FilePath .\Downloads\FIM\baselines.txt -Append

        }
        else {
            Write-Host "Baseline for $($f.FullName) already exists!" -ForegroundColor Red
        }
    }
}
elseif ($response -eq 2) {
    Write-Host "Monitoring file integrity..."
    $baselines = GetBaselines
    #$baselines

    while ($true) {
        Start-Sleep -Seconds 2
        Write-Host "Scanning..."
        $currFiles = Get-ChildItem -Path .\Downloads\FIM\Documents

        foreach ($f in $currFiles) {
            $hash = CalcFileHash($f.FullName)

            #File has been created
            if ($baselines[$hash.Path] -eq $null) {
                Write-Host "WARNING: A new file was created! $($hash.Path)" -ForegroundColor Yellow
            }
            # File has not been modified
            elseif ($baselines[$hash.Path] -eq $hash.Hash) {
                continue
            }
            # File has been modified
            else {
                Write-Host "WARNING: File $($f.FullName) has changed!" -ForegroundColor Red
            }
        }

        foreach ($key in $baselinesDict.Keys) {
            $baselineFileExists = Test-Path -Path $key
            if (-Not $baselineFileExists) {
                Write-Host "WARNING: $($key) has been deleted!" -ForegroundColor Red
            }
        }
    }
}
