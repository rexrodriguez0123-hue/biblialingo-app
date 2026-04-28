# 🧪 QA Testing Guide — BibliaLingo MVP

**Status:** Deployment completado, listo para QA  
**Fecha:** 28 de Abril de 2026

---

## ✅ Cambios Realizados en Este Deployment

```
✓ Limpieza de textos: 1,192/1,438 versículos (82.9%)
✓ GameOverPopup integrado en PracticeScreen
✓ Settings Screen con preferencias teológicas
✓ Preferencias Teológicas REMOVIDAS de Profile (solo en Settings)
✓ MVP ajustado: Génesis solamente (no agregar más libros)
✓ NLP validation activa contra ejercicios corruptos
```

---

## 📱 Escenarios de Testing

### 1. **Crear Nueva Cuenta**

**Pasos:**
1. Abrir BibliaLingo en emulador/dispositivo
2. Clickear "Registrarse"
3. Email: `qa-test-{timestamp}@biblialingo.test`
4. Contraseña: `TestPass123!`
5. Clickear "Crear Cuenta"

**Verificar:**
- [ ] Cuenta se crea exitosamente
- [ ] Redirecciona a Dashboard
- [ ] UserState se inicializa con valores por defecto

**Valores esperados iniciales:**
- Hearts: 5
- Gems: 0
- Streak: 0 días
- Total XP: 0
- Level: 1

---

### 2. **Profile Screen**

**Navegar a:** Tab "Perfil" en BottomNavigationBar

**Verificar que APAREZCA:**
- [ ] Avatar (ícono de persona)
- [ ] Username/Email
- [ ] Barra de progreso de Nivel (Nivel 1 / 0 XP)
- [ ] Tarjetas de Stats (❤️ Corazones, 💎 Gemas, 🔥 Racha, ⭐ Total XP)
- [ ] Botón "Ajustes" en AppBar (engranaje)
- [ ] Botón "Cerrar Sesión" al final

**Verificar que NO APAREZCA:**
- [ ] "Preferencias Teológicas" (debe estar solo en Settings)
- [ ] Ningún switch o toggle
- [ ] Ningún formulario

---

### 3. **Settings Screen**

**Navegar a:** Clickear ícono "Ajustes" en Profile

**Verificar que APAREZCA:**
- [ ] Sección "Preferencias Teológicas" con switch "Excluir festividades"
- [ ] Sección "Información de la App" (versión 1.0.0)
- [ ] Sección "Privacidad" con link a política
- [ ] Sección "Soporte" con email de contacto
- [ ] Sección "Cuenta" con botón "Cerrar Sesión"

**Interactuar con Switch:**
1. Clickear switch "Excluir festividades"
2. Cambiar a ON
3. **Esperar:** Loading spinner momentáneamente
4. **Verificar:** 
   - [ ] Switch actualiza en UI
   - [ ] No hay errores en logs
   - [ ] Preferencia se persiste (al volver al Settings, debe estar ON)

---

### 4. **Dashboard & Lessons**

**Navegar a:** Tab "Aprender"

**Verificar:**
- [ ] Se muestran lecciones de Génesis
- [ ] Cada lección tiene título y descripción
- [ ] Clickear en una lección abre PracticeScreen

---

### 5. **Practice Screen — Textos Limpios**

**Iniciar una lección:** Génesis 1-5 (primeras 5 lecciones)

**Verificar QUE NO APAREZCA corrupción:**
- [ ] NO hay `morirás; rás` (palabras duplicadas OCR)
- [ ] NO hay `expan- sión` (guiones huérfanos)
- [ ] NO hay `ĳ` (ligaduras raras)
- [ ] NO hay espacios dobles: `palabra  palabra`
- [ ] Textos se ven coherentes y legibles

**Ejemplos de textos esperados limpios:**
```
✓ "En el principio creó Dios los cielos y la tierra."
✓ "Y dijo Dios: Sea la luz."
✓ "Y vio Dios que la luz era buena."
```

---

### 6. **Exercise Generation — JIT**

**Ejecutar 10+ ejercicios en una lección**

**Verificar:**
- [ ] Cada ejercicio es diferente (tipos variados: cloze, selection, true_false, etc.)
- [ ] Las respuestas correctas tienen sentido
- [ ] No hay errores JSON o parsing
- [ ] Las opciones de múltiple choice son coherentes

**Ejemplo de ejercicio esperado:**
```
Tipo: Cloze
Pregunta: "En el principio creó Dios los _____ y la tierra."
Respuesta correcta: "cielos"
Pista: "C"
```

---

### 7. **GameOverPopup — Animaciones & Stats**

**Completar 5 ejercicios** (correctos e incorrectos)

**Verificar que aparezca el popup al terminar la lección:**
- [ ] Title: "¡Lección Completada!"
- [ ] Stats mostrados:
  - [ ] Respuestas correctas: X/5
  - [ ] Porcentaje de acierto: XX%
  - [ ] Gemas ganadas: (correctos × 2)
  - [ ] Progress bar de 0-100%
- [ ] Animación de entrada: Scale + fade-in
- [ ] Botón "Continuar" funciona

**Color del popup según performance:**
- 80%+: Verde 🟢
- 60-79%: Azul 🔵
- <60%: Naranja 🟠

---

### 8. **Hearts System**

**Completar 6 ejercicios CON ERRORES**

**Verificar:**
- [ ] Cada error resta 1 corazón
- [ ] Hearts disminuye en UI en tiempo real
- [ ] Cuando llega a 0, muestra mensaje/restricción
- [ ] ErrorPopup muestra respuesta correcta al fallar

---

### 9. **Streak Tracking**

**Completar 2+ lecciones en días diferentes**

**Verificar:**
- [ ] Streak aumenta en 1 cada día que practiques
- [ ] Se muestra en Profile Screen (🔥 Racha: X días)
- [ ] Si pasa 24h sin practicar, se resetea a 0

---

### 10. **XP & Level System**

**Completar 5+ lecciones con buen desempeño**

**Verificar:**
- [ ] Total XP aumenta (~10-20 XP por lección)
- [ ] Se muestra en Profile Screen (⭐ Total XP: XXX)
- [ ] Barra de progreso de Nivel se mueve
- [ ] Cuando llegas a 100 XP, subes de Nivel (Level 1 → Level 2)

---

### 11. **Logout & Re-login**

**Desde Settings Screen:**
1. Clickear "Cerrar Sesión"
2. Confirmar en diálogo
3. **Verificar:**
   - [ ] Redirecciona a Login screen
   - [ ] Sesión se cierra correctamente
   - [ ] Token se borra

**Re-login:**
1. Usar mismas credenciales (email/password)
2. **Verificar:**
   - [ ] Sesión se restaura
   - [ ] Stats se cargan (hearts, gems, streak, xp, preferences)
   - [ ] Preferencias se persisten (ej. "Excluir festividades")

---

### 12. **Error Handling**

**Probar escenarios de error:**

**Red desconectada:**
1. Modo Airplane en dispositivo
2. Intentar completar ejercicio
3. **Verificar:** Error graceful, no crash

**DB corrupta / Server down:**
1. Apagar Render backend temporalmente
2. Intentar cargar lección
3. **Verificar:** Mensaje de error claro

---

## 📊 Checklist Final

### Antes de Launch
- [ ] Todos los 12 escenarios pasan
- [ ] No hay errores en Firebase Logs (si aplicable)
- [ ] No hay crashes en emulador/device
- [ ] Performance es aceptable (<2s load time)
- [ ] Textos están limpios (sin corrupción visible)
- [ ] GameOverPopup se muestra correctamente
- [ ] Settings solo muestra preferencias (sin duplicate en Profile)

### Post-Launch (Semana 1)
- [ ] Beta testers reportan experiencia smooth
- [ ] No hay reportes de crashes
- [ ] Usuarios pueden crear cuenta y practicar
- [ ] Datos se guardan correctamente en BD

---

## 🐛 Issues Conocidos (Bugs)

Si encuentras algo, documéntalo aquí:

```
[Fecha] [Severidad] [Descripción]
Ejemplo:
[2026-04-28] [CRÍTICA] GameOverPopup no aparece al terminar lección
[2026-04-28] [MEDIA] Textos tienen espacios dobles en Génesis 5:23
```

---

## 📱 Devices Para Testing

**Recomendado probar en:**
- [ ] Android Emulator (API 30+)
- [ ] iOS Simulator (si tienes Mac)
- [ ] Dispositivo real Android (mínimo Android 8)
- [ ] Dispositivo real iOS (mínimo iOS 12)

---

## 🔗 Referencias

**Documentación relacionada:**
- [ESTADO_ACTUAL.md](ESTADO_ACTUAL.md) — Tareas pendientes futuras
- [EJECUCION_COMPLETADA.md](EJECUCION_COMPLETADA.md) — Resultados de limpieza
- [INSTRUCCIONES_EJECUCION.md](INSTRUCCIONES_EJECUCION.md) — Management command

---

**Inicio de QA:** [Completar cuando comience testing]  
**Fin de QA:** [Completar cuando termine testing]  
**Status:** 🟡 EN PROGRESO
