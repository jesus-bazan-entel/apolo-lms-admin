# Guía de Uso del Sistema de Carga de Estructura de Cursos

## Descripción General

El sistema ahora permite cargar la estructura completa de un curso mediante un archivo de texto en lugar de tener que crearla manualmente o con código hardcoded.

## Formato del Archivo

El archivo debe seguir un formato específico usando símbolos de markdown:

### Estructura Jerárquica

```
# Nivel: [Nombre del Nivel]
## Módulo: [Nombre del Módulo]
- [Nombre de la Lección]
- [Nombre de otra Lección]

## Módulo: [Nombre del siguiente Módulo]
- [Nombre de la Lección]
```

### Ejemplo Completo

```
# Nivel: Básico
## Módulo: Introducción al Portugués
- Lección 1: El alfabeto portugués
- Lección 2: Saludos y presentaciones
- Lección 3: Números del 1 al 20

## Módulo: Gramática Básica
- Lección 1: Artículos definidos e indefinidos
- Lección 2: Pronombres personales
- Lección 3: Verbos ser y estar

# Nivel: Intermedio
## Módulo: Conversación Cotidiana
- Lección 1: En el restaurante
- Lección 2: En la tienda
- Lección 3: En el hotel

## Módulo: Gramática Intermedia
- Lección 1: Tiempos verbales
- Lección 2: Adjetivos y adverbios
- Lección 3: Preposiciones
```

## Cómo Usar el Sistema

### Paso 1: Preparar el Archivo

1. Crea un archivo de texto (.txt) con la estructura de tu curso
2. Sigue el formato especificado arriba
3. Usa los símbolos correctos:
   - `#` para niveles
   - `##` para módulos
   - `-` para lecciones

### Paso 2: Subir el Archivo

1. Accede al panel de administración
2. Ve a la sección **Jerarquía** en el menú lateral
3. Selecciona el curso al que quieres agregar la estructura
4. Haz clic en el botón **"Subir Estructura"**
5. En el diálogo que aparece:
   - Lee las instrucciones de formato
   - Haz clic en **"Seleccionar Archivo"**
   - Elige tu archivo .txt, .pdf o .docx
   - Haz clic en **"Procesar y Crear Estructura"**

### Paso 3: Monitorear el Progreso

El sistema mostrará en tiempo real:
- ✓ Nivel creado: [Nombre]
- ✓ Módulo creado: [Nombre]
- ✓ Lección creada: [Nombre]

### Paso 4: Verificar la Estructura

1. Una vez completado el proceso, cierra el diálogo
2. La estructura debería aparecer automáticamente en la vista de jerarquía
3. Puedes navegar por los niveles y módulos para verificar que todo se creó correctamente

## Edición Posterior

Después de crear la estructura:

1. **Editar Lecciones**: Haz clic en "Ver Lecciones" en cualquier módulo
2. Puedes agregar:
   - Descripción detallada
   - Video URL
   - YouTube URL
   - Materiales PDF
   - Contenido generado con IA

## Formatos de Archivo Soportados

- **.txt** (Texto plano - Recomendado)
- **.pdf** (Portable Document Format)
- **.docx** (Microsoft Word)

## Notas Importantes

1. **Niveles**: Cada curso puede tener múltiples niveles (Básico, Intermedio, Avanzado, etc.)
2. **Módulos**: Cada nivel puede tener múltiples módulos
3. **Lecciones**: Cada módulo puede tener múltiples lecciones
4. **Orden**: Las lecciones se numeran automáticamente según el orden en el archivo
5. **Firestore**: Todo se almacena automáticamente en la base de datos Firebase

## Ventajas del Nuevo Sistema

✓ **Flexibilidad**: Ya no estás limitado a una estructura predefinida
✓ **Rapidez**: Carga toda la estructura en segundos
✓ **Escalabilidad**: Puedes crear cursos de cualquier tamaño
✓ **Reutilización**: Guarda plantillas de estructura para cursos similares
✓ **Control**: Modifica el archivo antes de subirlo para ajustar la estructura

## Solución de Problemas

### El archivo no se procesa correctamente

- Verifica que estés usando los símbolos correctos (# ## -)
- Asegúrate de que no haya líneas vacías innecesarias
- Comprueba que el archivo esté en formato de texto plano

### No se crean algunas lecciones

- Revisa que cada lección tenga el guión `-` al inicio
- Verifica que no haya caracteres especiales que causen problemas
- Asegúrate de que el módulo padre esté correctamente definido

### Error de permisos

- Verifica que estés autenticado como administrador
- Comprueba que hayas seleccionado un curso antes de subir el archivo
- Asegúrate de que Firebase esté configurado correctamente

## Mejoras Futuras

El sistema está diseñado para ser extensible. Futuras versiones podrían incluir:

- Importación directa desde Google Sheets
- Generación automática de contenido con IA
- Plantillas predefinidas para diferentes tipos de cursos
- Validación avanzada de la estructura
- Preview antes de crear la estructura

---

**Fecha de Actualización**: Diciembre 2024
**Versión**: 2.0
