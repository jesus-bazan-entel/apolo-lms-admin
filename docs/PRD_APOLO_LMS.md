# PRD - ApoloLMS (IDECAP Idiomas)

## Product Requirements Document

**Versión:** 2.0
**Fecha:** 30 de Enero de 2026
**Estado:** En Producción
**URL:** https://apololms.web.app

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Modelo de Datos](#3-modelo-de-datos)
4. [Módulos Funcionales](#4-módulos-funcionales)
5. [Componentes de UI](#5-componentes-de-ui)
6. [Servicios](#6-servicios)
7. [Providers (Estado)](#7-providers-estado)
8. [Flujos de Usuario](#8-flujos-de-usuario)
9. [Integraciones Externas](#9-integraciones-externas)
10. [Seguridad](#10-seguridad)
11. [Despliegue](#11-despliegue)
12. [Roadmap](#12-roadmap)

---

## 1. Resumen Ejecutivo

### 1.1 Descripción del Producto

**ApoloLMS** es un panel de administración web desarrollado en Flutter para **IDECAP Idiomas**, un instituto de enseñanza de idiomas especializado en portugués brasileño. El sistema permite gestionar cursos, estudiantes, tutores y contenido educativo con una estructura jerárquica de 5 niveles.

### 1.2 Objetivos del Producto

| Objetivo | Descripción |
|----------|-------------|
| Gestión Centralizada | Administrar todo el contenido educativo desde un único panel |
| Estructura Jerárquica | Organizar cursos en 5 niveles (Curso → Nivel → Módulo → Sección → Lección) |
| Generación con IA | Crear contenido educativo automáticamente con Google Gemini |
| Control de Acceso | Sistema robusto de roles y permisos |
| Multi-plataforma | App web responsiva accesible desde cualquier dispositivo |

### 1.3 Público Objetivo

| Rol | Descripción | Acceso |
|-----|-------------|--------|
| **Administrador** | Personal de IDECAP con acceso completo | 9 tabs completos |
| **Autor/Tutor** | Instructores con acceso limitado | 3 tabs (Dashboard, Cursos, Reseñas) |
| **Estudiante** | Usuarios finales | Solo app móvil (no acceden al admin) |

---

## 2. Arquitectura del Sistema

### 2.1 Stack Tecnológico

| Capa | Tecnología | Versión |
|------|------------|---------|
| **Frontend** | Flutter Web | 3.x |
| **Lenguaje** | Dart | 3.x |
| **State Management** | Riverpod | 2.6.1 |
| **Backend** | Firebase (Firestore, Auth, Storage) | Core 3.15.2 |
| **IA** | Google Gemini API | 0.4.7 |
| **Notificaciones** | Firebase Cloud Messaging | v1 API |
| **Hosting** | Firebase Hosting | - |

### 2.2 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FLUTTER WEB APP                               │
├─────────────────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────────┐ │
│  │   Pages    │  │    Tabs    │  │ Components │  │     Mixins     │ │
│  │  (login,   │  │  (admin,   │  │   (UI,     │  │  (lessons,     │ │
│  │   home,    │  │   author)  │  │  dialogs)  │  │ sections, etc) │ │
│  │  splash)   │  │            │  │            │  │                │ │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘  └───────┬────────┘ │
│        │               │               │                 │          │
│        └───────────────┴───────────────┴─────────────────┘          │
│                                │                                     │
│                      ┌─────────▼─────────┐                          │
│                      │     PROVIDERS     │                          │
│                      │    (Riverpod)     │                          │
│                      └─────────┬─────────┘                          │
│                                │                                     │
│                      ┌─────────▼─────────┐                          │
│                      │     SERVICES      │                          │
│                      └─────────┬─────────┘                          │
└────────────────────────────────┼────────────────────────────────────┘
                                 │
           ┌─────────────────────┼─────────────────────┐
           │                     │                     │
           ▼                     ▼                     ▼
  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐
  │    FIREBASE     │   │  GOOGLE GEMINI  │   │      FCM        │
  │  (Auth, Store,  │   │    (AI API)     │   │ (Notifications) │
  │    Storage)     │   │                 │   │                 │
  └─────────────────┘   └─────────────────┘   └─────────────────┘
```

### 2.3 Estructura de Directorios

```
lib/
├── pages/                    # Pantallas principales
│   ├── home.dart            # Hub de navegación con tabs
│   ├── login.dart           # Autenticación
│   ├── splash.dart          # Splash screen
│   └── verify.dart          # Verificación de licencia
│
├── tabs/                     # Vistas por rol
│   ├── admin_tabs/          # Tabs de administrador
│   │   ├── dashboard/       # Dashboard con estadísticas
│   │   ├── courses/         # Gestión de cursos
│   │   ├── students/        # Gestión de estudiantes
│   │   ├── tutors/          # Gestión de tutores
│   │   ├── categories/      # Categorías
│   │   ├── hierarchy/       # Vista jerárquica de cursos
│   │   ├── levels/          # Gestión de niveles
│   │   ├── modules/         # Gestión de módulos
│   │   ├── reviews/         # Reseñas
│   │   ├── purchases/       # Historial de compras
│   │   └── app_settings/    # Configuración
│   │
│   └── author_tabs/         # Tabs de autor (limitado)
│       ├── author_dashboard.dart
│       ├── author_courses.dart
│       └── author_course_reviews.dart
│
├── services/                 # Servicios externos
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── ai_content_service.dart
│   ├── notification_service.dart
│   └── qr_generator_service.dart
│
├── models/                   # Modelos de datos
│   ├── user_model.dart
│   ├── course.dart
│   ├── lesson.dart
│   ├── level.dart
│   ├── module.dart
│   └── ...
│
├── providers/                # Estado (Riverpod)
│   ├── auth_state_provider.dart
│   ├── user_data_provider.dart
│   ├── categories_provider.dart
│   └── theme_provider.dart
│
├── components/               # Componentes reutilizables
│   ├── ui/                  # Componentes UI genéricos
│   ├── text_editors/        # Editores HTML/Quill
│   ├── course_materials/    # Gestor de materiales
│   └── ...
│
├── forms/                    # Formularios
│   ├── course_form.dart
│   ├── lesson_form.dart
│   └── ...
│
├── mixins/                   # Lógica UI compartida
│   ├── lessons_mixin.dart
│   ├── sections_mixin.dart
│   └── ...
│
└── configs/                  # Configuración
    ├── app_config.dart      # Colores, gradientes
    ├── app_theme.dart       # Tema Material 3
    ├── design_tokens.dart   # Espaciado, animaciones
    └── constants.dart       # Enums y constantes
```

---

## 3. Modelo de Datos

### 3.1 Jerarquía de Cursos (5 Niveles)

```
courses/{courseId}
└── levels/{levelId}
    └── modules/{moduleId}
        └── sections/{sectionId}
            └── lessons/{lessonId}
```

### 3.2 Esquema Completo de Firestore

```
FIRESTORE DATABASE
│
├── users/
│   └── {userId}
│       ├── id: string
│       ├── email: string
│       ├── name: string
│       ├── image_url: string?
│       ├── role: array ['admin' | 'author' | 'student' | 'tutor']
│       ├── disabled: boolean
│       ├── enrolled: array [courseIds]
│       ├── wishlist: array [courseIds]
│       ├── completed_lessons: array [lessonIds]
│       │
│       │   # Campos específicos para Tutores
│       ├── assigned_courses: array [courseIds]
│       ├── tutor_permissions: map
│       │
│       │   # Campos específicos para Estudiantes
│       ├── student_level: string
│       ├── student_section: string
│       ├── payment_status: string ['paid' | 'unpaid']
│       ├── qr_code_hash: string
│       │
│       ├── created_at: timestamp
│       └── updated_at: timestamp
│
├── courses/
│   └── {courseId}
│       ├── id: string
│       ├── name: string
│       ├── image_url: string
│       ├── video_url: string?
│       ├── status: string ['draft' | 'pending' | 'live' | 'archive']
│       ├── category_id: string
│       ├── tag_ids: array
│       ├── price_status: string ['free' | 'premium']
│       ├── rating: number
│       ├── students: number
│       ├── featured: boolean
│       ├── lessons_count: number
│       ├── level: string?
│       ├── language: string?
│       │
│       ├── author: map
│       │   ├── id: string
│       │   ├── name: string
│       │   └── image_url: string
│       │
│       ├── tutor_ids: array [userIds]
│       ├── tutors: array [map]
│       │
│       ├── meta: map
│       │   ├── duration: string
│       │   ├── summary: string
│       │   ├── description: string (HTML)
│       │   ├── learnings: array
│       │   ├── requirements: array
│       │   └── language: string
│       │
│       └── /levels/{levelId}              # SUBCOLECCIÓN
│           ├── id: string
│           ├── name: string
│           ├── description: string
│           ├── order: number
│           ├── course_id: string
│           │
│           └── /modules/{moduleId}        # SUBCOLECCIÓN
│               ├── id: string
│               ├── name: string
│               ├── description: string
│               ├── order: number
│               ├── total_classes: number
│               │
│               └── /sections/{sectionId}  # SUBCOLECCIÓN
│                   ├── id: string
│                   ├── name: string
│                   ├── order: number
│                   │
│                   └── /lessons/{lessonId} # SUBCOLECCIÓN
│                       ├── id: string
│                       ├── name: string
│                       ├── order: number
│                       ├── content_type: string ['video' | 'article' | 'quiz' | 'document' | 'youtube' | 'mixed']
│                       ├── video_url: string?
│                       ├── lesson_body: string? (HTML)
│                       ├── description: string?
│                       ├── duration: string?
│                       ├── is_free: boolean
│                       │
│                       ├── youtube_video: map?
│                       │   ├── video_id: string
│                       │   ├── title: string
│                       │   └── thumbnails: map
│                       │
│                       ├── local_video: map?
│                       │   ├── url: string
│                       │   ├── title: string
│                       │   └── description: string
│                       │
│                       ├── materials: array [LessonMaterial]
│                       │   ├── id: string
│                       │   ├── title: string
│                       │   ├── url: string
│                       │   └── type: string
│                       │
│                       ├── quiz: array [Question]
│                       │   ├── question: string
│                       │   ├── options: array
│                       │   └── correct_ans_index: number
│                       │
│                       └── pdf_links: array
│
├── categories/
│   └── {categoryId}
│       ├── id: string
│       ├── name: string
│       ├── image_url: string
│       ├── index: number (orden)
│       ├── featured: boolean
│       └── created_at: timestamp
│
├── tags/
│   └── {tagId}
│       ├── id: string
│       ├── name: string
│       └── created_at: timestamp
│
├── reviews/
│   └── {reviewId}
│       ├── id: string
│       ├── course_id: string
│       ├── course_author_id: string
│       ├── course_title: string
│       ├── rating: number (1-5)
│       ├── review: string
│       ├── created_at: timestamp
│       └── user: map
│           ├── id: string
│           ├── name: string
│           └── image_url: string
│
├── purchases/
│   └── {purchaseId}
│       ├── id: string
│       ├── user_id: string
│       ├── user_name: string
│       ├── user_email: string
│       ├── user_image_url: string?
│       ├── plan: string
│       ├── price: number
│       ├── platform: string ['ios' | 'android' | 'web']
│       ├── purchase_id: string?
│       ├── purchase_at: timestamp
│       └── expire_at: timestamp
│
├── notifications/
│   └── {notificationId}
│       ├── id: string
│       ├── title: string
│       ├── description: string
│       ├── topic: string
│       └── sent_at: timestamp
│
└── settings/
    └── app
        ├── featured: boolean
        ├── top_authors: boolean
        ├── categories: boolean
        ├── free_courses: boolean
        ├── tags: boolean
        ├── onboarding: boolean
        ├── skip_login: boolean
        ├── latest_courses: boolean
        │
        ├── email: string
        ├── website: string
        ├── privacy_url: string
        │
        ├── category1: map (HomeCategory)
        ├── category2: map (HomeCategory)
        ├── category3: map (HomeCategory)
        │
        ├── social: map
        │   ├── fb: string
        │   ├── youtube: string
        │   ├── twitter: string
        │   └── instagram: string
        │
        ├── ads: map (AdsModel)
        ├── license: string ['none' | 'regular' | 'extended']
        ├── content_security: boolean
        └── gemini_api_key: string
```

### 3.3 Modelos Dart Principales

#### UserModel
```dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? imageUrl;
  final List<String> role;           // ['admin', 'author', 'student', 'tutor']
  final bool disabled;
  final List<String> enrolledCourses;
  final List<String> wishList;

  // Campos de Tutor
  final List<String>? assignedCourses;
  final Map<String, dynamic>? tutorPermissions;

  // Campos de Estudiante
  final String? studentLevel;
  final String? studentSection;
  final String? paymentStatus;       // 'paid' | 'unpaid'
  final String? qrCodeHash;

  // Getters
  bool get isTutor => role.contains('tutor');
  bool get isAdmin => role.contains('admin');
  bool get isStudent => role.contains('student');

  factory UserModel.fromFirestore(DocumentSnapshot doc);
  static Map<String, dynamic> getMap(UserModel user);
}
```

#### Course
```dart
class Course {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String status;               // 'draft' | 'pending' | 'live' | 'archive'
  final String? categoryId;
  final Author author;
  final String priceStatus;          // 'free' | 'premium'
  final double rating;
  final int studentsCount;
  final List<String> tagIds;
  final CourseMeta? courseMeta;
  final bool isFeatured;
  final int lessonsCount;
  final String? level;
  final String? language;
  final List<String>? tutorIds;
  final List<Map<String, dynamic>>? tutors;

  factory Course.fromFirestore(DocumentSnapshot doc);
  static Map<String, dynamic> getMap(Course course);
}
```

#### Lesson
```dart
class Lesson {
  final String id;
  final String name;
  final int order;
  final String contentType;          // 'video' | 'article' | 'quiz' | 'document' | 'youtube' | 'mixed'
  final String? videoUrl;
  final String? lessonBody;          // HTML content
  final String? description;
  final String? duration;
  final bool isFree;
  final List<Question>? questions;   // Quiz
  final List<LessonMaterial>? materials;
  final YouTubeVideo? youtubeVideo;
  final LocalVideo? localVideo;
  final List<String>? pdfLinks;

  // Getters de utilidad
  bool get hasMaterials => materials != null && materials!.isNotEmpty;
  bool get hasYouTubeVideo => youtubeVideo != null;
  bool get hasQuiz => questions != null && questions!.isNotEmpty;
  String? get primaryVideoUrl => videoUrl ?? youtubeVideo?.videoId ?? localVideo?.url;

  Lesson copyWith({...});
  factory Lesson.fromFirestore(DocumentSnapshot doc);
  static Map<String, dynamic> getMap(Lesson lesson);
}
```

---

## 4. Módulos Funcionales

### 4.1 Sistema de Autenticación

#### Métodos de Autenticación
| Método | Descripción | Implementación |
|--------|-------------|----------------|
| Email/Contraseña | Login tradicional | `FirebaseAuth.signInWithEmailAndPassword()` |
| Google Sign In | OAuth con Google | `GoogleSignIn().signIn()` |
| Demo/Anónimo | Acceso de demostración | `FirebaseAuth.signInAnonymously()` |

#### Flujo de Autenticación
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│    Splash    │────▶│    Login     │────▶│   Validar    │
│    Screen    │     │    Screen    │     │     Rol      │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                  │
                     ┌────────────────────────────┼────────────────────────────┐
                     │                            │                            │
                     ▼                            ▼                            ▼
             ┌──────────────┐            ┌──────────────┐             ┌──────────────┐
             │    Admin     │            │    Author    │             │  Sin Acceso  │
             │     Home     │            │   Verificar  │             │   (Error)    │
             │   (9 tabs)   │            │   Licencia   │             │              │
             └──────────────┘            └──────┬───────┘             └──────────────┘
                                                │
                                         ┌──────▼───────┐
                                         │    Author    │
                                         │     Home     │
                                         │   (3 tabs)   │
                                         └──────────────┘
```

#### Roles y Permisos

| Rol | Tabs Disponibles | Descripción |
|-----|------------------|-------------|
| **Admin** | Dashboard, Estudiantes, Tutores, Cursos, Cursos Destacados, Categorías, Etiquetas, Reseñas, Configuración | Acceso completo al sistema |
| **Author** | Dashboard, Cursos, Reseñas | Acceso limitado, requiere licencia |

### 4.2 Dashboard

#### Métricas en Tiempo Real
- Total de usuarios registrados
- Estudiantes activos
- Cursos publicados
- Compras realizadas
- Reseñas recibidas

#### Visualizaciones
| Componente | Descripción |
|------------|-------------|
| `UserBarChart` | Gráfico de barras de usuarios por nivel |
| `DashboardTopCourses` | Lista de cursos más populares |
| `DashboardReviews` | Últimas reseñas recibidas |
| `DashboardPurchases` | Historial de compras recientes |

### 4.3 Gestión de Cursos

#### Estados del Curso
| Estado | Descripción | Visible |
|--------|-------------|---------|
| `draft` | Borrador en edición | No |
| `pending` | Pendiente de aprobación | No |
| `live` | Publicado y activo | Sí |
| `archive` | Archivado | No |

#### Campos del Formulario
```dart
// Información Básica
- name: String (requerido)
- thumbnailUrl: String (imagen de portada)
- videoUrl: String? (video promocional)

// Categorización
- categoryId: String
- tagIds: List<String>

// Meta información
- meta.description: String (HTML)
- meta.summary: String
- meta.duration: String
- meta.language: String
- meta.learnings: List<String>
- meta.requirements: List<String>

// Configuración
- status: String ['draft' | 'live']
- priceStatus: String ['free' | 'premium']
- isFeatured: boolean

// Asignación
- tutorIds: List<String>
```

#### Tipos de Lección
| Tipo | Descripción | Campos Adicionales |
|------|-------------|-------------------|
| `video` | Video hospedado | `videoUrl` |
| `youtube` | Video de YouTube | `youtubeVideo` |
| `article` | Contenido HTML | `lessonBody` |
| `quiz` | Cuestionario | `questions` |
| `document` | Documento/PDF | `materials`, `pdfLinks` |
| `mixed` | Combinación | Todos los campos |

### 4.4 Gestión de Usuarios

#### Estudiantes
| Funcionalidad | Descripción |
|---------------|-------------|
| CRUD | Crear, leer, actualizar, eliminar |
| Asignar Nivel | Vincular a un nivel específico |
| Asignar Sección | Vincular a una sección |
| Generar QR | Código QR único de acceso |
| Estado de Pago | Marcar como pagado/no pagado |
| Ver Inscripciones | Cursos en los que está inscrito |

#### Tutores
| Funcionalidad | Descripción |
|---------------|-------------|
| CRUD | Crear, leer, actualizar, eliminar |
| Asignar Cursos | Vincular cursos al tutor |
| Permisos | Definir permisos específicos |
| Exportar | Exportar lista de tutores |

### 4.5 Sistema de IA (Gemini)

#### Funcionalidades de Generación
| Función | Input | Output |
|---------|-------|--------|
| `generateLessonContent()` | topic, level, language | HTML formateado |
| `generateQuiz()` | topic, questionCount, language | JSON con preguntas |
| `generateCourseDescription()` | courseName, language | Texto descriptivo |

#### Modelos con Fallback
```dart
static const List<String> _modelIds = [
  'gemini-2.0-flash-exp',
  'gemini-1.0-pro',
];
```

#### Configuración de API Key
- **Primario**: Firestore `settings/app.gemini_api_key`
- **Fallback**: `AppConfig.geminiApiKey` (hardcoded)

### 4.6 Sistema de Notificaciones

#### Arquitectura
```
Admin Panel → NotificationService → FCM API v1 → Dispositivos Móviles
```

#### Campos de Notificación
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `title` | String | Encabezado |
| `description` | String | Cuerpo del mensaje |
| `topic` | String | Canal de suscripción |

### 4.7 Categorías y Etiquetas

#### Categorías
- Nombre con imagen representativa
- Orden personalizable (drag & drop)
- Opción de destacar en home
- Asignación múltiple a cursos

#### Etiquetas (Tags)
- Etiquetas de texto simple
- Multi-asignación a cursos
- Filtrado rápido de cursos

### 4.8 Reseñas

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `courseId` | String | Curso asociado |
| `rating` | Number | Calificación 1-5 |
| `review` | String | Texto de la reseña |
| `user` | Map | Datos del usuario que reseña |
| `createdAt` | Timestamp | Fecha de creación |

### 4.9 Configuración del Sistema

| Categoría | Opciones |
|-----------|----------|
| **UI Home** | featured, topAuthors, categories, freeCourses, tags, latestCourses |
| **Onboarding** | Habilitar/deshabilitar pantalla de bienvenida |
| **Contacto** | email, website, privacyUrl |
| **Redes Sociales** | fb, youtube, twitter, instagram |
| **Publicidad** | Configuración de ads |
| **IA** | gemini_api_key |
| **Licencia** | none, regular, extended |

---

## 5. Componentes de UI

### 5.1 Design System

#### Design Tokens
```dart
class DesignTokens {
  // Espaciado
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;
  static const double space5xl = 64;

  // Touch Targets (Material Design)
  static const double minTouchTarget = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusFull = 999; // Pill

  // Animaciones
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Helpers
  static Widget get vSpaceSm => SizedBox(height: spaceSm);
  static Widget get vSpaceMd => SizedBox(height: spaceMd);
  static Widget get vSpaceLg => SizedBox(height: spaceLg);
}
```

#### Paleta de Colores
```dart
class AppConfig {
  // Primarios
  static const Color primaryColor = Color(0xFF4F46E5);  // Indigo
  static const Color accentColor = Color(0xFF8B5CF6);   // Purple

  // Semánticos
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Neutrales (reemplazan Colors.grey)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
}
```

#### Branding IDECAP (Brasil)
```dart
// Colores de la bandera de Brasil
static const Color brazilGreen = Color(0xFF009C3B);
static const Color brazilBlue = Color(0xFF002776);
static const Color brazilYellow = Color(0xFFFFDF00);
```

### 5.2 Componentes Principales

#### Botones
```dart
// Botón outlined con icono
Widget customOutlineButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  double minHeight = 48,  // Touch target
});

// Botón de submit con loading
Widget submitButton({
  required String label,
  required RoundedLoadingButtonController controller,
  required VoidCallback onPressed,
});
```

#### Loading Indicator
```dart
class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;  // small, medium, large
  final String? message;

  static Widget fullScreen({String? message});
  static Widget button();
}
```

#### Diálogos
```dart
class CustomDialogs {
  static void openResponsiveDialog(
    BuildContext context, {
    required Widget child,
    double? maxWidth,
  });

  static void openFullScreenDialog(
    BuildContext context, {
    required Widget child,
  });
}
```

#### Toasts
```dart
void openSuccessToast(String message);
void openFailureToast(String message);
void openInfoToast(String message);
```

#### Componentes Especializados
| Componente | Descripción | Ubicación |
|------------|-------------|-----------|
| `SideMenu` | Menú lateral de navegación | `components/side_menu.dart` |
| `LoadingIndicator` | Indicador de carga unificado | `components/loading_indicator.dart` |
| `CategoryDropdown` | Selector de categorías | `components/category_dropdown.dart` |
| `TagsDropdown` | Selector múltiple de etiquetas | `components/tags_dropdown.dart` |
| `QrDialog` | Diálogo para mostrar QR | `components/qr_dialog.dart` |
| `AiGeneratorDialog` | Generación con IA | `components/ai_generator_dialog.dart` |
| `HtmlEditor` | Editor de contenido HTML | `components/text_editors/html_editor.dart` |
| `CourseMaterialsManager` | Gestor de materiales | `components/course_materials/` |

---

## 6. Servicios

### 6.1 FirebaseService

```dart
class FirebaseService {
  // ═══════════════════════════════════════════════════════════════
  // USUARIOS
  // ═══════════════════════════════════════════════════════════════
  Future<UserModel?> getUserData(String uid);
  Future<void> updateUserAccess(String uid, Map<String, dynamic> data);
  Future<void> updateUserPaymentStatus(String uid, String status);
  Future<void> updateUserLevelSection(String uid, String level, String section);
  Future<void> updateUserQrHash(String uid, String hash);
  Future<int> getUsersCount();
  Future<int> getActiveStudentsCount();

  // ═══════════════════════════════════════════════════════════════
  // CURSOS
  // ═══════════════════════════════════════════════════════════════
  Future<void> saveCourse(Course course);
  Stream<QuerySnapshot> getCourses();
  Future<int> getCourseCount();

  // ═══════════════════════════════════════════════════════════════
  // JERARQUÍA DE CURSOS
  // ═══════════════════════════════════════════════════════════════
  // Niveles
  Future<List<Level>> getLevels(String courseId);
  Future<void> saveLevel(String courseId, Level level);
  Future<void> deleteLevel(String courseId, String levelId);

  // Módulos
  Future<List<Module>> getModules(String courseId, String levelId);
  Future<void> saveModule(String courseId, String levelId, Module module);
  Future<void> deleteModule(String courseId, String levelId, String moduleId);

  // Secciones
  Future<List<Section>> getSections(String courseId, String levelId, String moduleId);
  Future<void> saveSection(String courseId, String levelId, String moduleId, Section section);
  Future<void> deleteSection(String courseId, String levelId, String moduleId, String sectionId);

  // Lecciones
  Future<List<Lesson>> getLessons(String courseId, String levelId, String moduleId, String sectionId);
  Future<void> saveLesson(String courseId, String levelId, String moduleId, String sectionId, Lesson lesson);
  Future<void> deleteLesson(String courseId, String levelId, String moduleId, String sectionId, String lessonId);

  // ═══════════════════════════════════════════════════════════════
  // CATEGORÍAS Y TAGS
  // ═══════════════════════════════════════════════════════════════
  Future<void> saveCategory(Category category);
  Stream<QuerySnapshot> getCategories();
  Future<void> addCategoryToFeatured(String categoryId);
  Future<void> saveTag(Tag tag);
  Stream<QuerySnapshot> getTags();

  // ═══════════════════════════════════════════════════════════════
  // RESEÑAS Y COMPRAS
  // ═══════════════════════════════════════════════════════════════
  Stream<QuerySnapshot> getReviews();
  Future<int> getReviewsCount();
  Stream<QuerySnapshot> getPurchases();
  Future<int> getPurchasesCount();

  // ═══════════════════════════════════════════════════════════════
  // NOTIFICACIONES
  // ═══════════════════════════════════════════════════════════════
  Future<void> saveNotification(NotificationModel notification);
  Stream<QuerySnapshot> getNotifications();

  // ═══════════════════════════════════════════════════════════════
  // CONFIGURACIÓN
  // ═══════════════════════════════════════════════════════════════
  Future<AppSettings> getAppSettings();
  Future<void> updateAppSettings(Map<String, dynamic> data);

  // ═══════════════════════════════════════════════════════════════
  // MEDIA
  // ═══════════════════════════════════════════════════════════════
  Future<String?> uploadImageToFirebaseHosting(Uint8List bytes, String path);
}
```

### 6.2 AuthService

```dart
class AuthService {
  // Autenticación
  Future<User?> loginWithEmailPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> loginAnnonumously();
  Future<void> adminLogout();

  // Verificación de rol
  Future<UserRoles> checkUserRole(String uid);
  // Retorna: admin, author, guest, none
}
```

### 6.3 AiContentService

```dart
class AiContentService {
  // Configuración
  final String? _apiKey;  // De Firestore o AppConfig

  // Generación de contenido
  Future<String?> generateLessonContent({
    required String topic,
    required String level,      // 'básico' | 'intermedio' | 'avanzado'
    required String language,   // 'español' | 'portugués'
  });
  // Retorna: HTML formateado con el contenido de la lección

  Future<List<Question>?> generateQuiz({
    required String topic,
    required int questionCount,
    required String language,
  });
  // Retorna: Lista de preguntas con opciones y respuesta correcta

  Future<String?> generateCourseDescription({
    required String courseName,
    required String language,
  });
  // Retorna: Descripción atractiva del curso
}
```

### 6.4 NotificationService

```dart
class NotificationService {
  Future<bool> sendCustomNotificationByTopic({
    required String title,
    required String description,
    required String topic,
  });
  // Envía notificación via FCM API v1
  // Autenticación con Service Account de Firebase
}
```

### 6.5 QrGeneratorService

```dart
class QrGeneratorService {
  static String generateQrCode(String studentId);
  // Genera hash único para el estudiante

  static bool validateQrCode(String hash, String studentId);
  // Valida si el QR corresponde al estudiante
}
```

---

## 7. Providers (Estado)

### 7.1 Providers Principales

```dart
// ═══════════════════════════════════════════════════════════════
// AUTENTICACIÓN
// ═══════════════════════════════════════════════════════════════
enum UserRoles { admin, author, guest, none }

final userRoleProvider = StateProvider<UserRoles>((ref) => UserRoles.none);

// ═══════════════════════════════════════════════════════════════
// USUARIO ACTUAL
// ═══════════════════════════════════════════════════════════════
final userDataProvider = StateNotifierProvider<UserData, UserModel?>((ref) {
  return UserData();
});

class UserData extends StateNotifier<UserModel?> {
  UserData() : super(null);

  Future<void> getData() async {
    final user = await FirebaseService().getUserData(uid);
    state = user;
  }
}

// ═══════════════════════════════════════════════════════════════
// CATEGORÍAS
// ═══════════════════════════════════════════════════════════════
final categoriesProvider = StateNotifierProvider<CategoryData, List<Category>>((ref) {
  return CategoryData();
});

class CategoryData extends StateNotifier<List<Category>> {
  CategoryData() : super([]);

  Future<void> getCategories() async {
    // Obtiene categorías de Firestore
  }
}

// ═══════════════════════════════════════════════════════════════
// NAVEGACIÓN
// ═══════════════════════════════════════════════════════════════
final pageControllerProvider = StateProvider<PageController>((ref) {
  return PageController();
});

final menuIndexProvider = StateProvider<int>((ref) => 0);

// ═══════════════════════════════════════════════════════════════
// TEMA
// ═══════════════════════════════════════════════════════════════
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
```

### 7.2 Providers del Dashboard

```dart
final usersCountProvider = FutureProvider<int>((ref) async {
  return await FirebaseService().getUsersCount();
});

final activeStudentsCountProvider = FutureProvider<int>((ref) async {
  return await FirebaseService().getActiveStudentsCount();
});

final coursesCountProvider = FutureProvider<int>((ref) async {
  return await FirebaseService().getCourseCount();
});

final purchasesCountProvider = FutureProvider<int>((ref) async {
  return await FirebaseService().getPurchasesCount();
});

final reviewsCountProvider = FutureProvider<int>((ref) async {
  return await FirebaseService().getReviewsCount();
});
```

### 7.3 Providers de Query

```dart
final courseQueryProvider = StateProvider<Query>((ref) {
  return FirebaseFirestore.instance
      .collection('courses')
      .orderBy('created_at', descending: true);
});

final usersQueryProvider = StateProvider<Query>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('created_at', descending: true);
});

final purchasesQueryProvider = StateProvider<Query>((ref) {
  return FirebaseFirestore.instance
      .collection('purchases')
      .orderBy('purchase_at', descending: true);
});

// Estado de UI
final isSectionExpandedProvider = StateProvider<Map<String, bool>>((ref) => {});
```

---

## 8. Flujos de Usuario

### 8.1 Flujo de Creación de Curso

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CREACIÓN DE CURSO                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Admin navega a "Cursos"                                         │
│           │                                                          │
│           ▼                                                          │
│  2. Click en "Crear Curso"                                          │
│           │                                                          │
│           ▼                                                          │
│  3. Completa formulario:                                            │
│     ├── Nombre del curso                                            │
│     ├── Imagen de portada (thumbnail)                               │
│     ├── Video promocional (opcional)                                │
│     ├── Selecciona categoría                                        │
│     ├── Selecciona etiquetas                                        │
│     ├── Descripción (editor HTML)                                   │
│     ├── Resumen                                                     │
│     ├── Idioma                                                      │
│     ├── Duración                                                    │
│     ├── Objetivos de aprendizaje                                    │
│     ├── Requisitos                                                  │
│     ├── Precio (free/premium)                                       │
│     └── Asigna tutores                                              │
│           │                                                          │
│           ▼                                                          │
│  4. Guarda como borrador (draft)                                    │
│           │                                                          │
│           ▼                                                          │
│  5. Navega a "Jerarquía"                                            │
│           │                                                          │
│           ▼                                                          │
│  6. Selecciona el curso creado                                      │
│           │                                                          │
│           ▼                                                          │
│  7. Agrega estructura:                                              │
│     ├── Nivel 1 (ej: "Nivel Básico")                               │
│     │   └── Módulo 1.1                                              │
│     │       └── Sección 1.1.1                                       │
│     │           ├── Lección 1                                       │
│     │           ├── Lección 2                                       │
│     │           └── Lección N                                       │
│     ├── Nivel 2 (ej: "Nivel Intermedio")                           │
│     └── Nivel 3 (ej: "Nivel Avanzado")                             │
│           │                                                          │
│           ▼                                                          │
│  8. Para cada lección:                                              │
│     ├── Define tipo (video/article/quiz/mixed)                      │
│     ├── Agrega contenido (URL video, HTML, etc.)                    │
│     └── Opcionalmente usa IA para generar contenido                 │
│           │                                                          │
│           ▼                                                          │
│  9. Publica el curso (status: 'live')                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.2 Flujo de Registro de Estudiante

```
┌─────────────────────────────────────────────────────────────────────┐
│                       REGISTRO DE ESTUDIANTE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Admin navega a "Estudiantes"                                    │
│           │                                                          │
│           ▼                                                          │
│  2. Click en "Agregar Estudiante"                                   │
│           │                                                          │
│           ▼                                                          │
│  3. Completa formulario:                                            │
│     ├── Nombre                                                      │
│     ├── Email                                                       │
│     ├── Imagen de perfil (opcional)                                 │
│     ├── Asigna nivel                                                │
│     ├── Asigna sección                                              │
│     └── Define estado de pago (paid/unpaid)                         │
│           │                                                          │
│           ▼                                                          │
│  4. Sistema genera código QR automáticamente                        │
│     └── Hash único: qr_code_hash = hash(userId + email)            │
│           │                                                          │
│           ▼                                                          │
│  5. Guarda estudiante en Firestore                                  │
│           │                                                          │
│           ▼                                                          │
│  6. Estudiante puede acceder a app móvil con:                       │
│     ├── QR Code                                                     │
│     └── Email/Contraseña                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.3 Flujo de Generación con IA

```
┌─────────────────────────────────────────────────────────────────────┐
│                      GENERACIÓN CON IA (GEMINI)                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Admin edita una Lección                                         │
│           │                                                          │
│           ▼                                                          │
│  2. Click en "Generar con IA"                                       │
│           │                                                          │
│           ▼                                                          │
│  3. Abre AiGeneratorDialog                                          │
│           │                                                          │
│           ▼                                                          │
│  4. Completa parámetros:                                            │
│     ├── Tema de la lección                                          │
│     ├── Nivel de dificultad (básico/intermedio/avanzado)           │
│     └── Idioma (Portugués/Español)                                  │
│           │                                                          │
│           ▼                                                          │
│  5. Click en "Generar"                                              │
│           │                                                          │
│           ▼                                                          │
│  6. AiContentService llama a Gemini API                             │
│     ├── Intenta con gemini-2.0-flash-exp                           │
│     └── Fallback a gemini-1.0-pro si falla                         │
│           │                                                          │
│           ▼                                                          │
│  7. Recibe contenido HTML formateado                                │
│           │                                                          │
│           ▼                                                          │
│  8. Admin revisa y edita si es necesario                            │
│           │                                                          │
│           ▼                                                          │
│  9. Guarda la lección                                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 9. Integraciones Externas

### 9.1 Firebase

| Servicio | Uso | Configuración |
|----------|-----|---------------|
| **Authentication** | Login email/password, Google OAuth | `firebase_options.dart` |
| **Firestore** | Base de datos NoSQL principal | Reglas en `firestore.rules` |
| **Storage** | Almacenamiento de imágenes/archivos | Reglas en `storage.rules` |
| **Hosting** | Despliegue de la app web | `firebase.json` |
| **Cloud Messaging** | Notificaciones push | Service Account |

### 9.2 Google Gemini AI

| Aspecto | Detalle |
|---------|---------|
| **Endpoint** | `generativelanguage.googleapis.com` |
| **Modelos** | `gemini-2.0-flash-exp`, `gemini-1.0-pro` |
| **SDK** | `google_generative_ai: 0.4.7` |
| **API Key** | Almacenada en Firestore `settings/app.gemini_api_key` |

### 9.3 FCM (Firebase Cloud Messaging)

| Aspecto | Detalle |
|---------|---------|
| **API Version** | v1 |
| **Auth** | Service Account (OAuth2) |
| **Método** | Envío por tópicos (topics) |
| **Endpoint** | `fcm.googleapis.com/v1/projects/{project}/messages:send` |

---

## 10. Seguridad

### 10.1 Autenticación

| Mecanismo | Descripción |
|-----------|-------------|
| Firebase Auth | Gestión de usuarios y tokens JWT |
| Google OAuth | Autenticación social |
| Sesión persistente | Tokens con refresh automático |
| Verificación de rol | Validación en cada acceso |

### 10.2 Autorización

```dart
// Verificación de rol en login
Future<UserRoles> checkUserRole(String uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final roles = doc.data()?['role'] as List?;

  if (roles?.contains('admin') == true) return UserRoles.admin;
  if (roles?.contains('author') == true) return UserRoles.author;
  return UserRoles.none;
}
```

### 10.3 Reglas de Firestore (Ejemplo)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios autenticados pueden leer
    match /{document=**} {
      allow read: if request.auth != null;
    }

    // Solo admin puede escribir en configuración
    match /settings/{doc} {
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role.hasAny(['admin']);
    }

    // Estudiantes solo pueden leer sus propios datos
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role.hasAny(['admin']);
    }
  }
}
```

---

## 11. Despliegue

### 11.1 Comandos de Build

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run -d chrome

# Build de producción
flutter build web --release

# Desplegar a Firebase Hosting
firebase deploy --only hosting
```

### 11.2 Configuración de Firebase Hosting

```json
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### 11.3 Variables de Entorno

| Variable | Descripción | Ubicación |
|----------|-------------|-----------|
| `GEMINI_API_KEY` | API Key de Gemini | Firestore `settings/app` |
| `FIREBASE_PROJECT_ID` | ID del proyecto | `firebase_options.dart` |
| `FCM_SERVICE_ACCOUNT` | Credenciales FCM | Service Account JSON |

### 11.4 URL de Producción

- **Web**: `https://apololms.web.app`

---

## 12. Roadmap

### Versión 2.0 (Actual) ✅
- [x] Panel de administración completo
- [x] Gestión de cursos con estructura jerárquica (5 niveles)
- [x] Gestión de estudiantes con QR
- [x] Gestión de tutores
- [x] Gestión de categorías y etiquetas
- [x] Dashboard con estadísticas
- [x] Notificaciones push (FCM)
- [x] Generación de contenido con IA (Gemini)
- [x] Autenticación Google
- [x] Tema claro/oscuro
- [x] Design system con tokens

### Versión 2.1 (Próximo) 🔄
- [ ] Exportación de reportes a Excel/CSV
- [ ] Búsqueda avanzada con filtros
- [ ] Chat en tiempo real con estudiantes
- [ ] Integración con más plataformas de pago
- [ ] PWA con service workers

### Versión 3.0 (Futuro) ⏳
- [ ] Sistema de gamificación
- [ ] Certificados automáticos
- [ ] Foros de discusión
- [ ] Videoconferencias integradas
- [ ] Analytics avanzado

---

## Apéndice: Glosario

| Término | Definición |
|---------|------------|
| **Level** | Primer nivel de jerarquía (ej: A1, A2, B1) |
| **Module** | Agrupación de secciones dentro de un nivel |
| **Section** | Agrupación de lecciones dentro de un módulo |
| **Lesson** | Unidad mínima de contenido educativo |
| **Tutor** | Usuario con permisos para gestionar cursos asignados |
| **Author** | Usuario creador de contenido (requiere licencia) |
| **QR Hash** | Código único para verificar acceso de estudiante |
| **FCM** | Firebase Cloud Messaging (notificaciones) |
| **Gemini** | Modelo de IA de Google para generación de contenido |

---

*Documento generado para ApoloLMS Admin Panel - IDECAP Idiomas*
*Última actualización: 30 de Enero de 2026*
