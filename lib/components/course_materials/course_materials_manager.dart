import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:lms_admin/configs/constants.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseMaterial {
  final String id;
  final String title;
  final String type; // pdf, video, link, audio, image
  final String url;
  final String? description;
  final int order;
  final DateTime createdAt;

  CourseMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.description,
    required this.order,
    required this.createdAt,
  });

  factory CourseMaterial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseMaterial(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'link',
      url: data['url'] ?? '',
      description: data['description'],
      order: data['order'] ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'url': url,
      'description': description,
      'order': order,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

class CourseMaterialsManager extends StatefulWidget {
  final String courseId;
  final String? levelId;
  final String? moduleId;
  final String? lessonId;

  const CourseMaterialsManager({
    Key? key,
    required this.courseId,
    this.levelId,
    this.moduleId,
    this.lessonId,
  }) : super(key: key);

  @override
  State<CourseMaterialsManager> createState() => _CourseMaterialsManagerState();
}

class _CourseMaterialsManagerState extends State<CourseMaterialsManager> {
  List<CourseMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  CollectionReference get _materialsCollection {
    // Construir la ruta basada en los IDs proporcionados
    String path = 'courses/${widget.courseId}';
    if (widget.levelId != null) path += '/levels/${widget.levelId}';
    if (widget.moduleId != null) path += '/modules/${widget.moduleId}';
    if (widget.lessonId != null) path += '/lessons/${widget.lessonId}';
    path += '/materials';
    
    return FirebaseFirestore.instance.collection(path);
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _materialsCollection.orderBy('order').get();
      _materials = snapshot.docs
          .map((doc) => CourseMaterial.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading materials: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_materials.isEmpty)
            _buildEmptyState()
          else
            _buildMaterialsList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConfig.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: AppConfig.themeColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Materiales del Curso',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_materials.length} archivo(s)',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddMaterialDialog(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Agregar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.themeColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin materiales',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega PDFs, videos o enlaces externos',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _materials.length,
      onReorder: _reorderMaterials,
      itemBuilder: (context, index) {
        final material = _materials[index];
        return _MaterialCard(
          key: ValueKey(material.id),
          material: material,
          onEdit: () => _showEditMaterialDialog(material),
          onDelete: () => _deleteMaterial(material),
          onOpen: () => _openMaterial(material),
        );
      },
    );
  }

  void _showAddMaterialDialog() {
    _showMaterialDialog(null);
  }

  void _showEditMaterialDialog(CourseMaterial material) {
    _showMaterialDialog(material);
  }

  void _showMaterialDialog(CourseMaterial? material) {
    final titleController = TextEditingController(text: material?.title ?? '');
    final urlController = TextEditingController(text: material?.url ?? '');
    final descController = TextEditingController(text: material?.description ?? '');
    String selectedType = material?.type ?? 'pdf';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            material == null ? 'Agregar Material' : 'Editar Material',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Material',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: materialTypes.entries.map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(e.key), size: 20),
                        const SizedBox(width: 8),
                        Text(e.value),
                      ],
                    ),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: 'URL del recurso',
                    hintText: 'https://...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || urlController.text.isEmpty) {
                  openFailureToast(context, 'Completa los campos requeridos');
                  return;
                }

                final newMaterial = CourseMaterial(
                  id: material?.id ?? _materialsCollection.doc().id,
                  title: titleController.text,
                  type: selectedType,
                  url: urlController.text,
                  description: descController.text.isEmpty ? null : descController.text,
                  order: material?.order ?? _materials.length,
                  createdAt: material?.createdAt ?? DateTime.now(),
                );

                await _materialsCollection.doc(newMaterial.id).set(newMaterial.toMap());
                Navigator.pop(context);
                _loadMaterials();
                openSuccessToast(context, 'Material guardado');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Guardar', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMaterial(CourseMaterial material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Material'),
        content: Text('¿Eliminar "${material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppConfig.errorColor),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _materialsCollection.doc(material.id).delete();
      _loadMaterials();
      if (mounted) openSuccessToast(context, 'Material eliminado');
    }
  }

  Future<void> _reorderMaterials(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    
    final item = _materials.removeAt(oldIndex);
    _materials.insert(newIndex, item);
    setState(() {});

    // Actualizar orden en Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < _materials.length; i++) {
      batch.update(_materialsCollection.doc(_materials[i].id), {'order': i});
    }
    await batch.commit();
  }

  void _openMaterial(CourseMaterial material) async {
    final uri = Uri.parse(material.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) openFailureToast(context, 'No se puede abrir el enlace');
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'video': return Icons.play_circle_outline;
      case 'link': return Icons.link;
      case 'audio': return Icons.audiotrack;
      case 'image': return Icons.image_outlined;
      default: return Icons.insert_drive_file;
    }
  }
}

class _MaterialCard extends StatelessWidget {
  final CourseMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _MaterialCard({
    Key? key,
    required this.material,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 20),
        ),
        title: Text(
          material.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: material.description != null
            ? Text(
                material.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 18),
              color: AppConfig.themeColor,
              onPressed: onOpen,
              tooltip: 'Abrir',
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.grey.shade600,
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppConfig.errorColor,
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
            ReorderableDragStartListener(
              index: 0,
              child: Icon(Icons.drag_handle, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (material.type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'video': return Icons.play_circle_outline;
      case 'link': return Icons.link;
      case 'audio': return Icons.audiotrack;
      case 'image': return Icons.image_outlined;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor() {
    switch (material.type) {
      case 'pdf': return Colors.red;
      case 'video': return Colors.blue;
      case 'link': return Colors.green;
      case 'audio': return Colors.orange;
      case 'image': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
