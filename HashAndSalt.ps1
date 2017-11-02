Function Get-StringHash([String] $String, $HashName = "SHA256") {
    $StringBuilder = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))| % {
        [Void]$StringBuilder.Append($_.ToString("x2"))
    }
    $StringBuilder.ToString()
}


$password = "HeiaBrann!"
$sha1 = Get-StringHash -String $password "SHA1"
$salt = [String](Get-Random -Minimum 1000000 -Maximum 9999999)
$value = "{0}{1}" -f $sha1, $salt # to.Upper()

1..2000 | foreach {
    $value = Get-StringHash -String $value "SHA256"
}
$value = "{0},{1}" -f $salt, $value


$hash256 = $value # HeiaBrann! x 2000 SHA256 + salt
        
$split256 = $hash256.Split(",") ## salt
$value256 = "{0}{1}" -f (Get-StringHash -String $password "SHA1"), $split256[0]
1..2000 | foreach {
    $value256 = Get-StringHash -String $value256 "SHA256"
}
"Password correct: {0}" -f ($value256 -eq $split256[1])