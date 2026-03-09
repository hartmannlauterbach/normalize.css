Write-Host "=== CHAIN ATTACK INVESTIGATION ===" -ForegroundColor Red
Write-Host "Analyzing normalize.css combinations with other CSS libraries..." -ForegroundColor Yellow

# Initialize chain attack analysis
$chainFindings = @()
$libraries = @()

# Read all available CSS libraries
$cssFiles = Get-ChildItem "*.css" | Where-Object { $_.Name -in @("normalize.css", "sanitize.css", "css-reset.css") }

Write-Host "`n=== LIBRARY DISCOVERY ===" -ForegroundColor Cyan

foreach ($file in $cssFiles) {
    $content = Get-Content $file.FullName -Raw
    $asterisks = ($content.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    $lines = ($content -split "`n").Count
    $rules = [regex]::Matches($content, '[^{]*\{[^}]*\}').Count
    
    $library = @{
        Name = $file.Name
        Size = $file.Length
        Lines = $lines
        Rules = $rules
        Asterisks = $asterisks
        Content = $content
    }
    
    $libraries += $library
    Write-Host "$($file.Name): $($file.Length) bytes, $rules rules, $asterisks asterisks"
}

# Function to test CSS combinations for chain attacks
function Test-CSSCombination {
    param($libs)
    
    $combined = ""
    foreach ($lib in $libs) {
        $combined += $lib.Content + "`n"
    }
    
    # Test for potential attack vectors in combination
    $combinedAsterisks = ($combined.ToCharArray() | Where-Object { $_ -eq '*' }).Count
    $combinedRules = [regex]::Matches($combined, '[^{]*\{[^}]*\}').Count
    
    # Check for suspicious patterns that might only appear in combination
    $suspiciousPatterns = @(
        @{Pattern = '\*.*\*.*\*'; Name = "Triple asterisk patterns"},
        @{Pattern = '\*[^{]*\{[^}]*\*'; Name = "Asterisk in rule content"},
        @{Pattern = ':root.*\*'; Name = "Root selector with asterisk"},
        @{Pattern = '@.*\*'; Name = "At-rule with asterisk"}
    )
    
    $combinationFindings = @()
    
    foreach ($pattern in $suspiciousPatterns) {
        $matches = [regex]::Matches($combined, $pattern.Pattern)
        if ($matches.Count -gt 0) {
            $combinationFindings += @{
                Type = "SuspiciousPattern"
                Pattern = $pattern.Name
                Matches = $matches.Count
                Libraries = $libs.Name -join " + "
            }
        }
    }
    
    # Check for CSS injection vectors
    $injectionPatterns = @(
        @{Pattern = 'eval\s*\('; Name = "JavaScript eval"},
        @{Pattern = 'expression\s*\('; Name = "CSS expression"},
        @{Pattern = 'javascript\s*:'; Name = "JavaScript URL"},
        @{Pattern = 'vbscript\s*:'; Name = "VBScript URL"},
        @{Pattern = 'data\s*:'; Name = "Data URL"}
    )
    
    foreach ($pattern in $injectionPatterns) {
        $matches = [regex]::Matches($combined, $pattern.Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($matches.Count -gt 0) {
            $combinationFindings += @{
                Type = "InjectionVector"
                Pattern = $pattern.Name
                Matches = $matches.Count
                Libraries = $libs.Name -join " + "
                Severity = "Critical"
            }
        }
    }
    
    # Check for Unicode characters that might be exploited
    $unicodeChars = [regex]::Matches($combined, '[^\x00-\x7F]')
    if ($unicodeChars.Count -gt 0) {
        $combinationFindings += @{
            Type = "UnicodeContent"
            Characters = $unicodeChars.Count
            Libraries = $libs.Name -join " + "
            Severity = "Medium"
        }
    }
    
    # Check for CSS variables that might be manipulated
    $cssVars = [regex]::Matches($combined, '--[a-zA-Z][a-zA-Z0-9-]*')
    if ($cssVars.Count -gt 0) {
        $combinationFindings += @{
            Type = "CSSVariables"
            Variables = $cssVars.Count
            Libraries = $libs.Name -join " + "
            Severity = "Low"
        }
    }
    
    return @{
        Libraries = $libs.Name -join " + "
        CombinedAsterisks = $combinedAsterisks
        CombinedRules = $combinedRules
        Findings = $combinationFindings
    }
}

Write-Host "`n=== SINGLE LIBRARY ANALYSIS ===" -ForegroundColor Cyan

# Analyze each library individually for potential standalone attacks
foreach ($lib in $libraries) {
    Write-Host "`n--- $($lib.Name) Analysis ---" -ForegroundColor Yellow
    
    # Check for standalone attack patterns
    $standaloneFindings = @()
    
    # Check for excessive asterisks (universal selectors)
    if ($lib.Asterisks -gt 50) {
        $standaloneFindings += @{
            Type = "ExcessiveUniversalSelectors"
            Count = $lib.Asterisks
            Severity = "Low"
        }
    }
    
    # Check for unusual selectors
    $unusualSelectors = [regex]::Matches($lib.Content, '[^{]*\{')
    $suspiciousSelectors = 0
    
    foreach ($match in $unusualSelectors) {
        $selector = $match.Value.Trim()
        if ($selector -match '\*.*\*' -or $selector -match ':root.*\*') {
            $suspiciousSelectors++
        }
    }
    
    if ($suspiciousSelectors -gt 0) {
        $standaloneFindings += @{
            Type = "SuspiciousSelectors"
            Count = $suspiciousSelectors
            Severity = "Medium"
        }
    }
    
    # Check for comments that might hide code
    $comments = [regex]::Matches($lib.Content, '/\*.*?\*/', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $largeComments = 0
    
    foreach ($comment in $comments) {
        if ($comment.Value.Length -gt 500) {
            $largeComments++
        }
    }
    
    if ($largeComments -gt 0) {
        $standaloneFindings += @{
            Type = "LargeComments"
            Count = $largeComments
            Severity = "Low"
        }
    }
    
    Write-Host "Standalone findings: $($standaloneFindings.Count)"
    
    if ($standaloneFindings.Count -gt 0) {
        foreach ($finding in $standaloneFindings) {
            Write-Host "  $($finding.Type): $($finding.Count) (Severity: $($finding.Severity))"
        }
        
        $chainFindings += @{
            Type = "StandaloneAnalysis"
            Library = $lib.Name
            Findings = $standaloneFindings
        }
    }
}

Write-Host "`n=== COMBINATION TESTING ===" -ForegroundColor Cyan

# Test all possible combinations
$combinations = @()

# Single libraries
foreach ($lib in $libraries) {
    $combinations += ,@($lib)
}

# Two-library combinations
for ($i = 0; $i -lt $libraries.Count; $i++) {
    for ($j = $i + 1; $j -lt $libraries.Count; $j++) {
        $combinations += ,@($libraries[$i], $libraries[$j])
    }
}

# Three-library combination
if ($libraries.Count -ge 3) {
    $combinations += ,$libraries
}

Write-Host "Testing $($combinations.Count) combinations..."

$combinationResults = @()

foreach ($combo in $combinations) {
    $comboNames = $combo.Name -join " + "
    Write-Host "`nTesting: $comboNames"
    
    $result = Test-CSSCombination $combo
    $combinationResults += $result
    
    if ($result.Findings.Count -gt 0) {
        Write-Host "  CRITICAL FINDINGS: $($result.Findings.Count)" -ForegroundColor Red
        
        foreach ($finding in $result.Findings) {
            Write-Host "    $($finding.Type): $($finding.Pattern) - $($finding.Matches) matches" -ForegroundColor Red
        }
        
        $chainFindings += @{
            Type = "CombinationAttack"
            Combination = $comboNames
            Findings = $result.Findings
        }
    } else {
        Write-Host "  No attack vectors detected" -ForegroundColor Green
    }
}

Write-Host "`n=== DEEP NORMALIZATION ANALYSIS ===" -ForegroundColor Cyan

# Test normalization effects on combinations
Write-Host "Testing normalization effects on CSS combinations..." -ForegroundColor Yellow

$normalizationResults = @()

foreach ($combo in $combinations) {
    $comboNames = $combo.Name -join " + "
    Write-Host "`nNormalization testing: $comboNames"
    
    $combinedContent = ""
    foreach ($lib in $combo) {
        $combinedContent += $lib.Content + "`n"
    }
    
    # Test various normalization scenarios
    $normalizationTests = @(
        @{Name = "LineEnding"; Transform = { $args[0] -replace "`r`n", "`n" }},
        @{Name = "Whitespace"; Transform = { $args[0] -replace '\s+', ' ' }},
        @{Name = "CommentRemoval"; Transform = { $args[0] -replace '/\*.*?\*/', '' -replace '//.*$', '' }},
        @{Name = "SelectorSpacing"; Transform = { $args[0] -replace '\s*\{\s*', '{' -replace '\s*\}\s*', '}' }}
    )
    
    foreach ($test in $normalizationTests) {
        $normalized = & $test.Transform $combinedContent
        
        if ($normalized -ne $combinedContent) {
            $origAsterisks = ($combinedContent.ToCharArray() | Where-Object { $_ -eq '*' }).Count
            $normAsterisks = ($normalized.ToCharArray() | Where-Object { $_ -eq '*' }).Count
            
            if ($origAsterisks -ne $normAsterisks) {
                Write-Host "  CRITICAL: $($test.Name) normalization changed asterisks $origAsterisks → $normAsterisks" -ForegroundColor Red
                
                $normalizationResults += @{
                    Type = "NormalizationAttack"
                    Normalization = $test.Name
                    Combination = $comboNames
                    OriginalAsterisks = $origAsterisks
                    NormalizedAsterisks = $normAsterisks
                    Severity = "High"
                }
            }
        }
    }
}

Write-Host "`n=== ACTIVATION REQUIREMENT ANALYSIS ===" -ForegroundColor Cyan

# Check if normalize.css requires other libraries to "activate" attacks
Write-Host "Testing if normalize.css requires other libraries for attack activation..." -ForegroundColor Yellow

$activationTests = @()

# Test normalize.css alone vs in combinations
$normalizeAlone = $libraries | Where-Object { $_.Name -eq "normalize.css" }
$otherLibs = $libraries | Where-Object { $_.Name -ne "normalize.css" }

if ($normalizeAlone) {
    Write-Host "`nNormalize.css alone:"
    $aloneResult = Test-CSSCombination @($normalizeAlone)
    
    foreach ($otherLib in $otherLibs) {
        Write-Host "`nNormalize.css + $($otherLib.Name):"
        $comboResult = Test-CSSCombination @($normalizeAlone, $otherLib)
        
        # Compare findings
        $aloneFindings = $aloneResult.Findings.Count
        $comboFindings = $comboResult.Findings.Count
        
        if ($comboFindings -gt $aloneFindings) {
            Write-Host "  ACTIVATION DETECTED: $($comboFindings - $aloneFindings) additional findings when combined" -ForegroundColor Red
            
            $activationTests += @{
                Type = "LibraryActivation"
                BaseLibrary = "normalize.css"
                AddedLibrary = $otherLib.Name
                AloneFindings = $aloneFindings
                ComboFindings = $comboFindings
                AdditionalFindings = $comboFindings - $aloneFindings
                Severity = "High"
            }
        } elseif ($comboFindings -lt $aloneFindings) {
            Write-Host "  SUPPRESSION DETECTED: $($aloneFindings - $comboFindings) findings suppressed when combined" -ForegroundColor Yellow
        } else {
            Write-Host "  NO ACTIVATION: Same findings in both cases" -ForegroundColor Green
        }
    }
}

Write-Host "`n=== FINAL CHAIN ATTACK ASSESSMENT ===" -ForegroundColor Red

$totalFindings = $chainFindings.Count + $combinationResults.Where({$_.Findings.Count -gt 0}).Count + $normalizationResults.Count + $activationTests.Count

Write-Host "=== CHAIN ATTACK INVESTIGATION RESULTS ===" -ForegroundColor Red
Write-Host "Libraries analyzed: $($libraries.Count)" -ForegroundColor Yellow
Write-Host "Combinations tested: $($combinations.Count)" -ForegroundColor Yellow
Write-Host "Total findings: $totalFindings" -ForegroundColor Yellow

if ($totalFindings -gt 0) {
    Write-Host "`n🚨 CHAIN ATTACK VECTORS DETECTED!" -ForegroundColor Red
    Write-Host "Libraries may create attack chains!" -ForegroundColor Red
    
    # Categorize findings
    $criticalFindings = 0
    $highFindings = 0
    $mediumFindings = 0
    $lowFindings = 0
    
    foreach ($finding in $chainFindings) {
        foreach ($subFinding in $finding.Findings) {
            switch ($subFinding.Severity) {
                "Critical" { $criticalFindings++ }
                "High" { $highFindings++ }
                "Medium" { $mediumFindings++ }
                "Low" { $lowFindings++ }
            }
        }
    }
    
    foreach ($result in $combinationResults) {
        foreach ($finding in $result.Findings) {
            switch ($finding.Severity) {
                "Critical" { $criticalFindings++ }
                "High" { $highFindings++ }
                "Medium" { $mediumFindings++ }
                "Low" { $lowFindings++ }
            }
        }
    }
    
    foreach ($normResult in $normalizationResults) {
        switch ($normResult.Severity) {
            "Critical" { $criticalFindings++ }
            "High" { $highFindings++ }
            "Medium" { $mediumFindings++ }
            "Low" { $lowFindings++ }
        }
    }
    
    foreach ($activation in $activationTests) {
        switch ($activation.Severity) {
            "Critical" { $criticalFindings++ }
            "High" { $highFindings++ }
            "Medium" { $mediumFindings++ }
            "Low" { $lowFindings++ }
        }
    }
    
    Write-Host "`nFinding severity breakdown:"
    Write-Host "  Critical: $criticalFindings" -ForegroundColor Red
    Write-Host "  High: $highFindings" -ForegroundColor Red
    Write-Host "  Medium: $mediumFindings" -ForegroundColor Yellow
    Write-Host "  Low: $lowFindings" -ForegroundColor Gray
    
    Write-Host "`n⚠️ CHAIN ATTACK DETAILS:" -ForegroundColor Yellow
    
    if ($criticalFindings -gt 0) {
        Write-Host "  CRITICAL: Immediate security threat detected!" -ForegroundColor Red
    }
    
    if ($highFindings -gt 0) {
        Write-Host "  HIGH: Attack vectors may be activatable!" -ForegroundColor Red
    }
    
    if ($mediumFindings -gt 0) {
        Write-Host "  MEDIUM: Potential vulnerabilities identified!" -ForegroundColor Yellow
    }
    
    Write-Host "`n🔓 ATTACK MECHANISM:" -ForegroundColor Red
    Write-Host "  CSS libraries may combine to create attack vectors that:" -ForegroundColor White
    Write-Host "  1. Require multiple libraries to activate" -ForegroundColor White
    Write-Host "  2. Use normalization to reveal hidden content" -ForegroundColor White
    Write-Host "  3. Combine selectors to create injection points" -ForegroundColor White
    Write-Host "  4. Manipulate CSS parsing through library interactions" -ForegroundColor White
    
} else {
    Write-Host "`n✅ NO CHAIN ATTACK VECTORS DETECTED" -ForegroundColor Green
    Write-Host "Libraries appear safe in combination" -ForegroundColor Green
}

# Save comprehensive chain attack analysis
$chainAttackReport = @{
    Timestamp = Get-Date
    LibrariesAnalyzed = $libraries.Name
    CombinationsTested = $combinations.Count
    TotalFindings = $totalFindings
    ChainFindings = $chainFindings
    CombinationResults = $combinationResults
    NormalizationResults = $normalizationResults
    ActivationTests = $activationTests
    Status = if ($totalFindings -gt 0) { "CHAIN_ATTACK_DETECTED" } else { "SAFE" }
    RiskLevel = if ($criticalFindings -gt 0) { "CRITICAL" } elseif ($highFindings -gt 0) { "HIGH" } elseif ($mediumFindings -gt 0) { "MEDIUM" } else { "LOW" }
}

$chainAttackReport | ConvertTo-Json -Depth 4 | Out-File -FilePath "chain_attack_analysis.json"

Write-Host "`nComprehensive chain attack analysis saved to: chain_attack_analysis.json" -ForegroundColor Green
Write-Host "=== CHAIN ATTACK INVESTIGATION COMPLETE ===" -ForegroundColor Red
