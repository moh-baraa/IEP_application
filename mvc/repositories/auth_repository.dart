import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/views/auth/login_page.dart';

class AuthRepository {
  final colors = AppColors.light;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === login  ===
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // === signup  ===
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobile,
    required String birthDate, // YYYY-MM-DD
  }) async {
      // === create new user  ===
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'user_id': credential.user!.uid,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'mobile_num': mobile,
        'Date_of_birth': birthDate,
        'created_at': FieldValue.serverTimestamp(),
        'avatar_url': null, 
      });
    }
    return credential;
  }

  // === Forget Password ===
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // === Sign Out ===
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
    AppSnackBarState.show(
      context,
      color: colors.secText,
      content: 'signed out, successfully',
    );
  }

  // === get user information ===
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore
        .collection('users')
        .doc(uid)
        .get(); //get the user form the id
  }

  Future<bool> isBlocked(String uid) async {
    DocumentSnapshot userDoc = await getUserData(uid);
    if (!userDoc.exists) return false;
    return await (userDoc.data() as Map<String, dynamic>?)?['isBlocked'] ??
        false; //with full protection from null
  }
}
