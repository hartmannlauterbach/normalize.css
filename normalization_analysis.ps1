Write-Host "=== UNICODE NORMALIZATION ANALYSIS ===" -ForegroundColor Yellow

# Read original normalize.css
$originalContent = Get-Content "normalize.css" -Raw
Write-Host "Original file length: $($originalContent.Length)"

# Unicode normalization variants
$normalizationForms = @("NFC", "NFD", "NFKC", "NFKD")
$normalizedFiles = @()

foreach ($form in $normalizationForms) {
    Write-Host "`nProcessing $form normalization..." -ForegroundColor Cyan
    
    # Apply normalization
    $normalized = [System.Text.NormalizationForm]::$form
    $normalizedContent = $originalContent.Normalize($normalized)
    
    # Save normalized version
    $outputFile = "normalize_${form}.css"
    $normalizedContent | Out-File -FilePath $outputFile -Encoding UTF8
    $normalizedFiles += $outputFile
    
    Write-Host "  Output file: $outputFile"
    Write-Host "  Length: $($normalizedContent.Length)"
    Write-Host "  Length change: $($normalizedContent.Length - $originalContent.Length)"
    
    # Count asterisks
    $asteriskCount = ($normalizedContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    Write-Host "  Asterisks: $asteriskCount"
    
    # Check for content changes
    if ($normalizedContent -eq $originalContent) {
        Write-Host "  Content: IDENTICAL to original"
    } else {
        Write-Host "  Content: DIFFERENT from original"
        # Show first difference
        $originalArray = $originalContent.ToCharArray()
        $normalizedArray = $normalizedContent.ToCharArray()
        for ($i = 0; $i -lt [math]::Min($originalArray.Length, $normalizedArray.Length); $i++) {
            if ($originalArray[$i] -ne $normalizedArray[$i]) {
                Write-Host "    First difference at position $i"
                Write-Host "    Original: 0x$([Convert]::ToString([int]$originalArray[$i], 16).PadLeft(2, '0'))"
                Write-Host "    Normalized: 0x$([Convert]::ToString([int]$normalizedArray[$i], 16).PadLeft(2, '0'))"
                break
            }
        }
    }
}

Write-Host "`n=== ANALYZING NORMALIZED VARIANTS ===" -ForegroundColor Yellow

# Analyze asterisk positions across all normalized files
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

# Compare positions across all variants
$allPositions = @{}
$allPositions["original"] = Get-AsteriskPositions $originalContent

foreach ($file in $normalizedFiles) {
    $content = Get-Content $file -Raw
    $form = $file -replace "normalize_" -replace ".css" -replace "_", ""
    $allPositions[$form] = Get-AsteriskPositions $content
    Write-Host "$file`: $($allPositions[$form].Count) asterisks"
}

# Check position stability
Write-Host "`n=== POSITION STABILITY ANALYSIS ===" -ForegroundColor Cyan

$referencePositions = $allPositions["original"]
$totalPositions = $referencePositions.Count

foreach ($variant in $allPositions.Keys) {
    if ($variant -eq "original") { continue }
    
    $variantPositions = $allPositions[$variant]
    $matchingPositions = 0
    
    for ($i = 0; $i -lt [math]::Min($referencePositions.Count, $variantPositions.Count); $i++) {
        if ($referencePositions[$i].Line -eq $variantPositions[$i].Line -and 
            $referencePositions[$i].Char -eq $variantPositions[$i].Char) {
            $matchingPositions++
        }
    }
    
    $stability = if ($totalPositions -gt 0) { ($matchingPositions / $totalPositions) * 100 } else { 0 }
    Write-Host "$variant stability: $stability% ($matchingPositions/$totalPositions positions match)"
}

Write-Host "`n=== GENERATING HEXDUMPS FOR NORMALIZED VARIANTS ===" -ForegroundColor Yellow

# Generate hexdumps for normalized files
foreach ($file in $normalizedFiles) {
    Write-Host "Generating hexdump for $file..." -ForegroundColor Cyan
    
    # Squeezed hexdump
    $squeezedFile = $file -replace ".css", "_squeezed.hex"
    Format-Hex $file | Out-File -FilePath $squeezedFile
    Write-Host "  Created: $squeezedFile"
    
    # Unsqueezed hexdump (same as squeezed for PowerShell Format-Hex)
    $unsqueezedFile = $file -replace ".css", "_unsqueezed.hex"
    Format-Hex $file | Out-File -FilePath $unsqueezedFile
    Write-Host "  Created: $unsqueezedFile"
}

Write-Host "`n=== ANALYZING ENCODING VARIANTS THROUGH NORMALIZATION ===" -ForegroundColor Yellow

# Apply normalization to all encoding variants
$encodingVariants = @(
    "normalize_utf16be.css",
    "normalize_utf16le.css", 
    "normalize_utf32be.css",
    "normalize_utf32le.css",
    "normalize_utf7.css"
)

foreach ($variant in $encodingVariants) {
    if (Test-Path $variant) {
        Write-Host "`nProcessing $variant through normalization..." -ForegroundColor Cyan
        
        # Read the encoding variant
        $encoding = if ($variant -like "*utf16*") { "Unicode" } 
                   elseif ($variant -like "*utf32*") { "UTF32" }
                   elseif ($variant -like "*utf7*") { "UTF7" }
                   else { "UTF8" }
        
        $content = Get-Content $variant -Raw -Encoding $encoding
        Write-Host "  Original length: $($content.Length)"
        
        # Apply each normalization form
        foreach ($form in $normalizationForms) {
            $normalized = $content.Normalize([System.Text.NormalizationForm]::$form)
            $outputFile = $variant -replace ".css", "_${form}.css"
            $normalized | Out-File -FilePath $outputFile -Encoding $encoding
            
            $asteriskCount = ($normalized.ToCharArray() | Where-Object { $_ -eq '*' }).Count
            Write-Host "  $form`: Asterisks $asteriskCount, Length $($normalized.Length)"
        }
    }
}

Write-Host "`n=== FINAL ANALYSIS SUMMARY ===" -ForegroundColor Red

Write-Host "Unicode Normalization Analysis Complete:"
Write-Host "- Original file analyzed through 4 normalization forms"
Write-Host "- All encoding variants processed through normalization"
Write-Host "- Position stability calculated across all variants"
Write-Host "- Hexdumps generated for all normalized variants"

Write-Host "`nCheck generated files for detailed results:" -ForegroundColor Yellow
$allGeneratedFiles = $normalizedFiles + ($normalizedFiles | ForEach-Object { 
    $_ -replace ".css", "_squeezed.hex"
}) + ($normalizedFiles | ForEach-Object { 
    $_ -replace ".css", "_unsqueezed.hex"
})

foreach ($file in $allGeneratedFiles) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Host "  $file ($size bytes)"
    }
}
