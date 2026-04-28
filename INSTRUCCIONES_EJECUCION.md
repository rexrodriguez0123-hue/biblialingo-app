# 🚀 Instrucciones de Ejecución — Plan de Corrección de Textos

## Estado: LISTO PARA EJECUTAR

Se han implementado los siguientes cambios en el backend:

✅ **Management Command:** `clean_all_verses.py`  
✅ **Validación NLP:** Funciones `_is_text_corrupted()` y `_is_exercise_valid()` en `nlp_engine.py`  
✅ **Protección Ejercicios:** Validación automática en `generate_exercises_for_verse()` y `generate_exercises_for_lesson()`

---

## 📋 Pasos para Ejecutar

### **Paso 1: Hacer DRY-RUN (Simular sin cambios)**

Ejecuta esto primero para ver qué se cambiaría:

```bash
# En tu servidor Django (local o Render)
python manage.py clean_all_verses --dry-run
```

**Qué hace:**
- Escanea TODOS los versículos de la BD
- Detecta errores (ligaduras ĳ→ij, guiones huérfanos, palabras duplicadas, etc.)
- Muestra un reporte SIN guardar nada

**Salida esperada:**
```
================================================================================
🔍 INICIANDO LIMPIEZA DE VERSÍCULOS BÍBLICOS
================================================================================

📖 Procesando: TODOS LOS LIBROS
📊 Total de versículos a procesar: 1189
📋 Modo: DRY-RUN (Sin cambios)

✏️  [1] Génesis 1:1:
    ANTES: En el principio creó Dios los cielos y la tierra. [...]
    AHORA: En el principio creó Dios los cielos y la tierra. [...]
    
[... más cambios ...]

================================================================================
📊 RESUMEN DE LIMPIEZA
================================================================================

📚 VERSÍCULOS:
   Total procesados: 1189
   Actualizados: X (Y%)
   Bytes liberados: Z

🎯 EJERCICIOS:
   Eliminados (regeneración): 0 (aún dry-run)

📋 Modo: DRY-RUN (cambios simulados)

✅ Limpieza completada exitosamente
================================================================================
```

---

### **Paso 2: Ejecutar Limpieza Real**

Una vez verificado el dry-run, ejecuta con cambios reales:

```bash
python manage.py clean_all_verses --delete-exercises
```

**Opciones:**
- `--delete-exercises` → Elimina ejercicios corruptos (fuerza regeneración JIT)
- `--book "Génesis"` → Solo limpia un libro específico
- `--dry-run` → Solo simula (combinar con otros)

**Ejemplo: Limpiar solo Génesis**
```bash
python manage.py clean_all_verses --book "Génesis" --delete-exercises
```

---

### **Paso 3: Verificar Resultados**

Después de ejecutar, verifica que los cambios se aplicaron:

```bash
# Conectarse a la BD y verificar un versículo
python manage.py shell
>>> from apps.bible_content.models import Verse
>>> v = Verse.objects.get(number=1, chapter__number=1)
>>> print(v.text)
# Debe mostrar: "En el principio creó Dios los cielos y la tierra."
# SIN caracteres raros como ĳ o guiones huérfanos
```

---

### **Paso 4: Regenerar Ejercicios (Automático)**

**NO HAGAS NADA.** Los ejercicios se regenerarán automáticamente la próxima vez que un usuario:
1. Abra una lección
2. El backend detecte que faltan ejercicios
3. Corra el algoritmo JIT de `generate_exercises_for_lesson()`

Los ejercicios se generarán con el texto LIMPIO ahora, porque hemos agregado validaciones.

---

## 🔍 Qué se Limpia

### **Caracteres Especiales Reemplazados**
```
ĳ → ij        (dĳo → dijo, bendĳo → bendijo)
ſ → s         (long s)
– → -         (en-dash → hyphen)
— → -         (em-dash → hyphen)
… → ...       (ellipsis)
" → "         (curly quotes)
'' → ''       (curly apostrophes)
```

### **Errores de Extracción Arreglados**
```
"expan- sión" → "expansión"       (guiones huérfanos)
"más  de"     → "más de"           (espacios dobles)
"morirás; rás" → "morirás"         (palabras duplicadas OCR)
```

### **Espacios y Saltos Normalizados**
```
Múltiples saltos de línea → Un solo espacio
Tabulaciones → Espacios simples
Espacios antes de puntuación → Eliminados
```

---

## 🛡️ Protecciones Agregadas

### **En el NLP Engine (nlp_engine.py)**

**Nueva función `_is_text_corrupted(text)`:**
Detecta patrones de corrupción:
- `morirás; rás` (palabras duplicadas)
- `ex- pansión` (guiones huérfanos)
- `ĳ` (ligaduras raras)
- Espacios dobles entre palabras

**Nueva función `_is_exercise_valid(exercise)`:**
Valida ejercicios completos antes de guardarlos en BD.

**Cambios en generadores:**
- `generate_exercises_for_verse()` ahora valida cada ejercicio
- `generate_exercises_for_lesson()` ahora valida y rechaza versículos corruptos
- Los ejercicios corruptos simplemente no se generan (y se evitan automáticamente)

---

## 📊 Resultados Esperados

**ANTES:**
```
Pantalla de práctica: "Y porque el día que de él comieres, ciertamente morirás; rás"
Ejercicio: "Y de la ____ que jehová Dios tomó del"
```

**DESPUÉS:**
```
Pantalla de práctica: "Y porque el día que de él comieres, ciertamente morirás."
Ejercicio: "Y de la ____ que Jehová Dios tomó del hombre, hizo una mujer."
```

---

## ⚠️ Notas Importantes

1. **Reversible:** Si algo sale mal, puedes hacer restore de BD desde backup
2. **JIT Regeneration:** Ejercicios se regeneran automáticamente en próxima lectura
3. **Solo Backend:** No cambian archivos Flutter, solo la BD
4. **Sin downtime:** Puedes ejecutar en Render mientras está en producción (los usuarios verán ejercicios más limpios)

---

## 🐛 Troubleshooting

**P: El comando tarda mucho**
R: Es normal. Con 1000+ versículos y procesamiento spaCy, puede tardar 2-5 minutos.

**P: ¿Se pierden datos?**
R: No. Solo se corrige el texto corrupto. El versículo sigue siendo el mismo.

**P: ¿Afecta a usuarios en línea?**
R: No inmediatamente. Próxima lectura tendrá ejercicios regenerados y limpios.

**P: ¿Cómo revierdo?**
R: `python manage.py clean_all_verses --dry-run` para ver qué habría cambiado. Luego restaura backup si necesitas.

---

## ✅ Checklist Final

- [ ] Ejecuté `--dry-run` y revisé los cambios
- [ ] Ejecuté con `--delete-exercises` en ambiente seguro
- [ ] Verificué al menos 3 versículos en Django shell
- [ ] Los usuarios reportan textos más limpios en PracticeScreen
- [ ] No hay errores en los logs del servidor

---

**Listo para empezar. Ejecuta:**
```bash
python manage.py clean_all_verses --dry-run
```
