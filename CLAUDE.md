# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ApoloLMS is a Flutter web admin panel for IDECAP Idiomas, a language learning institute. It manages courses, students, and educational content with a hierarchical structure. The app is Spanish-localized.

## Build and Run Commands

```bash
# Install dependencies
flutter pub get

# Run in development (web)
flutter run -d chrome

# Build for production
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Run all tests (if configured)
flutter test
```

## Architecture

### State Management
- Uses **Riverpod** for state management
- Providers are in `lib/providers/`
- Main providers: `userDataProvider`, `categoriesProvider`, `authStateProvider`

### Data Flow
```
Pages/Tabs → Providers → Services → Firebase
```

### Hierarchical Course Structure
Courses follow a 5-level hierarchy stored in Firestore subcollections:
```
Course → Level → Module → Section → Lesson
```

Path: `courses/{courseId}/levels/{levelId}/modules/{moduleId}/sections/{sectionId}/lessons/{lessonId}`

### Key Directories
- `lib/pages/` - Main screens (login, home, splash)
- `lib/tabs/` - Tab views split by role (`admin_tabs/`, `author_tabs/`)
- `lib/services/` - Firebase, Auth, AI, Notification services
- `lib/models/` - Data models with `fromFirestore`/`getMap` pattern
- `lib/mixins/` - Shared widget logic for forms and UI
- `lib/components/` - Reusable UI components
- `lib/configs/` - App configuration, constants, theme

### Role-Based Access
Two user roles access this admin panel:
- **Admin**: Full access to all tabs
- **Author**: Limited to dashboard, courses, and reviews

Role-based tabs are defined in `lib/pages/home.dart`.

## Firebase Structure

### Main Collections
- `users` - User profiles with roles, enrollment, payment status
- `courses` - Course metadata with nested subcollections for hierarchy
- `categories`, `tags` - Course organization
- `reviews`, `purchases`, `notifications` - User activity
- `settings/app` - App configuration including Gemini API key

### Course Hierarchy Pattern
Use `FirebaseService` methods for hierarchy operations:
- `getLevels(courseId)`, `saveLevel(courseId, level)`
- `getModules(levelId, courseId)`, `saveModule(courseId, levelId, module)`
- Standard `saveSection`, `saveLesson` for deeper levels

## External Services

### Gemini AI Integration
- Service: `lib/services/ai_content_service.dart`
- Used for generating lesson content, quizzes, course descriptions
- API key stored in Firestore `settings/app.gemini_api_key` (preferred) or `AppConfig.geminiApiKey` (fallback)

### Firebase Services
- Authentication: Email/password and Google Sign-In
- Firestore: Main database
- Storage: Images and files
- Hosting: Web deployment at apololms.web.app

## Key Patterns

### Model Pattern
All models follow this structure:
```dart
class Model {
  final String id;
  // fields...

  factory Model.fromFirestore(DocumentSnapshot doc) { ... }
  static Map<String, dynamic> getMap(Model model) { ... }
}
```

### Mixin Pattern
UI logic is shared via mixins in `lib/mixins/`:
- `UserMixin` - User-related widgets
- `CourseMixin` - Course form fields
- `LessonsMixin`, `SectionsMixin` - Content management

## Design System

### Design Tokens (`lib/configs/design_tokens.dart`)
Centralized design tokens for consistent UI:
- **Spacing**: `spaceXs` (4) to `space5xl` (64) - use `DesignTokens.vSpaceMd` for vertical spacing
- **Touch Targets**: `minTouchTarget` = 48px (Material Design standard)
- **Border Radius**: `radiusSm` (8) to `radiusFull` (pill)
- **Animation**: `animFast` (150ms) to `animSlow` (350ms)

### Theme (`lib/configs/app_theme.dart`)
- Light and Dark themes with Material 3
- Use `Theme.of(context).colorScheme` for colors, not hardcoded `Colors.grey`
- Theme provider at `lib/providers/theme_provider.dart`

### Color Palette (`lib/configs/app_config.dart`)
- Primary: Indigo `#4F46E5`
- Accent: Purple `#8B5CF6`
- Semantic: `successColor`, `warningColor`, `errorColor`, `infoColor`
- Neutrals: `neutral50` to `neutral900` (replaces `Colors.grey`)

### UI Components
- `CustomButtons` - Accessible buttons with 48px touch targets
- `LoadingIndicator` - Unified loading states (loading, error, empty)
- Use `openSuccessToast()`, `openFailureToast()` for notifications

## Constants

Constants and enums are in `lib/configs/constants.dart`:
- `courseStatus`: draft, pending, live, archive
- `lessonTypes`: video, article, quiz
- `priceStatus`: free, premium
- Menu items and sort options

## Localization

The app is fully Spanish-localized. UI strings are in Spanish. When adding features, maintain Spanish text for user-facing content.
