$lines = Get-Content "normalize.css"
$positions = @()
$lineNum = 1
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

function IsPrime($n) {
    if ($n -le 1) { return $false }
    for ($i = 2; $i -le [math]::Sqrt($n); $i++) {
        if ($n % $i -eq 0) { return $false }
    }
    return $true
}

$fib = @()
$a = 0; $b = 1
while ($a -le 500) {
    $fib += $a
    $temp = $a
    $a = $b
    $b = $temp + $b
}

$primeCount = 0
$fibCount = 0
foreach ($pos in $positions) {
    if (IsPrime $pos.Line) { $primeCount++ }
    if ($fib -contains $pos.Line) { $fibCount++ }
}

Write-Host "Total asterisks: $($positions.Count)"
Write-Host "Prime line positions: $primeCount"
Write-Host "Fibonacci line positions: $fibCount"
