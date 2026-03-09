Write-Host "=== COMPREHENSIVE ANOMALY DETECTION ANALYSIS ===" -ForegroundColor Red

Write-Host "Searching for ANY and ALL anomalies in normalize.css..." -ForegroundColor Yellow

# Initialize anomaly tracking
$allAnomalies = @()
$anomalyCategories = @{
    "BinaryPatterns" = @()
    "CharacterAnomalies" = @()
    "EncodingIssues" = @()
    "StructuralAnomalies" = @()
    "MathematicalAnomalies" = @()
    "ContentAnomalies" = @()
    "FileStructureAnomalies" = @()
    "NetworkAnomalies" = @()
    "SystemAnomalies" = @()
}

# Read original file
$originalContent = Get-Content "normalize.css" -Raw
$originalBytes = [System.IO.File]::ReadAllBytes("normalize.css")

Write-Host "`n=== BINARY PATTERN ANALYSIS ===" -ForegroundColor Cyan

# Analyze binary patterns
$suspiciousBytePatterns = @(
    @{Pattern = [byte[]]0x90,0x90,0x90; Name = "NOP sled"},
    @{Pattern = [byte[]]0x4D,0x5A; Name = "MZ header"},
    @{Pattern = [byte[]]0x50,0x45; Name = "PE header"},
    @{Pattern = [byte[]]0x0F,0x0B; Name = "INT3 breakpoint"},
    @{Pattern = [byte[]]0xFF,0xE0; Name = "JMP EAX"},
    @{Pattern = [byte[]]0xB8,0x01,0x00,0x00,0x00; Name = "MOV EAX,1"},
    @{Pattern = [byte[]]0xCD,0x80; Name = "INT 80h"},
    @{Pattern = [byte[]]0x7F,0x45,0x4C,0x46; Name = "ELF header"}
)

foreach ($suspicious in $suspiciousBytePatterns) {
    $pattern = $suspicious.Pattern
    $name = $suspicious.Name
    
    for ($i = 0; $i -le $originalBytes.Length - $pattern.Length; $i++) {
        $match = $true
        for ($j = 0; $j -lt $pattern.Length; $j++) {
            if ($originalBytes[$i + $j] -ne $pattern[$j]) {
                $match = $false
                break
            }
        }
        
        if ($match) {
            $anomaly = @{
                Type = "BinaryPattern"
                Name = $name
                Position = $i
                Bytes = [string]::Join(" ", ($originalBytes[$i..($i + $pattern.Length - 1)] | ForEach-Object { "{0:X2}" -f $_ }))
                Severity = "High"
            }
            $allAnomalies += $anomaly
            $anomalyCategories["BinaryPatterns"] += $anomaly
            Write-Host "FOUND: $name at position $i" -ForegroundColor Red
        }
    }
}

# Check for unusual byte sequences
$byteFrequency = @{}
for ($i = 0; $i -lt $originalBytes.Length; $i++) {
    $byte = $originalBytes[$i]
    $byteFrequency[$byte] = $byteFrequency[$byte] + 1
}

# Look for bytes with unusual frequency
$avgFrequency = $originalBytes.Length / 256
foreach ($byte in $byteFrequency.Keys) {
    $frequency = $byteFrequency[$byte]
    if ($frequency -lt $avgFrequency / 10 -or $frequency -gt $avgFrequency * 10) {
        $anomaly = @{
            Type = "ByteFrequency"
            Byte = "0x{0:X2}" -f $byte
            Frequency = $frequency
            Expected = $avgFrequency
            Severity = "Medium"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["BinaryPatterns"] += $anomaly
    }
}

Write-Host "`n=== CHARACTER ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Analyze character anomalies
$chars = $originalContent.ToCharArray()
$charFrequency = @()
$invisibleChars = @()
$controlChars = @()
$unicodeAnomalies = @()

for ($i = 0; $i -lt $chars.Length; $i++) {
    $char = $chars[$i]
    $charCode = [int]$char
    
    # Check for invisible characters
    if ($charCode -eq 9 -or $charCode -eq 10 -or $charCode -eq 13 -or $charCode -eq 32) {
        # Normal whitespace, continue
    } elseif ($charCode -lt 32 -or ($charCode -ge 127 -and $charCode -le 159)) {
        $controlChars += @{Char = $char; Code = $charCode; Position = $i}
        $anomaly = @{
            Type = "ControlCharacter"
            Character = $char
            Code = "0x{0:X4}" -f $charCode
            Position = $i
            Severity = "Medium"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["CharacterAnomalies"] += $anomaly
    } elseif ($charCode -gt 127) {
        $unicodeAnomalies += @{Char = $char; Code = $charCode; Position = $i}
        $anomaly = @{
            Type = "UnicodeCharacter"
            Character = $char
            Code = "U+{0:X4}" -f $charCode
            Position = $i
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["CharacterAnomalies"] += $anomaly
    }
}

Write-Host "Control characters found: $($controlChars.Count)"
Write-Host "Unicode characters found: $($unicodeAnomalies.Count)"

# Check for suspicious character sequences
$suspiciousSequences = @(
    @{Pattern = "`0"; Name = "Null byte"},
    @{Pattern = "`b"; Name = "Backspace"},
    @{Pattern = "`f"; Name = "Form feed"},
    @{Pattern = "`v"; Name = "Vertical tab"},
    @{Pattern = "`uFEFF"; Name = "BOM"},
    @{Pattern = "`u200B"; Name = "Zero-width space"},
    @{Pattern = "`u200C"; Name = "Zero-width non-joiner"},
    @{Pattern = "`u200D"; Name = "Zero-width joiner"}
)

foreach ($seq in $suspiciousSequences) {
    $matches = [regex]::Matches($originalContent, [regex]::Escape($seq.Pattern))
    if ($matches.Count -gt 0) {
        Write-Host "FOUND: $($seq.Name) - $($matches.Count) occurrences" -ForegroundColor Red
        foreach ($match in $matches) {
            $anomaly = @{
                Type = "SuspiciousSequence"
                Name = $seq.Name
                Pattern = $seq.Pattern
                Position = $match.Index
                Severity = "Medium"
            }
            $allAnomalies += $anomaly
            $anomalyCategories["CharacterAnomalies"] += $anomaly
        }
    }
}

Write-Host "`n=== ENCODING ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Test encoding conversions
$encodingTests = @(
    @{Name = "UTF-16LE"; Encoding = "Unicode"},
    @{Name = "UTF-16BE"; Encoding = "BigEndianUnicode"},
    @{Name = "UTF-32LE"; Encoding = "UTF32"},
    @{Name = "UTF-32BE"; Encoding = "UTF32BE"},
    @{Name = "UTF-7"; Encoding = "UTF7"}
)

foreach ($test in $encodingTests) {
    $encodedFile = "normalize_$($test.Name.ToLower()).css"
    if (Test-Path $encodedFile) {
        try {
            if ($test.Encoding -eq "UTF32BE") {
                $bytes = [System.IO.File]::ReadAllBytes($encodedFile)
                $decodedContent = [System.Text.Encoding]::GetEncoding("utf-32BE").GetString($bytes)
            } else {
                $encoding = [System.Text.Encoding]::$($test.Encoding)
                $bytes = [System.IO.File]::ReadAllBytes($encodedFile)
                $decodedContent = $encoding.GetString($bytes)
            }
            
            # Compare with original
            if ($decodedContent.Length -ne $originalContent.Length) {
                $anomaly = @{
                    Type = "EncodingMismatch"
                    Encoding = $test.Name
                    OriginalLength = $originalContent.Length
                    DecodedLength = $decodedContent.Length
                    Difference = $decodedContent.Length - $originalContent.Length
                    Severity = "Medium"
                }
                $allAnomalies += $anomaly
                $anomalyCategories["EncodingIssues"] += $anomaly
                Write-Host "ENCODING ANOMALY: $($test.Name) length differs by $($anomaly.Difference)" -ForegroundColor Red
            }
            
            # Check asterisk preservation
            $originalAsterisks = ($originalContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
            $decodedAsterisks = ($decodedContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
            
            if ($decodedAsterisks -ne $originalAsterisks) {
                $anomaly = @{
                    Type = "AsteriskLoss"
                    Encoding = $test.Name
                    OriginalCount = $originalAsterisks
                    DecodedCount = $decodedAsterisks
                    Lost = $originalAsterisks - $decodedAsterisks
                    Severity = "High"
                }
                $allAnomalies += $anomaly
                $anomalyCategories["EncodingIssues"] += $anomaly
                Write-Host "ENCODING ANOMALY: $($test.Name) lost $($anomaly.Lost) asterisks" -ForegroundColor Red
            }
        }
        catch {
            $anomaly = @{
                Type = "EncodingError"
                Encoding = $test.Name
                Error = $_.Exception.Message
                Severity = "High"
            }
            $allAnomalies += $anomaly
            $anomalyCategories["EncodingIssues"] += $anomaly
            Write-Host "ENCODING ERROR: $($test.Name) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n=== STRUCTURAL ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Analyze CSS structure
$lines = $originalContent -split "`n"
$cssRules = [regex]::Matches($originalContent, '[^{]*\{[^}]*\}')
$comments = [regex]::Matches($originalContent, '/\*.*?\*/')
$asterisks = [regex]::Matches($originalContent, '\*')

# Check for unusual CSS patterns
$unusualSelectors = [regex]::Matches($originalContent, ':[\w-]+')
$importantDeclarations = [regex]::Matches($originalContent, '!important')
$atRules = [regex]::Matches($originalContent, '@[\w-]+')

Write-Host "CSS Structure Analysis:"
Write-Host "  Lines: $($lines.Count)"
Write-Host "  CSS rules: $($cssRules.Count)"
Write-Host "  Comments: $($comments.Count)"
Write-Host "  Asterisks: $($asterisks.Count)"
Write-Host "  Pseudo-classes: $($unusualSelectors.Count)"
Write-Host "  Important declarations: $($importantDeclarations.Count)"
Write-Host "  At-rules: $($atRules.Count)"

# Look for structural anomalies
if ($cssRules.Count -eq 0) {
    $anomaly = @{
        Type = "NoCSSRules"
        Severity = "High"
    }
    $allAnomalies += $anomaly
    $anomalyCategories["StructuralAnomalies"] += $anomaly
}

if ($asterisks.Count -eq 0) {
    $anomaly = @{
        Type = "NoAsterisks"
        Severity = "Medium"
    }
    $allAnomalies += $anomaly
    $anomalyCategories["StructuralAnomalies"] += $anomaly
}

# Check for unusually long lines
$longLines = @()
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Length -gt 1000) {
        $longLines += @{Line = $i; Length = $lines[$i].Length}
        $anomaly = @{
            Type = "LongLine"
            LineNumber = $i
            Length = $lines[$i].Length
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["StructuralAnomalies"] += $anomaly
    }
}

Write-Host "Long lines found: $($longLines.Count)"

Write-Host "`n=== MATHEMATICAL ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Analyze mathematical patterns
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

$asteriskPositions = Get-AsteriskPositions $originalContent

# Check for mathematical constants
$phi = 1.618033988749895
$pi = 3.141592653589793
$e = 2.718281828459045

$phiMatches = 0
$piMatches = 0
$eMatches = 0

foreach ($pos in $asteriskPositions) {
    $lineRatio = $pos.Line / $phi
    $charRatio = $pos.Char / $phi
    
    if ([math]::Abs($lineRatio - [math]::Round($lineRatio)) -lt 0.01) {
        $phiMatches++
        $anomaly = @{
            Type = "GoldenRatioPattern"
            Line = $pos.Line
            Char = $pos.Char
            Ratio = $lineRatio
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["MathematicalAnomalies"] += $anomaly
    }
    
    $linePiRatio = $pos.Line / $pi
    if ([math]::Abs($linePiRatio - [math]::Round($linePiRatio)) -lt 0.01) {
        $piMatches++
        $anomaly = @{
            Type = "PiPattern"
            Line = $pos.Line
            Char = $pos.Char
            Ratio = $linePiRatio
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["MathematicalAnomalies"] += $anomaly
    }
}

Write-Host "Mathematical pattern matches:"
Write-Host "  Golden ratio: $phiMatches"
Write-Host "  Pi: $piMatches"

# Check for prime number patterns
function IsPrime($n) {
    if ($n -le 1) { return $false }
    for ($i = 2; $i -le [math]::Sqrt($n); $i++) {
        if ($n % $i -eq 0) { return $false }
    }
    return $true
}

$primeLinePositions = 0
$primeCharPositions = 0

foreach ($pos in $asteriskPositions) {
    if (IsPrime $pos.Line) {
        $primeLinePositions++
        $anomaly = @{
            Type = "PrimeLinePosition"
            Line = $pos.Line
            Char = $pos.Char
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["MathematicalAnomalies"] += $anomaly
    }
    
    if (IsPrime $pos.Char) {
        $primeCharPositions++
        $anomaly = @{
            Type = "PrimeCharPosition"
            Line = $pos.Line
            Char = $pos.Char
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["MathematicalAnomalies"] += $anomaly
    }
}

Write-Host "Prime number positions:"
Write-Host "  Prime lines: $primeLinePositions"
Write-Host "  Prime characters: $primeCharPositions"

Write-Host "`n=== CONTENT ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Check for suspicious content patterns
$suspiciousContent = @(
    @{Pattern = 'eval\s*\('; Name = "eval function"},
    @{Pattern = 'document\.write'; Name = "document.write"},
    @{Pattern = 'innerHTML\s*='; Name = "innerHTML assignment"},
    @{Pattern = 'setTimeout\s*\('; Name = "setTimeout function"},
    @{Pattern = 'setInterval\s*\('; Name = "setInterval function"},
    @{Pattern = 'Function\s*\('; Name = "Function constructor"},
    @{Pattern = 'atob\s*\('; Name = "Base64 decode"},
    @{Pattern = 'btoa\s*\('; Name = "Base64 encode"},
    @{Pattern = 'String\.fromCharCode'; Name = "fromCharCode"},
    @{Pattern = 'String\.prototype'; Name = "String prototype manipulation"}
)

foreach ($suspicious in $suspiciousContent) {
    $matches = [regex]::Matches($originalContent, $suspicious.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($matches.Count -gt 0) {
        Write-Host "SUSPICIOUS CONTENT: $($suspicious.Name) - $($matches.Count) occurrences" -ForegroundColor Red
        foreach ($match in $matches) {
            $anomaly = @{
                Type = "SuspiciousContent"
                Name = $suspicious.Name
                Pattern = $suspicious.Pattern
                Position = $match.Index
                Severity = "High"
            }
            $allAnomalies += $anomaly
            $anomalyCategories["ContentAnomalies"] += $anomaly
        }
    }
}

# Check for encoded content
$base64Pattern = '[A-Za-z0-9+/]{20,}={0,2}'
$base64Matches = [regex]::Matches($originalContent, $base64Pattern)
if ($base64Matches.Count -gt 0) {
    Write-Host "POTENTIAL BASE64: $($base64Matches.Count) possible encoded strings" -ForegroundColor Yellow
    foreach ($match in $base64Matches) {
        $anomaly = @{
            Type = "Base64Pattern"
            Content = $match.Value
            Position = $match.Index
            Severity = "Medium"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["ContentAnomalies"] += $anomaly
    }
}

Write-Host "`n=== FILE STRUCTURE ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Check file system anomalies
$files = Get-ChildItem -Filter "*.css"
$expectedFiles = @("normalize.css", "normalize_utf16be.css", "normalize_utf16le.css", "normalize_utf32be.css", "normalize_utf32le.css", "normalize_utf7.css")

foreach ($expected in $expectedFiles) {
    if (-not (Test-Path $expected)) {
        $anomaly = @{
            Type = "MissingFile"
            FileName = $expected
            Severity = "Medium"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["FileStructureAnomalies"] += $anomaly
        Write-Host "MISSING FILE: $expected" -ForegroundColor Yellow
    }
}

# Check for unexpected files
$cssFiles = Get-ChildItem -Filter "*.css"
foreach ($file in $cssFiles) {
    if ($file.Name -notin $expectedFiles -and $file.Name -ne "normalize.css") {
        $anomaly = @{
            Type = "UnexpectedFile"
            FileName = $file.Name
            Size = $file.Length
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["FileStructureAnomalies"] += $anomaly
        Write-Host "UNEXPECTED FILE: $($file.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== SYSTEM ANOMALY ANALYSIS ===" -ForegroundColor Cyan

# Check system-level anomalies
$processes = Get-Process | Where-Object { $_.ProcessName -like "*powershell*" -or $_.ProcessName -like "*node*" -or $_.ProcessName -like "*git*" }
$suspiciousProcesses = @()

foreach ($process in $processes) {
    if ($process.WorkingSet -gt 100MB) {
        $suspiciousProcesses += @{Name = $process.ProcessName; Memory = $process.WorkingSet}
        $anomaly = @{
            Type = "HighMemoryUsage"
            Process = $process.ProcessName
            Memory = $process.WorkingSet
            Severity = "Low"
        }
        $allAnomalies += $anomaly
        $anomalyCategories["SystemAnomalies"] += $anomaly
    }
}

Write-Host "High memory processes: $($suspiciousProcesses.Count)"

# Check network connections
try {
    $connections = netstat -an | Select-String "ESTABLISHED"
    $suspiciousConnections = @()
    
    foreach ($conn in $connections) {
        if ($conn -match ":(5[0-9]{4}|6[0-9]{3}|7[0-9]{3}|8[0-9]{3}|9[0-9]{3})") {
            $suspiciousConnections += $conn
            $anomaly = @{
                Type = "SuspiciousConnection"
                Connection = $conn
                Severity = "Low"
            }
            $allAnomalies += $anomaly
            $anomalyCategories["NetworkAnomalies"] += $anomaly
        }
    }
    
    Write-Host "Suspicious network connections: $($suspiciousConnections.Count)"
}
catch {
    Write-Host "Network analysis failed"
}

Write-Host "`n=== ANOMALY SUMMARY ===" -ForegroundColor Red

Write-Host "Total anomalies detected: $($allAnomalies.Count)"
Write-Host ""

foreach ($category in $anomalyCategories.Keys) {
    $count = $anomalyCategories[$category].Count
    if ($count -gt 0) {
        Write-Host "$category`: $count anomalies" -ForegroundColor Yellow
    }
}

# Severity breakdown
$severityBreakdown = @{
    "High" = ($allAnomalies | Where-Object { $_.Severity -eq "High" }).Count
    "Medium" = ($allAnomalies | Where-Object { $_.Severity -eq "Medium" }).Count
    "Low" = ($allAnomalies | Where-Object { $_.Severity -eq "Low" }).Count
}

Write-Host "`nSeverity breakdown:"
Write-Host "  High severity: $($severityBreakdown.High)"
Write-Host "  Medium severity: $($severityBreakdown.Medium)"
Write-Host "  Low severity: $($severityBreakdown.Low)"

# Generate detailed report
$report = @()
$report += "# COMPREHENSIVE ANOMALY DETECTION REPORT"
$report += ""
$report += "Generated: $(Get-Date)"
$report += "Total anomalies detected: $($allAnomalies.Count)"
$report += ""

foreach ($category in $anomalyCategories.Keys) {
    $anomalies = $anomalyCategories[$category]
    if ($anomalies.Count -gt 0) {
        $report += "## $category ($($anomalies.Count) anomalies)"
        $report += ""
        
        foreach ($anomaly in $anomalies) {
            $report += "### $($anomaly.Type) - $($anomaly.Severity)"
            foreach ($prop in $anomaly.Keys) {
                if ($prop -notin @("Type", "Severity")) {
                    $report += "- $prop`: $($anomaly[$prop])"
                }
            }
            $report += ""
        }
    }
}

$report | Out-File -FilePath "COMPREHENSIVE_ANOMALY_REPORT.md" -Encoding UTF8

Write-Host "`nDetailed report saved to: COMPREHENSIVE_ANOMALY_REPORT.md" -ForegroundColor Green
Write-Host "`n=== ANALYSIS COMPLETE ===" -ForegroundColor Green
