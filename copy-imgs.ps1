### kopierer filer fra $assetPath til $tempPath og omdøper dem ved å legge til .jpg endelse

$assetPath = $env:USERPROFILE + "\" + 'AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets\'
$tempPath  = $env:USERPROFILE + "\" + 'Desktop\Temp\'
$assetImgs = @(Get-ChildItem -Path $assetPath)

for ($i = 0; $i -lt $assetImgs.Count; $i++) 
    {
    if ($assetImgs[$i].CreationTime -gt (Get-Date).AddDays(-1))
        {
        Copy-item $assetImgs[$i].FullName -Destination ($tempPath +  $assetImgs[$i] + ".jpg")
        }
    }
