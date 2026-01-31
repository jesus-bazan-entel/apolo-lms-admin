import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/configs/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_admin/models/level.dart';
import 'package:lms_admin/models/module.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/tabs/admin_tabs/modules/modules.dart';
import 'package:lms_admin/utils/toasts.dart';

class HierarchyView extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const HierarchyView({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  ConsumerState<HierarchyView> createState() => _HierarchyViewState();
}

class _HierarchyViewState extends ConsumerState<HierarchyView> {
  String? _selectedLevelId;
  late Future<List<Level>> _levelsFuture;

  @override
  void initState() {
    super.initState();
    _levelsFuture = FirebaseService().getLevels(widget.courseId);
  }

  void _refreshLevels() {
    setState(() {
      _levelsFuture = FirebaseService().getLevels(widget.courseId);
    });
  }

  void _showLevelDialog(BuildContext context, Level? level) {
    final nameCtlr = TextEditingController(text: level?.name ?? '');
    final descCtlr = TextEditingController(text: level?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                level == null ? Icons.add_circle_outline : Icons.edit_outlined,
                color: AppConfig.themeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              level == null ? 'Crear Nivel' : 'Editar Nivel',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtlr,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Nivel',
                    hintText: 'Ej: Nivel Básico, Nivel 1, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.layers_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descCtlr,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Describe el contenido de este nivel',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Obtener el orden máximo actual
                int maxOrder = 0;
                if (level == null) {
                  final levels = await FirebaseService().getLevels(widget.courseId);
                  if (levels.isNotEmpty) {
                    maxOrder = levels.map((l) => l.order).reduce((a, b) => a > b ? a : b) + 1;
                  }
                }

                final newLevel = Level(
                  id: level?.id ?? FirebaseService.getUID('levels'),
                  courseId: widget.courseId,
                  name: nameCtlr.text,
                  description: descCtlr.text,
                  order: level?.order ?? maxOrder,
                  createdAt: level?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await FirebaseService().saveLevel(widget.courseId, newLevel);
                if (!mounted) return;
                Navigator.pop(context);
                _refreshLevels();
                openSuccessToast(context, level == null ? 'Nivel creado exitosamente' : 'Nivel actualizado');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(level == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLevel(Level level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar Nivel',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de eliminar el nivel "${level.name}"?',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta acción eliminará también todos los módulos y lecciones asociados.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseService().deleteLevel(widget.courseId, level.id);
              if (!mounted) return;
              Navigator.pop(context);
              if (_selectedLevelId == level.id) {
                _selectedLevelId = null;
              }
              _refreshLevels();
              openSuccessToast(context, 'Nivel eliminado');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Sidebar (Left Panel)
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con botón de agregar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Niveles del Curso',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Material(
                        color: AppConfig.themeColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => _showLevelDialog(context, null),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Level>>(
                    future: _levelsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppConfig.themeColor,
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.layers_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sin niveles',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crea el primer nivel para comenzar a estructurar tu curso',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _showLevelDialog(context, null),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Crear Nivel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppConfig.themeColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final levels = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: levels.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          final isSelected = _selectedLevelId == level.id;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => setState(() => _selectedLevelId = level.id),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppConfig.themeColor.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppConfig.themeColor.withOpacity(0.3)
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: isSelected
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.02),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppConfig.themeColor
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            level.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: isSelected
                                                  ? AppConfig.themeColor
                                                  : Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (level.description.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              level.description,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Botones de acción
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        color: Colors.grey.shade500,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showLevelDialog(context, level);
                                        } else if (value == 'delete') {
                                          _confirmDeleteLevel(level);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined,
                                                  size: 18, color: Colors.grey.shade700),
                                              const SizedBox(width: 8),
                                              const Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline,
                                                  size: 18, color: Colors.red.shade400),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Eliminar',
                                                style: TextStyle(color: Colors.red.shade400),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
            ),
          ),

          // Content Area (Right Panel)
          Expanded(
            child: Container(
              color: Colors.white,
              child: _selectedLevelId == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.dashboard_customize_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Selecciona un Nivel',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Visualiza y gestiona los módulos y lecciones',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FutureBuilder<List<Level>>(
                      future: _levelsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final selectedLevel = snapshot.data!
                            .firstWhere((l) => l.id == _selectedLevelId);

                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: ModulesTab(
                            key: ValueKey(_selectedLevelId),
                            courseId: widget.courseId,
                            levelId: selectedLevel.id,
                            levelName: selectedLevel.name,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
