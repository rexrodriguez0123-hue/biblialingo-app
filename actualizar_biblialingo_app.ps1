# Script para actualizar archivos dentro de biblialingo_app
# (sin renombrar la carpeta, ya que está en uso)

$projectRoot = "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"
Set-Location $projectRoot

Write-Host "Actualizando archivos en biblialingo_app..." -ForegroundColor Cyan

# lib/main.dart
$filePath = "$projectRoot\biblialingo_app\lib\main.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "title: 'BibliaLingo'", "title: 'Camino Biblico'"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] lib/main.dart"

# lib/config/api_config.dart
$filePath = "$projectRoot\biblialingo_app\lib\config\api_config.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "Configuracion de API para BibliaLingo", "Configuracion de API para Camino Biblico"
$content = $content -replace "https://biblialingo-app.onrender.com", "https://camino-biblico-app.onrender.com"
$content = $content -replace "https://biblialingo-staging.onrender.com", "https://camino-biblico-staging.onrender.com"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] lib/config/api_config.dart"

# Screens
foreach ($file in @("welcome_screen.dart", "settings_screen.dart")) {
    $filePath = "$projectRoot\biblialingo_app\lib\screens\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Biblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "[OK] lib/screens/$file"
    }
}

# Tests
$filePath = "$projectRoot\biblialingo_app\test\widget_test.dart"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "package:biblialingo_app", "package:camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "[OK] test/widget_test.dart"
}

# README.md
$filePath = "$projectRoot\biblialingo_app\README.md"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "# biblialingo_app", "# camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "[OK] README.md"
}

# ANDROID
Write-Host "`nActualizando Android..." -ForegroundColor Cyan

# build.gradle.kts
$filePath = "$projectRoot\biblialingo_app\android\app\build.gradle.kts"
$content = Get-Content $filePath -Raw
$content = $content -replace 'namespace = "com.example.biblialingo_app"', 'namespace = "com.example.caminobiblico"'
$content = $content -replace 'applicationId = "com.example.biblialingo_app"', 'applicationId = "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] build.gradle.kts"

# AndroidManifest.xml
$filePath = "$projectRoot\biblialingo_app\android\app\src\main\AndroidManifest.xml"
$content = Get-Content $filePath -Raw
$content = $content -replace 'android:label="biblialingo_app"', 'android:label="Camino Biblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] AndroidManifest.xml"

# MainActivity.kt (actualizar sin mover)
$mainActivityPath = "$projectRoot\biblialingo_app\android\app\src\main\kotlin\com\example\biblialingo_app\MainActivity.kt"
if (Test-Path $mainActivityPath) {
    $content = Get-Content $mainActivityPath -Raw
    Set-Content -Path $mainActivityPath -Value $content
    Write-Host "[OK] MainActivity.kt"
}

# google-services.json
$filePath = "$projectRoot\biblialingo_app\android\app\google-services.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"project_id": "biblialingo"', '"project_id": "camino_biblico"'
$content = $content -replace '"storage_bucket": "biblialingo.firebasestorage.app"', '"storage_bucket": "camino-biblico.firebasestorage.app"'
$content = $content -replace '"package_name": "com.example.biblialingo_app"', '"package_name": "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] google-services.json"

# iOS
Write-Host "`nActualizando iOS..." -ForegroundColor Cyan

# Info.plist
$filePath = "$projectRoot\biblialingo_app\ios\Runner\Info.plist"
$content = Get-Content $filePath -Raw
$content = $content -replace "<string>Biblialingo App</string>", "<string>Camino Biblico</string>"
$content = $content -replace "<string>biblialingo_app</string>", "<string>camino_biblico_app</string>"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] iOS Info.plist"

# iOS project.pbxproj
$filePath = "$projectRoot\biblialingo_app\ios\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] iOS project.pbxproj"

# macOS
Write-Host "`nActualizando macOS..." -ForegroundColor Cyan

# AppInfo.xcconfig
$filePath = "$projectRoot\biblialingo_app\macos\Runner\Configs\AppInfo.xcconfig"
$content = Get-Content $filePath -Raw
$content = $content -replace "PRODUCT_NAME = biblialingo_app", "PRODUCT_NAME = camino_biblico_app"
$content = $content -replace "PRODUCT_BUNDLE_IDENTIFIER = com.example.biblialingoApp", "PRODUCT_BUNDLE_IDENTIFIER = com.example.caminobiblicoApp"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] macOS AppInfo.xcconfig"

# macOS project.pbxproj
$filePath = "$projectRoot\biblialingo_app\macos\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] macOS project.pbxproj"

# WEB
Write-Host "`nActualizando Web..." -ForegroundColor Cyan

# index.html
$filePath = "$projectRoot\biblialingo_app\web\index.html"
$content = Get-Content $filePath -Raw
$content = $content -replace 'content="biblialingo_app"', 'content="camino_biblico_app"'
$content = $content -replace "<title>biblialingo_app</title>", "<title>Camino Biblico</title>"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] web/index.html"

# manifest.json
$filePath = "$projectRoot\biblialingo_app\web\manifest.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"name": "biblialingo_app"', '"name": "camino_biblico_app"'
$content = $content -replace '"short_name": "biblialingo_app"', '"short_name": "Camino Biblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] web/manifest.json"

# LINUX
Write-Host "`nActualizando Linux..." -ForegroundColor Cyan

# CMakeLists.txt
$filePath = "$projectRoot\biblialingo_app\linux\CMakeLists.txt"
$content = Get-Content $filePath -Raw
$content = $content -replace 'set(BINARY_NAME "biblialingo_app")', 'set(BINARY_NAME "camino_biblico_app")'
$content = $content -replace 'set(APPLICATION_ID "com.example.biblialingo_app")', 'set(APPLICATION_ID "com.example.caminobiblico")'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] linux/CMakeLists.txt"

# my_application.cc
$filePath = "$projectRoot\biblialingo_app\linux\runner\my_application.cc"
$content = Get-Content $filePath -Raw
$content = $content -replace 'gtk_header_bar_set_title(header_bar, "biblialingo_app")', 'gtk_header_bar_set_title(header_bar, "Camino Biblico")'
$content = $content -replace 'gtk_window_set_title(window, "biblialingo_app")', 'gtk_window_set_title(window, "Camino Biblico")'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] linux/my_application.cc"

Write-Host "`n[IMPORTANTE]" -ForegroundColor Yellow
Write-Host "Todos los archivos dentro de biblialingo_app han sido actualizados."
Write-Host "Ahora debes:" -ForegroundColor Yellow
Write-Host "1. Cerrar VS Code completamente" -ForegroundColor Yellow
Write-Host "2. Renombrar la carpeta: biblialingo_app -> camino_biblico_app" -ForegroundColor Yellow
Write-Host "3. También renombrar carpeta de paquete Android:" -ForegroundColor Yellow
Write-Host "   de: camino_biblico_app/android/app/src/main/kotlin/com/example/biblialingo_app" -ForegroundColor Yellow
Write-Host "   a: camino_biblico_app/android/app/src/main/kotlin/com/example/caminobiblico" -ForegroundColor Yellow

Write-Host "`n[COMANDO para renombrar carpeta cuando cierres VS Code]:" -ForegroundColor Cyan
Write-Host "Move-Item -Path 'biblialingo_app' -Destination 'camino_biblico_app'" -ForegroundColor Cyan

Write-Host "`nHecho!" -ForegroundColor Green
