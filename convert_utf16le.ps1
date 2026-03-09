$bytes = [System.IO.File]::ReadAllBytes("normalize.css")
$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$utf16le = [System.Text.Encoding]::Unicode.GetBytes($utf8)
[System.IO.File]::WriteAllBytes("normalize_utf16le.css", $utf16le)
