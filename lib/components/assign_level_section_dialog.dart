import 'package:flutter/material.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../components/custom_buttons.dart';
import '../utils/toasts.dart';

class AssignLevelSectionDialog extends StatefulWidget {
  final UserModel user;
  const AssignLevelSectionDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<AssignLevelSectionDialog> createState() => _AssignLevelSectionDialogState();
}

class _AssignLevelSectionDialogState extends State<AssignLevelSectionDialog> {
  final _levelController = TextEditingController();
  final _sectionController = TextEditingController();
  final _btnController = RoundedLoadingButtonController();

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _levelController.text = widget.user.studentLevel ?? '';
    _sectionController.text = widget.user.studentSection ?? '';
  }

  Future<void> _handleUpdate() async {
    _btnController.start();
    await FirebaseService().updateUserLevelSection(
      userId: widget.user.id,
      level: _levelController.text,
      section: _sectionController.text,
    );
    _btnController.success();
    if (!mounted) return;
    Navigator.pop(context);
    openSuccessToast(context, 'Updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      // width: 400, // Let dialog handle width constraints or use simple constraint
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Edit Student Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(widget.user.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 30),
          
          Text('Level', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5)
            ),
            child: DropdownButtonFormField<String>(
              value: _levels.contains(_levelController.text) ? _levelController.text : null,
              hint: const Text('Select Level'),
              decoration: const InputDecoration(border: InputBorder.none),
              items: _levels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _levelController.text = val;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),

          Text('Section/Group', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          TextFormField(
            controller: _sectionController,
            decoration: InputDecoration(
              hintText: 'e.g. Group A, Morning',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            ),
          ),

          const SizedBox(height: 30),
          CustomButtons.submitButton(
              context,
              buttonController: _btnController,
              text: 'Save Details',
              onPressed: _handleUpdate
          )
        ],
      ),
    );
  }
}
