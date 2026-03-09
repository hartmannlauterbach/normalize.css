Write-Host "=== MATHEMATICAL TRICKS SCAN ===" -ForegroundColor Red
Write-Host "Scanning CSS files for mathematical patterns and tricks..." -ForegroundColor Yellow

# Mathematical functions
function IsPrime($n) {
    if ($n -le 1) { return $false }
    if ($n -le 3) { return $true }
    if ($n % 2 -eq 0 -or $n % 3 -eq 0) { return $false }
    $i = 5
    while ($i * $i -le $n) {
        if ($n % $i -eq 0 -or $n % ($i + 2) -eq 0) { return $false }
        $i += 6
    }
    return $true
}

function GetFibonacci($max) {
    $fib = @()
    $a = 0; $b = 1
    while ($a -le $max) {
        $fib += $a
        $temp = $a
        $a = $b
        $b = $temp + $b
    }
    return $fib
}

function GetGoldenRatioPositions($content) {
    $phi = 1.618033988749895
    $positions = @()
    $lines = $content -split "`n"
    $totalLength = $content.Length
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Length -gt 0) {
            $goldenPos = [math]::Round($line.Length * $phi)
            if ($goldenPos -lt $line.Length) {
                $positions += @{
                    Line = $i
                    Position = $goldenPos
                    Character = $line[$goldenPos]
                    Code = [int]$line[$goldenPos]
                }
            }
        }
    }
    return $positions
}

# Read CSS files
$cssFiles = @("normalize.css", "sanitize.css", "css-reset.css")
$mathematicalFindings = @()

foreach ($cssFile in $cssFiles) {
    if (Test-Path $cssFile) {
        Write-Host "`n--- Analyzing $cssFile ---" -ForegroundColor Yellow
        
        $content = Get-Content $cssFile -Raw
        $lines = $content -split "`n"
        $fileFindings = @()
        
        # 1. Prime number analysis
        Write-Host "  Scanning for prime number patterns..." -ForegroundColor Gray
        $primePositions = @()
        $charCodes = $content.ToCharArray() | ForEach-Object { [int]$_ }
        
        for ($i = 0; $i -lt $charCodes.Count; $i++) {
            if (IsPrime $charCodes[$i]) {
                $primePositions += @{
                    Position = $i
                    Code = $charCodes[$i]
                    Character = $content[$i]
                }
            }
        }
        
        if ($primePositions.Count -gt 10) {
            $fileFindings += @{
                Type = "PrimeNumbers"
                Count = $primePositions.Count
                Sample = $primePositions[0..4]
                Severity = "Medium"
            }
            Write-Host "  Prime numbers found: $($primePositions.Count)" -ForegroundColor Yellow
        }
        
        # 2. Fibonacci sequence analysis
        Write-Host "  Scanning for Fibonacci patterns..." -ForegroundColor Gray
        $fibNumbers = GetFibonacci 1000
        $fibPositions = @()
        
        for ($i = 0; $i -lt $charCodes.Count; $i++) {
            if ($fibNumbers -contains $charCodes[$i]) {
                $fibPositions += @{
                    Position = $i
                    Code = $charCodes[$i]
                    Character = $content[$i]
                }
            }
        }
        
        if ($fibPositions.Count -gt 5) {
            $fileFindings += @{
                Type = "FibonacciSequence"
                Count = $fibPositions.Count
                Sample = $fibPositions[0..4]
                Severity = "Medium"
            }
            Write-Host "  Fibonacci numbers found: $($fibPositions.Count)" -ForegroundColor Yellow
        }
        
        # 3. Golden ratio analysis
        Write-Host "  Scanning for golden ratio patterns..." -ForegroundColor Gray
        $goldenPositions = GetGoldenRatioPositions $content
        
        if ($goldenPositions.Count -gt 10) {
            $fileFindings += @{
                Type = "GoldenRatio"
                Count = $goldenPositions.Count
                Sample = $goldenPositions[0..4]
                Severity = "Low"
            }
            Write-Host "  Golden ratio positions: $($goldenPositions.Count)" -ForegroundColor Gray
        }
        
        # 4. Mathematical constants in values
        Write-Host "  Scanning for mathematical constants..." -ForegroundColor Gray
        $constants = @(
            @{Name = "Pi"; Value = 3.14159; Pattern = "3\.14"},
            @{Name = "E"; Value = 2.71828; Pattern = "2\.71"},
            @{Name = "GoldenRatio"; Value = 1.61803; Pattern = "1\.61"},
            @{Name = "Sqrt2"; Value = 1.41421; Pattern = "1\.41"},
            @{Name = "Sqrt3"; Value = 1.73205; Pattern = "1\.73"}
        )
        
        $constantMatches = @()
        foreach ($const in $constants) {
            $matches = [regex]::Matches($content, $const.Pattern)
            if ($matches.Count -gt 0) {
                $constantMatches += @{
                    Constant = $const.Name
                    Pattern = $const.Pattern
                    Count = $matches.Count
                    Sample = $matches[0].Value
                }
            }
        }
        
        if ($constantMatches.Count -gt 0) {
            $fileFindings += @{
                Type = "MathematicalConstants"
                Constants = $constantMatches
                Severity = "Medium"
            }
            Write-Host "  Mathematical constants found: $($constantMatches.Count)" -ForegroundColor Yellow
        }
        
        # 5. Geometric sequences
        Write-Host "  Scanning for geometric sequences..." -ForegroundColor Gray
        $geometricSequences = @()
        $numbers = [regex]::Matches($content, '\d+') | ForEach-Object { [long]$_.Value }
        
        for ($i = 0; $i -lt $numbers.Count - 2; $i++) {
            $a = $numbers[$i]
            $b = $numbers[$i+1]
            $c = $numbers[$i+2]
            
            if ($a -ne 0 -and $b -ne 0 -and ($b / $a) -eq ($c / $b)) {
                $ratio = $b / $a
                $geometricSequences += @{
                    Position = $i
                    Sequence = @($a, $b, $c)
                    Ratio = $ratio
                }
            }
        }
        
        if ($geometricSequences.Count -gt 0) {
            $fileFindings += @{
                Type = "GeometricSequences"
                Count = $geometricSequences.Count
                Sample = $geometricSequences[0]
                Severity = "Low"
            }
            Write-Host "  Geometric sequences found: $($geometricSequences.Count)" -ForegroundColor Gray
        }
        
        # 6. Arithmetic progressions
        Write-Host "  Scanning for arithmetic progressions..." -ForegroundColor Gray
        $arithmeticSequences = @()
        
        for ($i = 0; $i -lt $numbers.Count - 2; $i++) {
            $a = $numbers[$i]
            $b = $numbers[$i+1]
            $c = $numbers[$i+2]
            
            if (($b - $a) -eq ($c - $b)) {
                $diff = $b - $a
                $arithmeticSequences += @{
                    Position = $i
                    Sequence = @($a, $b, $c)
                    Difference = $diff
                }
            }
        }
        
        if ($arithmeticSequences.Count -gt 0) {
            $fileFindings += @{
                Type = "ArithmeticSequences"
                Count = $arithmeticSequences.Count
                Sample = $arithmeticSequences[0]
                Severity = "Low"
            }
            Write-Host "  Arithmetic sequences found: $($arithmeticSequences.Count)" -ForegroundColor Gray
        }
        
        # 7. Position-based mathematical relationships
        Write-Host "  Scanning for position-based relationships..." -ForegroundColor Gray
        $positionPatterns = @()
        
        for ($i = 0; $i -lt $content.Length; $i++) {
            $char = $content[$i]
            $code = [int]$char
            
            # Check if position relates to character code mathematically
            if ($code -gt 32 -and ($i % $code -eq 0 -or $code % ($i + 1) -eq 0)) {
                $positionPatterns += @{
                    Position = $i
                    Character = $char
                    Code = $code
                    Relationship = if ($i % $code -eq 0) { "Position divisible by code" } else { "Code divisible by position" }
                }
            }
        }
        
        if ($positionPatterns.Count -gt 10) {
            $fileFindings += @{
                Type = "PositionRelationships"
                Count = $positionPatterns.Count
                Sample = $positionPatterns[0..4]
                Severity = "Medium"
            }
            Write-Host "  Position relationships found: $($positionPatterns.Count)" -ForegroundColor Yellow
        }
        
        # 8. Character frequency analysis (mathematical distribution)
        Write-Host "  Analyzing character frequency distribution..." -ForegroundColor Gray
        $charFreq = @{}
        foreach ($char in $content.ToCharArray()) {
            if ($charFreq.ContainsKey($char)) {
                $charFreq[$char] = $charFreq[$char] + 1
            } else {
                $charFreq[$char] = 1
            }
        }
        
        $totalChars = $content.Length
        $entropy = 0.0
        foreach ($count in $charFreq.Values) {
            $prob = $count / $totalChars
            if ($prob -gt 0) {
                $entropy += -$prob * [math]::Log($prob, 2)
            }
        }
        
        $fileFindings += @{
            Type = "EntropyAnalysis"
            Entropy = [math]::Round($entropy, 3)
            UniqueChars = $charFreq.Count
            TotalChars = $totalChars
            Severity = "Low"
        }
        Write-Host "  Character entropy: $([math]::Round($entropy, 3)) bits" -ForegroundColor Gray
        
        # 9. Modulo patterns
        Write-Host "  Scanning for modulo patterns..." -ForegroundColor Gray
        $moduloPatterns = @()
        
        for ($mod = 2; $mod -le 10; $mod++) {
            $positions = @()
            for ($i = 0; $i -lt $content.Length; $i++) {
                if ($i % $mod -eq 0) {
                    $positions += $i
                }
            }
            
            # Check if characters at modulo positions form a pattern
            $modChars = $positions | ForEach-Object { $content[$_] }
            $uniqueModChars = $modChars | Select-Object -Unique
            
            if ($uniqueModChars.Count -le 3 -and $positions.Count -gt 10) {
                $moduloPatterns += @{
                    Modulo = $mod
                    Positions = $positions.Count
                    UniqueChars = $uniqueModChars.Count
                    Pattern = -join $uniqueModChars[0..2]
                }
            }
        }
        
        if ($moduloPatterns.Count -gt 0) {
            $fileFindings += @{
                Type = "ModuloPatterns"
                Patterns = $moduloPatterns
                Severity = "Medium"
            }
            Write-Host "  Modulo patterns found: $($moduloPatterns.Count)" -ForegroundColor Yellow
        }
        
        # 10. Cryptographic patterns (simple checks)
        Write-Host "  Scanning for cryptographic patterns..." -ForegroundColor Gray
        $cryptoPatterns = @()
        
        # Check for XOR-like patterns in character codes
        $codes = $content.ToCharArray() | ForEach-Object { [int]$_ }
        $xorPatterns = 0
        
        for ($i = 0; $i -lt $codes.Count - 1; $i++) {
            if (($codes[$i] -bxor $codes[$i+1]) -lt 32) {
                $xorPatterns++
            }
        }
        
        if ($xorPatterns -gt 20) {
            $cryptoPatterns += @{
                Type = "XORPatterns"
                Count = $xorPatterns
            }
        }
        
        # Check for repeating patterns that could be encryption
        $repeatingPatterns = [regex]::Matches($content, '(.{2,10})\1{2,}')
        if ($repeatingPatterns.Count -gt 0) {
            $cryptoPatterns += @{
                Type = "RepeatingPatterns"
                Count = $repeatingPatterns.Count
                Sample = $repeatingPatterns[0].Value.Substring(0, 20) + "..."
            }
        }
        
        if ($cryptoPatterns.Count -gt 0) {
            $fileFindings += @{
                Type = "CryptographicPatterns"
                Patterns = $cryptoPatterns
                Severity = "High"
            }
            Write-Host "  CRYPTOGRAPHIC PATTERNS DETECTED: $($cryptoPatterns.Count)" -ForegroundColor Red
        }
        
        if ($fileFindings.Count -gt 0) {
            Write-Host "  Total mathematical findings: $($fileFindings.Count)" -ForegroundColor Yellow
            $mathematicalFindings += @{
                File = $cssFile
                Findings = $fileFindings
                TotalFindings = $fileFindings.Count
            }
        } else {
            Write-Host "  No mathematical tricks detected" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== MATHEMATICAL TRICKS SUMMARY ===" -ForegroundColor Red

$totalFindings = 0
$criticalFindings = 0
$highFindings = 0
$mediumFindings = 0
$lowFindings = 0

foreach ($fileResult in $mathematicalFindings) {
    $totalFindings += $fileResult.TotalFindings
    
    foreach ($finding in $fileResult.Findings) {
        switch ($finding.Severity) {
            "Critical" { $criticalFindings++ }
            "High" { $highFindings++ }
            "Medium" { $mediumFindings++ }
            "Low" { $lowFindings++ }
        }
    }
}

Write-Host "Total mathematical findings across all files: $totalFindings" -ForegroundColor Yellow
Write-Host "Severity breakdown:" -ForegroundColor Yellow
Write-Host "  Critical: $criticalFindings" -ForegroundColor Red
Write-Host "  High: $highFindings" -ForegroundColor Red
Write-Host "  Medium: $mediumFindings" -ForegroundColor Yellow
Write-Host "  Low: $lowFindings" -ForegroundColor Gray

if ($totalFindings -gt 0) {
    Write-Host "`n🧮 MATHEMATICAL TRICKS DETECTED!" -ForegroundColor Red
    Write-Host "CSS files contain mathematical patterns!" -ForegroundColor Red
    
    foreach ($fileResult in $mathematicalFindings) {
        Write-Host "`n--- $($fileResult.File) ---" -ForegroundColor Yellow
        foreach ($finding in $fileResult.Findings) {
            $color = switch ($finding.Severity) {
                "Critical" { "Red" }
                "High" { "Red" }
                "Medium" { "Yellow" }
                "Low" { "Gray" }
            }
            if ($finding.PSObject.Properties.Match('Count').Count -gt 0 -and $finding.Count -ne $null) {
                $countDisplay = $finding.Count
            } else {
                $countDisplay = 'N/A'
            }
            Write-Host "  $($finding.Type): $countDisplay ($($finding.Severity))" -ForegroundColor $color
            
            # Show additional details for interesting findings
            if ($finding.Type -eq "PrimeNumbers" -and $finding.Sample) {
                Write-Host "    Sample primes: $(($finding.Sample | ForEach-Object { "$($_.Code)('$($_.Character)')" }) -join ', ')" -ForegroundColor White
            }
            if ($finding.Type -eq "FibonacciSequence" -and $finding.Sample) {
                Write-Host "    Sample fibonacci: $(($finding.Sample | ForEach-Object { "$($_.Code)('$($_.Character)')" }) -join ', ')" -ForegroundColor White
            }
            if ($finding.Type -eq "CryptographicPatterns") {
                foreach ($pattern in $finding.Patterns) {
                    Write-Host "    $($pattern.Type): $($pattern.Count)" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host "`n⚠️ MATHEMATICAL IMPLICATIONS:" -ForegroundColor Yellow
    Write-Host "  These patterns could be used for:" -ForegroundColor White
    Write-Host "  1. Hiding data in mathematical sequences" -ForegroundColor White
    Write-Host "  2. Creating steganographic encoding" -ForegroundColor White
    Write-Host "  3. Generating cryptographic keys" -ForegroundColor White
    Write-Host "  4. Position-based attack triggers" -ForegroundColor White
    Write-Host "  5. Entropy-based information hiding" -ForegroundColor White
    
    if ($highFindings -gt 0 -or $criticalFindings -gt 0) {
        Write-Host "`n🚨 HIGH RISK PATTERNS DETECTED!" -ForegroundColor Red
        Write-Host "  Cryptographic or advanced mathematical tricks found!" -ForegroundColor Red
    }
    
} else {
    Write-Host "`n✅ NO MATHEMATICAL TRICKS DETECTED" -ForegroundColor Green
    Write-Host "CSS files appear mathematically clean" -ForegroundColor Green
}

# Save comprehensive mathematical analysis
$mathematicalReport = @{
    Timestamp = Get-Date
    FilesAnalyzed = $cssFiles
    TotalFindings = $totalFindings
    SeverityBreakdown = @{
        Critical = $criticalFindings
        High = $highFindings
        Medium = $mediumFindings
        Low = $lowFindings
    }
    DetailedFindings = $mathematicalFindings
    Status = if ($totalFindings -gt 0) { "MATHEMATICAL_TRICKS_DETECTED" } else { "CLEAN" }
    RiskAssessment = if ($criticalFindings -gt 0 -or $highFindings -gt 0) { "HIGH" } elseif ($mediumFindings -gt 0) { "MEDIUM" } else { "LOW" }
}

$mathematicalReport | ConvertTo-Json -Depth 4 | Out-File -FilePath "mathematical_tricks_analysis.json"

Write-Host "`nComprehensive mathematical analysis saved to: mathematical_tricks_analysis.json" -ForegroundColor Green
Write-Host "=== MATHEMATICAL TRICKS SCAN COMPLETE ===" -ForegroundColor Red
