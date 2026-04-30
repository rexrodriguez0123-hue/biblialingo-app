# Script para renombrar BibliaLingo a Camino Biblico
# Autor: Automatizado, Fecha: 30 de Abril 2026

$projectRoot = "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"
$backupDate = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupPath = "C:\Backups\biblialingo_backup_$backupDate"

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "PLAN DE RENOMBRADO: BIBLIALINGO a CAMINO BIBLICO" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# FASE 0: BACKUP
Write-Host "`nFASE 0: CREANDO BACKUP..." -ForegroundColor Magenta
try {
    Copy-Item -Path $projectRoot -Destination $backupPath -Recurse
    Write-Host "[OK] Backup creado en: $backupPath" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo crear backup" -ForegroundColor Yellow
}

Set-Location $projectRoot

# FASE 1: RENOMBRAR CARPETAS
Write-Host "`nFASE 1: RENOMBRANDO CARPETAS..." -ForegroundColor Magenta

if (Test-Path "biblialingo") {
    Rename-Item -Path "biblialingo" -NewName "camino_biblico"
    Write-Host "[OK] biblialingo -> camino_biblico" -ForegroundColor Green
}

if (Test-Path "biblialingo_app") {
    Rename-Item -Path "biblialingo_app" -NewName "camino_biblico_app"
    Write-Host "[OK] biblialingo_app -> camino_biblico_app" -ForegroundColor Green
}

# FASE 2: DJANGO SETTINGS
Write-Host "`nFASE 2: ACTUALIZANDO DJANGO..." -ForegroundColor Magenta

# manage.py
$filePath = "$projectRoot\manage.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "'biblialingo.settings.dev'", "'camino_biblico.settings.dev'"
$content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] manage.py" -ForegroundColor Green

# settings/base.py
$filePath = "$projectRoot\camino_biblico\settings\base.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "ROOT_URLCONF = 'biblialingo.urls'", "ROOT_URLCONF = 'camino_biblico.urls'"
$content = $content -replace "WSGI_APPLICATION = 'biblialingo.wsgi.application'", "WSGI_APPLICATION = 'camino_biblico.wsgi.application'"
$content = $content -replace "'biblialingo'", "'camino_biblico'"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] settings/base.py" -ForegroundColor Green

# settings/dev.py y prod.py
foreach ($file in @("dev.py", "prod.py")) {
    $filePath = "$projectRoot\camino_biblico\settings\$file"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "BibliaLingo", "Camino Biblico"
    $content = $content -replace "biblialingo", "camino_biblico"
    $content = $content -replace "biblialingo-app.onrender.com", "camino-biblico-app.onrender.com"
    Set-Content -Path $filePath -Value $content
    Write-Host "[OK] settings/$file" -ForegroundColor Green
}

# urls.py, wsgi.py, asgi.py
foreach ($file in @("urls.py", "wsgi.py", "asgi.py")) {
    $filePath = "$projectRoot\camino_biblico\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Biblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "[OK] camino_biblico/$file" -ForegroundColor Green
    }
}

# Services
foreach ($file in @("apps\users\models.py", "apps\bible_content\services\nlp_engine.py", "apps\curriculum\services\srs_engine.py")) {
    $filePath = "$projectRoot\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "[OK] $file" -ForegroundColor Green
    }
}

# fix_genesis_1.py
$filePath = "$projectRoot\fix_genesis_1.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] fix_genesis_1.py" -ForegroundColor Green

# FASE 3: FLUTTER
Write-Host "`nFASE 3: ACTUALIZANDO FLUTTER..." -ForegroundColor Magenta

# pubspec.yaml
$filePath = "$projectRoot\camino_biblico_app\pubspec.yaml"
$content = Get-Content $filePath -Raw
$content = $content -replace "name: biblialingo_app", "name: camino_biblico_app"
$content = $content -replace "description: A new Flutter project for BibliaLingo", "description: A new Flutter project for Camino Biblico"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] pubspec.yaml" -ForegroundColor Green

# lib/main.dart
$filePath = "$projectRoot\camino_biblico_app\lib\main.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "title: 'BibliaLingo'", "title: 'Camino Biblico'"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] lib/main.dart" -ForegroundColor Green

# lib/config/api_config.dart
$filePath = "$projectRoot\camino_biblico_app\lib\config\api_config.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "Configuracion de API para BibliaLingo", "Configuracion de API para Camino Biblico"
$content = $content -replace "https://biblialingo-app.onrender.com", "https://camino-biblico-app.onrender.com"
$content = $content -replace "https://biblialingo-staging.onrender.com", "https://camino-biblico-staging.onrender.com"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] lib/config/api_config.dart" -ForegroundColor Green

# Screens
foreach ($file in @("lib\screens\welcome_screen.dart", "lib\screens\settings_screen.dart")) {
    $filePath = "$projectRoot\camino_biblico_app\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Biblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "[OK] $file" -ForegroundColor Green
    }
}

# Tests
$filePath = "$projectRoot\camino_biblico_app\test\widget_test.dart"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "package:biblialingo_app", "package:camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "[OK] test/widget_test.dart" -ForegroundColor Green
}

# README.md
$filePath = "$projectRoot\camino_biblico_app\README.md"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "# biblialingo_app", "# camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "[OK] camino_biblico_app/README.md" -ForegroundColor Green
}

# FASE 4: ANDROID
Write-Host "`nFASE 4: ACTUALIZANDO ANDROID..." -ForegroundColor Magenta

# build.gradle.kts
$filePath = "$projectRoot\camino_biblico_app\android\app\build.gradle.kts"
$content = Get-Content $filePath -Raw
$content = $content -replace 'namespace = "com.example.biblialingo_app"', 'namespace = "com.example.caminobiblico"'
$content = $content -replace 'applicationId = "com.example.biblialingo_app"', 'applicationId = "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] android/app/build.gradle.kts" -ForegroundColor Green

# AndroidManifest.xml
$filePath = "$projectRoot\camino_biblico_app\android\app\src\main\AndroidManifest.xml"
$content = Get-Content $filePath -Raw
$content = $content -replace 'android:label="biblialingo_app"', 'android:label="Camino Biblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] AndroidManifest.xml" -ForegroundColor Green

# Renombrar paquete Android
$oldPath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\biblialingo_app"
$newPath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\caminobiblico"

if (Test-Path $oldPath) {
    Move-Item -Path $oldPath -Destination $newPath
    $mainActivityPath = "$newPath\MainActivity.kt"
    $content = Get-Content $mainActivityPath -Raw
    $content = $content -replace "package com.example.biblialingo_app", "package com.example.caminobiblico"
    Set-Content -Path $mainActivityPath -Value $content
    Write-Host "[OK] Android package renombrado" -ForegroundColor Green
}

# google-services.json
$filePath = "$projectRoot\camino_biblico_app\android\app\google-services.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"project_id": "biblialingo"', '"project_id": "camino_biblico"'
$content = $content -replace '"storage_bucket": "biblialingo.firebasestorage.app"', '"storage_bucket": "camino-biblico.firebasestorage.app"'
$content = $content -replace '"package_name": "com.example.biblialingo_app"', '"package_name": "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] google-services.json" -ForegroundColor Green

# FASE 5: iOS
Write-Host "`nFASE 5: ACTUALIZANDO iOS..." -ForegroundColor Magenta

# Info.plist
$filePath = "$projectRoot\camino_biblico_app\ios\Runner\Info.plist"
$content = Get-Content $filePath -Raw
$content = $content -replace "<string>Biblialingo App</string>", "<string>Camino Biblico</string>"
$content = $content -replace "<string>biblialingo_app</string>", "<string>camino_biblico_app</string>"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] ios/Runner/Info.plist" -ForegroundColor Green

# iOS project.pbxproj
$filePath = "$projectRoot\camino_biblico_app\ios\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] ios/Runner.xcodeproj/project.pbxproj" -ForegroundColor Green

# AppInfo.xcconfig (macOS)
$filePath = "$projectRoot\camino_biblico_app\macos\Runner\Configs\AppInfo.xcconfig"
$content = Get-Content $filePath -Raw
$content = $content -replace "PRODUCT_NAME = biblialingo_app", "PRODUCT_NAME = camino_biblico_app"
$content = $content -replace "PRODUCT_BUNDLE_IDENTIFIER = com.example.biblialingoApp", "PRODUCT_BUNDLE_IDENTIFIER = com.example.caminobiblicoApp"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] macos/Runner/Configs/AppInfo.xcconfig" -ForegroundColor Green

# macOS project.pbxproj
$filePath = "$projectRoot\camino_biblico_app\macos\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] macos/Runner.xcodeproj/project.pbxproj" -ForegroundColor Green

# FASE 6: WEB
Write-Host "`nFASE 6: ACTUALIZANDO WEB..." -ForegroundColor Magenta

# index.html
$filePath = "$projectRoot\camino_biblico_app\web\index.html"
$content = Get-Content $filePath -Raw
$content = $content -replace 'content="biblialingo_app"', 'content="camino_biblico_app"'
$content = $content -replace "<title>biblialingo_app</title>", "<title>Camino Biblico</title>"
Set-Content -Path $filePath -Value $content
Write-Host "[OK] web/index.html" -ForegroundColor Green

# manifest.json
$filePath = "$projectRoot\camino_biblico_app\web\manifest.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"name": "biblialingo_app"', '"name": "camino_biblico_app"'
$content = $content -replace '"short_name": "biblialingo_app"', '"short_name": "Camino Biblico"'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] web/manifest.json" -ForegroundColor Green

# FASE 7: LINUX
Write-Host "`nFASE 7: ACTUALIZANDO LINUX..." -ForegroundColor Magenta

# CMakeLists.txt
$filePath = "$projectRoot\camino_biblico_app\linux\CMakeLists.txt"
$content = Get-Content $filePath -Raw
$content = $content -replace 'set(BINARY_NAME "biblialingo_app")', 'set(BINARY_NAME "camino_biblico_app")'
$content = $content -replace 'set(APPLICATION_ID "com.example.biblialingo_app")', 'set(APPLICATION_ID "com.example.caminobiblico")'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] linux/CMakeLists.txt" -ForegroundColor Green

# my_application.cc
$filePath = "$projectRoot\camino_biblico_app\linux\runner\my_application.cc"
$content = Get-Content $filePath -Raw
$content = $content -replace 'gtk_header_bar_set_title(header_bar, "biblialingo_app")', 'gtk_header_bar_set_title(header_bar, "Camino Biblico")'
$content = $content -replace 'gtk_window_set_title(window, "biblialingo_app")', 'gtk_window_set_title(window, "Camino Biblico")'
Set-Content -Path $filePath -Value $content
Write-Host "[OK] linux/runner/my_application.cc" -ForegroundColor Green

# FASE 8: DOCUMENTACION
Write-Host "`nFASE 8: ACTUALIZANDO DOCUMENTACION..." -ForegroundColor Magenta

$docFiles = @(
    "ESTADO_ACTUAL.md",
    "estado actual .md",
    "QA_TESTING_GUIDE.md",
    "PLAN_AUTO_SCROLL_BOTTOM.md",
    "PLAN_ELIMINAR_ESPACIO_LECCION.md",
    "build.sh"
)

foreach ($file in $docFiles) {
    $filePath = "$projectRoot\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Biblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        $content = $content -replace "biblialingo-app", "camino-biblico-app"
        $content = $content -replace "'rexbiblialingo.'", "'rexcaminobiblico.'"
        Set-Content -Path $filePath -Value $content
        Write-Host "[OK] $file" -ForegroundColor Green
    }
}

# FASE 9: BUSQUEDA MASIVA
Write-Host "`nFASE 9: BUSQUEDA Y REEMPLAZO MASIVO..." -ForegroundColor Magenta

$extensions = @("*.py", "*.dart", "*.kt", "*.json", "*.yaml")
$filesChanged = 0

Get-ChildItem -Path $projectRoot -Recurse -Include $extensions -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -notmatch "(\\build\\|\\\.flutter-plugins|\\\.gradle|\\node_modules|\\\.git|\\\.dart_tool)"
} | ForEach-Object {
    try {
        $filePath = $_.FullName
        $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
        
        if ($null -ne $content) {
            $originalContent = $content
            $content = $content -replace "biblialingo_app", "camino_biblico_app"
            $content = $content -replace "biblialingo-app", "camino-biblico-app"
            $content = $content -replace "biblialingo", "camino_biblico"
            $content = $content -replace "BibliaLingo", "Camino Biblico"
            
            if ($content -ne $originalContent) {
                Set-Content -Path $filePath -Value $content -ErrorAction SilentlyContinue
                $filesChanged++
            }
        }
    } catch {
        # Silenciar errores
    }
}

Write-Host "[OK] Procesados $filesChanged archivos" -ForegroundColor Green

# FASE 10: VERIFICACION
Write-Host "`nFASE 10: VERIFICANDO..." -ForegroundColor Magenta

$criticalFiles = @(
    "camino_biblico\settings\base.py",
    "manage.py",
    "camino_biblico_app\pubspec.yaml"
)

foreach ($file in $criticalFiles) {
    $filePath = "$projectRoot\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match "camino_biblico|Camino Biblico") {
            Write-Host "[OK] $file" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] $file" -ForegroundColor Yellow
        }
    }
}

# FASE 11: LIMPIAR
Write-Host "`nFASE 11: LIMPIANDO..." -ForegroundColor Magenta

$appPath = "$projectRoot\camino_biblico_app"
foreach ($dir in @("build", ".dart_tool", ".flutter-plugins")) {
    $cleanPath = "$appPath\$dir"
    if (Test-Path $cleanPath) {
        Remove-Item -Path $cleanPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[OK] Limpiado: $dir" -ForegroundColor Green
    }
}

# RESUMEN
Write-Host "`n=====================================================" -ForegroundColor Green
Write-Host "RENOMBRADO A CAMINO BIBLICO COMPLETADO" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

Write-Host "`nRESUMEN:" -ForegroundColor Cyan
Write-Host "- Carpetas: 2 renombradas" -ForegroundColor Green
Write-Host "- Archivos Django: ~10 actualizados" -ForegroundColor Green
Write-Host "- Archivos Flutter: ~8 actualizados" -ForegroundColor Green
Write-Host "- Configuracion Android: 4 actualizados" -ForegroundColor Green
Write-Host "- Configuracion iOS: 4 actualizados" -ForegroundColor Green
Write-Host "- Configuracion Web: 2 actualizados" -ForegroundColor Green
Write-Host "- Configuracion Linux: 2 actualizados" -ForegroundColor Green
Write-Host "- Archivos procesados: $filesChanged" -ForegroundColor Green

Write-Host "`nPROXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Renombrar repositorio en GitHub" -ForegroundColor Yellow
Write-Host "2. Actualizar git remote: git remote set-url origin https://github.com/rexrodriguez0123-hue/camino-biblico-app.git" -ForegroundColor Yellow
Write-Host "3. Hacer git push de cambios" -ForegroundColor Yellow
Write-Host "4. Reconfigurar deployment en Render" -ForegroundColor Yellow
Write-Host "5. Compilar localmente: flutter clean && flutter pub get" -ForegroundColor Yellow

Write-Host "`nBACKUP disponible en:" -ForegroundColor Cyan
Write-Host "$backupPath" -ForegroundColor Cyan

Write-Host "`nHecho!" -ForegroundColor Green
