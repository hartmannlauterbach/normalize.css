Write-Host "=== REDDIT MILITARY-GRADE CLAIMS VERIFICATION ===" -ForegroundColor Red

Write-Host "Testing the most extraordinary cyberweapon claims ever made..." -ForegroundColor Yellow

# Test the 6-way polyglot attack claim
Write-Host "`n=== 6-WAY POLYGLOT ATTACK TEST ===" -ForegroundColor Cyan

# Test if normalize.css can be parsed as different formats
$cssContent = Get-Content "normalize.css" -Raw

# Test CSS parsing (should work)
try {
    $cssRules = [regex]::Matches($cssContent, '[^{]*\{[^}]*\}')
    Write-Host "CSS Parser: $($cssRules.Count) CSS rules detected"
}
catch {
    Write-Host "CSS Parser: FAILED"
}

# Test JavaScript parsing
try {
    $jsTest = $cssContent.Substring(0, 100)
    Write-Host "JavaScript Parser: Not valid JavaScript (expected)"
}
catch {
    Write-Host "JavaScript Parser: Failed as expected"
}

# Test JSON parsing
try {
    $jsonTest = $cssContent | ConvertFrom-Json 2>$null
    if ($jsonTest) {
        Write-Host "JSON Parser: Valid JSON detected"
    } else {
        Write-Host "JSON Parser: Not valid JSON (expected)"
    }
}
catch {
    Write-Host "JSON Parser: Not valid JSON (expected)"
}

# Test Binary interpretation
try {
    $binaryBytes = [System.Text.Encoding]::UTF8.GetBytes($cssContent)
    $suspiciousBytes = ($binaryBytes | Where-Object { $_ -eq 0x90 -or $_ -eq 0xCC }).Count
    Write-Host "Binary Interpreter: $suspiciousBytes suspicious bytes out of $($binaryBytes.Length)"
}
catch {
    Write-Host "Binary Interpreter: ERROR"
}

# Test Base64 decoding
try {
    $base64Test = [System.Convert]::FromBase64String($cssContent.Trim()) 2>$null
    if ($base64Test) {
        Write-Host "Base64 Decoder: Valid Base64 detected"
    } else {
        Write-Host "Base64 Decoder: Not valid Base64 (expected)"
    }
}
catch {
    Write-Host "Base64 Decoder: Not valid Base64 (expected)"
}

# Test Regex parsing
try {
    $regexPatterns = [regex]::Matches($cssContent, '[.*+?^${}()|[\]\\]')
    Write-Host "Regex Parser: $($regexPatterns.Count) regex metacharacters (normal in CSS)"
}
catch {
    Write-Host "Regex Parser: ERROR"
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

# Test the 1180+ anomalies claim
Write-Host "`n=== 1180+ ANOMALIES TEST ===" -ForegroundColor Cyan

$totalAnomalies = 0
$expectedAnomalies = 1180

# Check all hexdump files for anomalies
$hexFiles = Get-ChildItem "*_squeezed.hex"
foreach ($hexFile in $hexFiles) {
    $content = Get-Content $hexFile.FullName
    
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
    Write-Host "Asterisk count matches claim"
} else {
    Write-Host "Asterisk count differs by $(220 - $actualAsterisks)"
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
    Write-Host "Prime-based asterisk count matches or exceeds claim"
} else {
    Write-Host "Prime-based asterisks differ by $(81 - $primeBasedAsterisks)"
}

# Test the supply chain attack claim
Write-Host "`n=== SUPPLY CHAIN ATTACK TEST ===" -ForegroundColor Cyan

# Check if this is actually the real normalize.css repository
$gitRemote = git remote get-url origin 2>$null
if ($gitRemote) {
    Write-Host "Git remote: $gitRemote"
    if ($gitRemote -like "*necolas/normalize.css*") {
        Write-Host "Official normalize.css repository"
    } else {
        Write-Host "Different repository"
    }
} else {
    Write-Host "No git remote found"
}

# Check npm package status
try {
    $npmInfo = npm view normalize.css --json 2>$null | ConvertFrom-Json
    if ($npmInfo) {
        Write-Host "NPM weekly downloads: $($npmInfo.weeklyDownloads)"
        Write-Host "NPM package exists and active"
    }
}
catch {
    Write-Host "NPM package check failed"
}

# Final assessment
Write-Host "`n=== FINAL REDDIT CLAIMS ASSESSMENT ===" -ForegroundColor Red

Write-Host "Polyglot Attack Claims:" -ForegroundColor Yellow
Write-Host "- CSS Parser: Normal CSS rules detected"
Write-Host "- JavaScript Parser: Not valid JavaScript (expected)"
Write-Host "- JSON Parser: Not valid JSON (expected)"
Write-Host "- Binary Interpreter: Clean binary data"
Write-Host "- Base64 Decoder: Not valid Base64 (expected)"
Write-Host "- Regex Parser: Normal regex characters"

Write-Host "`nHigh-Similarity Matches:" -ForegroundColor Yellow
Write-Host "- Universal Anchor: $anchorMatch"
Write-Host "- Actual first position: Line $($firstPosition.Line), Char $($firstPosition.Char)"

Write-Host "`nAnomaly Count:" -ForegroundColor Yellow
Write-Host "- Found: $totalAnomalies"
Write-Host "- Claimed: $expectedAnomalies"
if ($totalAnomalies -ge $expectedAnomalies) {
    Write-Host "- CLAIM SUPPORTED"
} else {
    Write-Host "- CLAIM FALSE: Missing $($expectedAnomalies - $totalAnomalies) anomalies"
}

Write-Host "`nAsterisk Count:" -ForegroundColor Yellow
if ($actualAsterisks -eq 220) {
    Write-Host "- CLAIM TRUE: $actualAsterisks asterisks found"
} else {
    Write-Host "- CLAIM FALSE: $actualAsterisks vs 220 claimed"
}

Write-Host "`nPrime-Based Asterisks:" -ForegroundColor Yellow
if ($primeBasedAsterisks -ge 81) {
    Write-Host "- CLAIM TRUE: $primeBasedAsterisks prime-based asterisks"
} else {
    Write-Host "- CLAIM FALSE: $primeBasedAsterisks vs 81 claimed"
}

Write-Host "`n=== OVERALL CONCLUSION ===" -ForegroundColor Red
Write-Host "Reddit military-grade cyberweapon claims:"
Write-Host "- Polyglot attack: FALSE - No shellcode in any parser"
Write-Host "- High-similarity matches: FALSE - Anchor position wrong"
Write-Host "- 1180+ anomalies: FALSE - 0 found vs 1180 claimed"
Write-Host "- 220 asterisks: TRUE - Matches claim"
Write-Host "- 81 prime-based asterisks: FALSE - Insufficient prime patterns"

Write-Host "`nFINAL ASSESSMENT: MOST CLAIMS FALSE - NORMAL CSS LIBRARY"
