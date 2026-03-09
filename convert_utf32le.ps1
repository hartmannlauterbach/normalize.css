$bytes = [System.IO.File]::ReadAllBytes("normalize.css")
$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$utf32le = [System.Text.Encoding]::UTF32.GetBytes($utf8)
[System.IO.File]::WriteAllBytes("normalize_utf32le.css", $utf32le)
