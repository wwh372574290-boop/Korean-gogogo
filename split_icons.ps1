Add-Type -AssemblyName System.Drawing

# build CJK path via unicode escapes to avoid encoding issues
$pic = [char]0x56FE + [char]0x7247  # 图片
$src = Join-Path "d:\orbit_fa\$pic" "Image_2-removebg-preview.png"
$outDir = Join-Path "d:\orbit_fa\$pic" "icons"

if (-not (Test-Path $src)) {
  Write-Host "Source NOT FOUND: $src"
  exit 1
}
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$img = [System.Drawing.Image]::FromFile($src)
$w = $img.Width
$h = $img.Height
Write-Host ("Source size: {0} x {1}" -f $w, $h)

$rowH = [int]($h / 2)
# keep only top ~65% of each row (drop number+text)
$iconH = [int]($rowH * 0.65)
$row1W = [int]($w / 4)
$row2W = [int]($w / 5)

$names1 = @("01_korean","02_bbq","03_chicken","04_western")
$names2 = @("05_dessert","06_drink","07_shopping","08_fashion","09_beauty")

function CropOne {
  param($srcImg,$sx,$sy,$sw,$sh,$outPath)
  $bmp = New-Object System.Drawing.Bitmap $sw,$sh
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $dst = New-Object System.Drawing.Rectangle 0,0,$sw,$sh
  $srcRect = New-Object System.Drawing.Rectangle $sx,$sy,$sw,$sh
  $g.DrawImage($srcImg,$dst,$srcRect,[System.Drawing.GraphicsUnit]::Pixel)
  $bmp.Save($outPath,[System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
}

for ($i=0; $i -lt 4; $i++) {
  CropOne $img ($i*$row1W) 0 $row1W $iconH (Join-Path $outDir ($names1[$i] + ".png"))
}
for ($i=0; $i -lt 5; $i++) {
  CropOne $img ($i*$row2W) $rowH $row2W $iconH (Join-Path $outDir ($names2[$i] + ".png"))
}

$img.Dispose()
Write-Host ("Done. Output: {0}" -f $outDir)
Get-ChildItem $outDir | Format-Table Name,Length
