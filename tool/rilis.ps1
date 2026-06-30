$ErrorActionPreference = 'Stop'
$tanggal = Get-Date -Format 'yyyyMMdd'
$target = if ($args.Count -ge 1) { $args[0] } else { 'appbundle' }
$sisa = if ($args.Count -ge 2) { $args[1..($args.Count - 1)] } else { @() }
$debugInfo = "build/debug-info/$tanggal"
flutter build $target --release --obfuscate --split-debug-info=$debugInfo --dart-define=TANGGAL_BUILD=$tanggal @sisa
Write-Host "Debug symbols tersimpan di $debugInfo"
