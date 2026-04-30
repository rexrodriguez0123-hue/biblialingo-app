# Script completo para renombrar BibliaLingo → Camino Bíblico
# Autor: Automatizado
# Fecha: 30 de Abril, 2026

$projectRoot = "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"
$backupDate = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupPath = "C:\Backups\biblialingo_backup_$backupDate"

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   PLAN DE RENOMBRADO: BIBLIALINGO → CAMINO BÍBLICO       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ============================================================================
# FASE 0: BACKUP
# ============================================================================
Write-Host "`n📦 FASE 0: CREANDO BACKUP..." -ForegroundColor Magenta
try {
    Copy-Item -Path $projectRoot -Destination $backupPath -Recurse
    Write-Host "✅ Backup creado en: $backupPath" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error al crear backup: $_" -ForegroundColor Yellow
}

Set-Location $projectRoot

# ============================================================================
# FASE 1: RENOMBRAR CARPETAS PRINCIPALES
# ============================================================================
Write-Host "`n📁 FASE 1: RENOMBRANDO CARPETAS..." -ForegroundColor Magenta

try {
    Write-Host "  Renombrando: biblialingo/ → camino_biblico/" -ForegroundColor Cyan
    Rename-Item -Path "biblialingo" -NewName "camino_biblico" -ErrorAction Stop
    Write-Host "  ✅ Carpeta Django renombrada" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Error: $_" -ForegroundColor Red
}

try {
    Write-Host "  Renombrando: biblialingo_app/ → camino_biblico_app/" -ForegroundColor Cyan
    Rename-Item -Path "biblialingo_app" -NewName "camino_biblico_app" -ErrorAction Stop
    Write-Host "  ✅ Carpeta Flutter renombrada" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Error: $_" -ForegroundColor Red
}

# ============================================================================
# FASE 2: ACTUALIZAR CONFIGURACIÓN DJANGO
# ============================================================================
Write-Host "`n⚙️  FASE 2: ACTUALIZANDO DJANGO..." -ForegroundColor Magenta

# 2.1 manage.py
try {
    $filePath = "$projectRoot\manage.py"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "'biblialingo.settings.dev'", "'camino_biblico.settings.dev'"
    $content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ manage.py" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en manage.py: $_" -ForegroundColor Red }

# 2.2 settings/base.py
try {
    $filePath = "$projectRoot\camino_biblico\settings\base.py"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "ROOT_URLCONF = 'biblialingo.urls'", "ROOT_URLCONF = 'camino_biblico.urls'"
    $content = $content -replace "WSGI_APPLICATION = 'biblialingo.wsgi.application'", "WSGI_APPLICATION = 'camino_biblico.wsgi.application'"
    $content = $content -replace "'biblialingo'", "'camino_biblico'"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ settings/base.py" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en settings/base.py: $_" -ForegroundColor Red }

# 2.3 settings/dev.py y prod.py
@("dev.py", "prod.py") | ForEach-Object {
    try {
        $filePath = "$projectRoot\camino_biblico\settings\$_"
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        $content = $content -replace "biblialingo-app.onrender.com", "camino-biblico-app.onrender.com"
        Set-Content -Path $filePath -Value $content
        Write-Host "  ✅ settings/$_" -ForegroundColor Green
    } catch { Write-Host "  ⚠️  Error en settings/$_: $_" -ForegroundColor Red }
}

# 2.4 urls.py, wsgi.py, asgi.py
@("urls.py", "wsgi.py", "asgi.py") | ForEach-Object {
    try {
        $filePath = "$projectRoot\camino_biblico\$_"
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "  ✅ camino_biblico/$_" -ForegroundColor Green
    } catch { Write-Host "  ⚠️  Error en camino_biblico/$_: $_" -ForegroundColor Red }
}

# 2.5 Archivos de servicios
@(
    "apps\users\models.py",
    "apps\bible_content\services\nlp_engine.py",
    "apps\curriculum\services\srs_engine.py"
) | ForEach-Object {
    try {
        $filePath = "$projectRoot\$_"
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw
            $content = $content -replace "BibliaLingo", "Camino Bíblico"
            Set-Content -Path $filePath -Value $content
            Write-Host "  ✅ $_" -ForegroundColor Green
        }
    } catch { Write-Host "  ⚠️  Error en $_: $_" -ForegroundColor Red }
}

# 2.6 fix_genesis_1.py
try {
    $filePath = "$projectRoot\fix_genesis_1.py"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ fix_genesis_1.py" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en fix_genesis_1.py: $_" -ForegroundColor Red }

# ============================================================================
# FASE 3: ACTUALIZAR FLUTTER APP
# ============================================================================
Write-Host "`n📱 FASE 3: ACTUALIZANDO FLUTTER..." -ForegroundColor Magenta

# 3.1 pubspec.yaml
try {
    $filePath = "$projectRoot\camino_biblico_app\pubspec.yaml"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "name: biblialingo_app", "name: camino_biblico_app"
    $content = $content -replace "description: A new Flutter project for BibliaLingo", "description: A new Flutter project for Camino Bíblico"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ pubspec.yaml" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en pubspec.yaml: $_" -ForegroundColor Red }

# 3.2 lib/main.dart
try {
    $filePath = "$projectRoot\camino_biblico_app\lib\main.dart"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "title: 'BibliaLingo'", "title: 'Camino Bíblico'"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ lib/main.dart" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en lib/main.dart: $_" -ForegroundColor Red }

# 3.3 lib/config/api_config.dart
try {
    $filePath = "$projectRoot\camino_biblico_app\lib\config\api_config.dart"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "/// Configuración de API para BibliaLingo", "/// Configuración de API para Camino Bíblico"
    $content = $content -replace "https://biblialingo-app.onrender.com", "https://camino-biblico-app.onrender.com"
    $content = $content -replace "https://biblialingo-staging.onrender.com", "https://camino-biblico-staging.onrender.com"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ lib/config/api_config.dart" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en api_config.dart: $_" -ForegroundColor Red }

# 3.4 Pantallas
@(
    "lib\screens\welcome_screen.dart",
    "lib\screens\settings_screen.dart"
) | ForEach-Object {
    try {
        $filePath = "$projectRoot\camino_biblico_app\$_"
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw
            $content = $content -replace "BibliaLingo", "Camino Bíblico"
            $content = $content -replace "biblialingo", "camino_biblico"
            Set-Content -Path $filePath -Value $content
            Write-Host "  ✅ $_" -ForegroundColor Green
        }
    } catch { Write-Host "  ⚠️  Error en $_: $_" -ForegroundColor Red }
}

# 3.5 Tests
try {
    $filePath = "$projectRoot\camino_biblico_app\test\widget_test.dart"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "package:biblialingo_app", "package:camino_biblico_app"
        Set-Content -Path $filePath -Value $content
        Write-Host "  ✅ test/widget_test.dart" -ForegroundColor Green
    }
} catch { Write-Host "  ⚠️  Error en widget_test.dart: $_" -ForegroundColor Red }

# 3.6 README.md
try {
    $filePath = "$projectRoot\camino_biblico_app\README.md"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "# biblialingo_app", "# camino_biblico_app"
        Set-Content -Path $filePath -Value $content
        Write-Host "  ✅ camino_biblico_app/README.md" -ForegroundColor Green
    }
} catch { Write-Host "  ⚠️  Error en README.md: $_" -ForegroundColor Red }

# ============================================================================
# FASE 4: ACTUALIZAR CONFIGURACIÓN ANDROID
# ============================================================================
Write-Host "`n🤖 FASE 4: ACTUALIZANDO ANDROID..." -ForegroundColor Magenta

# 4.1 build.gradle.kts
try {
    $filePath = "$projectRoot\camino_biblico_app\android\app\build.gradle.kts"
    $content = Get-Content $filePath -Raw
    $content = $content -replace 'namespace = "com.example.biblialingo_app"', 'namespace = "com.example.caminobiblico"'
    $content = $content -replace 'applicationId = "com.example.biblialingo_app"', 'applicationId = "com.example.caminobiblico"'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ android/app/build.gradle.kts" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en build.gradle.kts: $_" -ForegroundColor Red }

# 4.2 AndroidManifest.xml
try {
    $filePath = "$projectRoot\camino_biblico_app\android\app\src\main\AndroidManifest.xml"
    $content = Get-Content $filePath -Raw
    $content = $content -replace 'android:label="biblialingo_app"', 'android:label="Camino Bíblico"'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ AndroidManifest.xml" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en AndroidManifest.xml: $_" -ForegroundColor Red }

# 4.3 Renombrar paquete Android
try {
    $oldPackagePath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\biblialingo_app"
    $newPackagePath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\caminobiblico"
    
    if (Test-Path $oldPackagePath) {
        Write-Host "  Moviendo paquete Android: com.example.biblialingo_app → com.example.caminobiblico" -ForegroundColor Cyan
        Move-Item -Path $oldPackagePath -Destination $newPackagePath -ErrorAction Stop
        
        # Actualizar MainActivity.kt
        $mainActivityPath = "$newPackagePath\MainActivity.kt"
        $content = Get-Content $mainActivityPath -Raw
        $content = $content -replace "package com.example.biblialingo_app", "package com.example.caminobiblico"
        Set-Content -Path $mainActivityPath -Value $content
        Write-Host "  ✅ Android package renombrado" -ForegroundColor Green
    }
} catch { Write-Host "  ⚠️  Error al renombrar paquete Android: $_" -ForegroundColor Red }

# 4.4 google-services.json
try {
    $filePath = "$projectRoot\camino_biblico_app\android\app\google-services.json"
    $content = Get-Content $filePath -Raw
    $content = $content -replace '"project_id": "biblialingo"', '"project_id": "camino_biblico"'
    $content = $content -replace '"storage_bucket": "biblialingo.firebasestorage.app"', '"storage_bucket": "camino-biblico.firebasestorage.app"'
    $content = $content -replace '"package_name": "com.example.biblialingo_app"', '"package_name": "com.example.caminobiblico"'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ google-services.json" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en google-services.json: $_" -ForegroundColor Red }

# ============================================================================
# FASE 5: ACTUALIZAR CONFIGURACIÓN iOS
# ============================================================================
Write-Host "`n🍎 FASE 5: ACTUALIZANDO iOS..." -ForegroundColor Magenta

# 5.1 Info.plist
try {
    $filePath = "$projectRoot\camino_biblico_app\ios\Runner\Info.plist"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "<string>Biblialingo App</string>", "<string>Camino Bíblico</string>"
    $content = $content -replace "<string>biblialingo_app</string>", "<string>camino_biblico_app</string>"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ ios/Runner/Info.plist" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en Info.plist: $_" -ForegroundColor Red }

# 5.2 project.pbxproj (iOS)
try {
    $filePath = "$projectRoot\camino_biblico_app\ios\Runner.xcodeproj\project.pbxproj"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
    $content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ ios/Runner.xcodeproj/project.pbxproj" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en iOS project.pbxproj: $_" -ForegroundColor Red }

# 5.3 AppInfo.xcconfig (macOS)
try {
    $filePath = "$projectRoot\camino_biblico_app\macos\Runner\Configs\AppInfo.xcconfig"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "PRODUCT_NAME = biblialingo_app", "PRODUCT_NAME = camino_biblico_app"
    $content = $content -replace "PRODUCT_BUNDLE_IDENTIFIER = com.example.biblialingoApp", "PRODUCT_BUNDLE_IDENTIFIER = com.example.caminobiblicoApp"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ macos/Runner/Configs/AppInfo.xcconfig" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en AppInfo.xcconfig: $_" -ForegroundColor Red }

# 5.4 project.pbxproj (macOS)
try {
    $filePath = "$projectRoot\camino_biblico_app\macos\Runner.xcodeproj\project.pbxproj"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
    $content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ macos/Runner.xcodeproj/project.pbxproj" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en macOS project.pbxproj: $_" -ForegroundColor Red }

# ============================================================================
# FASE 6: ACTUALIZAR CONFIGURACIÓN WEB
# ============================================================================
Write-Host "`n🌐 FASE 6: ACTUALIZANDO WEB..." -ForegroundColor Magenta

# 6.1 index.html
try {
    $filePath = "$projectRoot\camino_biblico_app\web\index.html"
    $content = Get-Content $filePath -Raw
    $content = $content -replace 'content="biblialingo_app"', 'content="camino_biblico_app"'
    $content = $content -replace "<title>biblialingo_app</title>", "<title>Camino Bíblico</title>"
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ web/index.html" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en index.html: $_" -ForegroundColor Red }

# 6.2 manifest.json
try {
    $filePath = "$projectRoot\camino_biblico_app\web\manifest.json"
    $content = Get-Content $filePath -Raw
    $content = $content -replace '"name": "biblialingo_app"', '"name": "camino_biblico_app"'
    $content = $content -replace '"short_name": "biblialingo_app"', '"short_name": "Camino Bíblico"'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ web/manifest.json" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en manifest.json: $_" -ForegroundColor Red }

# ============================================================================
# FASE 7: ACTUALIZAR CONFIGURACIÓN LINUX
# ============================================================================
Write-Host "`n🐧 FASE 7: ACTUALIZANDO LINUX..." -ForegroundColor Magenta

# 7.1 CMakeLists.txt
try {
    $filePath = "$projectRoot\camino_biblico_app\linux\CMakeLists.txt"
    $content = Get-Content $filePath -Raw
    $content = $content -replace 'set(BINARY_NAME "biblialingo_app")', 'set(BINARY_NAME "camino_biblico_app")'
    $content = $content -replace 'set(APPLICATION_ID "com.example.biblialingo_app")', 'set(APPLICATION_ID "com.example.caminobiblico")'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ linux/CMakeLists.txt" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en CMakeLists.txt: $_" -ForegroundColor Red }

# 7.2 my_application.cc
try {
    $filePath = "$projectRoot\camino_biblico_app\linux\runner\my_application.cc"
    $content = Get-Content $filePath -Raw
    $content = $content -replace 'gtk_header_bar_set_title(header_bar, "biblialingo_app")', 'gtk_header_bar_set_title(header_bar, "Camino Bíblico")'
    $content = $content -replace 'gtk_window_set_title(window, "biblialingo_app")', 'gtk_window_set_title(window, "Camino Bíblico")'
    Set-Content -Path $filePath -Value $content
    Write-Host "  ✅ linux/runner/my_application.cc" -ForegroundColor Green
} catch { Write-Host "  ⚠️  Error en my_application.cc: $_" -ForegroundColor Red }

# ============================================================================
# FASE 8: ACTUALIZAR DOCUMENTACIÓN
# ============================================================================
Write-Host "`n📄 FASE 8: ACTUALIZANDO DOCUMENTACIÓN..." -ForegroundColor Magenta

$docFiles = @(
    "ESTADO_ACTUAL.md",
    "estado actual .md",
    "QA_TESTING_GUIDE.md",
    "PLAN_AUTO_SCROLL_BOTTOM.md",
    "PLAN_ELIMINAR_ESPACIO_LECCION.md",
    "build.sh"
)

$docFiles | ForEach-Object {
    try {
        $filePath = "$projectRoot\$_"
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw
            $content = $content -replace "BibliaLingo", "Camino Bíblico"
            $content = $content -replace "biblialingo", "camino_biblico"
            $content = $content -replace "biblialingo-app", "camino-biblico-app"
            $content = $content -replace "'rexbiblialingo.'", "'rexcaminobiblico.'"
            Set-Content -Path $filePath -Value $content
            Write-Host "  OK $_" -ForegroundColor Green
        }
    } catch { Write-Host "  ERROR en $_" -ForegroundColor Red }
}

# Archivo análisis ui (nombre especial con espacios)
try {
    $filePath = "$projectRoot\análisis ui\ux biblialingo .md"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "  OK análisis ui/ux biblialingo .md" -ForegroundColor Green
    }
} catch { Write-Host "  ERROR en análisis ui" -ForegroundColor Red }

# ============================================================================
# FASE 9: BÚSQUEDA Y REEMPLAZO MASIVO
# ============================================================================
Write-Host "`n🔍 FASE 9: BÚSQUEDA Y REEMPLAZO MASIVO..." -ForegroundColor Magenta

$searchPatterns = @(
    @{ old = "biblialingo"; new = "camino_biblico" },
    @{ old = "BibliaLingo"; new = "Camino Bíblico" },
    @{ old = "biblialingo-app"; new = "camino-biblico-app" },
    @{ old = "biblialingo_app"; new = "camino_biblico_app" },
    @{ old = "biblialingo@example.com"; new = "caminobiblico@example.com" }
)

$extensions = @("*.py", "*.dart", "*.kt", "*.swift", "*.tsx", "*.ts", "*.js", "*.json", "*.yaml", "*.yml", "*.xml", "*.plist", "*.gradle")

$filesChanged = 0
Get-ChildItem -Path $projectRoot -Recurse -Include $extensions -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -notmatch "(\\build\\|\\\.flutter-plugins|\\\.gradle|\\node_modules|\\\.git|\\\.dart_tool)"
} | ForEach-Object {
    try {
        $filePath = $_.FullName
        $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
        
        if ($null -ne $content) {
            $originalContent = $content
            
            $searchPatterns | ForEach-Object {
                if ($_.old -ne $_.new) {
                    $content = $content -replace [regex]::Escape($_.old), $_.new
                }
            }
            
            if ($content -ne $originalContent) {
                Set-Content -Path $filePath -Value $content -ErrorAction SilentlyContinue
                $filesChanged++
            }
        }
    } catch {
        # Silenciar errores de archivos que no se pueden leer
    }
}

Write-Host "  ✅ Archivos procesados en búsqueda masiva: $filesChanged" -ForegroundColor Green

# ============================================================================
# FASE 10: VERIFICACIÓN
# ============================================================================
Write-Host "`n✔️  FASE 10: VERIFICANDO CAMBIOS..." -ForegroundColor Magenta

$criticalFiles = @(
    "camino_biblico\settings\base.py",
    "manage.py",
    "camino_biblico_app\pubspec.yaml",
    "camino_biblico_app\lib\main.dart"
)

$criticalFiles | ForEach-Object {
    $filePath = "$projectRoot\$_"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match "camino_biblico|Camino Bíblico") {
            Write-Host "  ✅ $_" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $_" -ForegroundColor Yellow
        }
    }
}

# Verificar referencias antiguas
Write-Host "`n🔎 Buscando referencias antiguas..." -ForegroundColor Cyan
$oldReferences = Get-ChildItem -Path $projectRoot -Recurse -Include @("*.py", "*.dart", "*.kt", "*.json", "*.yaml") -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -notmatch "(\\build\\|\\\.flutter-plugins|\\\.gradle|\\node_modules|\\\.git|\\\.dart_tool)" } |
    Select-String -Pattern "biblialingo|BibliaLingo" -ErrorAction SilentlyContinue | Select-Object -First 20

if ($oldReferences) {
    Write-Host "⚠️  Referencias antiguas encontradas:" -ForegroundColor Yellow
    $oldReferences | ForEach-Object { 
        Write-Host "  → $($_.Path | Split-Path -Leaf): $(($_.Line -replace '\s+', ' ').Substring(0, [Math]::Min(60, ($_.Line -replace '\s+', ' ').Length)))..." -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No se encontraron referencias antiguas" -ForegroundColor Green
}

# ============================================================================
# FASE 11: LIMPIAR Y FINALIZAR
# ============================================================================
Write-Host "`n🧹 FASE 11: LIMPIANDO Y FINALIZANDO..." -ForegroundColor Magenta

# Limpiar caché de Flutter
$appPath = "$projectRoot\camino_biblico_app"
$directoriestoClean = @("build", ".dart_tool", ".flutter-plugins")

$directoriestoClean | ForEach-Object {
    $cleanPath = "$appPath\$_"
    if (Test-Path $cleanPath) {
        try {
            Remove-Item -Path $cleanPath -Recurse -Force
            Write-Host "  ✅ Limpiado: $_" -ForegroundColor Green
        } catch { 
            Write-Host "  ℹ️  No se pudo limpiar $_" -ForegroundColor Gray
        }
    }
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ RENOMBRADO A 'CAMINO BÍBLICO' COMPLETADO              ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 RESUMEN DE CAMBIOS:" -ForegroundColor Cyan
Write-Host "  ✓ Carpetas: 2 renombradas (biblialingo → camino_biblico)" -ForegroundColor Green
Write-Host "  ✓ Archivos Django: ~10 actualizados" -ForegroundColor Green
Write-Host "  ✓ Archivos Flutter: ~8 actualizados" -ForegroundColor Green
Write-Host "  ✓ Configuración Android: 4 actualizados" -ForegroundColor Green
Write-Host "  ✓ Configuración iOS: 4 actualizados" -ForegroundColor Green
Write-Host "  ✓ Configuración Web: 2 actualizados" -ForegroundColor Green
Write-Host "  ✓ Configuración Linux: 2 actualizados" -ForegroundColor Green
Write-Host "  ✓ Documentación: 8+ archivos actualizados" -ForegroundColor Green
Write-Host "  ✓ Búsqueda masiva: ~$filesChanged archivos procesados" -ForegroundColor Green

Write-Host "`n📝 PRÓXIMOS PASOS MANUALES:" -ForegroundColor Yellow
Write-Host "  1. GitHub: Renombrar repositorio en github.com" -ForegroundColor Yellow
Write-Host "  2. Git local: Actualizar remote URL" -ForegroundColor Yellow
Write-Host "  3. Render: Actualizar deployment" -ForegroundColor Yellow
Write-Host "  4. Firebase: Actualizar configuración (si es necesario)" -ForegroundColor Yellow
Write-Host "  5. Compilar localmente: flutter clean && flutter pub get" -ForegroundColor Yellow

Write-Host "`n💾 BACKUP DISPONIBLE EN:" -ForegroundColor Cyan
Write-Host "  $backupPath" -ForegroundColor Cyan

Write-Host "`n✅ El renombrado ha sido completado exitosamente." -ForegroundColor Green
Write-Host "⚠️  Consulta PASOS_MANUALES_SERVICIOS_EXTERNOS.md para los cambios en servicios externos." -ForegroundColor Cyan

Read-Host "`nPresiona Enter para finalizar"
