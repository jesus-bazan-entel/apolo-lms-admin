import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/course.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/services/portuguese_data_loader.dart';
import 'package:lms_admin/forms/course_structure_uploader_dialog.dart';
import 'package:lms_admin/tabs/admin_tabs/hierarchy/hierarchy_view.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class CourseHierarchyTab extends ConsumerStatefulWidget {
  const CourseHierarchyTab({Key? key}) : super(key: key);

  @override
  ConsumerState<CourseHierarchyTab> createState() => _CourseHierarchyTabState();
}

class _CourseHierarchyTabState extends ConsumerState<CourseHierarchyTab> {
  String? _selectedCourseId;
  Course? _selectedCourse;
  late Future<List<Course>> _coursesFuture;
  final RoundedLoadingButtonController _loadDataController = RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _coursesFuture = FirebaseService().getAllCourses();
  }

  Future<void> _showUploadStructureDialog() async {
    if (_selectedCourse == null || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un curso primero'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadDataController.reset();
      return;
    }
    
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CourseStructureUploaderDialog(
          courseId: _selectedCourseId!,
          courseName: _selectedCourse!.name,
        ),
      );
      
      _loadDataController.success();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Estructura del curso cargada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _loadDataController.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    Future.delayed(const Duration(seconds: 2), () {
      _loadDataController.reset();
    });
  }

  Future<void> _loadPortugueseData() async {
    debugPrint('🚀 Iniciando carga de datos de Portugués...');
    
    try {
      // Buscar si existe un curso de Portugués
      final courses = await _coursesFuture;
      debugPrint('📚 Cursos encontrados: ${courses.length}');
      
      final portugueseCourse = courses.firstWhere(
        (c) {
          debugPrint('Verificando curso: ${c.name}');
          return c.name.toLowerCase().contains('portugués') || 
                 c.name.toLowerCase().contains('portugues');
        },
        orElse: () => throw Exception('No se encontró el curso de Portugués. Por favor créalo primero.'),
      );

      debugPrint('✓ Curso encontrado: ${portugueseCourse.name} (ID: ${portugueseCourse.id})');
      
      final loader = PortugueseDataLoader();
      
      // Mostrar diálogo de progreso
      if (mounted) {
        final progressMessages = <String>[];
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                loader.progressStream.listen((message) {
                  setDialogState(() {
                    progressMessages.add(message);
                  });
                });
                
                return AlertDialog(
                  title: const Text('Cargando Datos de Portugués'),
                  content: SizedBox(
                    width: 500,
                    height: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LinearProgressIndicator(),
                        const SizedBox(height: 20),
                        const Text(
                          'Progreso:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: SingleChildScrollView(
                              child: Text(
                                progressMessages.join('\n'),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }
      
      // Cargar datos
      await loader.loadAllData(portugueseCourse.id!);

      // Cerrar diálogo
      if (mounted) {
        Navigator.pop(context);
      }
      
      _loadDataController.success();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Datos de Portugués cargados exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refrescar vista
        setState(() {
          _coursesFuture = FirebaseService().getAllCourses();
        });
      }
      
      debugPrint('✅ Proceso completado exitosamente');
    } catch (e, stackTrace) {
      debugPrint('❌ Error al cargar datos: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Cerrar diálogo si está abierto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      _loadDataController.error();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _loadDataController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: _selectedCourseId == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBarMixin.buildTitleBar(
                  context,
                  title: 'Estructura de Cursos',
                  buttons: [
                    CustomButtons.submitButton(
                      context,
                      buttonController: _loadDataController,
                      text: 'Subir Estructura',
                      onPressed: _showUploadStructureDialog,
                      width: 180,
                      bgColor: Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    CustomButtons.circleButton(
                      context,
                      icon: Icons.add,
                      bgColor: Theme.of(context).primaryColor,
                      iconColor: Colors.white,
                      radius: 22,
                      onPressed: () {
                        // Navegar a creación de curso
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<Course>>(
                    future: _coursesFuture,
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
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
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
                                setState(() {
                                  _selectedCourseId = course.id;
                                  _selectedCourse = course;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 120),
                                    Text(
                                      course.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
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
                                        'Configurar',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              children: [
                AppBarMixin.buildTitleBar(
                  context,
                  title: 'Estructura: ${_selectedCourse?.name}',
                  buttons: [
                    CustomButtons.circleButton(
                      context,
                      icon: Icons.arrow_back,
                      bgColor: Theme.of(context).primaryColor,
                      iconColor: Colors.white,
                      radius: 22,
                      onPressed: () {
                        setState(() {
                          _selectedCourseId = null;
                          _selectedCourse = null;
                        });
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: HierarchyView(
                    key: ValueKey(_selectedCourseId),
                    courseId: _selectedCourseId!,
                    courseName: _selectedCourse!.name,
                  ),
                ),
              ],
            ),
    );
  }
}
