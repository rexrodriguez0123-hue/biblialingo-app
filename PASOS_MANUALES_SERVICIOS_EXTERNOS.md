# 🖱️ GUÍA MANUAL - CAMBIOS EXTERNOS PARA "CAMINO BÍBLICO"

**Documento:** Pasos manuales que debes ejecutar en servicios externos  
**Fecha:** 30 de Abril, 2026  
**Cambio:** BibliaLingo → Camino Bíblico

---

## ⚠️ IMPORTANTE - ORDEN DE EJECUCIÓN

**PRIMERO:** Ejecuta el script PowerShell automatizado (`PLAN_RENOMBRADO_A_CAMINO_BIBLICO.md`)  
**DESPUÉS:** Ejecuta estos pasos manuales

---

## 1️⃣ GITHUB - RENOMBRAR REPOSITORIO

### Paso 1.1: Acceder al repositorio

```
1. Ve a: https://github.com/rexrodriguez0123-hue/biblialingo-app
2. Verifica que estés logueado con tu cuenta
```

### Paso 1.2: Entrar en Configuración del repositorio

```
1. En la página del repositorio, haz clic en la pestaña "Settings" (⚙️)
   (Está en la barra de navegación superior derecha)
```

**Captura visual (lo que verás):**
```
┌─────────────────────────────────────────────┐
│ biblialingo-app                             │
│ ⭐ Watch  Fork  ⋯                           │
│                                             │
│ Code  Issues  Pull requests  Discussions   │
│ Actions  Security  Insights  Settings ⚙️   │
└─────────────────────────────────────────────┘
```

### Paso 1.3: Renombrar el repositorio

```
1. En el lado izquierdo, haz clic en "General"
2. En la sección "Repository name" (cercana al principio), verás el nombre actual
3. Campo actual: "biblialingo-app"
4. Elimina el contenido y escribe: "camino-biblico-app"
```

**Lo que verás:**
```
General settings
├── Repository name
│   ├── Current: biblialingo-app
│   └── [text field]  camino-biblico-app
├── Description
├── Website
└── ...
```

### Paso 1.4: Cambiar la rama por defecto (opcional pero recomendado)

```
1. En la sección "Default branch", verifica que esté en "main"
2. Si no está, cámbialo a "main"
3. Esto asegura que Render detecte los cambios correctamente
```

### Paso 1.5: Guardar cambios

```
1. Desplázate hasta el final de la página
2. Haz clic en el botón "Rename" (color rojo/naranja)
3. Se abrirá un modal de confirmación
4. Haz clic en "I understand, update the repository name"
```

**Confirmación:**
```
┌────────────────────────────────────────┐
│ Rename repository?                     │
│                                        │
│ ⚠️ This may affect my Git operations  │
│ and CI/CD integrations                │
│                                        │
│ [Cancel]  [Rename repository]         │
└────────────────────────────────────────┘
```

### Paso 1.6: Actualizar configuración local de Git

**En tu terminal local:**

```powershell
# Navega al proyecto
cd "c:\Users\bonil\Resilio Sync\familia\Proyecto Esteban Biblialingo\biblialingo"

# Actualiza la URL remota
git remote set-url origin https://github.com/rexrodriguez0123-hue/camino-biblico-app.git

# Verifica que se actualizó correctamente
git remote -v
# Debería mostrar:
# origin  https://github.com/rexrodriguez0123-hue/camino-biblico-app.git (fetch)
# origin  https://github.com/rexrodriguez0123-hue/camino-biblico-app.git (push)

# Hacer commit con el cambio
git add .
git commit -m "chore: rename app to Camino Bíblico"
git push origin main

Write-Host "✅ GitHub actualizado exitosamente"
```

**Resultado esperado:**
```
✓ Repositorio renombrado en GitHub
✓ URL remota actualizada localmente
✓ Cambios pusheados a rama main
```

---

## 2️⃣ RENDER - ACTUALIZAR DEPLOYMENT

### Paso 2.1: Acceder al dashboard de Render

```
1. Ve a: https://dashboard.render.com/
2. Inicia sesión con tu cuenta de Render
```

### Paso 2.2: Encontrar tu servicio actual

```
1. En el dashboard, verás una lista de servicios
2. Busca el servicio llamado "biblialingo-app"
3. Haz clic en él para abrir la configuración
```

**Lo que verás:**
```
Services
├── biblialingo-app  [Click aquí]
├── Otros servicios...
```

### Paso 2.3: Acceder a Configuración del servicio

```
1. Una vez en la página del servicio, busca la pestaña "Settings"
2. Haz clic en ella (generalmente está en la barra de navegación superior)
```

### Paso 2.4: Cambiar nombre del servicio

```
1. En Settings, busca el campo "Name"
2. Cambiar de: "biblialingo-app"
3. Cambiar a: "camino-biblico-app"
4. Haz clic en "Save" (guardar)
```

**Lo que verás:**
```
Service Settings
├── Name: [biblialingo-app] → [camino-biblico-app]
├── Repository: github.com/rexrodriguez0123-hue/camino-biblico-app
├── Branch: main
└── ...
```

### Paso 2.5: Verificar que la rama esté correcta

```
1. En la sección "Repository", verifica que apunte a:
   https://github.com/rexrodriguez0123-hue/camino-biblico-app
2. En "Branch", debe estar: main
3. Si algo cambió, selecciona los valores correctos y guarda
```

### Paso 2.6: Actualizar la URL personalizada (Custom Domain)

```
1. En Settings, busca la sección "Custom Domain" o "Domains"
2. Si tienes un dominio personalizado:
   - De: biblialingo-app.onrender.com
   - A: camino-biblico-app.onrender.com
3. O Render generará una nueva URL automáticamente
```

### Paso 2.7: Verificar variables de entorno

```
1. Busca la sección "Environment" o "Environment Variables"
2. Verifica que todas las variables estén correctas:
   - SECRET_KEY (debe estar igual)
   - ALLOWED_HOSTS debe incluir: camino-biblico-app.onrender.com
   - DATABASE_URL (debe estar igual)
3. Si está ALLOWED_HOSTS, actualízalo:
   - De: biblialingo-app.onrender.com
   - A: camino-biblico-app.onrender.com
4. Haz clic en "Save"
```

**Lo que verás:**
```
Environment Variables
├── SECRET_KEY: ***
├── ALLOWED_HOSTS: camino-biblico-app.onrender.com
├── DATABASE_URL: postgresql://...
└── ...
```

### Paso 2.8: Redeploy del servicio

```
1. En la página del servicio (antes de Settings), busca un botón "Deploy"
2. Haz clic en "Manual Deploy" o "Deploy"
3. Selecciona la rama "main"
4. Haz clic en "Create Deploy"
5. Verás un log de deployment en tiempo real
```

**Lo que verás:**
```
┌──────────────────────────────────┐
│ Manual Deploy                    │
│                                  │
│ Select branch: [main ▼]          │
│                                  │
│ [Create Deploy]                  │
└──────────────────────────────────┘
```

### Paso 2.9: Esperar a que termine el deployment

```
1. En los logs, verás:
   - "Building..."
   - "Installing dependencies..."
   - "Collecting static files..."
   - "Running migrations..."
2. Cuando veas: "Live" (en verde) → ✅ Deploy completado
3. El proceso toma aproximadamente 10-15 minutos
```

### Paso 2.10: Verificar que funciona

```
1. Ve a: https://camino-biblico-app.onrender.com/health/
2. Deberías ver: {"status": "ok"}
3. O prueba el endpoint de login:
   https://camino-biblico-app.onrender.com/api/v1/auth/login
```

**Si ves error 404:**
```
⚠️ Esperéa a que el deploy termine completamente
⚠️ Recarga la página (Ctrl+Shift+R para limpiar caché)
⚠️ Verifica que el branch sea "main"
```

---

## 3️⃣ FIREBASE - ACTUALIZAR PROJECT

### Paso 3.1: Acceder a Firebase Console

```
1. Ve a: https://console.firebase.google.com/
2. Inicia sesión con tu cuenta de Google
```

### Paso 3.2: Verificar el proyecto actual

```
1. En la parte superior izquierda, verás el nombre del proyecto actual
2. Proyecto actual: "biblialingo" (o similar)
3. Verifica que sea el correcto haciendo clic en él
```

**Lo que verás:**
```
┌─────────────────────────────────┐
│ 🔥 biblialingo                  │ ← Click aquí si quieres cambiar
│                                 │
│ Overview  Settings  ...         │
└─────────────────────────────────┘
```

### Paso 3.3: Acceder a Configuración del proyecto

```
1. En el menú izquierdo inferior, haz clic en el icono ⚙️ (engranaje)
2. Selecciona "Project settings" (Configuración del proyecto)
```

### Paso 3.4: Cambiar el nombre del proyecto (Opcional)

```
OPCIÓN A: Si quieres cambiar el ID del proyecto
- Nota: Esto es más complicado y afectará varias cosas
- NO RECOMENDADO para proyectos en producción

OPCIÓN B: Mantener el ID del proyecto interno
- Cambiar solo el "Nombre del proyecto" mostrado
- Esto es RECOMENDADO

➡️ Recomendación: Usa OPCIÓN B
```

### Paso 3.5: Cambiar el nombre mostrado (OPCIÓN B RECOMENDADA)

```
1. En "Project settings", busca el campo "Project name"
2. Cambiar de: "biblialingo"
3. Cambiar a: "Camino Bíblico"
4. Haz clic en "Save"
```

**Lo que verás:**
```
Project Settings
├── Project name: [biblialingo] → [Camino Bíblico]
├── Project ID: biblialingo (NO CAMBIAR)
├── Project number: 1067304772395
└── ...
```

### Paso 3.6: Actualizar credenciales de Android

```
1. En la sección de "Your apps" o "Apps", busca tu app Android
2. Nombre: "biblialingo_app" o similar
3. Haz clic en el menú de tres puntos (⋮) → "Rename app"
4. Cambiar de: "biblialingo_app"
5. Cambiar a: "camino_biblico_app"
```

### Paso 3.7: Descargar nuevo google-services.json (si cambió package name)

```
Si solo cambió el nombre visible (OPCIÓN B):
  ✓ No necesitas descargar nuevo google-services.json
  ✓ El archivo actual sigue siendo válido

Si cambió el package name Android:
  1. En "Project settings" → "Your apps"
  2. Haz clic en tu app Android
  3. En el panel de la derecha, haz clic en "Download google-services.json"
  4. Reemplaza el archivo en: 
     camino_biblico_app\android\app\google-services.json
  5. Sube los cambios a GitHub
```

### Paso 3.8: Actualizar configuración de Storage

```
1. En el menú izquierdo, selecciona "Storage"
2. Verifica que el bucket sea: "biblialingo.firebasestorage.app"
3. Si todo está correcto, NO necesitas cambiar nada más
4. El storage seguirá funcionando con el mismo nombre
```

---

## 4️⃣ ACTUALIZAR EN DISPOSITIVOS Y COMPILACIONES LOCALES

### Paso 4.1: Limpiar datos locales

```powershell
# En la terminal, en la carpeta del proyecto:

# Limpiar caché de Gradle (Android)
cd camino_biblico_app
./gradlew clean

# Limpiar caché de Flutter
flutter clean
flutter pub get

# Limpiar caché de iOS (macOS)
cd ios
rm -rf Pods
rm Podfile.lock
cd ..
flutter pub get
```

### Paso 4.2: Reinstalar en emulador/dispositivo

```powershell
# Para Android
flutter run -d android

# Para iOS (solo en macOS)
flutter run -d ios

# Para Web
flutter run -d chrome

# Para Linux (solo en Linux)
flutter run -d linux
```

---

## 5️⃣ APP STORES - CAMBIOS CUANDO ESTÉ LISTO PARA RELEASE

### ⚠️ NOTA IMPORTANTE
```
Estos pasos solo se ejecutan CUANDO hayas terminado de probar
y estés listo para publicar en App Stores (Google Play, Apple App Store)
```

### Paso 5.1: GOOGLE PLAY STORE

#### 5.1.1: Acceder a Google Play Console

```
1. Ve a: https://play.google.com/console/
2. Inicia sesión con tu cuenta de desarrollador de Google
```

#### 5.1.2: Actualizar nombre de aplicación

```
1. En la izquierda, selecciona tu aplicación "biblialingo_app"
2. En el menú, busca "App details" (Información de la aplicación)
3. Busca el campo "App name" (Nombre de la aplicación)
4. Cambiar de: "BibliaLingo"
5. Cambiar a: "Camino Bíblico"
6. Haz clic en "Save"
```

#### 5.1.3: Actualizar Short description

```
1. En "App details", busca "Short description"
2. Cambiar la descripción a algo como:
   "Aprende la Biblia como nunca antes con Camino Bíblico"
3. Haz clic en "Save"
```

#### 5.1.4: Actualizar Full description

```
1. Busca "Full description"
2. Actualiza con: "Camino Bíblico - Estudio Bíblico Gamificado"
3. Haz clic en "Save"
```

#### 5.1.5: Cambiar Package name (⚠️ CRÍTICO)

```
⚠️ IMPORTANTE: El Package name NO se puede cambiar después de publicar!

Si aún NO has publicado:
  1. En "App details" → "App name and type"
  2. Busca "Package name"
  3. Cambiar de: com.example.biblialingo_app
  4. Cambiar a: com.example.caminobiblico
  
Si YA has publicado:
  ⚠️ NO PUEDES cambiar el package name
  ⚠️ Deberías crear un nuevo listado
```

#### 5.1.6: Actualizar categoría y contenido

```
1. Ve a "App details" → "Category"
2. Mantén la categoría como: Education / Lifestyle
3. Ve a "Content rating"
4. Completa el cuestionario con información sobre la app
5. Haz clic en "Save"
```

#### 5.1.7: Publicar nueva versión

```
1. En "Release" o "Releases" (Lanzamientos)
2. Haz clic en "Create new release"
3. Sube el nuevo APK/AAB compilado
4. Actualiza el changelog:
   "Cambio de nombre a Camino Bíblico"
5. Revisa y publica
```

### Paso 5.2: APPLE APP STORE

#### 5.2.1: Acceder a App Store Connect

```
1. Ve a: https://appstoreconnect.apple.com/
2. Inicia sesión con tu cuenta de Apple Developer
```

#### 5.2.2: Actualizar nombre de aplicación

```
1. En "My Apps", selecciona tu aplicación
2. En "App Information"
3. Busca "App Name"
4. Cambiar de: "BibliaLingo"
5. Cambiar a: "Camino Bíblico"
6. Haz clic en "Save"
```

#### 5.2.3: Actualizar subtítulo y descripción

```
1. En "App Information"
2. "Subtitle": Cambiar a algo breve descriptivo
3. "Description": Actualizar con "Camino Bíblico - Estudio Bíblico Gamificado"
4. Haz clic en "Save"
```

#### 5.2.4: Actualizar keywords

```
1. En "App Information" → "Keywords"
2. Actualizar con palabras clave relevantes:
   "biblia, estudio, educación, gamificación"
3. Haz clic en "Save"
```

#### 5.2.5: Cambiar Bundle ID (⚠️ CRÍTICO)

```
⚠️ IMPORTANTE: El Bundle ID NO se puede cambiar después de publicar!

Si aún NO has publicado:
  1. En "App Information"
  2. Busca "Bundle ID"
  3. Cambiar de: com.example.biblialingoApp
  4. Cambiar a: com.example.caminobiblicoApp
  5. Haz clic en "Save"
  
Si YA has publicado:
  ⚠️ NO PUEDES cambiar el Bundle ID
  ⚠️ Deberías crear una nueva aplicación
```

#### 5.2.6: Crear una nueva versión (Build)

```
1. Ve a "Builds"
2. Haz clic en "+" para crear nuevo build
3. Sube el nuevo .ipa compilado
4. Completa información del build
5. Crea la versión de release
```

#### 5.2.7: Crear nueva version de App

```
1. Ve a "Releases"
2. Haz clic en "+" para crear nuevo release
3. Selecciona el build que acabas de subir
4. En "What's New in This Version", escribe:
   "Cambio de nombre a Camino Bíblico"
5. Revisa y envía para revisión
```

---

## 6️⃣ VERIFICACIÓN FINAL

### Checklist de verificación

```powershell
# Verificar que todo funciona correctamente

Write-Host "=== VERIFICACIÓN FINAL ===" -ForegroundColor Cyan

# 1. Verificar GitHub
Write-Host "`n1. GitHub:" -ForegroundColor Yellow
Write-Host "   ✓ Repositorio renombrado a 'camino-biblico-app'"
Write-Host "   ✓ URL remota actualizada localmente"
Write-Host "   ✓ Cambios pusheados a 'main'"

# 2. Verificar Render
Write-Host "`n2. Render:" -ForegroundColor Yellow
Write-Host "   ✓ Servicio renombrado a 'camino-biblico-app'"
Write-Host "   ✓ Apunta a repositorio correcto"
Write-Host "   ✓ Deploy completado exitosamente"
Write-Host "   ✓ URL: https://camino-biblico-app.onrender.com/"

# 3. Verificar Firebase
Write-Host "`n3. Firebase:" -ForegroundColor Yellow
Write-Host "   ✓ Nombre del proyecto actualizado"
Write-Host "   ✓ Apps renombradas (si corresponde)"

# 4. Verificar compilación local
Write-Host "`n4. Compilación local:" -ForegroundColor Yellow
Write-Host "   ✓ Flutter build completado sin errores"
Write-Host ✓ Android build sin errores"
Write-Host "   ✓ iOS build sin errores"

Write-Host "`n✅ Todas las verificaciones completadas" -ForegroundColor Green
```

---

## 📋 RESUMEN DE TAREAS MANUALES

| # | Tarea | Dificultad | Tiempo | ✓ |
|----|-------|-----------|--------|---|
| 1 | Renombrar repositorio GitHub | 🟢 Fácil | 2 min | ☐ |
| 2 | Actualizar Git remoto local | 🟢 Fácil | 1 min | ☐ |
| 3 | Actualizar Render settings | 🟡 Medio | 5 min | ☐ |
| 4 | Redeploy en Render | 🟡 Medio | 15 min | ☐ |
| 5 | Actualizar Firebase proyecto | 🟢 Fácil | 3 min | ☐ |
| 6 | Descargar google-services.json (si cambió) | 🟢 Fácil | 2 min | ☐ |
| 7 | Compilar localmente | 🟡 Medio | 10 min | ☐ |
| 8 | Google Play Store (cuando liberes) | 🟡 Medio | 15 min | ☐ |
| 9 | Apple App Store (cuando liberes) | 🟡 Medio | 15 min | ☐ |
| **TOTAL** | | | **68 min** | |

---

## 🆘 TROUBLESHOOTING - ERRORES COMUNES

### Error: "Repository not found" en Render después de renombrar GitHub

```
Solución:
1. Ve a Render dashboard
2. En tu servicio, ve a Settings
3. En la sección "Repository", haz clic en "Disconnect"
4. Haz clic en "Connect a different repository"
5. Busca y selecciona "camino-biblico-app"
6. Haz clic en "Save" y vuelve a hacer deploy
```

### Error: "CORS error" después de cambiar URL en Render

```
Solución:
1. El error de CORS significa que el frontend y backend están en dominios diferentes
2. Verifica que en Django prod.py esté:
   ALLOWED_HOSTS = ['camino-biblico-app.onrender.com']
3. Verifica que en Flutter api_config.dart esté:
   baseUrl = 'https://camino-biblico-app.onrender.com/api/v1'
4. Redeploy en Render
5. Limpia caché en el navegador (Ctrl+Shift+R)
```

### Error: "google-services.json error" en Android

```
Solución:
1. Descargar nuevo google-services.json desde Firebase
2. Reemplazar en: camino_biblico_app/android/app/
3. En AndroidManifest.xml, verifica que el package sea: com.example.caminobiblico
4. Ejecutar: ./gradlew clean build
```

### Error: "Pod dependency error" en iOS

```
Solución:
1. En terminal, navega a: camino_biblico_app/ios
2. Ejecutar: rm Podfile.lock
3. Ejecutar: pod install --repo-update
4. Regresar a: camino_biblico_app
5. Ejecutar: flutter clean && flutter pub get
```

### Error: "App name no se actualiza en dispositivo"

```
Solución:
1. Desinstalar la app completamente
2. Ejecutar: flutter clean
3. Ejecutar: flutter pub get
4. Compilar nuevamente
5. Instalar la app nueva
```

---

## ✅ CHECKLIST ANTES DE LANZAR

### Antes de release en App Stores

```
VERIFICACIÓN FUNCIONAL:
- [ ] App inicia correctamente
- [ ] Login funciona
- [ ] Conexión con API backend funciona
- [ ] Firebase authentication funciona
- [ ] Todas las pantallas tienen nombre actualizado
- [ ] No hay referencias a "BibliaLingo" en la UI

VERIFICACIÓN TÉCNICA:
- [ ] No hay errores en los logs de Flutter
- [ ] No hay errores CORS
- [ ] Base de datos está sincronizada
- [ ] Las imágenes y assets cargan correctamente

VERIFICACIÓN EN APP STORES:
- [ ] Nombre actualizado en Google Play
- [ ] Nombre actualizado en App Store
- [ ] Descripciones actualizadas
- [ ] Screenshots/imágenes están correctas
- [ ] Package name correcto (no se puede cambiar después)
- [ ] Bundle ID correcto (no se puede cambiar después)

VERIFICACIÓN FINAL:
- [ ] Commit final hecho: "chore: rename app to Camino Bíblico"
- [ ] Todos los cambios en rama 'main'
- [ ] Backup del proyecto antiguo (biblialingo)
- [ ] Documentación actualizada
```

---

## 📞 SOPORTE Y AYUDA

Si tienes problemas:

1. **Render Support:** https://support.render.com/
2. **Firebase Support:** https://firebase.google.com/support
3. **GitHub Support:** https://support.github.com/
4. **Flutter Support:** https://flutter.dev/docs

---

**Fin de la guía manual**

*Este documento contiene todos los pasos que debes hacer manualmente en servicios externos para completar el cambio de nombre a "Camino Bíblico".*
