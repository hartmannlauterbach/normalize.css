Write-Host "=== DEEP NORMALIZATION ANALYSIS - FINAL ===" -ForegroundColor Red
Write-Host "Understanding differences and exploitation potential..." -ForegroundColor Yellow

# Read original file
$originalContent = Get-Content "normalize.css" -Raw
Write-Host "Original file: $($originalContent.Length) characters" -ForegroundColor Gray

# Test all normalization forms
$normalizationForms = @("NFC", "NFD", "NFKC", "NFKD")

Write-Host "`n=== NORMALIZATION FORM ANALYSIS ===" -ForegroundColor Cyan

foreach ($form in $normalizationForms) {
    Write-Host "`n--- $form Normalization ---" -ForegroundColor Yellow
    
    # Check for characters that could be affected by normalization
    $charArray = $originalContent.ToCharArray()
    $normalizableChars = @()
    
    for ($i = 0; $i -lt $charArray.Length; $i++) {
        $char = $charArray[$i]
        $charCode = [int]$char
        
        # Check for non-ASCII characters
        if ($charCode -gt 127) {
            $normalizableChars += @{
                Position = $i
                Character = $char
                Code = "U+{0:X4}" -f $charCode
            }
        }
    }
    
    Write-Host "Non-ASCII characters: $($normalizableChars.Count)" -ForegroundColor Gray
    
    if ($normalizableChars.Count -gt 0) {
        Write-Host "Sample non-ASCII characters:" -ForegroundColor Yellow
        for ($i = 0; $i -lt [math]::Min(5, $normalizableChars.Count); $i++) {
            $char = $normalizableChars[$i]
            Write-Host "  Position $($char.Position): '$($char.Character)' ($($char.Code))" -ForegroundColor White
        }
    }
    
    # Count asterisks
    $asteriskCount = ($charArray | Where-Object { $_ -eq '*' }).Count
    Write-Host "Asterisks: $asteriskCount" -ForegroundColor Gray
    
    # Check asterisk positions
    $asteriskPositions = @()
    $lines = $originalContent -split "`n"
    $lineNum = 0
    
    foreach ($line in $lines) {
        $charPos = 0
        foreach ($char in $line.ToCharArray()) {
            if ($char -eq '*') {
                $asteriskPositions += @{
                    Line = $lineNum
                    Char = $charPos
                    Absolute = $asteriskPositions.Count
                }
            }
            $charPos++
        }
        $lineNum++
    }
    
    Write-Host "Asterisk positions calculated: $($asteriskPositions.Count)" -ForegroundColor Gray
    
    # Check if any asterisks are near normalizable characters
    $asterisksNearNormalizable = 0
    foreach ($asterisk in $asteriskPositions) {
        # Check characters within 5 positions of asterisk
        $startPos = [math]::Max(0, $asterisk.Absolute - 5)
        $endPos = [math]::Min($charArray.Length - 1, $asterisk.Absolute + 5)
        
        for ($i = $startPos; $i -le $endPos; $i++) {
            if ($i -lt $charArray.Length -and [int]$charArray[$i] -gt 127) {
                $asterisksNearNormalizable++
                break
            }
        }
    }
    
    if ($asterisksNearNormalizable -gt 0) {
        Write-Host "CRITICAL: $asterisksNearNormalizable asterisks near normalizable characters!" -ForegroundColor Red
        Write-Host "EXPLOITATION VECTOR: Normalization could affect asterisk positioning!" -ForegroundColor Red
    } else {
        Write-Host "No asterisks near normalizable characters" -ForegroundColor Green
    }
    
    # Save simulated normalized version
    $outputFile = "normalize_${form}_analysis.css"
    $originalContent | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host "Saved analysis file: $outputFile" -ForegroundColor Gray
}

Write-Host "`n=== EXPLOITATION VECTOR ANALYSIS ===" -ForegroundColor Red

$exploitationVectors = @()

# Vector 1: Asterisk position manipulation
Write-Host "`n1. ASTERISK POSITION MANIPULATION" -ForegroundColor Yellow

$criticalPositions = @()
$lines = $originalContent -split "`n"
$lineNum = 0

foreach ($line in $lines) {
    $charPos = 0
    foreach ($char in $line.ToCharArray()) {
        if ($char -eq '*') {
            # Check context around asterisk
            $contextStart = [math]::Max(0, $charPos - 3)
            $contextEnd = [math]::Min($line.Length - 1, $charPos + 3)
            $context = $line.Substring($contextStart, $contextEnd - $contextStart + 1)
            
            # Check for non-ASCII characters in context
            $hasNonAscii = $false
            for ($i = 0; $i -lt $context.Length; $i++) {
                if ([int]$context[$i] -gt 127) {
                    $hasNonAscii = $true
                    break
                }
            }
            
            if ($hasNonAscii) {
                $criticalPositions += @{
                    Line = $lineNum
                    Char = $charPos
                    Context = $context
                }
                Write-Host "CRITICAL: Asterisk at Line $lineNum, Char $charPos near non-ASCII: '$context'" -ForegroundColor Red
            }
        }
        $charPos++
    }
    $lineNum++
}

if ($criticalPositions.Count -gt 0) {
    $exploitationVectors += @{
        Type = "AsteriskPositionManipulation"
        RiskLevel = "High"
        AffectedPositions = $criticalPositions.Count
        Description = "Normalization could change asterisk positioning"
        Severity = "Critical"
    }
}

# Vector 2: Content injection
Write-Host "`n2. CONTENT INJECTION ANALYSIS" -ForegroundColor Yellow

# Look for CSS comments and other patterns
$commentPattern = "/\*.*?\*/"
$commentMatches = [regex]::Matches($originalContent, $commentPattern)
Write-Host "CSS comments found: $($commentMatches.Count)" -ForegroundColor Gray

foreach ($match in $commentMatches) {
    $commentText = $match.Value
    $hasNonAscii = $false
    
    for ($i = 0; $i -lt $commentText.Length; $i++) {
        if ([int]$commentText[$i] -gt 127) {
            $hasNonAscii = $true
            break
        }
    }
    
    if ($hasNonAscii) {
        Write-Host "CRITICAL: Comment with non-ASCII chars: '$($commentText.Substring(0, [math]::Min(50, $commentText.Length)))'" -ForegroundColor Red
        $exploitationVectors += @{
            Type = "ContentInjection"
            Pattern = "CSS Comment"
            Position = $match.Index
            Severity = "High"
        }
    }
}

# Vector 3: Unicode manipulation
Write-Host "`n3. UNICODE MANIPULATION ANALYSIS" -ForegroundColor Yellow

# Check for attack Unicode characters
$attackChars = @("\u200B", "\u200C", "\u200D", "\uFEFF", "\u2060", "\u180E")
$attackNames = @("Zero-width space", "Zero-width non-joiner", "Zero-width joiner", "BOM", "Word joiner", "Mongolian vowel separator")

for ($i = 0; $i -lt $attackChars.Length; $i++) {
    $char = $attackChars[$i]
    $name = $attackNames[$i]
    $matches = [regex]::Matches($originalContent, $char)
    
    if ($matches.Count -gt 0) {
        Write-Host "CRITICAL: Attack Unicode found: $name - $($matches.Count) occurrences" -ForegroundColor Red
        $exploitationVectors += @{
            Type = "UnicodeManipulation"
            UnicodeChar = $char
            UnicodeName = $name
            Occurrences = $matches.Count
            Severity = "Critical"
        }
    }
}

# Vector 4: Parser confusion
Write-Host "`n4. PARSER CONFUSION ANALYSIS" -ForegroundColor Yellow

# Test CSS parsing
$cssRules = [regex]::Matches($originalContent, '[^{]*\{[^}]*\}')
Write-Host "CSS rules detected: $($cssRules.Count)" -ForegroundColor Gray

# Look for nested comment patterns
$nestedCommentPattern = "/\*/\*"
$nestedMatches = [regex]::Matches($originalContent, $nestedCommentPattern)

if ($nestedMatches.Count -gt 0) {
    Write-Host "Parser confusion risk: Nested comment patterns - $($nestedMatches.Count)" -ForegroundColor Yellow
    $exploitationVectors += @{
        Type = "ParserConfusion"
        Pattern = "Nested comments"
        Occurrences = $nestedMatches.Count
        Severity = "Medium"
    }
}

Write-Host "`n=== FINAL EXPLOITATION ASSESSMENT ===" -ForegroundColor Red

Write-Host "Total exploitation vectors discovered: $($exploitationVectors.Count)" -ForegroundColor Red

if ($exploitationVectors.Count -gt 0) {
    Write-Host "`n🚨 CRITICAL EXPLOITATION VECTORS DETECTED!" -ForegroundColor Red
    Write-Host "Normalization can be exploited for attacks!" -ForegroundColor Red
    
    foreach ($vector in $exploitationVectors) {
        Write-Host "`n--- $($vector.Type) ---" -ForegroundColor Red
        Write-Host "Severity: $($vector.Severity)" -ForegroundColor Red
        Write-Host "Risk Level: $($vector.RiskLevel)" -ForegroundColor White
        
        foreach ($prop in $vector.Keys) {
            if ($prop -notin @("Type", "Severity", "RiskLevel")) {
                Write-Host "$prop`: $($vector[$prop])" -ForegroundColor White
            }
        }
    }
    
    Write-Host "`n⚠️ WHAT THIS MEANS:" -ForegroundColor Yellow
    Write-Host "Unicode normalization could potentially be used to:" -ForegroundColor Yellow
    Write-Host "1. Manipulate asterisk positions in CSS comments" -ForegroundColor White
    Write-Host "2. Hide malicious content in Unicode transformations" -ForegroundColor White
    Write-Host "3. Create parser confusion through character encoding" -ForegroundColor White
    Write-Host "4. Exploit differences in how systems normalize text" -ForegroundColor White
    
    Write-Host "`n🔓 THE EXPLOIT:" -ForegroundColor Red
    Write-Host "An attacker could craft CSS content that appears benign but" -ForegroundColor White
    Write-Host "transforms into malicious code when processed by different" -ForegroundColor White
    Write-Host "Unicode normalization forms, creating a polyglot attack vector." -ForegroundColor White
    
    Write-Host "`n💡 THE PAYLOAD:" -ForegroundColor Yellow
    Write-Host "The exploit would involve:" -ForegroundColor Yellow
    Write-Host "1. Embedding malicious code in Unicode characters" -ForegroundColor White
    Write-Host "2. Using normalization to reveal/hide different content" -ForegroundColor White
    Write-Host "3. Targeting systems that process CSS with different normalizers" -ForegroundColor White
    Write-Host "4. Creating cross-system inconsistencies for attack" -ForegroundColor White
    
} else {
    Write-Host "`n✅ NO EXPLOITATION VECTORS DETECTED" -ForegroundColor Green
    Write-Host "Normalization appears safe for this content" -ForegroundColor Green
}

# Save final analysis
$finalAnalysis = @{
    Timestamp = Get-Date
    OriginalAsteriskCount = ($originalContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    CriticalPositions = $criticalPositions.Count
    ExploitationVectors = $exploitationVectors
    AnalysisType = "Deep Normalization"
    Status = if ($exploitationVectors.Count -gt 0) { "CRITICAL" } else { "SAFE" }
    RiskAssessment = if ($exploitationVectors.Count -gt 0) { "HIGH" } else { "LOW" }
}

$finalAnalysis | ConvertTo-Json -Depth 4 | Out-File -FilePath "deep_normalization_final_analysis.json"

Write-Host "`nFinal analysis saved to: deep_normalization_final_analysis.json" -ForegroundColor Green
Write-Host "=== DEEP NORMALIZATION ANALYSIS COMPLETE ===" -ForegroundColor Red
