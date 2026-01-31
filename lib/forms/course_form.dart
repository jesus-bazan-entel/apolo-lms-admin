import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_admin/components/text_editors/html_editor.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/components/category_dropdown.dart';
import 'package:lms_admin/mixins/course_mixin.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/components/dialogs.dart';
import 'package:lms_admin/utils/reponsive.dart';
import 'package:lms_admin/mixins/sections_mixin.dart';
import 'package:lms_admin/components/tags_dropdown.dart';
import 'package:lms_admin/mixins/textfields.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/models/author.dart';
import 'package:lms_admin/models/course.dart';
import 'package:lms_admin/models/course_meta.dart';
import 'package:lms_admin/models/tag.dart';
import 'package:lms_admin/tabs/admin_tabs/courses/course_preview/course_preview.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../providers/user_data_provider.dart';
import '../services/app_service.dart';
import '../services/firebase_service.dart';
import 'package:lms_admin/tabs/admin_tabs/hierarchy/hierarchy_view.dart';
import '../tabs/admin_tabs/dashboard/dashboard_providers.dart';
import 'package:lms_admin/forms/course_structure_uploader_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  List<Tag> tags = await FirebaseService().getTags();
  return tags;
});

class CourseForm extends ConsumerStatefulWidget {
  const CourseForm({Key? key, required this.course, this.isAuthorTab})
      : super(key: key);

  final Course? course;
  final bool? isAuthorTab;

  @override
  ConsumerState<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends ConsumerState<CourseForm>
    with TextFields, SectionsMixin, CourseMixin {
  var nameCtlr = TextEditingController();
  var thumbnailUrlCtlr = TextEditingController();
  var videoUrlCtlr = TextEditingController();
  var durationCtlr = TextEditingController();
  String _durationUnit = 'meses';
  final List<String> _durationUnits = ['horas', 'días', 'semanas', 'meses'];
  var summaryCtlr = TextEditingController();

  final HtmlEditorController descriptionCtlr = HtmlEditorController();

  final _publishBtnCtlr = RoundedLoadingButtonController();
  final _draftBtnCtlr = RoundedLoadingButtonController();

  var formKey = GlobalKey<FormState>();
  XFile? _selectedImage;

  String? _selectedCategoryId;
  List _selectedTagIDs = [];
  List<String> _selectedTutorIds = [];
  List<Map<String, dynamic>> _selectedTutors = [];

  late Course? _course;
  bool _structureLoaded = false;

  void _onPickImage() async {
    XFile? image = await AppService.pickImage();
    if (image != null) {
      _selectedImage = image;
      thumbnailUrlCtlr.text = image.name;
    }
  }

  Future<String?> _getImageUrl() async {
    if (_selectedImage != null) {
      final String? imageUrl = await FirebaseService()
          .uploadImageToFirebaseHosting(_selectedImage!, 'course_thumbnails');
      return imageUrl;
    } else {
      final text = thumbnailUrlCtlr.text.trim();
      return text.isNotEmpty ? text : null;
    }
  }

  void _handleSubmit() async {
    if (UserMixin.hasAccess(ref.read(userDataProvider))) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        _publishBtnCtlr.start();
        final String? imageUrl = await _getImageUrl();
        if (imageUrl != null) {
          thumbnailUrlCtlr.text = imageUrl;
          await _handleUpload(setCourseStatus(
              course: _course,
              isAuthorTab: widget.isAuthorTab,
              isDraft: false));
          ref.invalidate(coursesCountProvider);
          _publishBtnCtlr.reset();
          if (!mounted) return;
          openSuccessToast(context, '¡Publicado exitosamente!');
        } else {
          _selectedImage = null;
          thumbnailUrlCtlr.clear();
          setState(() {});
          _publishBtnCtlr.reset();
          openFailureToast(context, 'Por favor proporcione una imagen de vista previa');
        }
      } else {
        openFailureToast(context, 'Por favor complete todos los campos requeridos');
      }
    } else {
      openTestingToast(context);
    }
  }

  Future<void> _handleDraftSubmit() async {
    if (UserMixin.hasAccess(ref.read(userDataProvider))) {
      _draftBtnCtlr.start();
      final String? imageUrl = await _getImageUrl();
      thumbnailUrlCtlr.text = imageUrl ?? '';
      await _handleUpload(setCourseStatus(
          course: _course, isAuthorTab: widget.isAuthorTab, isDraft: true));
      _draftBtnCtlr.reset();
      if (!mounted) return;
      openSuccessToast(context, '¡Borrador guardado!');
    } else {
      openTestingToast(context);
    }
  }

  Future _handleUpload(String courseStatus) async {
    final String description = await descriptionCtlr.getText();
    final int lessonsCount = await _getLessonCount();
    final course = _courseData(courseStatus, description, lessonsCount);
    await FirebaseService().saveCourse(course);
    setState(() {
      _course = course;
    });
  }

  Course _courseData(
      String courseStatus, String description, int lessonsCount) {
    final String id = _course?.id ?? FirebaseService.getUID('courses');
    final createdAt = _course?.createdAt ?? DateTime.now().toUtc();
    final updatedAt = _course == null ? null : DateTime.now().toUtc();
    final String name = nameCtlr.text.isEmpty ? 'Sin título' : nameCtlr.text;
    final String thumbnail =
        thumbnailUrlCtlr.text.isEmpty ? '' : thumbnailUrlCtlr.text;
    final String? video = videoUrlCtlr.text.isEmpty ? null : videoUrlCtlr.text;
    final double rating = _course?.rating ?? 0.0;
    final int studentsCount = _course?.studentsCount ?? 0;
    final String? duration =
        durationCtlr.text.isEmpty ? null : '${durationCtlr.text} $_durationUnit';
    final String? summary = summaryCtlr.text.isEmpty ? null : summaryCtlr.text;
    final String? categoriyId = _selectedCategoryId;

    final Author? author = _authorData();

    final CourseMeta meta = CourseMeta(
      description: description,
      duration: duration,
      learnings: [],
      requirements: [],
      summary: summary,
      language: null,
    );

    final Course course = Course(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      name: name,
      categoryId: categoriyId,
      thumbnailUrl: thumbnail,
      tagIDs: _selectedTagIDs,
      videoUrl: video,
      status: courseStatus,
      author: author,
      priceStatus: 'free',
      rating: rating,
      studentsCount: studentsCount,
      courseMeta: meta,
      lessonsCount: lessonsCount,
      level: null,
      language: null,
      tutorIds: _selectedTutorIds,
      tutors: _selectedTutors,
    );

    return course;
  }

  Future<int> _getLessonCount() async {
    if (_course != null) {
      final int count =
          await FirebaseService().getLessonsCountFromCourse(_course!.id);
      return count;
    } else {
      return 0;
    }
  }

  Author? _authorData() {
    Author? author;
    final user = ref.read(userDataProvider);
    if (user != null) {
      if (_course?.author == null) {
        author = Author(id: user.id, name: user.name, imageUrl: user.imageUrl);
      } else {
        author = Author(
            id: _course!.author!.id,
            name: _course!.author!.name,
            imageUrl: _course!.author!.imageUrl);
      }
    }
    return author;
  }

  @override
  void initState() {
    if (widget.course != null) {
      _course = widget.course;
      nameCtlr.text = _course?.name ?? '';
      thumbnailUrlCtlr.text = _course?.thumbnailUrl ?? '';
      videoUrlCtlr.text = _course?.videoUrl ?? '';
      _selectedCategoryId = _course?.categoryId;
      _selectedTagIDs = _course?.tagIDs ?? [];
      _selectedTutorIds = _course?.tutorIds ?? [];
      _selectedTutors = _course?.tutors ?? [];
      final existingDuration = _course?.courseMeta.duration ?? '';
      if (existingDuration.isNotEmpty) {
        final parts = existingDuration.split(' ');
        if (parts.length >= 2) {
          durationCtlr.text = parts[0];
          final unit = parts.sublist(1).join(' ');
          if (_durationUnits.contains(unit)) {
            _durationUnit = unit;
          }
        } else {
          durationCtlr.text = existingDuration;
        }
      }
      summaryCtlr.text = _course?.courseMeta.summary ?? '';
      _structureLoaded = true; // Curso existente ya tiene estructura
    } else {
      _course = null;
    }
    super.initState();
  }

  void _handlePreview() async {
    final String description = await descriptionCtlr.getText();
    final int lessonsCount = await _getLessonCount();
    final course = _courseData('', description, lessonsCount);
    if (!mounted) return;
    CustomDialogs.openFormDialog(context,
        widget: PointerInterceptor(child: CoursePreview(course: course)),
        verticalPaddingPercentage: 0.02,
        horizontalPaddingPercentage: 0.15);
  }

  void _openStructureUploader() async {
    if (_course == null) {
      // Primero guardar el curso como borrador
      _draftBtnCtlr.start();
      final String? imageUrl = await _getImageUrl();
      thumbnailUrlCtlr.text = imageUrl ?? '';
      await _handleUpload(setCourseStatus(
          course: _course, isAuthorTab: widget.isAuthorTab, isDraft: true));
      _draftBtnCtlr.reset();
    }

    if (_course != null && mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => CourseStructureUploaderDialog(
          courseId: _course!.id,
          courseName: nameCtlr.text.isEmpty ? 'Nuevo Curso' : nameCtlr.text,
        ),
      );

      if (result == true) {
        setState(() {
          _structureLoaded = true;
        });
        if (mounted) {
          openSuccessToast(context, '¡Estructura del curso cargada exitosamente!');
        }
      }
    }
  }

  Widget _buildStructureSection() {
    if (_course?.id != null) {
      // Curso existente - mostrar jerarquía
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estructura del Curso',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: _openStructureUploader,
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Cargar desde documento'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 600,
            child: HierarchyView(
              courseId: _course!.id,
              courseName: nameCtlr.text,
            ),
          ),
        ],
      );
    } else {
      // Curso nuevo - mostrar opciones para crear estructura
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              LineIcons.sitemap,
              size: 64,
              color: AppConfig.themeColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Estructura del Curso',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guarde el curso primero para poder crear la estructura de niveles, módulos y lecciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _openStructureUploader,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Cargar desde Documento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    // Guardar como borrador primero
                    await _handleDraftSubmit();
                    if (mounted && _course != null) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Manualmente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.themeColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTutorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tutores Asignados',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Lista de tutores seleccionados
              if (_selectedTutors.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTutors.map((tutor) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppConfig.themeColor.withOpacity(0.1),
                        backgroundImage: tutor['image_url'] != null
                            ? NetworkImage(tutor['image_url'])
                            : null,
                        child: tutor['image_url'] == null
                            ? Text(
                                (tutor['name'] as String? ?? 'T')[0].toUpperCase(),
                                style: TextStyle(
                                  color: AppConfig.themeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      label: Text(tutor['name'] ?? 'Tutor'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedTutorIds.remove(tutor['id']);
                          _selectedTutors.removeWhere((t) => t['id'] == tutor['id']);
                        });
                        _updateTutorAssignment(tutor['id'], false);
                      },
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppConfig.themeColor.withOpacity(0.3)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Botón para agregar tutores
              TextButton.icon(
                onPressed: () => _showTutorSelectionDialog(),
                icon: const Icon(Icons.add),
                label: Text(
                  _selectedTutors.isEmpty
                      ? 'Asignar tutores a este curso'
                      : 'Agregar más tutores',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppConfig.themeColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTutorSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => _TutorSelectionDialog(
        selectedTutorIds: _selectedTutorIds,
        onTutorsSelected: (tutorIds, tutors) {
          setState(() {
            _selectedTutorIds = tutorIds;
            _selectedTutors = tutors;
          });
        },
      ),
    );
  }

  Future<void> _updateTutorAssignment(String tutorId, bool assign) async {
    try {
      // Actualizar el tutor
      final tutorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tutorId)
          .get();

      if (tutorDoc.exists && _course != null) {
        final tutorData = tutorDoc.data()!;
        final assignedCourses = List<String>.from(tutorData['assigned_courses'] ?? []);

        if (assign && !assignedCourses.contains(_course!.id)) {
          assignedCourses.add(_course!.id);
        } else if (!assign) {
          assignedCourses.remove(_course!.id);
        }

        await tutorDoc.reference.update({
          'assigned_courses': assignedCourses,
        });
      }
    } catch (e) {
      debugPrint('Error updating tutor assignment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CustomButtons.customOutlineButton(context,
                    icon: Icons.remove_red_eye,
                    text: 'Vista Previa',
                    onPressed: () => _handlePreview()),
                const SizedBox(width: 10),
                Visibility(
                  visible: _course == null ||
                      _course?.status == courseStatus.keys.elementAt(0),
                  child: CustomButtons.submitButton(context,
                      buttonController: _draftBtnCtlr,
                      text: 'Guardar Borrador',
                      onPressed: _handleDraftSubmit,
                      borderRadius: 20,
                      width: 160,
                      height: 45,
                      bgColor: Colors.blueGrey.shade300),
                ),
                const SizedBox(width: 10),
                CustomButtons.submitButton(
                  context,
                  buttonController: _publishBtnCtlr,
                  text: widget.isAuthorTab != null && widget.isAuthorTab == true
                      ? 'Enviar'
                      : 'Publicar',
                  onPressed: _handleSubmit,
                  borderRadius: 20,
                  width: 120,
                  height: 45,
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.isMobile(context)
            ? const EdgeInsets.all(20)
            : const EdgeInsets.symmetric(vertical: 50, horizontal: 100),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Información básica del curso
              Text(
                'Información del Curso',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(context,
                        controller: nameCtlr,
                        hint: 'Ingrese el título del curso',
                        title: 'Título del Curso *',
                        hasImageUpload: false),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CategoryDropdown(
                      selectedCategoryId: _selectedCategoryId,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),
              buildTextField(
                context,
                controller: thumbnailUrlCtlr,
                hint: 'Ingrese URL de imagen o seleccione una imagen',
                title: 'Imagen de Vista Previa *',
                hasImageUpload: true,
                onPickImage: _onPickImage,
              ),
              const SizedBox(height: 30),
              buildTextField(
                context,
                controller: videoUrlCtlr,
                hint: 'Ingrese URL del video',
                title: 'Video de Vista Previa',
                hasImageUpload: false,
                validationRequired: false,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: buildTextField(context,
                                controller: durationCtlr,
                                hint: 'Ej: 3',
                                title: 'Duración del Curso',
                                hasImageUpload: false,
                                validationRequired: false),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unidad',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(5)),
                                  child: DropdownButtonFormField<String>(
                                    value: _durationUnit,
                                    decoration:
                                        const InputDecoration(border: InputBorder.none),
                                    onChanged: (value) =>
                                        setState(() => _durationUnit = value ?? 'meses'),
                                    items: _durationUnits
                                        .map((e) =>
                                            DropdownMenuItem(value: e, child: Text(e)))
                                        .toList(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 30),
              tags.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, x) => Container(),
                data: (data) => TagsDropdown(
                  selectedTagIDs: _selectedTagIDs,
                  tags: data,
                  onAdd: (value) => setState(() => _selectedTagIDs.add(value)),
                  onRemove: (value) =>
                      setState(() => _selectedTagIDs.remove(value)),
                ),
              ),
              const SizedBox(height: 30),

              // Sección de tutores asignados
              _buildTutorsSection(),
              const SizedBox(height: 30),

              buildTextField(
                context,
                controller: summaryCtlr,
                hint: 'Ingrese un resumen del curso',
                title: 'Resumen del Curso',
                hasImageUpload: false,
                maxLines: null,
                validationRequired: false,
                minLines: 3,
              ),
              const SizedBox(height: 30),
              CustomHtmlEditor(
                title: 'Descripción del Curso',
                height: 300,
                controller: descriptionCtlr,
                initialText: _course?.courseMeta.description ?? '',
                hint: 'Ingrese la descripción',
              ),
              
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 30),
              
              // Sección de estructura del curso
              _buildStructureSection(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo para seleccionar tutores para un curso
class _TutorSelectionDialog extends StatefulWidget {
  final List<String> selectedTutorIds;
  final Function(List<String>, List<Map<String, dynamic>>) onTutorsSelected;

  const _TutorSelectionDialog({
    required this.selectedTutorIds,
    required this.onTutorsSelected,
  });

  @override
  State<_TutorSelectionDialog> createState() => _TutorSelectionDialogState();
}

class _TutorSelectionDialogState extends State<_TutorSelectionDialog> {
  late List<String> _selectedIds;
  late List<Map<String, dynamic>> _selectedTutors;
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableTutors = [];

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedTutorIds);
    _selectedTutors = [];
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', arrayContains: 'tutor')
          .where('disabled', isNotEqualTo: true)
          .get();

      setState(() {
        _availableTutors = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Sin nombre',
            'email': data['email'] ?? '',
            'image_url': data['image_url'],
          };
        }).toList();

        // Pre-select existing tutors
        _selectedTutors = _availableTutors
            .where((t) => _selectedIds.contains(t['id']))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppConfig.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Seleccionar Tutores',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Lista de tutores
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _availableTutors.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay tutores disponibles.\nCrea tutores desde la pestaña de Tutores.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableTutors.length,
                          itemBuilder: (context, index) {
                            final tutor = _availableTutors[index];
                            final isSelected = _selectedIds.contains(tutor['id']);

                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedIds.add(tutor['id']);
                                    _selectedTutors.add(tutor);
                                  } else {
                                    _selectedIds.remove(tutor['id']);
                                    _selectedTutors.removeWhere(
                                        (t) => t['id'] == tutor['id']);
                                  }
                                });
                              },
                              title: Text(
                                tutor['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                tutor['email'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor:
                                    AppConfig.themeColor.withOpacity(0.1),
                                backgroundImage: tutor['image_url'] != null
                                    ? NetworkImage(tutor['image_url'])
                                    : null,
                                child: tutor['image_url'] == null
                                    ? Text(
                                        tutor['name'][0].toUpperCase(),
                                        style: TextStyle(
                                          color: AppConfig.themeColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              activeColor: AppConfig.themeColor,
                            );
                          },
                        ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onTutorsSelected(_selectedIds, _selectedTutors);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Confirmar (${_selectedIds.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
