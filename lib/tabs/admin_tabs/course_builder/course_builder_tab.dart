import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/course.dart';
import 'package:lms_admin/services/course_structure_parser.dart';
import 'package:lms_admin/services/firebase_service.dart';

/// Estado del constructor de cursos
class CourseBuilderState {
  final bool isLoading;
  final bool isParsing;
  final bool isUploading;
  final String? selectedCourseId;
  final Course? selectedCourse;
  final ParsedCourseStructure? parsedStructure;
  final List<String> progressMessages;
  final String? errorMessage;

  CourseBuilderState({
    this.isLoading = false,
    this.isParsing = false,
    this.isUploading = false,
    this.selectedCourseId,
    this.selectedCourse,
    this.parsedStructure,
    this.progressMessages = const [],
    this.errorMessage,
  });

  CourseBuilderState copyWith({
    bool? isLoading,
    bool? isParsing,
    bool? isUploading,
    String? selectedCourseId,
    Course? selectedCourse,
    ParsedCourseStructure? parsedStructure,
    List<String>? progressMessages,
    String? errorMessage,
  }) {
    return CourseBuilderState(
      isLoading: isLoading ?? this.isLoading,
      isParsing: isParsing ?? this.isParsing,
      isUploading: isUploading ?? this.isUploading,
      selectedCourseId: selectedCourseId ?? this.selectedCourseId,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      parsedStructure: parsedStructure ?? this.parsedStructure,
      progressMessages: progressMessages ?? this.progressMessages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Provider para el estado del constructor de cursos
final courseBuilderProvider = StateNotifierProvider<CourseBuilderNotifier, CourseBuilderState>((ref) {
  return CourseBuilderNotifier();
});

/// Notifier para gestionar el estado del constructor de cursos
class CourseBuilderNotifier extends StateNotifier<CourseBuilderState> {
  CourseBuilderNotifier() : super(CourseBuilderState());

  Future<void> loadCourses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final courses = await FirebaseService().getAllCourses();
      // Los cursos se cargarán en el widget
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar cursos: $e',
      );
    }
  }

  void selectCourse(Course course) {
    state = state.copyWith(
      selectedCourseId: course.id,
      selectedCourse: course,
      parsedStructure: null,
      progressMessages: [],
      errorMessage: null,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedCourseId: null,
      selectedCourse: null,
      parsedStructure: null,
      progressMessages: [],
      errorMessage: null,
    );
  }

  Future<void> parseText(String text) async {
    state = state.copyWith(
      isParsing: true,
      parsedStructure: null,
      progressMessages: [],
      errorMessage: null,
    );

    try {
      final parser = CourseStructureParser();
      
      // Escuchar progreso
      parser.progressStream.listen((message) {
        state = state.copyWith(
          progressMessages: [...state.progressMessages, message],
        );
      });

      final structure = await parser.parseText(text);
      
      if (structure != null) {
        state = state.copyWith(
          isParsing: false,
          parsedStructure: structure,
        );
      } else {
        state = state.copyWith(
          isParsing: false,
          errorMessage: 'No se pudo parsear el texto',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isParsing: false,
        errorMessage: 'Error al parsear texto: $e',
      );
    }
  }

  Future<void> uploadStructure() async {
    if (state.selectedCourseId == null || state.parsedStructure == null) {
      state = state.copyWith(
        errorMessage: 'Selecciona un curso y parsea un documento primero',
      );
      return;
    }

    state = state.copyWith(
      isUploading: true,
      progressMessages: [],
      errorMessage: null,
    );

    try {
      final parser = CourseStructureParser();
      
      // Escuchar progreso
      parser.progressStream.listen((message) {
        state = state.copyWith(
          progressMessages: [...state.progressMessages, message],
        );
      });

      await parser.loadStructureToFirestore(
        state.selectedCourseId!,
        state.parsedStructure!,
      );

      state = state.copyWith(
        isUploading: false,
        parsedStructure: null,
        progressMessages: [],
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Error al cargar estructura: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Pestaña del Constructor de Cursos
class CourseBuilderTab extends ConsumerStatefulWidget {
  const CourseBuilderTab({Key? key}) : super(key: key);

  @override
  ConsumerState<CourseBuilderTab> createState() => _CourseBuilderTabState();
}

class _CourseBuilderTabState extends ConsumerState<CourseBuilderTab> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(courseBuilderProvider.notifier).loadCourses();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, ingresa el contenido del curso')),
        );
      }
      return;
    }

    await ref.read(courseBuilderProvider.notifier).parseText(text);
    
    final state = ref.read(courseBuilderProvider);
    if (state.parsedStructure != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Contenido parseado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${state.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadStructure() async {
    await ref.read(courseBuilderProvider.notifier).uploadStructure();
    
    final state = ref.read(courseBuilderProvider);
    if (state.errorMessage == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Estructura cargada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${state.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final builderState = ref.watch(courseBuilderProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(context, builderState),
          Expanded(
            child: _buildContent(context, builderState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CourseBuilderState state) {
    return AppBarMixin.buildTitleBar(
      context,
      title: 'Constructor de Cursos',
      buttons: [
        if (state.selectedCourseId != null && state.parsedStructure != null)
          ElevatedButton(
            onPressed: _uploadStructure,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(180, 40),
            ),
            child: const Text('Cargar Estructura'),
          ),
        const SizedBox(width: 10),
        if (state.selectedCourseId != null)
          CustomButtons.circleButton(
            context,
            icon: Icons.arrow_back,
            bgColor: Theme.of(context).primaryColor,
            iconColor: Colors.white,
            radius: 22,
            onPressed: () {
              ref.read(courseBuilderProvider.notifier).clearSelection();
              _textController.clear();
            },
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CourseBuilderState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.selectedCourseId == null) {
      return _buildCourseSelection(context);
    }

    if (state.parsedStructure == null) {
      return _buildTextInput(context, state);
    }

    return _buildStructurePreview(context, state);
  }

  Widget _buildCourseSelection(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: FirebaseService().getAllCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay cursos disponibles'),
          );
        }

        final courses = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    ref.read(courseBuilderProvider.notifier).selectCourse(course);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (course.thumbnailUrl.isNotEmpty)
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                course.thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.book, size: 50),
                                  );
                                },
                              ),
                            ),
                          )
                        else
                          const Expanded(
                            child: Center(
                              child: Icon(Icons.book, size: 50),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Seleccionar',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextInput(BuildContext context, CourseBuilderState state) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Curso seleccionado: ${state.selectedCourse?.name}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pega el contenido del curso con la estructura de niveles, módulos y lecciones',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            width: 800,
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Pega aquí el contenido del curso...\n\nEjemplo:\nNivel Básico\n\n- Módulo 1: Fundamentos del Portugués\n- Saludos y presentaciones\n- El alfabeto portugués y pronunciación básica\n\n- Módulo 2: Ampliando el Vocabulario y la Gramática\n- Verbos irregulares comunes en presente\n- Preposiciones de lugar y tiempo',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.isParsing ? null : _parseText,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.isParsing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Parsear Contenido'),
          ),
          const SizedBox(height: 24),
          _buildFormatInfo(),
        ],
      ),
    );
  }

  Widget _buildFormatInfo() {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Formato del contenido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFormatItem('Nivel Básico', 'Encabezado de nivel'),
          _buildFormatItem('- Módulo 1: Nombre', 'Encabezado de módulo'),
          _buildFormatItem('- Nombre de la lección', 'Lección individual'),
          const SizedBox(height: 8),
          Text(
            'Ejemplo: El contenido debe tener la estructura:',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Nivel Básico\n\n- Módulo 1: Fundamentos\n- Saludos y presentaciones\n- El alfabeto portugués\n\n- Módulo 2: Ampliando el Vocabulario\n- Verbos irregulares comunes en presente\n- Preposiciones de lugar y tiempo',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatItem(String format, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              format,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStructurePreview(BuildContext context, CourseBuilderState state) {
    final structure = state.parsedStructure!;
    
    return Column(
      children: [
        if (state.progressMessages.isNotEmpty)
          _buildProgressPanel(state.progressMessages),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: structure.levels.length,
            itemBuilder: (context, levelIndex) {
              final level = structure.levels[levelIndex];
              return _buildLevelCard(level);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressPanel(List<String> messages) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso de carga:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                messages.join('\n'),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(ParsedLevel level) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.layers, color: Colors.blue[700]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${level.modules.length} módulos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: level.modules.map((module) {
          return _buildModuleTile(module);
        }).toList(),
      ),
    );
  }

  Widget _buildModuleTile(ParsedModule module) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.folder, color: Colors.green[700], size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${module.lessons.length} lecciones',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: module.lessons.map((lesson) {
                return Chip(
                  label: Text(
                    '${lesson.order}. ${lesson.name}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text(
                      '${lesson.order}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}