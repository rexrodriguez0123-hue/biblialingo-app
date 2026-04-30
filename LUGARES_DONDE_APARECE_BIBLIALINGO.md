# 📍 LUGARES DONDE APARECE "BIBLIALINGO"

**Documento generado:** 30 de Abril, 2026  
**Propósito:** Mapeo completo de referencias a "biblialingo" para cambio de nombre de la aplicación

---

## 📁 ESTRUCTURA DE CARPETAS Y DIRECTORIOS

### Carpetas principales del proyecto:
| Ubicación | Tipo | Descripción |
|-----------|------|-------------|
| `biblialingo/` | Carpeta Django | Configuración central del backend Django |
| `biblialingo_app/` | Carpeta Flutter | Frontend y aplicación móvil Flutter |
| `db.sqlite3` | Base de datos | Base de datos SQLite del proyecto |

---

## 🔐 CONFIGURACIÓN DJANGO (Backend)

### Archivos de configuración de entorno:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `biblialingo/settings/base.py` | 3 | `ROOT_URLCONF = 'biblialingo.urls'`<br>`WSGI_APPLICATION = 'biblialingo.wsgi.application'` |
| `biblialingo/settings/dev.py` | 1 | Encabezado: "Django development settings for BibliaLingo project" |
| `biblialingo/settings/prod.py` | 3 | Encabezado: "Django production settings for BibliaLingo project"<br>`ALLOWED_HOSTS` contiene `'biblialingo-app.onrender.com'`<br>CORS origin: `'https://biblialingo-app.onrender.com'` |
| `biblialingo/urls.py` | 2 | Encabezado: "URL configuration for BibliaLingo project"<br>Message: `'BibliaLingo API v1'` |
| `biblialingo/wsgi.py` | 2 | Encabezado: "WSGI config for BibliaLingo project"<br>`os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'biblialingo.settings.prod')` |
| `biblialingo/asgi.py` | 2 | Encabezado: "ASGI config for BibliaLingo project"<br>`os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'biblialingo.settings.prod')` |
| `manage.py` | 1 | `os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'biblialingo.settings.dev')` |

### Archivos de servicios y modelos:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `apps/users/models.py` | 1 | Docstring: "Extended user profile for BibliaLingo" |
| `apps/bible_content/services/nlp_engine.py` | 1 | Docstring: "NLP Engine for BibliaLingo" |
| `apps/curriculum/services/srs_engine.py` | 1 | Docstring: "SM-2 Spaced Repetition Algorithm for BibliaLingo" |

### Scripts:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `fix_genesis_1.py` | 1 | `os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'biblialingo.settings.prod')` |
| `build.sh` | 1 | Contraseña admin: `'rexbiblialingo.'` |

---

## 📱 FLUTTER APP (biblialingo_app/)

### Configuración general:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `pubspec.yaml` | 2 | `name: biblialingo_app`<br>`description: A new Flutter project for BibliaLingo` |
| `README.md` | 1 | Título: `# biblialingo_app` |
| `lib/main.dart` | 1 | `title: 'BibliaLingo'` |

### Archivos de configuración:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `lib/config/api_config.dart` | 4 | Comentarios en código<br>`/// Configuración de API para BibliaLingo`<br>URLs comentadas: `https://biblialingo-app.onrender.com/api/v1`<br>`https://biblialingo-staging.onrender.com/api/v1` |

### Pantallas (Screens):
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `lib/screens/welcome_screen.dart` | 1 | Texto mostrado: `'Bienvenido a\nBibliaLingo'` |
| `lib/screens/settings_screen.dart` | 3 | `'Acerca de BibliaLingo'`<br>`'BibliaLingo respeta tu privacidad...'`<br>Email mostrado: `biblialingo@example.com` (2 veces) |

### Tests:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `test/widget_test.dart` | 1 | `import 'package:biblialingo_app/main.dart'` |

---

## 🤖 CONFIGURACIÓN ANDROID

### Archivos de configuración:
| Archivo | Ruta Completa | Referencias | Detalles |
|---------|---------------|-------------|----------|
| `build.gradle.kts` | `android/app/` | 2 | `namespace = "com.example.biblialingo_app"`<br>`applicationId = "com.example.biblialingo_app"` |
| `AndroidManifest.xml` | `android/app/src/main/` | 1 | `android:label="biblialingo_app"` |
| `MainActivity.kt` | `android/app/src/main/kotlin/com/example/biblialingo_app/` | 2 | `package com.example.biblialingo_app` (en ruta de carpeta)<br>Contenido del archivo |
| `google-services.json` | `android/app/` | 3 | `"project_id": "biblialingo"`<br>`"storage_bucket": "biblialingo.firebasestorage.app"`<br>`"package_name": "com.example.biblialingo_app"` |

### Estructura de paquetes Android:
```
com.example.biblialingo_app
└── MainActivity.kt
```

---

## 🍎 CONFIGURACIÓN iOS

### Archivos de configuración:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `ios/Runner/Info.plist` | 2 | Nombre mostrado: `<string>Biblialingo App</string>`<br>Bundle: `<string>biblialingo_app</string>` |
| `ios/Runner.xcodeproj/project.pbxproj` | 8 | Bundle Identifiers: `com.example.biblialingoApp` (múltiples referencias)<br>Rutas de app: `biblialingo_app.app` |
| `macos/Runner/Configs/AppInfo.xcconfig` | 2 | `PRODUCT_NAME = biblialingo_app`<br>`PRODUCT_BUNDLE_IDENTIFIER = com.example.biblialingoApp` |
| `macos/Runner.xcodeproj/project.pbxproj` | 6 | Referencias similares a iOS |

---

## 🌐 WEB (Flutter Web)

### Archivos web:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `web/index.html` | 2 | Meta tag: `<meta name="apple-mobile-web-app-title" content="biblialingo_app">`<br>Title: `<title>biblialingo_app</title>` |
| `web/manifest.json` | 2 | `"name": "biblialingo_app"`<br>`"short_name": "biblialingo_app"` |

---

## 🐧 CONFIGURACIÓN LINUX

### Archivos de configuración:
| Archivo | Referencias | Detalles |
|---------|-------------|----------|
| `linux/CMakeLists.txt` | 2 | `set(BINARY_NAME "biblialingo_app")`<br>`set(APPLICATION_ID "com.example.biblialingo_app")` |
| `linux/runner/my_application.cc` | 2 | `gtk_header_bar_set_title(header_bar, "biblialingo_app")`<br>`gtk_window_set_title(window, "biblialingo_app")` |

---

## 🔗 SERVICIOS EXTERNOS Y URLs

### Firebase:
| Servicio | Referencia | Detalles |
|----------|-----------|----------|
| Firebase Project ID | `biblialingo` | En `google-services.json` |
| Firebase Storage | `biblialingo.firebasestorage.app` | En `google-services.json` |

### Render (Hosting Backend):
| Entorno | URL | Ubicación |
|---------|-----|----------|
| Producción | `https://biblialingo-app.onrender.com` | Múltiples archivos de configuración |
| Staging | `https://biblialingo-staging.onrender.com` | Comentario en `api_config.dart` |
| Health Check | `https://biblialingo-app.onrender.com/health/` | Documentación |
| API v1 | `https://biblialingo-app.onrender.com/api/v1` | `api_config.dart` y comentarios |

### GitHub:
| Repositorio | URL | Notas |
|-------------|-----|-------|
| Backend | `github.com/rexrodriguez0123-hue/biblialingo-app` | Conectado a Render (deploy automático) |
| Rama monitoreada | `main` | Deploy automático en cambios |

---

## 📄 ARCHIVOS DE DOCUMENTACIÓN

### Documentos del proyecto:
| Archivo | Referencias | Contexto |
|---------|-------------|----------|
| `ESTADO_ACTUAL.md` | 16+ | Título, descripciones varias, URLs, rutas |
| `estado actual .md` | 16+ | Título, descripciones, estructura del proyecto |
| `QA_TESTING_GUIDE.md` | 3 | Título: "QA Testing Guide — BibliaLingo MVP"<br>Email de test: `qa-test-{timestamp}@biblialingo.test` |
| `análisis ui/ux biblialingo .md` | 3 | Título, descripción del proyecto, equipo |
| `biblialingo_app/ESTADO_ACTUAL.md` | 1 | Título: "Estado Actual - BibliaLingo App" |
| `PLAN_AUTO_SCROLL_BOTTOM.md` | 1 | Referencia a rutas |
| `PLAN_ELIMINAR_ESPACIO_LECCION.md` | 3 | Referencia a rutas de archivos Flutter |
| `PLAN_BACK_BUTTON_FIX.md` | - | Puede contener referencias (no verificado) |

---

## 📊 RESUMEN DE REFERENCIAS POR CATEGORÍA

### Conteo total de referencias:
| Categoría | Cantidad | Ejemplos |
|-----------|----------|----------|
| **Backend Django** | 15 | Settings, URLs, WSGI, servicios |
| **Flutter App** | 10 | pubspec.yaml, main.dart, screens |
| **Android** | 5 | Namespace, applicationId, manifest |
| **iOS** | 8 | Bundle identifiers, app names |
| **Web** | 2 | HTML, manifest |
| **Linux/macOS** | 8 | Binary names, app titles |
| **URLs de producción** | 6 | Render, GitHub, Firebase |
| **Documentación** | 40+ | Archivos MD, comentarios |
| **TOTAL ESTIMADO** | **94+** | Múltiples instancias |

---

## 🎯 CATEGORIZACIÓN POR TIPO DE CAMBIO

### 🔴 CRÍTICO - Cambiar inmediatamente:
- [ ] `biblialingo/` - Nombre de carpeta del proyecto Django
- [ ] `biblialingo_app/` - Nombre de carpeta de la app Flutter
- [ ] `biblialingo_app` en `pubspec.yaml` - Nombre del paquete Flutter
- [ ] `com.example.biblialingo_app` - Package name Android
- [ ] `com.example.biblialingoApp` - Bundle ID iOS
- [ ] Rutas en módulos Django (`biblialingo.settings`, `biblialingo.urls`, etc.)

### 🟡 ALTO - Cambiar en configuración y referencias:
- [ ] URLs en `api_config.dart` y settings Django
- [ ] GitHub repository name: `biblialingo-app`
- [ ] Render service name: `biblialingo-app`
- [ ] Firebase Project ID: `biblialingo`
- [ ] APP IDs y Labels en todas las plataformas

### 🟢 BAJO - Cambiar en contenido:
- [ ] Textos en pantallas (welcome, settings)
- [ ] Títulos en archivos de documentación
- [ ] Comentarios en código
- [ ] Descripciones en archivos de configuración

---

## 💡 NOTAS IMPORTANTES PARA EL CAMBIO

1. **Dependencias de carpetas:** Si cambias `biblialingo/` a otro nombre, debes actualizar:
   - Rutas de imports en todos los archivos Python
   - Variables de entorno `DJANGO_SETTINGS_MODULE`
   - Configuración de Render/GitHub

2. **Dependencias de package name Android:** Cambiar `com.example.biblialingo_app` afecta:
   - `google-services.json`
   - `build.gradle.kts`
   - `AndroidManifest.xml`
   - Estructura de carpetas en `android/app/src/main/kotlin/`

3. **Dependencias de Bundle ID iOS:** Cambiar `com.example.biblialingoApp` afecta:
   - `project.pbxproj` (múltiples referencias)
   - `AppInfo.xcconfig`
   - `Info.plist`

4. **URLs de producción:** Cambiar `biblialingo-app.onrender.com` requiere:
   - Crear nuevo servicio en Render
   - Actualizar configuración de CORS en Django
   - Actualizar `api_config.dart` en Flutter

5. **GitHub Repository:** Cambiar `biblialingo-app` requiere:
   - Renombrar repositorio en GitHub
   - Reconfigurar deployment en Render
   - Actualizar referencias locales en `.git/config`

---

## 📋 CHECKLIST DE CAMBIOS NECESARIOS

### Fase 1: Preparación
- [ ] Hacer backup del proyecto actual
- [ ] Decidir nuevo nombre y mantener consistencia
- [ ] Verificar disponibilidad en Firebase, Render, GitHub

### Fase 2: Renombrado de Carpetas
- [ ] Renombrar `biblialingo/` → `[NUEVO_NOMBRE]/`
- [ ] Renombrar `biblialingo_app/` → `[NUEVO_NOMBRE]_app/`

### Fase 3: Backend (Django)
- [ ] Actualizar referencias en `DJANGO_SETTINGS_MODULE`
- [ ] Renombrar configuración de aplicaciones
- [ ] Actualizar bases de datos

### Fase 4: Frontend (Flutter)
- [ ] Actualizar `pubspec.yaml`
- [ ] Actualizar `api_config.dart`
- [ ] Actualizar imports en archivos

### Fase 5: Plataformas
- [ ] Android: Cambiar namespace y applicationId
- [ ] iOS: Cambiar bundle identifiers
- [ ] Web: Actualizar manifest.json e index.html
- [ ] Linux/macOS: Actualizar CMakeLists.txt y configs

### Fase 6: Servicios Externos
- [ ] Firebase: Actualizar project ID (si es necesario)
- [ ] GitHub: Renombrar repositorio
- [ ] Render: Actualizar nombre de servicio

### Fase 7: Documentación
- [ ] Actualizar archivos .md
- [ ] Actualizar comentarios en código
- [ ] Actualizar referencias en docstrings

---

**Fin del documento**

*Este archivo fue generado automáticamente para asegurar que no se pierda ninguna referencia al cambiar el nombre de la aplicación.*
