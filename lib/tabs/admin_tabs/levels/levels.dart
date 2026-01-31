import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/mixins/appbar_mixin.dart';
import 'package:lms_admin/models/level.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:lms_admin/providers/categories_provider.dart';

class LevelsTab extends ConsumerStatefulWidget {
  final String courseId;
  const LevelsTab({Key? key, required this.courseId}) : super(key: key);

  @override
  ConsumerState<LevelsTab> createState() => _LevelsTabState();
}

class _LevelsTabState extends ConsumerState<LevelsTab> {
  late Future<List<Level>> _levelsFuture;

  @override
  void initState() {
    super.initState();
    _levelsFuture = FirebaseService().getLevels(widget.courseId);
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
            title: 'Niveles del Curso',
            buttons: [
              CustomButtons.circleButton(
                context,
                icon: Icons.add,
                bgColor: Theme.of(context).primaryColor,
                iconColor: Colors.white,
                radius: 22,
                onPressed: () => _showLevelDialog(context, null),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<Level>>(
              future: _levelsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay niveles creados'),
                  );
                }

                final levels = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        title: Text(level.name),
                        subtitle: Text(level.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showLevelDialog(context, level),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteLevel(level.id),
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
    );
  }

  void _showLevelDialog(BuildContext context, Level? level) {
    final nameCtlr = TextEditingController(text: level?.name ?? '');
    final descCtlr = TextEditingController(text: level?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(level == null ? 'Crear Nivel' : 'Editar Nivel'),
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
                final newLevel = Level(
                  id: level?.id ?? FirebaseService.getUID('levels'),
                  courseId: widget.courseId,
                  name: nameCtlr.text,
                  description: descCtlr.text,
                  order: level?.order ?? 0,
                  createdAt: level?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await FirebaseService().saveLevel(widget.courseId, newLevel);
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  _levelsFuture = FirebaseService().getLevels(widget.courseId);
                });
                openSuccessToast(context, 'Nivel guardado exitosamente');
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLevel(String levelId) async {
    await FirebaseService().deleteLevel(widget.courseId, levelId);
    setState(() {
      _levelsFuture = FirebaseService().getLevels(widget.courseId);
    });
    openSuccessToast(context, 'Nivel eliminado');
  }
}
