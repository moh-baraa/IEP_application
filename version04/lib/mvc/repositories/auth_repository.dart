import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iep_app/core/constans/colors.dart';

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



  // === Sign Out ===
  Future<void> signOut() async {
    await _auth.signOut();
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
  // === Forget Password ===
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      }
      throw e.message ?? 'Something went wrong.';
    } catch (e) {
      throw e.toString();
    }
  }

  // Future<void> verifyEmail({required String controllerText, String? email}) async {
  //   bool check = true;
  //   final currentUser = _auth.currentUser;
  //   if (currentUser != null) {
  //     if (email != null) {
  //       check = currentUser.email != email.trim();
  //     }
  //     if(check) {
  //       await currentUser.verifyBeforeUpdateEmail(controllerText.trim());
  //     }
  //   }
  // }
}
