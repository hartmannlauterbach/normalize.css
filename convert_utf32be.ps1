$bytes = [System.IO.File]::ReadAllBytes("normalize.css")
$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$utf32be = [System.Text.Encoding]::GetEncoding("utf-32BE").GetBytes($utf8)
[System.IO.File]::WriteAllBytes("normalize_utf32be.css", $utf32be)
