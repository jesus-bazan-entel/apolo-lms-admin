import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lms_admin/models/user_model.dart';
import 'custom_buttons.dart';

class QrDialog extends StatelessWidget {
  final UserModel user;
  const QrDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Scan this code to login as ${user.name}'),
            const SizedBox(height: 20),
            if (user.qrCodeHash != null)
              QrImageView(
                data: user.qrCodeHash!,
                version: QrVersions.auto,
                size: 200.0,
              )
            else
              const Text('No QR Code generated yet'),
            const SizedBox(height: 20),
            CustomButtons.normalButton(context, text: 'Close', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
