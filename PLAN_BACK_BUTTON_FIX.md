# 🎯 Plan de Implementación: Manejo de Back Button en Popups

## 📋 Resumen del Problema

**Estado Actual:**
- PopScope bloquea el back button cuando hay popup abierto
- El popup desaparece pero la app queda congelada sin responder a nada
- Usuario no puede ni navegar ni continuar

**Comportamiento Deseado:**
- Back button CIERRA el popup Y ejecuta una acción inteligente según el tipo de popup

---

## 🔄 Matriz de Comportamiento Deseado

| Tipo de Popup | Usuario Presiona Back | Acción Esperada | Pantalla Resultante |
|---------------|----------------------|-----------------|---------------------|
| ✅ **SuccessPopup** (respuesta correcta) | Botón Atrás | Cerrar popup + Ir al siguiente ejercicio | Pregunta #N+1 |
| ❌ **ErrorPopup** (respuesta incorrecta, hearts > 0) | Botón Atrás | Cerrar popup + Ir al siguiente ejercicio | Pregunta #N+1 |
| 🛑 **NoHeartsPopup** (hearts = 0) | Botón Atrás | Cerrar popup + Ir a página "Aprender" | Dashboard (/dashboard) |
| 🏁 **GameOverPopup** (fin de lección) | Botón Atrás | Cerrar popup + Ir a página "Aprender" | Dashboard (/dashboard) |

---

## 🛠️ Estrategia de Implementación

### Opción A: PopScope Inteligente (Recomendada)

**Concepto:**
- Mantener PopScope pero permitir back button
- En `onPopInvokedWithResult`, ejecutar lógica según el tipo de popup actual
- Usar un enum para rastrear qué popup está abierto

**Pasos:**

```dart
// 1. Crear enum para identificar popup
enum OpenPopupType {
  none,
  success,
  error,
  noHearts,
  gameOver,
}

// 2. Agregar a state
OpenPopupType _currentPopupType = OpenPopupType.none;

// 3. En PopScope
PopScope(
  canPop: true, // ✅ PERMITIR back button siempre
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) {
      _handleBackButtonPress(_currentPopupType);
    }
  },
  child: Scaffold(...)
)

// 4. Manejador central
void _handleBackButtonPress(OpenPopupType popupType) {
  switch (popupType) {
    case OpenPopupType.success:
    case OpenPopupType.error:
      // Ir al siguiente ejercicio
      setState(() => _currentPopupType = OpenPopupType.none);
      _nextQuestion();
      break;
      
    case OpenPopupType.noHearts:
    case OpenPopupType.gameOver:
      // Ir a /dashboard
      setState(() => _currentPopupType = OpenPopupType.none);
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      break;
      
    case OpenPopupType.none:
      // Back button normal
      Navigator.pop(context);
      break;
  }
}

// 5. Actualizar en cada popup
setState(() => _currentPopupType = OpenPopupType.success);
showGeneralDialog(...);
```

**Ventajas:**
- ✅ Simple y clara
- ✅ Un punto central para toda la lógica
- ✅ Fácil de mantener y debuggear
- ✅ No necesita cambiar popups

**Desventajas:**
- Requiere mantener sincronizado el tipo de popup actual

---

### Opción B: Remover PopScope Completamente

**Concepto:**
- El back button cierra los dialogs automáticamente (por defecto)
- No bloquear back button con PopScope
- Detectar cuándo un popup fue cerrado por back button (vs botón del popup)

**Pasos:**
```dart
// 1. Remover PopScope
// 2. En showGeneralDialog, usar barrierDismissible: true
showGeneralDialog(
  barrierDismissible: true, // Permitir cerrar con back
  onBarrierDismiss: () {
    // Este callback se ejecuta cuando se cierra el dialog
    if (_currentPopupType == OpenPopupType.success || ...) {
      _nextQuestion();
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', ...);
    }
  },
  ...
)
```

**Ventajas:**
- ✅ Más simple (menos código)
- ✅ Comportamiento estándar de Flutter

**Desventajas:**
- ❌ El popup se cierra CON el back button (no solo ejecuta acción)
- ❌ Menos control
- ❌ Los botones del popup y el back button hacen lo mismo

---

## 🎯 Recomendación: **Opción A (PopScope Inteligente)**

**Razón:** Permite máximo control:
- Back button ejecuta la acción lógica correcta
- Popups se cierran limpiamente
- Usuario no puede quedarse atrapado

---

## 📝 Cambios Específicos en Código

### Archivo: `practice_screen.dart`

**1. Agregar enum al inicio del archivo**
```dart
enum OpenPopupType {
  none,
  success,
  error,
  noHearts,
  gameOver,
}
```

**2. En `_PracticeScreenState`, agregar variable de estado**
```dart
OpenPopupType _currentPopupType = OpenPopupType.none;
```

**3. Crear método `_handleBackButtonPress`**
```dart
void _handleBackButtonPress() {
  switch (_currentPopupType) {
    case OpenPopupType.success:
    case OpenPopupType.error:
      setState(() => _currentPopupType = OpenPopupType.none);
      _nextQuestion();
      break;
      
    case OpenPopupType.noHearts:
    case OpenPopupType.gameOver:
      setState(() => _currentPopupType = OpenPopupType.none);
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      break;
      
    case OpenPopupType.none:
      Navigator.pop(context);
      break;
  }
}
```

**4. Actualizar PopScope en `build()`**
```dart
PopScope(
  canPop: true, // ✅ Permitir back button siempre
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) {
      _handleBackButtonPress();
    }
  },
  child: Scaffold(...)
)
```

**5. En cada popup, establecer el tipo**

En `_checkAnswer()`, cuando se muestra SuccessPopup:
```dart
setState(() => _currentPopupType = OpenPopupType.success);
showGeneralDialog(...);
```

En `_checkAnswer()`, cuando se muestra ErrorPopup:
```dart
setState(() => _currentPopupType = OpenPopupType.error);
showGeneralDialog(...);
```

En `_checkAnswer()`, cuando se muestra NoHeartsPopup:
```dart
setState(() => _currentPopupType = OpenPopupType.noHearts);
showGeneralDialog(...);
```

En `_finishLesson()`, cuando se muestra GameOverPopup:
```dart
setState(() => _currentPopupType = OpenPopupType.gameOver);
showDialog(...);
```

**6. En callbacks de popups, resetear tipo**
```dart
// En SuccessPopup callback
onNext: () {
  setState(() => _currentPopupType = OpenPopupType.none);
  Navigator.pop(dialogContext);
  _nextQuestion();
}

// En ErrorPopup callback
onNext: () {
  setState(() => _currentPopupType = OpenPopupType.none);
  Navigator.pop(dialogContext);
  _nextQuestion();
}

// En NoHeartsPopup callbacks
onRecharge: () {
  setState(() => _currentPopupType = OpenPopupType.none);
  Navigator.pop(dialogContext);
  Navigator.pushNamed(context, '/shop');
}

onGoHome: () {
  setState(() => _currentPopupType = OpenPopupType.none);
  Navigator.pop(dialogContext);
  Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
}

// En GameOverPopup callback
onNext: () {
  setState(() => _currentPopupType = OpenPopupType.none);
  Navigator.pop(dialogContext);
  Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
}
```

---

## 📊 Matriz de Cambios

| Componente | Cambio | Línea |
|-----------|--------|-------|
| enum | AGREGAR `OpenPopupType` | Inicio archivo |
| State variable | AGREGAR `_currentPopupType` | Line ~40 |
| PopScope | MODIFICAR `canPop: true` | Line ~400 |
| onPopInvokedWithResult | MODIFICAR lógica | Line ~410 |
| _handleBackButtonPress | AGREGAR método nuevo | Line ~300 |
| SuccessPopup show | AGREGAR setState(_currentPopupType = .success) | Line ~165 |
| ErrorPopup show | AGREGAR setState(_currentPopupType = .error) | Line ~210 |
| NoHeartsPopup show | AGREGAR setState(_currentPopupType = .noHearts) | Line ~205 |
| GameOverPopup show | AGREGAR setState(_currentPopupType = .gameOver) | Line ~360 |
| Todos callbacks | AGREGAR setState(_currentPopupType = .none) | Múltiples líneas |

---

## ✅ Validación Post-Implementación

**Escenarios a probar:**

1. ✅ Pregunta correcta → popup correcto → Back → Ir a Q#2
2. ✅ Pregunta incorrecta → popup error → Back → Ir a Q#2
3. ✅ Hearts = 0 → NoHeartsPopup → Back → Ir a /dashboard
4. ✅ Última pregunta correcta → GameOverPopup → Back → Ir a /dashboard
5. ✅ Pregunta correcta → popup correcto → Botón "Continuar" → Ir a Q#2 (sin back)
6. ✅ Última pregunta correcta → GameOverPopup → Botón "Continuar" → Ir a /dashboard (sin back)

---

## 🎯 ¿Es esto lo que quieres?

- ✅ Back button cierra popup E ejecuta acción correcta
- ✅ Diferente comportamiento según tipo de popup
- ✅ Usuario nunca queda atrapado
- ✅ Página "Aprender" = /dashboard
- ✅ Siguiente ejercicio en lección = _nextQuestion()
