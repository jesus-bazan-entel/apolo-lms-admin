import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/models/lesson.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:lms_admin/forms/lesson_editor_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModulesTab extends ConsumerStatefulWidget {
  final String courseId;
  final String levelId;
  final String levelName;

  const ModulesTab({
    Key? key,
    required this.courseId,
    required this.levelId,
    required this.levelName,
  }) : super(key: key);

  @override
  ConsumerState<ModulesTab> createState() => _ModulesTabState();
}

class _ModulesTabState extends ConsumerState<ModulesTab> {
  late Future<List<Module>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _modulesFuture = FirebaseService().getModules(widget.levelId, courseId: widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBarMixin.buildTitleBar(
            context,
            title: 'Módulos - ${widget.levelName}',
            buttons: [
              CustomButtons.circleButton(
                context,
                icon: Icons.add,
                bgColor: Theme.of(context).primaryColor,
                iconColor: Colors.white,
                radius: 22,
                onPressed: () => _showModuleDialog(context, null),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Module>>(
              future: _modulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay módulos en este nivel'),
                  );
                }

                final modules = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return ModuleTreeItem(
                      module: module,
                      courseId: widget.courseId,
                      levelId: widget.levelId,
                      onEdit: () => _showModuleDialog(context, module),
                      onDelete: () => _deleteModule(module.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showModuleDialog(BuildContext context, Module? module) {
    final nameCtlr = TextEditingController(text: module?.name ?? '');
    final descCtlr = TextEditingController(text: module?.description ?? '');
    final classesCtlr = TextEditingController(text: module?.totalClasses.toString() ?? '16');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module == null ? 'Crear Módulo' : 'Editar Módulo'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtlr,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtlr,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: classesCtlr,
                decoration: const InputDecoration(labelText: 'Total de Clases'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newModule = Module(
                  id: module?.id ?? FirebaseService.getUID('modules'),
                  courseId: widget.courseId,
                  levelId: widget.levelId,
                  name: nameCtlr.text,
                  description: descCtlr.text,
                  order: module?.order ?? 0,
                  totalClasses: int.parse(classesCtlr.text),
                  createdAt: module?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await FirebaseService().saveModule(
                  widget.courseId,
                  widget.levelId,
                  newModule,
                );

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  _modulesFuture = FirebaseService().getModules(widget.levelId, courseId: widget.courseId);
                });
                openSuccessToast(context, 'Módulo guardado exitosamente');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteModule(String moduleId) async {
    await FirebaseService().deleteModule(widget.courseId, widget.levelId, moduleId);
    setState(() {
      _modulesFuture = FirebaseService().getModules(widget.levelId, courseId: widget.courseId);
    });
    openSuccessToast(context, 'Módulo eliminado');
  }

  void _showLessonsDialog(BuildContext context, Module module) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 800,
            height: 600,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lecciones de ${module.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${module.totalClasses} lecciones',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Lesson>>(
                    future: _getLessons(module),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No hay lecciones en este módulo'),
                        );
                      }

                      final lessons = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  '${lesson.order}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                lesson.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    lesson.contentType ?? 'Sin tipo',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (lesson.description?.isNotEmpty == true)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        lesson.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lesson.videoUrl?.isNotEmpty == true)
                                    const Icon(Icons.video_library, size: 18, color: Colors.blue),
                                  if (lesson.pdfLinks?.isNotEmpty == true)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _editLesson(context, lesson, module);
                                    },
                                    tooltip: 'Editar lección',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Lesson>> _getLessons(Module module) async {
    // Buscar la sección del módulo
    final sectionsSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('levels')
        .doc(widget.levelId)
        .collection('modules')
        .doc(module.id)
        .collection('sections')
        .get();

    if (sectionsSnapshot.docs.isEmpty) {
      return [];
    }

    // Tomar la primera sección (asumiendo que hay una sección por defecto)
    final sectionId = sectionsSnapshot.docs.first.id;

    // Obtener lecciones
    final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('levels')
        .doc(widget.levelId)
        .collection('modules')
        .doc(module.id)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .orderBy('order')
        .get();

    return lessonsSnapshot.docs.map((doc) => Lesson.fromFiresore(doc)).toList();
  }

  void _editLesson(BuildContext context, Lesson lesson, Module module) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LessonEditorDialog(
          lesson: lesson,
          module: module,
          courseId: widget.courseId,
          levelId: widget.levelId,
        );
      },
    ).then((result) {
      // Si se guardaron cambios, mostrar el diálogo de lecciones actualizado
      if (result == true) {
        // Refresh handled by callback
      }
    });
  }
}

class ModuleTreeItem extends StatefulWidget {
  final Module module;
  final String courseId;
  final String levelId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModuleTreeItem({
    Key? key,
    required this.module,
    required this.courseId,
    required this.levelId,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ModuleTreeItem> createState() => _ModuleTreeItemState();
}

class _ModuleTreeItemState extends State<ModuleTreeItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isLoadingLessons = false;
  List<Lesson>? _lessons;
  String? _sectionId;

  Future<void> _fetchLessons() async {
    if (_lessons != null) return; 

    setState(() => _isLoadingLessons = true);
    
    try {
      final sectionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('levels')
          .doc(widget.levelId)
          .collection('modules')
          .doc(widget.module.id)
          .collection('sections')
          .get();

      if (sectionsSnapshot.docs.isEmpty) {
        // Create a default section if none exists? 
        // For now just return empty, but creation logic should probably handle this.
        if (mounted) setState(() => _lessons = []);
        return;
      }

      final sectionId = sectionsSnapshot.docs.first.id;
      _sectionId = sectionId;

      final lessonsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('levels')
          .doc(widget.levelId)
          .collection('modules')
          .doc(widget.module.id)
          .collection('sections')
          .doc(sectionId)
          .collection('lessons')
          .orderBy('order')
          .get();

      if (mounted) {
        setState(() {
          _lessons = lessonsSnapshot.docs
              .map((doc) => Lesson.fromFiresore(doc))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLessons = false);
    }
  }

  void _editLesson(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => LessonEditorDialog(
        lesson: lesson,
        module: widget.module,
        courseId: widget.courseId,
        levelId: widget.levelId,
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _lessons = null; 
        });
        _fetchLessons();
      }
    });
  }

  void _createNewLesson() {
    if (_sectionId == null) {
        // If we don't have a section ID (e.g. no lessons yet and init failed), we might need to create one.
        // For now, simple fallback or alert.
        return;
    }
    
    final newId = FirebaseFirestore.instance.collection('tmp').doc().id;
    final newLesson = Lesson(
      id: newId,
      name: '',
      order: (_lessons?.length ?? 0) + 1,
      contentType: 'video',
      courseId: widget.courseId,
      levelId: widget.levelId,
      moduleId: widget.module.id,
      sectionId: _sectionId,
      description: '',
      videoUrl: '',
      pdfLinks: [],
      questions: []
    );
    
    _editLesson(newLesson);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Module Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConfig.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.view_module_rounded, color: AppConfig.themeColor),
            ),
            title: Text(
              widget.module.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.video_library_outlined, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.module.totalClasses} lecciones',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isExpanded ? Colors.grey : AppConfig.themeColor,
                    side: BorderSide(
                      color: _isExpanded 
                        ? Colors.grey.withOpacity(0.3) 
                        : AppConfig.themeColor.withOpacity(0.3)
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.visibility_outlined, 
                    size: 18
                  ),
                  label: Text(_isExpanded ? 'Ocultar' : 'Lecciones'),
                  onPressed: () {
                    setState(() => _isExpanded = !_isExpanded);
                    if (_isExpanded) _fetchLessons();
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.grey.shade600,
                  tooltip: 'Editar Módulo',
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  tooltip: 'Eliminar Módulo',
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
          
          // Lessons List
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _isLoadingLessons 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CONTENIDO DEL MÓDULO',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade400,
                                letterSpacing: 1,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _createNewLesson,
                              icon: const Icon(Icons.add_circle_outline, size: 16),
                              label: const Text('Nueva Lección'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppConfig.themeColor,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_lessons == null || _lessons!.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No hay lecciones en este módulo',
                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ..._lessons!.map((lesson) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppConfig.themeColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${lesson.order}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppConfig.themeColor,
                                  ),
                                ),
                              ),
                              title: Text(
                                lesson.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              subtitle: lesson.contentType != null 
                                ? Text(
                                    lesson.contentType!,
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                                  ) 
                                : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   if (lesson.videoUrl?.isNotEmpty == true)
                                    Tooltip(
                                      message: 'Video',
                                      child: Icon(Icons.play_circle_outline, size: 18, color: Colors.blue.shade400),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    color: Colors.grey.shade500,
                                    onPressed: () => _editLesson(lesson),
                                    tooltip: 'Editar Lección',
                                  ),
                                ],
                              ),
                            ),
                          )).toList(),
                      ],
                    ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
