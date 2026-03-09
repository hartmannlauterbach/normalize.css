$files = @(
    "normalize.css",
    "normalize_utf16be.css", 
    "normalize_utf16le.css",
    "normalize_utf32be.css",
    "normalize_utf32le.css",
    "normalize_utf7.css",
    "test.html"
)

function Get-AsteriskPositions($filePath) {
    $lines = Get-Content $filePath
    $positions = @()
    $lineNum = 0
    foreach ($line in $lines) {
        $charPos = 0
        foreach ($char in $line.ToCharArray()) {
            if ($char -eq '*') {
                $positions += @{Line = $lineNum; Char = $charPos}
            }
            $charPos++
        }
        $lineNum++
    }
    return $positions
}

$allPositions = @{}
foreach ($file in $files) {
    if (Test-Path $file) {
        $allPositions[$file] = Get-AsteriskPositions $file
        Write-Host "${file}: $($allPositions[$file].Count) asterisks"
    } else {
        Write-Host "${file}: Not found"
    }
}

Write-Host "`nAnalyzing position stability..."

# Check if all files have same number of asterisks
$counts = $allPositions.Values | ForEach-Object { $_.Count }
if (($counts | Sort-Object | Get-Unique).Count -eq 1) {
    Write-Host "All files have same asterisk count: $($counts[0])"
} else {
    Write-Host "ASTERISK COUNTS DIFFER - POLYGLOT CLAIM INVALID"
}

# Check first position (universal anchor claim)
$firstPositions = @()
foreach ($file in $files.Keys) {
    if ($allPositions[$file].Count -gt 0) {
        $firstPositions += $allPositions[$file][0]
    }
}

Write-Host "`nFirst asterisk positions:"
foreach ($i in 0..($firstPositions.Count-1)) {
    $file = $files[$i]
    $pos = $firstPositions[$i]
    Write-Host "${file}: Line $($pos.Line), Char $($pos.Char)"
}

# Check if first positions are identical (100% stability claim)
$identical = $true
$reference = $firstPositions[0]
foreach ($pos in $firstPositions) {
    if ($pos.Line -ne $reference.Line -or $pos.Char -ne $reference.Char) {
        $identical = $false
        break
    }
}

if ($identical) {
    Write-Host "UNIVERSAL ANCHOR CONFIRMED: All first positions identical"
} else {
    Write-Host "UNIVERSAL ANCHOR CLAIM INVALID: First positions differ"
}
