$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$root = (Get-Location).Path
$zipDir = Join-Path $root "presentation-docs\overleaf-zips"
New-Item -ItemType Directory -Force -Path $zipDir | Out-Null

$members = @(
  @{
    Name = "pison-golda-mountera"
    Tex = "presentation-docs\latex\pison-golda-mountera.tex"
    Images = @(
      "ugm-logo.png",
      "pison-admin-rekap-penjualan.png",
      "pison-admin-top-analytics.png",
      "pison-api-reports-sales.png"
    )
  },
  @{
    Name = "ravif-gayuh-wicaksono"
    Tex = "presentation-docs\latex\ravif-gayuh-wicaksono.tex"
    Images = @(
      "ugm-logo.png",
      "ravif-admin-tambah-produk.png",
      "ravif-web-pencarian-produk.png"
    )
  },
  @{
    Name = "aloysius-pijar-hutama-indrianto"
    Tex = "presentation-docs\latex\aloysius-pijar-hutama-indrianto.tex"
    Images = @(
      "ugm-logo.png",
      "aloysius-admin-tambah-stok-1-tampilan-form.png",
      "aloysius-admin-tambah-stok-2-bertambah.png",
      "aloysius-admin-riwayat-stok.png",
      "aloysius-api-inventory-movements.png"
    )
  },
  @{
    Name = "gilbert-nathaniel"
    Tex = "presentation-docs\latex\gilbert-nathaniel.tex"
    Images = @(
      "ugm-logo.png",
      "gilbert-admin-tambah-perusahaan-1.png",
      "gilbert-admin-tambah-perusahaan-2.png",
      "gilbert-admin-tambah-user.png"
    )
  },
  @{
    Name = "indratanaya-budiman"
    Tex = "presentation-docs\latex\indratanaya-budiman.tex"
    Images = @(
      "ugm-logo.png",
      "indratanaya-web-checkout-1.png",
      "indratanaya-web-checkout-2.png",
      "indratanaya-web-riwayat-po.png",
      "indratanaya-api-order-detail.png"
    )
  }
)

foreach ($member in $members) {
  $zipPath = Join-Path $zipDir ($member.Name + "-overleaf.zip")
  $stream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
  $zip = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)

  try {
    $texPath = Join-Path $root $member.Tex
    $texContent = Get-Content -Path $texPath -Raw
    $texContent = $texContent.Replace("../screenshots/", "screenshots/")
    $texEntry = $zip.CreateEntry("main.tex", [System.IO.Compression.CompressionLevel]::Optimal)
    $texStream = $texEntry.Open()
    $writer = New-Object System.IO.StreamWriter($texStream, (New-Object System.Text.UTF8Encoding($false)))
    try {
      $writer.Write($texContent)
    } finally {
      $writer.Dispose()
      $texStream.Dispose()
    }

    foreach ($image in $member.Images) {
      $imagePath = Join-Path $root ("presentation-docs\screenshots\" + $image)
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $zip,
        $imagePath,
        ("screenshots/" + $image),
        [System.IO.Compression.CompressionLevel]::Optimal
      ) | Out-Null
    }
  } finally {
    $zip.Dispose()
    $stream.Dispose()
  }
}

Get-ChildItem -Path $zipDir -Filter "*-overleaf.zip" | Select-Object Name,Length
