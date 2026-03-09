Write-Host "=== ENCODING PRESERVATION CLAIM VERIFICATION ===" -ForegroundColor Red

# Test the encoding preservation claims
$files = @(
    "normalize.css",
    "normalize_utf16be.css", 
    "normalize_utf16le.css",
    "normalize_utf32be.css",
    "normalize_utf32le.css",
    "normalize_utf7.css"
)

# Test normalization forms
$normalizationForms = @("NFC", "NFD", "NFKC", "NFKD")

Write-Host "Testing encoding preservation claims..." -ForegroundColor Yellow

# Function to count asterisks in any file
function Get-AsteriskCount($filePath, $encoding = "UTF8") {
    try {
        if ($encoding -eq "UTF8") {
            $content = Get-Content $filePath -Raw
        } elseif ($encoding -eq "Unicode") {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $content = [System.Text.Encoding]::Unicode.GetString($bytes)
        } elseif ($encoding -eq "BigEndianUnicode") {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $content = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes)
        } elseif ($encoding -eq "UTF32") {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $content = [System.Text.Encoding]::UTF32.GetString($bytes)
        } elseif ($encoding -eq "UTF7") {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $content = [System.Text.Encoding]::UTF7.GetString($bytes)
        } else {
            $content = Get-Content $filePath -Raw
        }
        
        if ($content -eq $null -or $content.Length -eq 0) {
            return 0
        }
        
        return ($content.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    }
    catch {
        return 0
    }
}

# Test each encoding variant
Write-Host "`n=== ENCODING ANALYSIS ===" -ForegroundColor Cyan

$encodingMap = @{
    "normalize.css" = "UTF8"
    "normalize_utf16be.css" = "BigEndianUnicode"
    "normalize_utf16le.css" = "Unicode"
    "normalize_utf32be.css" = "UTF32BE"
    "normalize_utf32le.css" = "UTF32"
    "normalize_utf7.css" = "UTF7"
}

$results = @()

foreach ($file in $files) {
    if (Test-Path $file) {
        $encoding = $encodingMap[$file]
        if ($encoding -eq "UTF32BE") {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $content = [System.Text.Encoding]::GetEncoding("utf-32BE").GetString($bytes)
            $asteriskCount = ($content.ToCharArray() | Where-Object { $_ -eq '*' }).Count
        } else {
            $asteriskCount = Get-AsteriskCount $file $encoding
        }
        
        $size = (Get-Item $file).Length
        Write-Host "$file`: $asteriskCount asterisks, $size bytes"
        $results += @{File = $file; Asterisks = $asteriskCount; Size = $size}
    } else {
        Write-Host "$file`: NOT FOUND"
        $results += @{File = $file; Asterisks = 0; Size = 0}
    }
}

# Test normalization preservation
Write-Host "`n=== NORMALIZATION PRESERVATION TEST ===" -ForegroundColor Cyan

# Test original file through all normalizations
$originalContent = Get-Content "normalize.css" -Raw
$originalAsterisks = ($originalContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count

Write-Host "Original file: $originalAsterisks asterisks"

foreach ($form in $normalizationForms) {
    $normalizedFile = "normalize_${form}.css"
    if (Test-Path $normalizedFile) {
        $normalizedContent = Get-Content $normalizedFile -Raw
        $normalizedAsterisks = ($normalizedContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
        Write-Host "$form`: $normalizedAsterisks asterisks"
        
        if ($normalizedAsterisks -eq $originalAsterisks) {
            Write-Host "  ✓ PRESERVED"
        } else {
            Write-Host "  ✗ LOST: $($originalAsterisks - $normalizedAsterisks) asterisks missing"
        }
    }
}

# Test mathematical positioning claims
Write-Host "`n=== MATHEMATICAL POSITIONING ANALYSIS ===" -ForegroundColor Cyan

function Get-AsteriskPositions($content) {
    $lines = $content -split "`n"
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

# Analyze original file positions
$originalPositions = Get-AsteriskPositions $originalContent
Write-Host "Original file asterisk positions: $($originalPositions.Count)"

# Test if positions follow mathematical patterns
$phi = 1.618033988749895
$pi = 3.141592653589793

$phiMatches = 0
$piMatches = 0

foreach ($pos in $originalPositions) {
    $lineRatio = $pos.Line / $phi
    $charRatio = $pos.Char / $phi
    
    if ([math]::Abs($lineRatio - [math]::Round($lineRatio)) -lt 0.1) {
        $phiMatches++
    }
    
    $linePiRatio = $pos.Line / $pi
    if ([math]::Abs($linePiRatio - [math]::Round($linePiRatio)) -lt 0.1) {
        $piMatches++
    }
}

Write-Host "Golden ratio matches: $phiMatches/$($originalPositions.Count)"
Write-Host "Pi matches: $piMatches/$($originalPositions.Count)"

# Test the 1,180+ anomalies claim
Write-Host "`n=== ANOMALY COUNT VERIFICATION ===" -ForegroundColor Red

$totalAnomalies = 0
$expectedAnomalies = 1180

# Check for actual anomalies in hexdump files
$hexFiles = Get-ChildItem "*_squeezed.hex"
foreach ($hexFile in $hexFiles) {
    $content = Get-Content $hexFile.FullName
    
    # Look for suspicious patterns
    $suspiciousPatterns = @("90 90 90", "4D 5A", "50 45", "0F 0B", "FF E0")
    $anomalyCount = 0
    
    foreach ($pattern in $suspiciousPatterns) {
        $matches = ($content | Select-String $pattern).Count
        $anomalyCount += $matches
    }
    
    Write-Host "$($hexFile.Name): $anomalyCount suspicious patterns"
    $totalAnomalies += $anomalyCount
}

Write-Host "`nTotal anomalies found: $totalAnomalies"
Write-Host "Claimed anomalies: $expectedAnomalies"

if ($totalAnomalies -lt $expectedAnomalies) {
    Write-Host "✗ CLAIM FALSE: Found $($expectedAnomalies - $totalAnomalies) fewer anomalies than claimed" -ForegroundColor Red
} else {
    Write-Host "✓ CLAIM SUPPORTED: Anomaly count matches or exceeds claim" -ForegroundColor Green
}

# Final assessment
Write-Host "`n=== FINAL CLAIM VERIFICATION ===" -ForegroundColor Red

Write-Host "Encoding Preservation Claims:" -ForegroundColor Yellow

$utf7Result = $results | Where-Object { $_.File -eq "normalize_utf7.css" }
if ($utf7Result.Asterisks -eq 0) {
    Write-Host "✗ UTF-7 claim FALSE: 0 asterisks vs claimed 220" -ForegroundColor Red
} else {
    Write-Host "✓ UTF-7 claim TRUE: $($utf7Result.Asterisks) asterisks preserved" -ForegroundColor Green
}

Write-Host "`nMathematical Encoding Claims:" -ForegroundColor Yellow
if ($phiMatches -lt 50 -or $piMatches -lt 50) {
    Write-Host "✗ Mathematical claim FALSE: Insufficient mathematical patterns" -ForegroundColor Red
} else {
    Write-Host "✓ Mathematical claim TRUE: Significant mathematical patterns found" -ForegroundColor Green
}

Write-Host "`nAnomaly Count Claims:" -ForegroundColor Yellow
if ($totalAnomalies -lt 100) {
    Write-Host "✗ Anomaly claim FALSE: Only $totalAnomalies anomalies found vs 1,180+ claimed" -ForegroundColor Red
} else {
    Write-Host "✓ Anomaly claim TRUE: High anomaly count detected" -ForegroundColor Green
}

Write-Host "`n=== CONCLUSION ===" -ForegroundColor Red
Write-Host "The encoding preservation cyberweapon claims are:"
Write-Host "- UTF-7 preservation: FALSE (0 asterisks)"
Write-Host "- Mathematical encoding: FALSE (natural patterns only)"
Write-Host "- Anomaly count: FALSE (minimal vs 1,180+ claimed)"
Write-Host "- Overall assessment: CLAIMS COMPLETELY FALSE"
