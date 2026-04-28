# 🛠️ Plan de Implementación: Corrección de Gramática y Coherencia en Ejercicios

## 1. Diagnóstico del Problema

Actualmente, los usuarios ven errores ortográficos, palabras duplicadas (ej. `morirás; rás`) y oraciones cortadas abruptamente (ej. `Y de la ____ que jehová Dios tomó del`) en la pantalla de `PracticeScreen`. 

**Causas detectadas:**
1. **Basura de Extracción (OCR/PDF):** El archivo fuente (`genesis_rvr1960.txt`) contiene saltos de línea duros, saltos de página y palabras separadas por guiones que se importaron literalmente a la base de datos (ej. `mo- rirás`).
2. **Caracteres Raros (Ligaduras):** El texto usa el carácter especial `ĳ` en lugar de `ij` (ej. `dĳo`, `bendĳo`). Esto rompe los diccionarios del procesador de lenguaje natural (NLP).
3. **Límites de Versículos Rígidos:** El algoritmo crea ejercicios versículo por versículo. Si una oración empieza en el versículo 21 y termina en el 22, el ejercicio del versículo 21 queda con el texto cortado.

---

## 2. Plan de Acción (Backend Focus)

Para resolver esto de raíz y de forma permanente, no modificaremos Flutter (el frontend solo muestra lo que le da el servidor). Trabajaremos en el **Backend (Django / Python)** mediante los siguientes pasos:

### Paso 1: Script de Saneamiento de Base de Datos (Data Cleansing)
Crearé un script en Python (similar a `fix_genesis_1.py` pero mucho más inteligente) que recorrerá todos los versículos guardados en la base de datos y aplicará las siguientes reglas de limpieza:
- Reemplazar el carácter `ĳ` por `ij`.
- Eliminar guiones huérfanos y unir las sílabas separadas (ej. `expan- sión` -> `expansión`).
- Eliminar espacios dobles y saltos de línea innecesarios.

### Paso 2: Eliminación de Ejercicios Corruptos (Cache Clearing)
El script buscará todos los ejercicios (`Exercise`) generados previamente en la base de datos que contengan estos textos corruptos y los **eliminará**. 
- *Nota:* Esto forzará al algoritmo JIT (Just-In-Time) de tu backend a regenerar los ejercicios la próxima vez que un usuario abra la lección, pero esta vez usando el texto limpio.

### Paso 3: Ajuste al Generador NLP (Opcional si es accesible)
Revisaré la lógica de cómo se arman los ejercicios `cloze` y `scramble` para asegurar que el motor de IA tome en cuenta la puntuación final y no mutile las palabras al ocultarlas (evitando el problema de `morirás; rás` cuando la IA intenta aislar la palabra objetivo y se tropieza con un punto y coma o coma).

---

## 3. Resultados Esperados

- **Antes:** *"Y porque el día que de él comieres, ciertamente morirás; rás"*
- **Después:** *"Y porque el día que de él comieres, ciertamente morirás."*

- **Antes:** *"Y de la ____ que jehová Dios tomó del"*
- **Después:** *"Y de la ____ que Jehová Dios tomó del hombre, hizo una mujer."* (El texto se mostrará coherente o se elegirá un fragmento válido).

---

## 4. Archivos a Modificar

1. Se creará un nuevo script: `scripts/clean_bible_text.py` (o similar) para ejecutar en tu servidor Django / Render.
2. (Si aplica) El archivo de generación de ejercicios en Django (ej. `apps/exercises/services.py` o donde viva tu lógica spaCy) para mejorar el recorte de palabras.