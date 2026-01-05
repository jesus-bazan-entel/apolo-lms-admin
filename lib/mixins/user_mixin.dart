import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lms_admin/models/course.dart';
import 'package:lms_admin/models/user_model.dart';
import 'package:lms_admin/utils/custom_cache_image.dart';

mixin UserMixin {
  ClipOval getUserImage({
    required UserModel? user,
    double radius = 30,
    double iconSize = 18,
    String? imagePath,
  }) {
    final String? image = imagePath ?? user?.imageUrl;

    return ClipOval(
      child: Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: CustomCacheImage(imageUrl: image ?? '', radius: radius, errorIcon: LineIcons.user),
      ),
    );
  }

  static ClipOval getUserImageByUrl({
    required String? imageUrl,
    double radius = 30,
    double iconSize = 18,
  }) {
    return ClipOval(
      child: Container(
        height: radius,
        width: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
        ),
        child: CustomCacheImage(imageUrl: imageUrl ?? '', radius: radius, errorIcon: LineIcons.user),
      ),
    );
  }

  String getUserRole(UserModel? user) {
    String role = '';
    if (user != null && user.role != null && user.role!.isNotEmpty) {
      if (user.role!.contains('admin')) {
        role = 'Admin';
      } else if (user.role!.contains('author')) {
        role = 'Author';
      } else {
        role = 'User';
      }
    } else {
      role = 'Tester';
    }

    return role;
  }

  String getUserName(UserModel? user) {
    if (user != null) {
      return user.name;
    } else {
      return 'John Doe';
    }
  }

  static bool hasAccess(UserModel? user) {
    if (user != null && (user.role!.contains('admin') || user.role!.contains('author'))) {
      return true;
    } else {
      return false;
    }
  }

  static bool hasAdminAccess(UserModel? user) {
    if (user != null && (user.role!.contains('admin'))) {
      return true;
    } else {
      return false;
    }
  }

  static bool isAuthor(UserModel? user, Course course) {
    if (user != null && course.author!.id == user.id) {
      return true;
    } else {
      return false;
    }
  }
}
