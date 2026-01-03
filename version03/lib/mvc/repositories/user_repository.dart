import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserRepository {
  Future<void> updateUserData(
    String uid,
    Map<String, dynamic> updatedData,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(updatedData, SetOptions(merge: true));
  }

  Future<String?> addAvatarUrlAndGetUrl({
    File? localImageFile,
    required String uid,
  }) async {
    if (localImageFile != null) {
      // === determine the path in storing the image ===
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$uid.jpg');

      // === upload the file ===
      await storageRef.putFile(localImageFile!);

      // === get the new url ===
      return await storageRef.getDownloadURL();
    }
    return null;
  }

  Future<String> getUserName({required String userId}) async {
    String ownerRealName = "Project Owner";
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        if (userData['first_name'] != '' || userData['last_name'] != '') {
          ownerRealName =
              "${userData['first_name']} ${userData['last_name']}" ??
              "Project Owner";
        }
      }
    } catch (e) {
      print("⚠️ Could not fetch owner name: $e");
    }
    return ownerRealName;
  }

  Future<void> isVerified(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isVerified': true,
    });
  }
}
