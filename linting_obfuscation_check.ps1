Write-Host "=== LINTING/PARSING OBFUSCATION ANALYSIS ===" -ForegroundColor Red
Write-Host "Checking CSS files for obfuscation that could confuse linters or parsers..." -ForegroundColor Yellow

# Read CSS files
$cssFiles = @("normalize.css", "sanitize.css", "css-reset.css")
$obfuscationFindings = @()

foreach ($cssFile in $cssFiles) {
    if (Test-Path $cssFile) {
        Write-Host "`n--- Analyzing $cssFile ---" -ForegroundColor Yellow
        
        $content = Get-Content $cssFile -Raw
        $lines = $content -split "`n"
        $fileFindings = @()
        
        # Check 1: Unusual line lengths (could hide code)
        $longLines = $lines | Where-Object { $_.Length -gt 200 }
        if ($longLines.Count -gt 0) {
            $fileFindings += @{
                Type = "UnusualLineLengths"
                Count = $longLines.Count
                MaxLength = ($longLines | Measure-Object -Property Length -Maximum).Maximum
                Severity = "Medium"
            }
            Write-Host "  Unusual line lengths: $($longLines.Count) lines > 200 chars" -ForegroundColor Yellow
        }
        
        # Check 2: Excessive whitespace patterns
        $excessiveWhitespace = [regex]::Matches($content, '\s{10,}').Count
        if ($excessiveWhitespace -gt 0) {
            $fileFindings += @{
                Type = "ExcessiveWhitespace"
                Count = $excessiveWhitespace
                Severity = "Low"
            }
            Write-Host "  Excessive whitespace patterns: $excessiveWhitespace" -ForegroundColor Gray
        }
        
        # Check 3: Mixed quote styles that could confuse parsers
        $singleQuotes = [regex]::Matches($content, "'[^']*'").Count
        $doubleQuotes = [regex]::Matches($content, '"[^"]*"').Count
        if ($singleQuotes -gt 0 -and $doubleQuotes -gt 0) {
            $fileFindings += @{
                Type = "MixedQuoteStyles"
                SingleQuotes = $singleQuotes
                DoubleQuotes = $doubleQuotes
                Severity = "Low"
            }
            Write-Host "  Mixed quote styles: $singleQuotes single, $doubleQuotes double" -ForegroundColor Gray
        }
        
        # Check 4: CSS comments that could hide malicious code
        $comments = [regex]::Matches($content, '/\*.*?\*/', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $suspiciousComments = 0
        
        foreach ($comment in $comments) {
            $commentText = $comment.Value
            # Check for unusual patterns in comments
            if ($commentText -match '[<>]' -or $commentText -match '[{}]' -or $commentText.Length -gt 100) {
                $suspiciousComments++
            }
        }
        
        if ($suspiciousComments -gt 0) {
            $fileFindings += @{
                Type = "SuspiciousComments"
                Count = $suspiciousComments
                Severity = "Medium"
            }
            Write-Host "  Suspicious comments: $suspiciousComments" -ForegroundColor Yellow
        }
        
        # Check 5: Non-standard CSS syntax that could confuse linters
        $nonStandardSyntax = @(
            @{Pattern = '[a-zA-Z_-]+\s*:'; Name = "Property without value"},
            @{Pattern = '[{}]\s*[{}]\s*'; Name = "Adjacent braces"},
            @{Pattern = ';\s*;'; Name = "Double semicolons"},
            @{Pattern = '::?[a-zA-Z_-]+\s*::?[a-zA-Z_-]+'; Name = "Double pseudo-selectors"}
        )
        
        foreach ($pattern in $nonStandardSyntax) {
            $matches = [regex]::Matches($content, $pattern.Pattern)
            if ($matches.Count -gt 0) {
                $fileFindings += @{
                    Type = "NonStandardSyntax"
                    Pattern = $pattern.Name
                    Count = $matches.Count
                    Severity = "Low"
                }
                Write-Host "  Non-standard syntax ($($pattern.Name)): $($matches.Count)" -ForegroundColor Gray
            }
        }
        
        # Check 6: Obfuscated selectors (minified or compressed patterns)
        $compressedSelectors = [regex]::Matches($content, '[^{]*\{[^}]{0,10}\}').Count
        if ($compressedSelectors -gt 0) {
            $fileFindings += @{
                Type = "CompressedSelectors"
                Count = $compressedSelectors
                Severity = "Low"
            }
            Write-Host "  Compressed selectors: $compressedSelectors" -ForegroundColor Gray
        }
        
        # Check 7: CSS parsing edge cases
        $parsingEdgeCases = @(
            @{Pattern = '@[a-zA-Z_-]+\s*\{'; Name = "Unclosed at-rule"},
            @{Pattern = '[a-zA-Z_-]+\s*\{[^}]*$'; Name = "Unclosed rule"},
            @{Pattern = '\}\s*[^{]*\{'; Name = "Adjacent rules without separator"}
        )
        
        foreach ($pattern in $parsingEdgeCases) {
            $matches = [regex]::Matches($content, $pattern.Pattern)
            if ($matches.Count -gt 0) {
                $fileFindings += @{
                    Type = "ParsingEdgeCase"
                    Pattern = $pattern.Name
                    Count = $matches.Count
                    Severity = "High"
                }
                Write-Host "  PARSING ISSUE ($($pattern.Name)): $($matches.Count)" -ForegroundColor Red
            }
        }
        
        # Check 8: CSS validator confusion patterns
        $validatorConfusion = @(
            @{Pattern = '!\s*important\s*!\s*important'; Name = "Double important"},
            @{Pattern = '[a-zA-Z_-]+:\s*[a-zA-Z_-]+;?\s*[a-zA-Z_-]+:\s*[a-zA-Z_-]+'; Name = "Multiple properties on one line"},
            @{Pattern = ':\s*;\s*'; Name = "Empty property values"}
        )
        
        foreach ($pattern in $validatorConfusion) {
            $matches = [regex]::Matches($content, $pattern.Pattern)
            if ($matches.Count -gt 0) {
                $fileFindings += @{
                    Type = "ValidatorConfusion"
                    Pattern = $pattern.Name
                    Count = $matches.Count
                    Severity = "Medium"
                }
                Write-Host "  Validator confusion ($($pattern.Name)): $($matches.Count)" -ForegroundColor Yellow
            }
        }
        
        # Check 9: Encoding confusion (mixed encoding hints)
        $encodingHints = [regex]::Matches($content, '@charset|@import.*utf', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($encodingHints.Count -gt 1) {
            $fileFindings += @{
                Type = "MultipleEncodingHints"
                Count = $encodingHints.Count
                Severity = "Medium"
            }
            Write-Host "  Multiple encoding hints: $($encodingHints.Count)" -ForegroundColor Yellow
        }
        
        # Check 10: CSS preprocessor confusion
        $preprocessorHints = [regex]::Matches($content, '\$|@mixin|@include|&\.|&\:', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($preprocessorHints.Count -gt 0) {
            $fileFindings += @{
                Type = "PreprocessorHints"
                Count = $preprocessorHints.Count
                Severity = "Low"
            }
            Write-Host "  Preprocessor hints: $($preprocessorHints.Count)" -ForegroundColor Gray
        }
        
        if ($fileFindings.Count -gt 0) {
            Write-Host "  Total obfuscation findings: $($fileFindings.Count)" -ForegroundColor Yellow
            
            $obfuscationFindings += @{
                File = $cssFile
                Findings = $fileFindings
                TotalFindings = $fileFindings.Count
            }
        } else {
            Write-Host "  No obfuscation patterns detected" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== LINTING/PARSING OBFUSCATION SUMMARY ===" -ForegroundColor Red

$totalFindings = 0
$criticalFindings = 0
$highFindings = 0
$mediumFindings = 0
$lowFindings = 0

foreach ($fileResult in $obfuscationFindings) {
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

Write-Host "Total obfuscation findings across all files: $totalFindings" -ForegroundColor Yellow
Write-Host "Severity breakdown:" -ForegroundColor Yellow
Write-Host "  Critical: $criticalFindings" -ForegroundColor Red
Write-Host "  High: $highFindings" -ForegroundColor Red
Write-Host "  Medium: $mediumFindings" -ForegroundColor Yellow
Write-Host "  Low: $lowFindings" -ForegroundColor Gray

if ($totalFindings -gt 0) {
    Write-Host "`n🚨 OBFUSCATION PATTERNS DETECTED!" -ForegroundColor Red
    Write-Host "CSS files may contain obfuscation to confuse linters/parsers!" -ForegroundColor Red
    
    foreach ($fileResult in $obfuscationFindings) {
        Write-Host "`n--- $($fileResult.File) ---" -ForegroundColor Yellow
        foreach ($finding in $fileResult.Findings) {
            $color = switch ($finding.Severity) {
                "Critical" { "Red" }
                "High" { "Red" }
                "Medium" { "Yellow" }
                "Low" { "Gray" }
            }
            Write-Host "  $($finding.Type): $($finding.Count) ($($finding.Severity))" -ForegroundColor $color
        }
    }
    
    Write-Host "`n⚠️ OBFUSCATION IMPLICATIONS:" -ForegroundColor Yellow
    Write-Host "  These patterns could:" -ForegroundColor White
    Write-Host "  1. Confuse CSS linters and validators" -ForegroundColor White
    Write-Host "  2. Hide malicious code from static analysis" -ForegroundColor White
    Write-Host "  3. Create parser confusion in different engines" -ForegroundColor White
    Write-Host "  4. Bypass security scanning tools" -ForegroundColor White
    
} else {
    Write-Host "`n✅ NO OBFUSCATION PATTERNS DETECTED" -ForegroundColor Green
    Write-Host "CSS files appear clean for linting/parsing" -ForegroundColor Green
}

# Save obfuscation analysis
$obfuscationReport = @{
    Timestamp = Get-Date
    FilesAnalyzed = $cssFiles
    TotalFindings = $totalFindings
    SeverityBreakdown = @{
        Critical = $criticalFindings
        High = $highFindings
        Medium = $mediumFindings
        Low = $lowFindings
    }
    DetailedFindings = $obfuscationFindings
    Status = if ($totalFindings -gt 0) { "OBFUSCATION_DETECTED" } else { "CLEAN" }
    RiskAssessment = if ($criticalFindings -gt 0 -or $highFindings -gt 0) { "HIGH" } elseif ($mediumFindings -gt 0) { "MEDIUM" } else { "LOW" }
}

$obfuscationReport | ConvertTo-Json -Depth 4 | Out-File -FilePath "linting_obfuscation_analysis.json"

Write-Host "`nObfuscation analysis saved to: linting_obfuscation_analysis.json" -ForegroundColor Green
Write-Host "=== LINTING/PARSING OBFUSCATION ANALYSIS COMPLETE ===" -ForegroundColor Red
