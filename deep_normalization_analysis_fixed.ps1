Write-Host "=== DEEP NORMALIZATION VARIANT ANALYSIS ===" -ForegroundColor Red
Write-Host "Understanding differences and potential exploitation vectors..." -ForegroundColor Yellow

# Read original file
$originalContent = Get-Content "normalize.css" -Raw
$originalBytes = [System.IO.File]::ReadAllBytes("normalize.css")

Write-Host "Original file: $($originalContent.Length) chars, $($originalBytes.Length) bytes" -ForegroundColor Gray

# Test all normalization forms
$normalizationForms = @("NFC", "NFD", "NFKC", "NFKD")
$encodingVariants = @("utf8", "utf16be", "utf16le", "utf32be", "utf32le", "utf7")

Write-Host "`n=== NORMALIZATION FORM ANALYSIS ===" -ForegroundColor Cyan

foreach ($form in $normalizationForms) {
    Write-Host "`n--- $form Normalization ---" -ForegroundColor Yellow
    
    # Apply normalization using .NET
    try {
        $normalizedContent = [System.Text.Normalization]::NormalizeString($originalContent, [System.Text.NormalizationForm]::$form)
        
        Write-Host "Length: $($normalizedContent.Length) (original: $($originalContent.Length))" -ForegroundColor Gray
        Write-Host "Difference: $($normalizedContent.Length - $originalContent.Length) characters" -ForegroundColor Gray
        
        # Count asterisks
        $asteriskCount = ($normalizedContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
        Write-Host "Asterisks: $asteriskCount" -ForegroundColor Gray
        
        # Find first differences
        if ($normalizedContent -ne $originalContent) {
            Write-Host "CONTENT CHANGED DETECTED!" -ForegroundColor Red
            
            # Find exact differences
            $originalArray = $originalContent.ToCharArray()
            $normalizedArray = $normalizedContent.ToCharArray()
            
            $differences = @()
            $maxLen = [math]::Max($originalArray.Length, $normalizedArray.Length)
            
            for ($i = 0; $i -lt $maxLen; $i++) {
                if ($i -ge $originalArray.Length -or $i -ge $normalizedArray.Length) {
                    $differences += @{
                        Position = $i
                        Original = if ($i -lt $originalArray.Length) { $originalArray[$i] } else { "[EOF]" }
                        Normalized = if ($i -lt $normalizedArray.Length) { $normalizedArray[$i] } else { "[EOF]" }
                        Type = "Length"
                    }
                } elseif ($originalArray[$i] -ne $normalizedArray[$i]) {
                    $differences += @{
                        Position = $i
                        Original = $originalArray[$i]
                        Normalized = $normalizedArray[$i]
                        Type = "Character"
                    }
                }
            }
            
            Write-Host "Differences found: $($differences.Count)" -ForegroundColor Red
            
            # Show first 10 differences
            for ($i = 0; $i -lt [math]::Min(10, $differences.Count); $i++) {
                $diff = $differences[$i]
                $origCode = if ($diff.Original -is [string]) { $diff.Original } else { "0x{0:X2}" -f [int]$diff.Original }
                $normCode = if ($diff.Normalized -is [string]) { $diff.Normalized } else { "0x{0:X2}" -f [int]$diff.Normalized }
                Write-Host "  Position $($diff.Position): '$origCode' → '$normCode' ($($diff.Type))" -ForegroundColor Red
            }
            
            if ($differences.Count -gt 10) {
                Write-Host "  ... and $($differences.Count - 10) more differences" -ForegroundColor Red
            }
            
            # Check if asterisks affected
            $originalAsterisks = ($originalArray | Where-Object { $_ -eq '*' }).Count
            $normalizedAsterisks = ($normalizedArray | Where-Object { $_ -eq '*' }).Count
            
            if ($originalAsterisks -ne $normalizedAsterisks) {
                Write-Host "CRITICAL: Asterisks changed from $originalAsterisks to $normalizedAsterisks" -ForegroundColor Red
                Write-Host "EXPLOITATION VECTOR: Normalization affects asterisk positions!" -ForegroundColor Red
            }
            
        } else {
            Write-Host "No content changes detected" -ForegroundColor Green
        }
        
        # Save normalized file for further analysis
        $outputFile = "normalize_${form}_detailed.css"
        $normalizedContent | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Host "Saved to: $outputFile" -ForegroundColor Gray
        
    }
    catch {
        Write-Host "Normalization failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== EXPLOITATION VECTOR ANALYSIS ===" -ForegroundColor Red

# Analyze potential exploitation scenarios
Write-Host "Analyzing potential exploitation vectors..." -ForegroundColor Yellow

$exploitationVectors = @()

# Check 1: Asterisk position manipulation
Write-Host "`n1. ASTERISK POSITION MANIPULATION" -ForegroundColor Yellow

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

$originalPositions = Get-AsteriskPositions $originalContent
Write-Host "Original asterisk positions: $($originalPositions.Count)" -ForegroundColor Gray

# Check each normalization variant
foreach ($form in $normalizationForms) {
    $normFile = "normalize_${form}_detailed.css"
    if (Test-Path $normFile) {
        $normContent = Get-Content $normFile -Raw
        $normPositions = Get-AsteriskPositions $normContent
        
        if ($normPositions.Count -ne $originalPositions.Count) {
            Write-Host "CRITICAL: $form changed asterisk count!" -ForegroundColor Red
            $exploitationVectors += @{
                Type = "AsteriskCountChange"
                Normalization = $form
                OriginalCount = $originalPositions.Count
                NewCount = $normPositions.Count
                Severity = "High"
            }
        }
        
        # Check position stability
        $unstablePositions = 0
        for ($i = 0; $i -lt [math]::Min($originalPositions.Count, $normPositions.Count); $i++) {
            if ($originalPositions[$i].Line -ne $normPositions[$i].Line -or 
                $originalPositions[$i].Char -ne $normPositions[$i].Char) {
                $unstablePositions++
            }
        }
        
        if ($unstablePositions -gt 0) {
            Write-Host "CRITICAL: $form has $unstablePositions unstable asterisk positions!" -ForegroundColor Red
            $exploitationVectors += @{
                Type = "PositionInstability"
                Normalization = $form
                UnstableCount = $unstablePositions
                Severity = "High"
            }
        }
    }
}

# Check 2: Content injection via normalization
Write-Host "`n2. CONTENT INJECTION ANALYSIS" -ForegroundColor Yellow

foreach ($form in $normalizationForms) {
    $normFile = "normalize_${form}_detailed.css"
    if (Test-Path $normFile) {
        $normContent = Get-Content $normFile -Raw
        $originalContent = Get-Content "normalize.css" -Raw
        
        # Look for injection patterns
        $injectionPatterns = @(
            'eval\s*\(',
            'Function\s*\(',
            'setTimeout\s*\(',
            'document\.write',
            'innerHTML\s*=',
            'atob\s*\(',
            'btoa\s*\('
        )
        
        foreach ($pattern in $injectionPatterns) {
            $origMatches = [regex]::Matches($originalContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            $normMatches = [regex]::Matches($normContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            
            if ($normMatches.Count -gt $origMatches.Count) {
                Write-Host "CRITICAL: $form introduced injection pattern: $pattern" -ForegroundColor Red
                $exploitationVectors += @{
                    Type = "ContentInjection"
                    Normalization = $form
                    Pattern = $pattern
                    OriginalCount = $origMatches.Count
                    NewCount = $normMatches.Count
                    Severity = "Critical"
                }
            }
        }
    }
}

# Check 3: Unicode manipulation
Write-Host "`n3. UNICODE MANIPULATION ANALYSIS" -ForegroundColor Yellow

foreach ($form in $normalizationForms) {
    $normFile = "normalize_${form}_detailed.css"
    if (Test-Path $normFile) {
        $normContent = Get-Content $normFile -Raw
        $originalContent = Get-Content "normalize.css" -Raw
        
        # Look for suspicious Unicode characters
        $suspiciousUnicode = @(
            '\u200B',  # Zero-width space
            '\u200C',  # Zero-width non-joiner
            '\u200D',  # Zero-width joiner
            '\uFEFF',  # BOM
            '\u2060',  # Word joiner
            '\u180E',  # Mongolian vowel separator
            '\u061C'   # Arabic letter mark
        )
        
        foreach ($unicode in $suspiciousUnicode) {
            $origMatches = [regex]::Matches($originalContent, $unicode)
            $normMatches = [regex]::Matches($normContent, $unicode)
            
            if ($normMatches.Count -gt $origMatches.Count) {
                Write-Host "CRITICAL: $form introduced suspicious Unicode: $unicode" -ForegroundColor Red
                $exploitationVectors += @{
                    Type = "UnicodeManipulation"
                    Normalization = $form
                    UnicodeChar = $unicode
                    OriginalCount = $origMatches.Count
                    NewCount = $normMatches.Count
                    Severity = "Critical"
                }
            }
        }
    }
}

Write-Host "`n=== EXPLOITATION VECTOR SUMMARY ===" -ForegroundColor Red

Write-Host "Total exploitation vectors discovered: $($exploitationVectors.Count)" -ForegroundColor Red

if ($exploitationVectors.Count -gt 0) {
    Write-Host "`nCRITICAL FINDINGS:" -ForegroundColor Red
    foreach ($vector in $exploitationVectors) {
        Write-Host "Type: $($vector.Type)" -ForegroundColor Red
        Write-Host "Normalization: $($vector.Normalization)" -ForegroundColor Red
        Write-Host "Severity: $($vector.Severity)" -ForegroundColor Red
        Write-Host "Details: $($vector | ConvertTo-Json -Compress)" -ForegroundColor Red
        Write-Host "---" -ForegroundColor Red
    }
    
    Write-Host "`n⚠️ EXPLOITATION VECTORS DETECTED!" -ForegroundColor Red
    Write-Host "Normalization can be used for attacks!" -ForegroundColor Red
} else {
    Write-Host "`n✅ No exploitation vectors detected" -ForegroundColor Green
    Write-Host "Normalization appears safe" -ForegroundColor Green
}

# Save exploitation analysis
$exploitationAnalysis = @{
    Timestamp = Get-Date
    ExploitationVectors = $exploitationVectors
    AnalysisType = "Deep Normalization"
    Status = if ($exploitationVectors.Count -gt 0) { "CRITICAL" } else { "SAFE" }
}

$exploitationAnalysis | ConvertTo-Json -Depth 4 | Out-File -FilePath "normalization_exploitation_analysis.json"

Write-Host "`nDetailed analysis saved to: normalization_exploitation_analysis.json" -ForegroundColor Green
Write-Host "=== DEEP NORMALIZATION ANALYSIS COMPLETE ===" -ForegroundColor Red
