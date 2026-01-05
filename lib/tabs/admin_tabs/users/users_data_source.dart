import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms_admin/components/user_info.dart';
import 'package:lms_admin/components/custom_buttons.dart';
import 'package:lms_admin/components/dialogs.dart';
import 'package:lms_admin/mixins/user_mixin.dart';
import 'package:lms_admin/mixins/users_mixin.dart';
import 'package:lms_admin/services/firebase_service.dart';
import 'package:lms_admin/utils/toasts.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_data_provider.dart';
import 'package:lms_admin/services/qr_generator_service.dart';
import 'package:lms_admin/components/qr_dialog.dart';
import 'package:lms_admin/components/assign_level_section_dialog.dart';

class UsersDataSource extends DataTableSource with UsersMixins, UserMixin {
  final List<UserModel> users;
  final BuildContext context;
  final WidgetRef ref;
  UsersDataSource(this.users, this.context, this.ref);

  void _onCopyUserId(String userId) async {
    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      Clipboard.setData(ClipboardData(text: userId));
      openSuccessToast(context, 'Copied to clipboard');
    } else {
      openTestingToast(context);
    }
  }

  void _handleUserAccess(UserModel user) {
    final btnCtlr = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      title: user.isDisbaled! ? "Enabled Access to this user?" : "Disbale access to this user?",
      message: user.isDisbaled! ? 'Warning: ${user.name} can access the app and contents' : "Warning: ${user.name} can't access the app and contents",
      actionBtnController: btnCtlr,
      actionButtonText: user.isDisbaled! ? 'Yes, Enable Access' : 'Yes, Disable Access',
      onAction: () async {
        final navigator = Navigator.of(context);
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          btnCtlr.start();
          if (user.isDisbaled!) {
            await FirebaseService().updateUserAccess(userId: user.id, shouldDisable: false);
          } else {
            await FirebaseService().updateUserAccess(userId: user.id, shouldDisable: true);
          }

          btnCtlr.success();
          navigator.pop();
          if (!context.mounted) return;
          openSuccessToast(context, 'User access has been updated!');
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  void _handleAuthorAccess(UserModel user, bool isAuthor) {
    final btnCtlr = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      title: !isAuthor ? "Assign As An Author?" : "Remove Author Access?",
      message: !isAuthor
          ? 'Warning: ${user.name} can access author dashboard and submit courses!'
          : "Warning: ${user.name} can't access the author dashboard!",
      actionBtnController: btnCtlr,
      actionButtonText: !isAuthor ? 'Yes, Enable Access' : 'Yes, Disable Access',
      onAction: () async {
        final navigator = Navigator.of(context);
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          btnCtlr.start();
          if (isAuthor) {
            await FirebaseService().updateAuthorAccess(userId: user.id, shouldAssign: false);
          } else {
            await FirebaseService().updateAuthorAccess(userId: user.id, shouldAssign: true);
          }

          btnCtlr.success();
          navigator.pop();
          if (!context.mounted) return;
          openSuccessToast(context, 'Author access has been updated!');
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  void _handleQrCode(UserModel user) async {
    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      UserModel userToShow = user;
      
      // Check if hash exists, if not generate and save
      if (QrGeneratorService.needsQrCode(user.qrCodeHash)) {
        final String newHash = QrGeneratorService.generateUserQrHash(user.id, user.email);
        await FirebaseService().updateUserQrHash(userId: user.id, hash: newHash);
        
        // Create temporary user with new hash to show immediately
        userToShow = UserModel(
          id: user.id,
          email: user.email,
          name: user.name,
          imageUrl: user.imageUrl,
          role: user.role,
          wishList: user.wishList,
          enrolledCourses: user.enrolledCourses,
          isDisbaled: user.isDisbaled,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          authorInfo: user.authorInfo,
          subscription: user.subscription,
          completedLessons: user.completedLessons,
          platform: user.platform,
          qrCodeHash: newHash,
          paymentStatus: user.paymentStatus,
        );
        
        // Also ensure user isn't disabled if we are generating QR (assuming active student)
        // Optionally: updateUserPaymentStatus(user.id, true);
        
        if (context.mounted) {
            openSuccessToast(context, 'QR Code Generated!');
        }
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => QrDialog(user: userToShow),
        );
      }
    } else {
      openTestingToast(context);
    }
  }

  void _handlePaymentStatus(UserModel user) async {
    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      final btnCtlr = RoundedLoadingButtonController();
      bool isCurrentlyPaid = user.paymentStatus == 'paid';
      
      CustomDialogs.openActionDialog(
        context,
        title: isCurrentlyPaid ? "Mark as Unpaid?" : "Mark as Paid?",
        message: isCurrentlyPaid
            ? 'Warning: User will lose access to paid content.'
            : "User will be granted access to paid content.",
        actionBtnController: btnCtlr,
        actionButtonText: isCurrentlyPaid ? 'Mark Unpaid' : 'Mark Paid',
        onAction: () async {
          final navigator = Navigator.of(context);
          if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
            btnCtlr.start();
            await FirebaseService().updateUserPaymentStatus(userId: user.id, isPaid: !isCurrentlyPaid);
            // Optionally sync 'disabled' status if strict payment control is desired
            // await FirebaseService().updateUserAccess(userId: user.id, shouldDisable: isCurrentlyPaid); 

            btnCtlr.success();
            navigator.pop();
            if (!context.mounted) return;
            openSuccessToast(context, 'Payment status updated!');
          } else {
            openTestingToast(context);
          }
        },
      );
    } else {
        openTestingToast(context);
    }
  }

  void _handleAssignLevelSection(UserModel user) {
     if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
        CustomDialogs.openActionDialog(
           context, 
           title: 'Edit Student Details', 
           message: 'Update level and section for ${user.name}', 
           actionBtnController: RoundedLoadingButtonController(), 
           actionButtonText: 'Proceed',
           onAction: () {
             Navigator.pop(context);
             showDialog(
                context: context,
                builder: (context) => AssignLevelSectionDialog(user: user),
             );
           }
        );
     } else {
        openTestingToast(context);
     }
  }

  @override
  DataRow getRow(int index) {
    final UserModel user = users[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(_userName(user)),
      DataCell(getEmail(user, ref)),
      DataCell(_getEnrolledCourses(user)),
      DataCell(Text(user.studentLevel ?? '-')),
      DataCell(Text(user.studentSection ?? '-')),
      DataCell(_getPaymentStatus(user)),
      DataCell(_getPlatform(user)),
      DataCell(_actions(user)),
    ]);
  }

  static Text _getEnrolledCourses(UserModel user) {
    return Text(user.enrolledCourses!.length.toString());
  }

  ListTile _userName(UserModel user) {
    return ListTile(
        horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.all(0),
        title: Wrap(
          direction: Axis.horizontal,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 14),
            ),
            Row(
              children: user.role!
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(color: _getColor(e), borderRadius: BorderRadius.circular(3)),
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        leading: getUserImage(user: user));
  }

  static Color _getColor(String role) {
    if (role == 'admin') {
      return Colors.indigoAccent;
    } else if (role == 'author') {
      return Colors.orangeAccent;
    } else {
      return Colors.blueAccent;
    }
  }

  static Text _getPlatform(UserModel user) {
    return Text(user.platform ?? 'Undefined');
  }

  static Widget _getPaymentStatus(UserModel user) {
     bool isPaid = user.paymentStatus == 'paid';
     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: isPaid ? Colors.green : Colors.red, width: 0.5)
        ),
        child: Text(
            isPaid ? 'PAID' : 'UNPAID',
            style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold
            ),
        ),
     );
  }

  Widget _actions(UserModel user) {
    return Row(
      children: [
        CustomButtons.circleButton(
          context,
          icon: Icons.remove_red_eye,
          tooltip: 'view user info',
          onPressed: () => CustomDialogs.openResponsiveDialog(
            context,
            widget: UserInfo(user: user),
            verticalPaddingPercentage: 0.05,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        _menuButton(user)
      ],
    );
  }

  PopupMenuButton _menuButton(UserModel user) {
    final bool isAuthor = user.role!.contains('author') ? true : false;
    final bool isAdmin = user.role!.contains('admin') ? true : false;

    return PopupMenuButton(
      child: const CircleAvatar(
        radius: 16,
        child: Icon(
          Icons.menu,
          size: 16,
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(child: const Text('Copy User Id'), onTap: () => _onCopyUserId(user.id)),
          PopupMenuItem(
            enabled: !isAdmin,
            child: Text(user.isDisbaled! ? 'Enable User Access' : 'Disable User Access'),
            onTap: () => _handleUserAccess(user),
          ),
          PopupMenuItem(
            enabled: !isAdmin,
            child: Text(isAuthor ? 'Disable Author Access' : 'Assign As Author'),
            onTap: () => _handleAuthorAccess(user, isAuthor),
          ),
          PopupMenuItem(
            child: const Text('View/Generate QR'),
            onTap: () => _handleQrCode(user),
          ),
          PopupMenuItem(
            child: Text(user.paymentStatus == 'paid' ? 'Mark Unpaid' : 'Mark Paid'),
            onTap: () => _handlePaymentStatus(user),
          ),
          PopupMenuItem(
            child: const Text('Edit Level/Section'),
            onTap: () => _handleAssignLevelSection(user),
          ),
        ];
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
