$bytes = [System.IO.File]::ReadAllBytes("normalize.css")
$utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$utf7 = [System.Text.Encoding]::UTF7.GetBytes($utf8)
[System.IO.File]::WriteAllBytes("normalize_utf7.css", $utf7)
