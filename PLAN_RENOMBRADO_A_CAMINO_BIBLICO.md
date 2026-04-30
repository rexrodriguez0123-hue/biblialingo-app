# 🔄 PLAN DE RENOMBRADO: BIBLIALINGO → CAMINO BÍBLICO

**Documento:** Plan completo automatizado para cambiar el nombre de la aplicación  
**Fecha de creación:** 30 de Abril, 2026  
**Nueva app:** Camino Bíblico  
**Scope:** 94+ referencias en carpetas, código, configuración y servicios externos

---

## 📋 MAPEO DE CAMBIOS PRINCIPALES

| Anterior | Nuevo | Categoría | Crítico |
|----------|-------|-----------|---------|
| `biblialingo/` | `camino_biblico/` | Carpeta Django | ✅ SÍ |
| `biblialingo_app/` | `camino_biblico_app/` | Carpeta Flutter | ✅ SÍ |
| `biblialingo_app` | `camino_biblico_app` | Nombre paquete Flutter | ✅ SÍ |
| `com.example.biblialingo_app` | `com.example.caminobiblico` | Package Android | ✅ SÍ |
| `com.example.biblialingoApp` | `com.example.caminobiblicoApp` | Bundle iOS/macOS | ✅ SÍ |
| `biblialingo` | `camino_biblico` | Módulo Django | ✅ SÍ |
| `BibliaLingo` | `Camino Bíblico` | Nombre mostrado UI | 🟡 ALTO |
| `biblialingo-app` | `camino-biblico-app` | URLs/Servicios externos | 🟡 ALTO |

---

## ⚠️ PREREQUISITOS ANTES DE EJECUTAR

**IMPORTANTE:** Hacer backup completo antes de empezar

```powershell
# Crear backup
$backupDate = Get-Date -Format "yyyy-MM-dd_HHmmss"
$backupPath = "C:\Backups\biblialingo_backup_$backupDate"
Copy-Item -Path "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo" -Destination $backupPath -Recurse
Write-Host "Backup creado en: $backupPath"
```

---

## 🚀 EJECUCIÓN DEL PLAN

### FASE 1: RENOMBRAR CARPETAS PRINCIPALES

```powershell
# Navegar al directorio raíz del proyecto
$projectRoot = "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"
Set-Location $projectRoot

# Renombrar carpeta Django principal
Write-Host "Renombrando carpeta Django: biblialingo/ → camino_biblico/" -ForegroundColor Cyan
Rename-Item -Path "biblialingo" -NewName "camino_biblico"
Write-Host "✅ Carpeta Django renombrada" -ForegroundColor Green

# Renombrar carpeta Flutter
Write-Host "Renombrando carpeta Flutter: biblialingo_app/ → camino_biblico_app/" -ForegroundColor Cyan
Rename-Item -Path "biblialingo_app" -NewName "camino_biblico_app"
Write-Host "✅ Carpeta Flutter renombrada" -ForegroundColor Green
```

---

### FASE 2: ACTUALIZAR CONFIGURACIÓN DJANGO

#### 2.1 Actualizar manage.py

```powershell
$filePath = "$projectRoot\manage.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "'biblialingo.settings.dev'", "'camino_biblico.settings.dev'"
$content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
Set-Content -Path $filePath -Value $content
Write-Host "✅ manage.py actualizado"
```

#### 2.2 Actualizar settings/base.py

```powershell
$filePath = "$projectRoot\camino_biblico\settings\base.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "ROOT_URLCONF = 'biblialingo.urls'", "ROOT_URLCONF = 'camino_biblico.urls'"
$content = $content -replace "WSGI_APPLICATION = 'biblialingo.wsgi.application'", "WSGI_APPLICATION = 'camino_biblico.wsgi.application'"
$content = $content -replace "'biblialingo'" , "'camino_biblico'"
Set-Content -Path $filePath -Value $content
Write-Host "✅ settings/base.py actualizado"
```

#### 2.3 Actualizar settings/dev.py y prod.py

```powershell
@("dev.py", "prod.py") | ForEach-Object {
    $filePath = "$projectRoot\camino_biblico\settings\$_"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "BibliaLingo", "Camino Bíblico"
    $content = $content -replace "biblialingo", "camino_biblico"
    Set-Content -Path $filePath -Value $content
    Write-Host "✅ settings/$_ actualizado"
}
```

#### 2.4 Actualizar settings/prod.py - URLs

```powershell
$filePath = "$projectRoot\camino_biblico\settings\prod.py"
$content = Get-Content $filePath -Raw

# Cambiar URLs de producción (reservar para cambios manuales en Render)
$content = $content -replace "biblialingo-app.onrender.com", "camino-biblico-app.onrender.com"

Set-Content -Path $filePath -Value $content
Write-Host "✅ URLs de producción en prod.py actualizadas"
```

#### 2.5 Actualizar urls.py y otros archivos de configuración

```powershell
@("urls.py", "wsgi.py", "asgi.py") | ForEach-Object {
    $filePath = "$projectRoot\camino_biblico\$_"
    $content = Get-Content $filePath -Raw
    $content = $content -replace "BibliaLingo", "Camino Bíblico"
    $content = $content -replace "biblialingo", "camino_biblico"
    Set-Content -Path $filePath -Value $content
    Write-Host "✅ camino_biblico/$_ actualizado"
}
```

#### 2.6 Actualizar archivos de servicios

```powershell
@(
    "apps\users\models.py",
    "apps\bible_content\services\nlp_engine.py",
    "apps\curriculum\services\srs_engine.py"
) | ForEach-Object {
    $filePath = "$projectRoot\$_"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "✅ $_ actualizado"
    }
}
```

#### 2.7 Actualizar fix_genesis_1.py

```powershell
$filePath = "$projectRoot\fix_genesis_1.py"
$content = Get-Content $filePath -Raw
$content = $content -replace "'biblialingo.settings.prod'", "'camino_biblico.settings.prod'"
Set-Content -Path $filePath -Value $content
Write-Host "✅ fix_genesis_1.py actualizado"
```

---

### FASE 3: ACTUALIZAR FLUTTER APP

#### 3.1 Actualizar pubspec.yaml

```powershell
$filePath = "$projectRoot\camino_biblico_app\pubspec.yaml"
$content = Get-Content $filePath -Raw
$content = $content -replace "name: biblialingo_app", "name: camino_biblico_app"
$content = $content -replace "description: A new Flutter project for BibliaLingo", "description: A new Flutter project for Camino Bíblico"
Set-Content -Path $filePath -Value $content
Write-Host "✅ pubspec.yaml actualizado"
```

#### 3.2 Actualizar lib/main.dart

```powershell
$filePath = "$projectRoot\camino_biblico_app\lib\main.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "title: 'BibliaLingo'", "title: 'Camino Bíblico'"
Set-Content -Path $filePath -Value $content
Write-Host "✅ lib/main.dart actualizado"
```

#### 3.3 Actualizar lib/config/api_config.dart

```powershell
$filePath = "$projectRoot\camino_biblico_app\lib\config\api_config.dart"
$content = Get-Content $filePath -Raw
$content = $content -replace "/// Configuración de API para BibliaLingo", "/// Configuración de API para Camino Bíblico"
$content = $content -replace "https://biblialingo-app.onrender.com", "https://camino-biblico-app.onrender.com"
$content = $content -replace "https://biblialingo-staging.onrender.com", "https://camino-biblico-staging.onrender.com"
Set-Content -Path $filePath -Value $content
Write-Host "✅ lib/config/api_config.dart actualizado"
```

#### 3.4 Actualizar pantallas (Screens)

```powershell
@(
    "lib\screens\welcome_screen.dart",
    "lib\screens\settings_screen.dart"
) | ForEach-Object {
    $filePath = "$projectRoot\camino_biblico_app\$_"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "✅ $_ actualizado"
    }
}
```

#### 3.5 Actualizar test/widget_test.dart

```powershell
$filePath = "$projectRoot\camino_biblico_app\test\widget_test.dart"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "package:biblialingo_app", "package:camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "✅ test/widget_test.dart actualizado"
}
```

#### 3.6 Actualizar README.md Flutter

```powershell
$filePath = "$projectRoot\camino_biblico_app\README.md"
if (Test-Path $filePath) {
    $content = Get-Content $filePath -Raw
    $content = $content -replace "# biblialingo_app", "# camino_biblico_app"
    Set-Content -Path $filePath -Value $content
    Write-Host "✅ camino_biblico_app/README.md actualizado"
}
```

---

### FASE 4: ACTUALIZAR CONFIGURACIÓN ANDROID

#### 4.1 Actualizar build.gradle.kts

```powershell
$filePath = "$projectRoot\camino_biblico_app\android\app\build.gradle.kts"
$content = Get-Content $filePath -Raw
$content = $content -replace 'namespace = "com.example.biblialingo_app"', 'namespace = "com.example.caminobiblico"'
$content = $content -replace 'applicationId = "com.example.biblialingo_app"', 'applicationId = "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "✅ android/app/build.gradle.kts actualizado"
```

#### 4.2 Actualizar AndroidManifest.xml

```powershell
$filePath = "$projectRoot\camino_biblico_app\android\app\src\main\AndroidManifest.xml"
$content = Get-Content $filePath -Raw
$content = $content -replace 'android:label="biblialingo_app"', 'android:label="Camino Bíblico"'
Set-Content -Path $filePath -Value $content
Write-Host "✅ android/app/src/main/AndroidManifest.xml actualizado"
```

#### 4.3 Renombrar paquete Android y actualizar MainActivity.kt

```powershell
# Renombrar carpeta de paquete
$oldPackagePath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\biblialingo_app"
$newPackagePath = "$projectRoot\camino_biblico_app\android\app\src\main\kotlin\com\example\caminobiblico"

if (Test-Path $oldPackagePath) {
    Write-Host "Renombrando carpeta Android: com.example.biblialingo_app → com.example.caminobiblico" -ForegroundColor Cyan
    Move-Item -Path $oldPackagePath -Destination $newPackagePath
    
    # Actualizar MainActivity.kt con nuevo package
    $mainActivityPath = "$newPackagePath\MainActivity.kt"
    $content = Get-Content $mainActivityPath -Raw
    $content = $content -replace "package com.example.biblialingo_app", "package com.example.caminobiblico"
    Set-Content -Path $mainActivityPath -Value $content
    Write-Host "✅ Android package renombrado y MainActivity.kt actualizado"
}
```

#### 4.4 Actualizar google-services.json

```powershell
$filePath = "$projectRoot\camino_biblico_app\android\app\google-services.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"project_id": "biblialingo"', '"project_id": "camino_biblico"'
$content = $content -replace '"storage_bucket": "biblialingo.firebasestorage.app"', '"storage_bucket": "camino-biblico.firebasestorage.app"'
$content = $content -replace '"package_name": "com.example.biblialingo_app"', '"package_name": "com.example.caminobiblico"'
Set-Content -Path $filePath -Value $content
Write-Host "✅ android/app/google-services.json actualizado"
```

---

### FASE 5: ACTUALIZAR CONFIGURACIÓN iOS

#### 5.1 Actualizar Info.plist

```powershell
$filePath = "$projectRoot\camino_biblico_app\ios\Runner\Info.plist"
$content = Get-Content $filePath -Raw
$content = $content -replace "<string>Biblialingo App</string>", "<string>Camino Bíblico</string>"
$content = $content -replace "<string>biblialingo_app</string>", "<string>camino_biblico_app</string>"
Set-Content -Path $filePath -Value $content
Write-Host "✅ ios/Runner/Info.plist actualizado"
```

#### 5.2 Actualizar project.pbxproj (iOS)

```powershell
$filePath = "$projectRoot\camino_biblico_app\ios\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "✅ ios/Runner.xcodeproj/project.pbxproj actualizado"
```

#### 5.3 Actualizar AppInfo.xcconfig (macOS)

```powershell
$filePath = "$projectRoot\camino_biblico_app\macos\Runner\Configs\AppInfo.xcconfig"
$content = Get-Content $filePath -Raw
$content = $content -replace "PRODUCT_NAME = biblialingo_app", "PRODUCT_NAME = camino_biblico_app"
$content = $content -replace "PRODUCT_BUNDLE_IDENTIFIER = com.example.biblialingoApp", "PRODUCT_BUNDLE_IDENTIFIER = com.example.caminobiblicoApp"
Set-Content -Path $filePath -Value $content
Write-Host "✅ macos/Runner/Configs/AppInfo.xcconfig actualizado"
```

#### 5.4 Actualizar project.pbxproj (macOS)

```powershell
$filePath = "$projectRoot\camino_biblico_app\macos\Runner.xcodeproj\project.pbxproj"
$content = Get-Content $filePath -Raw
$content = $content -replace "com.example.biblialingoApp", "com.example.caminobiblicoApp"
$content = $content -replace "biblialingo_app.app", "camino_biblico_app.app"
Set-Content -Path $filePath -Value $content
Write-Host "✅ macos/Runner.xcodeproj/project.pbxproj actualizado"
```

---

### FASE 6: ACTUALIZAR CONFIGURACIÓN WEB

#### 6.1 Actualizar index.html

```powershell
$filePath = "$projectRoot\camino_biblico_app\web\index.html"
$content = Get-Content $filePath -Raw
$content = $content -replace 'content="biblialingo_app"', 'content="camino_biblico_app"'
$content = $content -replace "<title>biblialingo_app</title>", "<title>Camino Bíblico</title>"
Set-Content -Path $filePath -Value $content
Write-Host "✅ web/index.html actualizado"
```

#### 6.2 Actualizar manifest.json

```powershell
$filePath = "$projectRoot\camino_biblico_app\web\manifest.json"
$content = Get-Content $filePath -Raw
$content = $content -replace '"name": "biblialingo_app"', '"name": "camino_biblico_app"'
$content = $content -replace '"short_name": "biblialingo_app"', '"short_name": "Camino Bíblico"'
Set-Content -Path $filePath -Value $content
Write-Host "✅ web/manifest.json actualizado"
```

---

### FASE 7: ACTUALIZAR CONFIGURACIÓN LINUX

#### 7.1 Actualizar CMakeLists.txt

```powershell
$filePath = "$projectRoot\camino_biblico_app\linux\CMakeLists.txt"
$content = Get-Content $filePath -Raw
$content = $content -replace 'set(BINARY_NAME "biblialingo_app")', 'set(BINARY_NAME "camino_biblico_app")'
$content = $content -replace 'set(APPLICATION_ID "com.example.biblialingo_app")', 'set(APPLICATION_ID "com.example.caminobiblico")'
Set-Content -Path $filePath -Value $content
Write-Host "✅ linux/CMakeLists.txt actualizado"
```

#### 7.2 Actualizar my_application.cc

```powershell
$filePath = "$projectRoot\camino_biblico_app\linux\runner\my_application.cc"
$content = Get-Content $filePath -Raw
$content = $content -replace 'gtk_header_bar_set_title(header_bar, "biblialingo_app")', 'gtk_header_bar_set_title(header_bar, "Camino Bíblico")'
$content = $content -replace 'gtk_window_set_title(window, "biblialingo_app")', 'gtk_window_set_title(window, "Camino Bíblico")'
Set-Content -Path $filePath -Value $content
Write-Host "✅ linux/runner/my_application.cc actualizado"
```

---

### FASE 8: ACTUALIZAR DOCUMENTACIÓN

#### 8.1 Actualizar archivos de documentación

```powershell
$docFiles = @(
    "ESTADO_ACTUAL.md",
    "estado actual .md",
    "QA_TESTING_GUIDE.md",
    "análisis ui\ux biblialingo .md",
    "camino_biblico_app\ESTADO_ACTUAL.md",
    "PLAN_AUTO_SCROLL_BOTTOM.md",
    "PLAN_ELIMINAR_ESPACIO_LECCION.md"
)

$docFiles | ForEach-Object {
    $filePath = "$projectRoot\$_"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        $content = $content -replace "BibliaLingo", "Camino Bíblico"
        $content = $content -replace "biblialingo", "camino_biblico"
        $content = $content -replace "biblialingo-app", "camino-biblico-app"
        $content = $content -replace "ux biblialingo", "ux camino biblico"
        Set-Content -Path $filePath -Value $content
        Write-Host "✅ $_ actualizado"
    }
}
```

#### 8.2 Actualizar build.sh

```powershell
$filePath = "$projectRoot\build.sh"
$content = Get-Content $filePath -Raw
$content = $content -replace "'rexbiblialingo.'", "'rexcaminobiblico.'"
Set-Content -Path $filePath -Value $content
Write-Host "✅ build.sh actualizado"
```

---

### FASE 9: ACTUALIZAR TODAS LAS REFERENCIAS RESTANTES

#### 9.1 Búsqueda y reemplazo masivo en todo el proyecto

```powershell
# Buscar y reemplazar en todos los archivos de código
$searchPatterns = @(
    @{ old = "biblialingo"; new = "camino_biblico" },
    @{ old = "BibliaLingo"; new = "Camino Bíblico" },
    @{ old = "biblialingo-app"; new = "camino-biblico-app" },
    @{ old = "biblialingo_app"; new = "camino_biblico_app" },
    @{ old = "biblialingo@example.com"; new = "caminobiblico@example.com" },
    @{ old = "qa-test-"; new = "qa-test-"; } # Esto se deja igual, es un patrón
)

# Extensiones de archivo a buscar
$extensions = @("*.py", "*.dart", "*.kt", "*.swift", "*.tsx", "*.ts", "*.js", "*.json", "*.yaml", "*.yml", "*.xml", "*.plist", "*.gradle", "*.md")

Write-Host "Ejecutando búsqueda y reemplazo masivo en proyecto..." -ForegroundColor Yellow

Get-ChildItem -Path $projectRoot -Recurse -Include $extensions | Where-Object {
    # Excluir carpetas de build, node_modules, etc.
    $_.FullName -notmatch "(\\build\\|\\\.flutter-plugins|\\\.gradle|\\node_modules|\\\.git)" 
} | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath -Raw -ErrorAction SilentlyContinue
    
    if ($null -ne $content) {
        $originalContent = $content
        
        # Aplicar todos los patrones de búsqueda
        $searchPatterns | ForEach-Object {
            if ($_.old -ne $_.new) {
                $content = $content -replace [regex]::Escape($_.old), $_.new
            }
        }
        
        # Si cambió algo, guardar el archivo
        if ($content -ne $originalContent) {
            Set-Content -Path $filePath -Value $content -ErrorAction SilentlyContinue
            Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
        }
    }
}

Write-Host "✅ Búsqueda y reemplazo masivo completado" -ForegroundColor Green
```

---

### FASE 10: VERIFICACIÓN Y VALIDACIÓN

#### 10.1 Verificar cambios en archivos críticos

```powershell
Write-Host "=== VERIFICACIÓN DE CAMBIOS ===" -ForegroundColor Cyan

# Lista de archivos críticos a verificar
$criticalFiles = @(
    "camino_biblico\settings\base.py",
    "manage.py",
    "camino_biblico_app\pubspec.yaml",
    "camino_biblico_app\lib\main.dart",
    "camino_biblico_app\android\app\build.gradle.kts",
    "camino_biblico_app\ios\Runner\Info.plist"
)

$criticalFiles | ForEach-Object {
    $filePath = "$projectRoot\$_"
    if (Test-Path $filePath) {
        Write-Host "`n📄 $_" -ForegroundColor Yellow
        $content = Get-Content $filePath | Select-String -Pattern "(camino_biblico|Camino Bíblico)" | Select-Object -First 3
        if ($content) {
            $content | ForEach-Object { Write-Host "  → $_" }
        } else {
            Write-Host "  ⚠️ No se encontraron referencias esperadas" -ForegroundColor Yellow
        }
    }
}
```

#### 10.2 Buscar referencias antiguas restantes

```powershell
Write-Host "`n=== BÚSQUEDA DE REFERENCIAS ANTIGUAS ===" -ForegroundColor Cyan

$oldReferences = Get-ChildItem -Path $projectRoot -Recurse -Include @("*.py", "*.dart", "*.kt", "*.swift", "*.json", "*.yaml", "*.md") | 
    Where-Object { $_.FullName -notmatch "(\\build\\|\\\.flutter-plugins|\\\.gradle|\\node_modules|\\\.git)" } |
    Select-String -Pattern "biblialingo|BibliaLingo" -ErrorAction SilentlyContinue

if ($oldReferences) {
    Write-Host "⚠️ Referencias antiguas encontradas:" -ForegroundColor Red
    $oldReferences | ForEach-Object { 
        Write-Host "  → $($_.Path): $($_.Line.Trim())" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ No se encontraron referencias antiguas" -ForegroundColor Green
}
```

---

### FASE 11: LIMPIAR Y FINALIZAR

#### 11.1 Limpiar archivos de caché (Flutter)

```powershell
Write-Host "Limpiando caché de Flutter..." -ForegroundColor Cyan

$appPath = "$projectRoot\camino_biblico_app"
$directoriestoClean = @("build", ".dart_tool", ".flutter-plugins")

$directoriestoClean | ForEach-Object {
    $cleanPath = "$appPath\$_"
    if (Test-Path $cleanPath) {
        Remove-Item -Path $cleanPath -Recurse -Force
        Write-Host "  ✓ Limpiado: $_"
    }
}

Write-Host "✅ Caché limpiado"
```

#### 11.2 Ejecutar Flutter pub get

```powershell
Write-Host "Ejecutando Flutter pub get..." -ForegroundColor Cyan
Set-Location "$projectRoot\camino_biblico_app"
flutter pub get
Write-Host "✅ Dependencias actualizadas"
```

#### 11.3 Verificar integridad del proyecto Django

```powershell
Write-Host "Verificando integridad del proyecto Django..." -ForegroundColor Cyan
Set-Location $projectRoot

# Ejecutar migraciones pendientes
python manage.py migrate --no-input
Write-Host "✅ Migraciones verificadas"

# Colectar archivos estáticos
python manage.py collectstatic --no-input
Write-Host "✅ Archivos estáticos recolectados"
```

---

## 📊 RESUMEN DE CAMBIOS

### Archivos modificados por fase:
| Fase | Archivos | Cambios |
|------|----------|---------|
| 1 | 2 carpetas | Renombrado |
| 2 | 10+ archivos Django | URLs, imports, settings |
| 3 | 8+ archivos Flutter | Paquete, rutas, UI |
| 4 | 4 archivos Android | Package, gradle, manifest |
| 5 | 4 archivos iOS/macOS | Bundle ID, plist |
| 6 | 2 archivos Web | HTML, manifest |
| 7 | 2 archivos Linux | CMake, app.cc |
| 8 | 8+ documentos | Referencias generales |
| 9 | 50+ archivos (búsqueda masiva) | Referencias adicionales |
| **TOTAL** | **94+ referencias** | ✅ Completado |

---

## 🔗 CAMBIOS PENDIENTES MANUALES

Estos cambios NO se pueden hacer automatizados y requieren intervención en servicios externos:

### GitHub
```
1. Renombrar repositorio
   De: github.com/rexrodriguez0123-hue/biblialingo-app
   A: github.com/rexrodriguez0123-hue/camino-biblico-app

2. Actualizar en configuración local:
   cd [proyecto]
   git remote set-url origin https://github.com/rexrodriguez0123-hue/camino-biblico-app.git
```

### Render
```
1. Dashboard Render: https://dashboard.render.com
2. Crear nuevo Web Service (o renombrar existente)
3. Conectar a: github.com/rexrodriguez0123-hue/camino-biblico-app
4. Configurar URL: camino-biblico-app.onrender.com
5. Configurar variables de entorno
```

### Firebase
```
1. Ir a: https://console.firebase.google.com
2. Si es necesario, crear nuevo proyecto o renombrar existente
3. Descargar nuevo google-services.json
4. Actualizar package name en Android
```

### App Stores (Cuando esté listo para release)
```
1. Google Play Store:
   - Cambiar nombre de aplicación
   - Actualizar package name: com.example.caminobiblico
   - Actualizar descripciones

2. Apple App Store:
   - Cambiar nombre de aplicación
   - Actualizar bundle ID: com.example.caminobiblicoApp
```

---

## ✅ CHECKLIST FINAL

### Antes de ejecutar
- [ ] Hacer backup completo del proyecto
- [ ] Verificar conexión de internet
- [ ] Tener acceso a GitHub, Firebase, Render

### Después de ejecutar el script
- [ ] Verificar que todas las carpetas fueron renombradas
- [ ] Confirmar que no hay referencias antiguas de "biblialingo"
- [ ] Ejecutar `flutter clean` y `flutter pub get`
- [ ] Ejecutar `python manage.py check` (Django)
- [ ] Compilar en Android/iOS localmente para verificar
- [ ] Hacer commit con mensaje: "chore: rename app to Camino Bíblico"

### Cambios posteriores manuales
- [ ] Renombrar repositorio en GitHub
- [ ] Reconfigurar Render deployment
- [ ] Actualizar Firebase project
- [ ] Actualizar App Stores

---

## 🚨 PASOS PARA EJECUTAR TODO AUTOMÁTICAMENTE

**Crear un archivo PowerShell con todo el script:**

```powershell
# Archivo: rename_to_camino_biblico.ps1
# Guardar en: c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo\

# [Copiar todas las FASES anteriores aquí]

# Al final agregar:
Write-Host "`n╔═══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ RENOMBRADO A 'CAMINO BÍBLICO' COMPLETADO    ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n📝 Cambios pendientes manuales:" -ForegroundColor Cyan
Write-Host "  1. Renombrar repositorio en GitHub"
Write-Host "  2. Reconfigurar deployment en Render"
Write-Host "  3. Actualizar Firebase project"
Write-Host "`n⏱️  Tiempo total estimado: 15-20 minutos"
```

**Ejecutar el script:**

```powershell
# Abriendo PowerShell como Administrador:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
cd "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"
.\rename_to_camino_biblico.ps1
```

---

## 📞 EN CASO DE ERRORES

### Si falla el renombrado de carpetas:
```powershell
# Verificar que no hay procesos bloqueando los archivos
Get-Process | Where-Object { $_.Handles -gt 0 -and $_.Name -like "*flutter*" } | Stop-Process -Force
Get-Process | Where-Object { $_.Handles -gt 0 -and $_.Name -like "*gradle*" } | Stop-Process -Force
```

### Si falla algún archivo de actualización:
```powershell
# Verificar el archivo específico
Get-Content $filePath -Raw | Select-String "biblialingo"
# Y actualizar manualmente si es necesario
```

### Para restaurar desde backup:
```powershell
# Si algo salió mal, restaurar desde backup
Remove-Item -Path "$projectRoot" -Recurse -Force
Copy-Item -Path "$backupPath" -Destination "$projectRoot" -Recurse
Write-Host "Proyecto restaurado desde backup"
```

---

**Fin del plan**

*Este documento contiene todas las instrucciones para renombrar la aplicación de "BibliaLingo" a "Camino Bíblico" de forma completamente automatizada usando PowerShell.*
