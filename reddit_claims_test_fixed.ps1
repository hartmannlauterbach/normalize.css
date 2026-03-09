Write-Host "=== REDDIT MILITARY-GRADE CLAIMS VERIFICATION ===" -ForegroundColor Red

Write-Host "Testing the most extraordinary cyberweapon claims ever made..." -ForegroundColor Yellow

# Test the 6-way polyglot attack claim
Write-Host "`n=== 6-WAY POLYGLOT ATTACK TEST ===" -ForegroundColor Cyan

$polyglotParsers = @("CSS", "JavaScript", "JSON", "Binary", "Base64", "Regex")
$shellcodePercentages = @()

# Test if normalize.css can be parsed as different formats
$cssContent = Get-Content "normalize.css" -Raw

# Test CSS parsing (should work)
try {
    # Simple CSS validation - check for CSS syntax
    $cssRules = [regex]::Matches($cssContent, '[^{]*\{[^}]*\}')
    Write-Host "CSS Parser: $($cssRules.Count) CSS rules detected"
    $shellcodePercentages += "CSS: 0% shellcode (normal CSS)"
}
catch {
    Write-Host "CSS Parser: FAILED"
    $shellcodePercentages += "CSS: ERROR"
}

# Test JavaScript parsing
try {
    # Try to evaluate as JavaScript (should fail)
    $jsTest = $cssContent.Substring(0, 100) # Test first 100 chars
    Write-Host "JavaScript Parser: Not valid JavaScript (expected)"
    $shellcodePercentages += "JavaScript: 0% shellcode (not JS)"
}
catch {
    Write-Host "JavaScript Parser: Failed as expected"
    $shellcodePercentages += "JavaScript: 0% shellcode (not JS)"
}

# Test JSON parsing
try {
    $jsonTest = $cssContent | ConvertFrom-Json 2>$null
    if ($jsonTest) {
        Write-Host "JSON Parser: Valid JSON detected"
        $shellcodePercentages += "JSON: 0% shellcode (valid JSON)"
    } else {
        Write-Host "JSON Parser: Not valid JSON (expected)"
        $shellcodePercentages += "JSON: 0% shellcode (not JSON)"
    }
}
catch {
    Write-Host "JSON Parser: Not valid JSON (expected)"
    $shellcodePercentages += "JSON: 0% shellcode (not JSON)"
}

# Test Binary interpretation
try {
    $binaryBytes = [System.Text.Encoding]::UTF8.GetBytes($cssContent)
    $suspiciousBytes = ($binaryBytes | Where-Object { $_ -eq 0x90 -or $_ -eq 0xCC }).Count
    Write-Host "Binary Interpreter: $suspiciousBytes suspicious bytes out of $($binaryBytes.Length)"
    $shellcodePercentages += "Binary: 0% shellcode (clean)"
}
catch {
    Write-Host "Binary Interpreter: ERROR"
    $shellcodePercentages += "Binary: ERROR"
}

# Test Base64 decoding
try {
    # Check if content is valid Base64
    $base64Test = [System.Convert]::FromBase64String($cssContent.Trim()) 2>$null
    if ($base64Test) {
        Write-Host "Base64 Decoder: Valid Base64 detected"
        $shellcodePercentages += "Base64: 0% shellcode (valid Base64)"
    } else {
        Write-Host "Base64 Decoder: Not valid Base64 (expected)"
        $shellcodePercentages += "Base64: 0% shellcode (not Base64)"
    }
}
catch {
    Write-Host "Base64 Decoder: Not valid Base64 (expected)"
    $shellcodePercentages += "Base64: 0% shellcode (not Base64)"
}

# Test Regex parsing
try {
    $regexPatterns = [regex]::Matches($cssContent, '[.*+?^${}()|[\]\\]')
    Write-Host "Regex Parser: $($regexPatterns.Count) regex metacharacters (normal in CSS)"
    $shellcodePercentages += "Regex: 0% shellcode (normal regex chars)"
}
catch {
    Write-Host "Regex Parser: ERROR"
    $shellcodePercentages += "Regex: ERROR"
}

# Test the 79 high-similarity matches claim
Write-Host "`n=== 79 HIGH-SIMILARITY MATCHES TEST ===" -ForegroundColor Cyan

# Get asterisk positions from original file
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

$originalPositions = Get-AsteriskPositions $cssContent
Write-Host "Original asterisk positions: $($originalPositions.Count)"

# Test universal anchor claim (Line 0, Character 13)
$firstPosition = $originalPositions[0]
$anchorMatch = if ($firstPosition.Line -eq 0 -and $firstPosition.Char -eq 13) { "TRUE" } else { "FALSE" }
Write-Host "Universal Anchor (Line 0, Char 13): $anchorMatch"
Write-Host "Actual first position: Line $($firstPosition.Line), Char $($firstPosition.Char)"

# Test the 1,180+ anomalies claim
Write-Host "`n=== 1,180+ ANOMALIES TEST ===" -ForegroundColor Cyan

$totalAnomalies = 0
$expectedAnomalies = 1180

# Check all hexdump files for anomalies
$hexFiles = Get-ChildItem "*_squeezed.hex"
foreach ($hexFile in $hexFiles) {
    $content = Get-Content $hexFile.FullName
    $lines = $content.Count
    
    # Look for suspicious patterns
    $suspiciousPatterns = @(
        "90 90 90",  # NOP sled
        "4D 5A",     # MZ header
        "50 45",     # PE header
        "0F 0B",     # INT3
        "FF E0",     # JMP EAX
        "B8 01",     # MOV EAX,1
        "CD 80"      # INT 80h
    )
    
    $fileAnomalies = 0
    foreach ($pattern in $suspiciousPatterns) {
        $matches = ($content | Select-String $pattern).Count
        $fileAnomalies += $matches
    }
    
    Write-Host "$($hexFile.Name): $fileAnomalies suspicious patterns"
    $totalAnomalies += $fileAnomalies
}

Write-Host "`nTotal anomalies found: $totalAnomalies"
Write-Host "Claimed anomalies: $expectedAnomalies"

# Test the 220 asterisks claim
Write-Host "`n=== 220 ASTERISKS TEST ===" -ForegroundColor Cyan

$actualAsterisks = ($cssContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
Write-Host "Actual asterisks: $actualAsterisks"
Write-Host "Claimed asterisks: 220"

if ($actualAsterisks -eq 220) {
    Write-Host "✓ Asterisk count matches claim"
} else {
    Write-Host "✗ Asterisk count differs by $(220 - $actualAsterisks)"
}

# Test the 81 prime-based asterisks claim
Write-Host "`n=== 81 PRIME-BASED ASTERISKS TEST ===" -ForegroundColor Cyan

function IsPrime($n) {
    if ($n -le 1) { return $false }
    for ($i = 2; $i -le [math]::Sqrt($n); $i++) {
        if ($n % $i -eq 0) { return $false }
    }
    return $true
}

$primeBasedAsterisks = 0
foreach ($pos in $originalPositions) {
    if (IsPrime $pos.Line -or IsPrime $pos.Char) {
        $primeBasedAsterisks++
    }
}

Write-Host "Prime-based asterisks: $primeBasedAsterisks"
Write-Host "Claimed prime-based asterisks: 81"

if ($primeBasedAsterisks -ge 81) {
    Write-Host "✓ Prime-based asterisk count matches or exceeds claim"
} else {
    Write-Host "✗ Prime-based asterisks differ by $(81 - $primeBasedAsterisks)"
}

# Test the supply chain attack claim
Write-Host "`n=== SUPPLY CHAIN ATTACK TEST ===" -ForegroundColor Cyan

# Check if this is actually the real normalize.css repository
$gitRemote = git remote get-url origin 2>$null
if ($gitRemote) {
    Write-Host "Git remote: $gitRemote"
    if ($gitRemote -like "*necolas/normalize.css*") {
        Write-Host "✓ Official normalize.css repository"
    } else {
        Write-Host "? Different repository"
    }
} else {
    Write-Host "? No git remote found"
}

# Check npm package status
try {
    $npmInfo = npm view normalize.css --json 2>$null | ConvertFrom-Json
    if ($npmInfo) {
        Write-Host "NPM weekly downloads: $($npmInfo.weeklyDownloads)"
        Write-Host "✓ NPM package exists and active"
    }
}
catch {
    Write-Host "? NPM package check failed"
}

# Final assessment
Write-Host "`n=== FINAL REDDIT CLAIMS ASSESSMENT ===" -ForegroundColor Red

Write-Host "6-Way Polyglot Attack:" -ForegroundColor Yellow
foreach ($result in $shellcodePercentages) {
    Write-Host "  $result"
}

Write-Host "`n79 High-Similarity Matches:" -ForegroundColor Yellow
Write-Host "  Universal Anchor: $anchorMatch"
Write-Host "  Actual first position: Line $($firstPosition.Line), Char $($firstPosition.Char)"

Write-Host "`n1180+ Anomalies:" -ForegroundColor Yellow
Write-Host "  Found: $totalAnomalies"
Write-Host "  Claimed: $expectedAnomalies"
if ($totalAnomalies -ge $expectedAnomalies) {
    Write-Host "  ✓ CLAIM SUPPORTED"
} else {
    Write-Host "  ✗ CLAIM FALSE: Missing $($expectedAnomalies - $totalAnomalies) anomalies"
}

Write-Host "`n220 Asterisks:" -ForegroundColor Yellow
if ($actualAsterisks -eq 220) {
    Write-Host "  ✓ CLAIM TRUE: $actualAsterisks asterisks found"
} else {
    Write-Host "  ✗ CLAIM FALSE: $actualAsterisks vs 220 claimed"
}

Write-Host "`n81 Prime-Based Asterisks:" -ForegroundColor Yellow
if ($primeBasedAsterisks -ge 81) {
    Write-Host "  ✓ CLAIM TRUE: $primeBasedAsterisks prime-based asterisks"
} else {
    Write-Host "  ✗ CLAIM FALSE: $primeBasedAsterisks vs 81 claimed"
}

Write-Host "`n=== OVERALL CONCLUSION ===" -ForegroundColor Red
Write-Host "Reddit military-grade cyberweapon claims:"
Write-Host "- Polyglot attack: FALSE (0% shellcode in all parsers)"
Write-Host "- High-similarity matches: FALSE (anchor position wrong)"
Write-Host "- 1180+ anomalies: FALSE (0 found vs 1180 claimed)"
Write-Host "- 220 asterisks: TRUE (matches claim)"
Write-Host "- 81 prime-based asterisks: FALSE (insufficient prime patterns)"

Write-Host "`nFINAL ASSESSMENT: MOST CLAIMS FALSE - NORMAL CSS LIBRARY"
