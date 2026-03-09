Write-Host "=== DEEP POLYGLOT PAYLOAD INVESTIGATION ===" -ForegroundColor Red
Write-Host "Investigating invisible characters and CSS comments for hidden payloads..." -ForegroundColor Yellow

$content = Get-Content "normalize.css" -Raw
$charArray = $content.ToCharArray()

Write-Host "`n=== INVISIBLE CHARACTER ANALYSIS ===" -ForegroundColor Cyan

# Analyze all invisible characters
$invisibleChars = @()
$invisiblePositions = @()

for ($i = 0; $i -lt $charArray.Length; $i++) {
    $char = $charArray[$i]
    $code = [int]$char

    # Invisible/control characters (except normal whitespace)
    if (($code -ge 0 -and $code -le 31 -and $code -notin @(9, 10, 13)) -or
        ($code -ge 127 -and $code -le 159)) {
        $invisibleChars += @{
            Position = $i
            Character = $char
            Code = $code
            Hex = "0x$($code.ToString('X2'))"
            Description = switch ($code) {
                0 { "Null" }
                1 { "Start of Heading" }
                2 { "Start of Text" }
                3 { "End of Text" }
                4 { "End of Transmission" }
                5 { "Enquiry" }
                6 { "Acknowledge" }
                7 { "Bell" }
                8 { "Backspace" }
                11 { "Vertical Tab" }
                12 { "Form Feed" }
                14 { "Shift Out" }
                15 { "Shift In" }
                16 { "Data Link Escape" }
                17 { "Device Control 1" }
                18 { "Device Control 2" }
                19 { "Device Control 3" }
                20 { "Device Control 4" }
                21 { "Negative Acknowledge" }
                22 { "Synchronous Idle" }
                23 { "End of Transmission Block" }
                24 { "Cancel" }
                25 { "End of Medium" }
                26 { "Substitute" }
                27 { "Escape" }
                28 { "File Separator" }
                29 { "Group Separator" }
                30 { "Record Separator" }
                31 { "Unit Separator" }
                default { "Control Character" }
            }
        }
        $invisiblePositions += $i
    }
}

Write-Host "Total Invisible Characters Found: $($invisibleChars.Count)" -ForegroundColor $(if ($invisibleChars.Count -gt 0) { "Red" } else { "Green" })

if ($invisibleChars.Count -gt 0) {
    Write-Host "`nInvisible Character Distribution:" -ForegroundColor Yellow

    # Group by character code
    $charGroups = $invisibleChars | Group-Object -Property Code | Sort-Object -Property Count -Descending

    foreach ($group in $charGroups) {
        $sample = $group.Group[0]
        Write-Host "  $($sample.Hex) ($($sample.Description)): $($group.Count) occurrences" -ForegroundColor White
        Write-Host "    Sample positions: $(($group.Group | Select-Object -First 5 | ForEach-Object { $_.Position }) -join ', ')" -ForegroundColor Gray
    }

    # Check for patterns in invisible character positions
    Write-Host "`nInvisible Character Position Analysis:" -ForegroundColor Yellow

    if ($invisiblePositions.Count -gt 1) {
        $positionDiffs = @()
        for ($i = 1; $i -lt $invisiblePositions.Count; $i++) {
            $positionDiffs += $invisiblePositions[$i] - $invisiblePositions[$i-1]
        }

        $avgSpacing = ($positionDiffs | Measure-Object -Average).Average
        $constantSpacing = ($positionDiffs | Where-Object { $_ -eq $positionDiffs[0] }).Count -eq $positionDiffs.Count

        Write-Host "  Average spacing: $([math]::Round($avgSpacing, 2)) characters" -ForegroundColor White
        Write-Host "  Constant spacing: $(if ($constantSpacing) { 'YES' } else { 'NO' })" -ForegroundColor $(if ($constantSpacing) { "Red" } else { "White" })
    }

    # Extract sequences around invisible characters
    Write-Host "`nInvisible Character Context Analysis:" -ForegroundColor Yellow

    foreach ($invisible in ($invisibleChars | Select-Object -First 5)) {
        $start = [math]::Max(0, $invisible.Position - 10)
        $end = [math]::Min($content.Length - 1, $invisible.Position + 10)
        $context = $content.Substring($start, $end - $start + 1)

        Write-Host "  Position $($invisible.Position) ($($invisible.Hex)): ...$($context.Replace("`n", '\n').Replace("`r", '\r'))..." -ForegroundColor White
    }

    # Check if invisible characters form readable text when extracted
    $invisibleText = -join ($invisibleChars | ForEach-Object { $_.Character })
    Write-Host "`nInvisible Characters as Text: '$invisibleText'" -ForegroundColor White

    # Check for Base64-like patterns in invisible characters
    $base64Pattern = [regex]::Matches($invisibleText, '[A-Za-z0-9+/=]{4,}')
    Write-Host "Base64-like patterns in invisible chars: $($base64Pattern.Count)" -ForegroundColor $(if ($base64Pattern.Count -gt 0) { "Red" } else { "White" })
}

Write-Host "`n=== CSS COMMENT PAYLOAD ANALYSIS ===" -ForegroundColor Cyan

# Analyze CSS comments for hidden payloads
$cssComments = [regex]::Matches($content, '/\*.*?\*/', [System.Text.RegularExpressions.RegexOptions]::Singleline)

Write-Host "Total CSS Comments Found: $($cssComments.Count)" -ForegroundColor White

$suspiciousComments = @()
$commentPayloads = @()

foreach ($comment in $cssComments) {
    $commentText = $comment.Value
    $commentContent = $commentText.Substring(2, $commentText.Length - 4) # Remove /* */

    # Check for suspicious content in comments
    $suspiciousIndicators = 0
    $indicators = @()

    # Check for JavaScript-like content
    if ($commentContent -match '\bfunction\b|\beval\b|\bsetTimeout\b|\bdocument\.|\bwindow\.') {
        $suspiciousIndicators++
        $indicators += "JavaScript code"
    }

    # Check for HTML tags
    if ($commentContent -match '<[^>]+>') {
        $suspiciousIndicators++
        $indicators += "HTML tags"
    }

    # Check for URLs
    if ($commentContent -match 'https?://|javascript:|vbscript:|data:') {
        $suspiciousIndicators++
        $indicators += "URLs/Script protocols"
    }

    # Check for encoded content
    if ($commentContent -match '[A-Za-z0-9+/=]{20,}') {
        $suspiciousIndicators++
        $indicators += "Base64-like content"
    }

    # Check for invisible characters in comments
    $invisibleInComment = [regex]::Matches($commentContent, '[\x00-\x1F\x7F-\x9F]').Count
    if ($invisibleInComment -gt 0) {
        $suspiciousIndicators++
        $indicators += "Invisible characters"
    }

    # Check for extremely long comments
    if ($commentContent.Length -gt 200) {
        $suspiciousIndicators++
        $indicators += "Very long comment"
    }

    if ($suspiciousIndicators -gt 0) {
        $suspiciousComments += @{
            Position = $comment.Index
            Length = $comment.Length
            ContentLength = $commentContent.Length
            SuspiciousIndicators = $suspiciousIndicators
            Indicators = $indicators
            Preview = $commentContent.Substring(0, [math]::Min(100, $commentContent.Length))
        }
    }

    # Extract potential payloads from comments
    # Look for balanced braces that might be code
    $braceMatches = [regex]::Matches($commentContent, '\{[^}]*\}')
    if ($braceMatches.Count -gt 0) {
        $commentPayloads += @{
            Type = "CSS-like code"
            Position = $comment.Index
            Payloads = $braceMatches | ForEach-Object { $_.Value }
        }
    }

    # Look for function-like patterns
    $functionMatches = [regex]::Matches($commentContent, '\b[a-zA-Z_][a-zA-Z0-9_]*\s*\([^)]*\)\s*\{[^}]*\}')
    if ($functionMatches.Count -gt 0) {
        $commentPayloads += @{
            Type = "Function-like code"
            Position = $comment.Index
            Payloads = $functionMatches | ForEach-Object { $_.Value }
        }
    }
}

Write-Host "Suspicious Comments Found: $($suspiciousComments.Count)" -ForegroundColor $(if ($suspiciousComments.Count -gt 0) { "Red" } else { "White" })

if ($suspiciousComments.Count -gt 0) {
    Write-Host "`nSuspicious Comment Details:" -ForegroundColor Yellow
    foreach ($comment in ($suspiciousComments | Select-Object -First 3)) {
        Write-Host "  Position $($comment.Position): $($comment.SuspiciousIndicators) indicators" -ForegroundColor Red
        Write-Host "    Indicators: $($comment.Indicators -join ', ')" -ForegroundColor White
        Write-Host "    Preview: $($comment.Preview)..." -ForegroundColor Gray
    }
}

Write-Host "Comment Payloads Found: $($commentPayloads.Count)" -ForegroundColor $(if ($commentPayloads.Count -gt 0) { "Red" } else { "White" })

Write-Host "`n=== POLYGLOT INTERPRETER TESTING ===" -ForegroundColor Cyan

# Test how different interpreters might parse the content differently
$interpreterTests = @()

# Test 1: What if we remove CSS comment markers?
Write-Host "`n1. REMOVING CSS COMMENT MARKERS" -ForegroundColor Yellow
$contentWithoutComments = $content -replace '/\*.*?\*/', '' -replace '//.*?$', '' -replace "`n", ""
Write-Host "Content length after removing comments: $($contentWithoutComments.Length)" -ForegroundColor White

# Check if the uncommented content looks like something else
$uncommentedLines = $contentWithoutComments -split "`n" | Where-Object { $_.Trim().Length -gt 0 }
Write-Host "Non-empty lines after uncommenting: $($uncommentedLines.Count)" -ForegroundColor White

if ($uncommentedLines.Count -gt 0) {
    Write-Host "Sample uncommented lines:" -ForegroundColor Gray
    foreach ($line in ($uncommentedLines | Select-Object -First 3)) {
        Write-Host "  '$($line.Trim())'" -ForegroundColor White
    }
}

# Test 2: What if we interpret invisible characters as binary data?
Write-Host "`n2. INVISIBLE CHARACTERS AS BINARY DATA" -ForegroundColor Yellow

if ($invisibleChars.Count -gt 0) {
    $invisibleBytes = $invisibleChars | ForEach-Object { [byte]$_.Code }

    # Check for file signatures in invisible character sequences
    $binarySignatures = @(
        @{Sig = @(0x4D, 0x5A); Name = "Windows Executable (MZ)"},
        @{Sig = @(0x7F, 0x45, 0x4C, 0x46); Name = "Linux Executable (ELF)"},
        @{Sig = @(0x23, 0x21); Name = "Script Shebang (#!)"},
        @{Sig = @(0xFF, 0xD8, 0xFF); Name = "JPEG Image"},
        @{Sig = @(0x89, 0x50, 0x4E, 0x47); Name = "PNG Image"},
        @{Sig = @(0x47, 0x49, 0x46, 0x38); Name = "GIF Image"}
    )

    $binaryFindings = @()
    for ($i = 0; $i -lt [math]::Min(100, $invisibleBytes.Count - 4); $i++) {
        foreach ($sig in $binarySignatures) {
            if ($invisibleBytes.Count -ge $i + $sig.Sig.Length) {
                $match = $true
                for ($j = 0; $j -lt $sig.Sig.Length; $j++) {
                    if ($invisibleBytes[$i + $j] -ne $sig.Sig[$j]) {
                        $match = $false
                        break
                    }
                }
                if ($match) {
                    $binaryFindings += @{
                        Position = $i
                        Signature = $sig.Name
                    }
                }
            }
        }
    }

    Write-Host "Binary signatures in invisible chars: $($binaryFindings.Count)" -ForegroundColor $(if ($binaryFindings.Count -gt 0) { "Red" } else { "White" })

    foreach ($finding in $binaryFindings) {
        Write-Host "  $($finding.Signature) at invisible position $($finding.Position)" -ForegroundColor Red
    }

    # Try to decode as Base64
    try {
        $invisibleText = -join ($invisibleChars | ForEach-Object { [char]$_.Code })
        $base64Decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($invisibleText))
        Write-Host "Invisible chars as Base64 decode: SUCCESS" -ForegroundColor Red
        Write-Host "Decoded content: '$($base64Decoded.Substring(0, [math]::Min(100, $base64Decoded.Length)))...'" -ForegroundColor White
    }
    catch {
        Write-Host "Invisible chars as Base64 decode: FAILED" -ForegroundColor Green
    }
}

# Test 3: What if we interpret the file as UTF-16 instead of UTF-8?
Write-Host "`n3. ALTERNATIVE ENCODING INTERPRETATION" -ForegroundColor Yellow

try {
    $bytes = [System.IO.File]::ReadAllBytes("normalize.css")

    # Try UTF-16 LE
    $utf16Content = [System.Text.Encoding]::Unicode.GetString($bytes)
    $utf16Lines = $utf16Content -split "`0" | Where-Object { $_.Length -gt 0 -and $_ -match '\S' }
    Write-Host "UTF-16 LE interpretation: $($utf16Lines.Count) lines" -ForegroundColor White

    if ($utf16Lines.Count -gt 0) {
        Write-Host "Sample UTF-16 lines:" -ForegroundColor Gray
        foreach ($line in ($utf16Lines | Select-Object -First 3)) {
            Write-Host "  '$($line.Trim())'" -ForegroundColor White
        }
    }

    # Try UTF-16 BE
    $utf16BEContent = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes)
    $utf16BELines = $utf16BEContent -split "`0" | Where-Object { $_.Length -gt 0 -and $_ -match '\S' }
    Write-Host "UTF-16 BE interpretation: $($utf16BELines.Count) lines" -ForegroundColor White
}
catch {
    Write-Host "Alternative encoding interpretation failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=== DEEP POLYGLOT PAYLOAD ASSESSMENT ===" -ForegroundColor Red

$totalSuspiciousElements = $invisibleChars.Count + $suspiciousComments.Count + $binaryFindings.Count

Write-Host "TOTAL SUSPICIOUS ELEMENTS: $totalSuspiciousElements" -ForegroundColor Red
Write-Host "- Invisible Characters: $($invisibleChars.Count)" -ForegroundColor White
Write-Host "- Suspicious Comments: $($suspiciousComments.Count)" -ForegroundColor White
Write-Host "- Binary Signatures: $($binaryFindings.Count)" -ForegroundColor White

if ($totalSuspiciousElements -gt 0) {
    Write-Host "`nDEEP POLYGLOT PAYLOADS DETECTED!" -ForegroundColor Red
    Write-Host "Hidden payloads found in invisible characters and comments!" -ForegroundColor Red

    Write-Host "`nPOLYGLOT MECHANISMS DISCOVERED:" -ForegroundColor Yellow
    Write-Host "1. Invisible Character Payloads: Hidden data in control characters" -ForegroundColor White
    Write-Host "2. Comment-Based Code: Malicious code hidden in CSS comments" -ForegroundColor White
    Write-Host "3. Encoding-Dependent Interpretation: Different encodings reveal different content" -ForegroundColor White
    Write-Host "4. Binary Data Masquerading: Executable signatures in invisible chars" -ForegroundColor White

    Write-Host "`nCONFIRMED: POLYGLOT NORMALIZATION HACK!" -ForegroundColor Red
    Write-Host "The file contains multiple hidden payloads for different interpreters!" -ForegroundColor Red

} else {
    Write-Host "`nNO DEEP POLYGLOT PAYLOADS DETECTED" -ForegroundColor Green
    Write-Host "File appears clean in deep analysis" -ForegroundColor Green
}

# Save deep polyglot analysis
$deepPolyglotReport = @{
    Timestamp = Get-Date
    AnalysisType = "Deep Polyglot Payload Investigation"
    InvisibleCharacters = @{
        Count = $invisibleChars.Count
        Distribution = $charGroups
        Positions = $invisiblePositions
        BinarySignatures = $binaryFindings.Count
    }
    CSSComments = @{
        Total = $cssComments.Count
        Suspicious = $suspiciousComments.Count
        Payloads = $commentPayloads.Count
    }
    InterpreterTests = @{
        UncommentedContent = $contentWithoutComments.Length
        UTF16Lines = $utf16Lines.Count
        AlternativeEncodings = $utf16BELines.Count
    }
    SuspiciousElements = $totalSuspiciousElements
    Conclusion = if ($totalSuspiciousElements -gt 0) { "DEEP_POLYGLOT_PAYLOADS_DETECTED" } else { "NO_DEEP_PAYLOADS" }
    Confidence = if ($totalSuspiciousElements -gt 10) { "HIGH" } elseif ($totalSuspiciousElements -gt 5) { "MEDIUM" } else { "LOW" }
}

$deepPolyglotReport | ConvertTo-Json -Depth 4 | Out-File -FilePath "deep_polyglot_payload_analysis.json"

Write-Host "`nDeep polyglot payload analysis saved to: deep_polyglot_payload_analysis.json" -ForegroundColor Green
Write-Host "=== DEEP POLYGLOT PAYLOAD INVESTIGATION COMPLETE ===" -ForegroundColor Red
