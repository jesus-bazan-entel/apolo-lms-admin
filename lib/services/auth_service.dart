import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms_admin/providers/auth_state_provider.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<UserCredential?> loginWithEmailPassword(String email, String password) async {
    UserCredential? userCredential;
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((UserCredential user) async {
      userCredential = user;
    }).catchError((e) {
      debugPrint('SignIn Error: $e');
    });

    return userCredential;
  }

  Future loginAnnonumously() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future adminLogout() async {
    return _firebaseAuth.signOut().then((value) {
      debugPrint('Logout Success');
    }).catchError((e) {
      debugPrint('Logout error: $e');
    });
  }

  // Future<bool> checkAccess(String uid) async {
  //   bool hasAccess = false;
  //   await _firebaseFirestore.collection('users').doc(uid).get().then((DocumentSnapshot snap) {
  //     if (snap.exists) {
  //       List? userRole = snap['role'];
  //       debugPrint('User Role: $userRole');
  //       if (userRole != null && (userRole.contains('admin') || userRole.contains('author'))) {
  //         hasAccess = true;
  //       }
  //     }
  //   }).catchError((e) {
  //     debugPrint('check access error: $e');
  //   });
  //   return hasAccess;
  // }

  Future<UserRoles> checkUserRole(String uid) async {
    UserRoles authState = UserRoles.none;
    debugPrint('Checking user role for UID: $uid');
    
    await _firebaseFirestore.collection('users').doc(uid).get().then((DocumentSnapshot snap) {
      debugPrint('Document exists: ${snap.exists}');
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>?;
        debugPrint('User data: $data');
        
        dynamic userRole = snap['role'];
        debugPrint('User Role field: $userRole (type: ${userRole.runtimeType})');
        
        if (userRole != null) {
          // Handle both String and List<String> formats
          bool isAdmin = false;
          bool isAuthor = false;
          
          if (userRole is List) {
            isAdmin = userRole.any((r) => r.toString().toLowerCase() == 'admin');
            isAuthor = userRole.any((r) => r.toString().toLowerCase() == 'author');
          } else if (userRole is String) {
            final role = userRole.toLowerCase().trim();
            isAdmin = role == 'admin';
            isAuthor = role == 'author';
          }
          
          debugPrint('isAdmin: $isAdmin, isAuthor: $isAuthor');
          
          if (isAdmin) {
            authState = UserRoles.admin;
          } else if (isAuthor) {
            authState = UserRoles.author;
          }
        }
      } else {
        debugPrint('User document NOT found in Firestore!');
      }
    }).catchError((e) {
      debugPrint('check access error: $e');
    });
    
    debugPrint('Final authState: $authState');
    return authState;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    bool success = false;
    final user = _firebaseAuth.currentUser;
    final cred = EmailAuthProvider.credential(email: user!.email!, password: oldPassword);
    await user.reauthenticateWithCredential(cred).then((UserCredential? userCredential) async {
      if (userCredential != null) {
        await user.updatePassword(newPassword).then((_) {
          success = true;
        }).catchError((error) {
          debugPrint(error);
          success = false;
        });
      } else {
        success = false;
        debugPrint('Reauthentication failed');
      }
    }).catchError((err) {
      debugPrint('errro: $err');
      success = false;
    });

    return success;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        debugPrint('Google Sign In cancelled');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      debugPrint('Google Sign In Success: ${userCredential.user?.email}');
      
      // Verificar si el usuario existe en Firestore, si no, crearlo como estudiante
      if (userCredential.user != null) {
        await _createUserIfNotExists(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      return null;
    }
  }

  /// Crea el usuario en Firestore si no existe, con rol de estudiante por defecto
  Future<void> _createUserIfNotExists(User user) async {
    try {
      final userDoc = await _firebaseFirestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Crear nuevo usuario como estudiante
        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Usuario',
          'email': user.email,
          'image_url': user.photoURL,
          'role': ['student'], // Por defecto es estudiante
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'disabled': false,
          'student_level': 'beginner',
          'payment_status': 'pending',
          'auth_provider': 'google',
        });
        debugPrint('Nuevo estudiante creado: ${user.email}');
        
        // Actualizar estadísticas de usuarios
        await _updateUserStatsOnCreate();
      } else {
        debugPrint('Usuario ya existe: ${user.email}');
      }
    } catch (e) {
      debugPrint('Error creando usuario: $e');
    }
  }

  /// Actualiza las estadísticas de usuarios cuando se crea uno nuevo
  Future<void> _updateUserStatsOnCreate() async {
    try {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      final docId = '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

      final docRef = _firebaseFirestore.collection('user_stats').doc(docId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({'count': FieldValue.increment(1)});
      } else {
        await docRef.set({
          'timestamp': Timestamp.fromDate(dateOnly),
          'count': 1,
        });
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas: $e');
    }
  }
}
