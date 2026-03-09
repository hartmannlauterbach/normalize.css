$bytes = [System.IO.File]::ReadAllBytes("normalize.css")
$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$utf16be = [System.Text.Encoding]::BigEndianUnicode.GetBytes($utf8)
[System.IO.File]::WriteAllBytes("normalize_utf16be.css", $utf16be)
