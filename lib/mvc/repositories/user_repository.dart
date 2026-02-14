import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
    XFile? localImageFile,
    required String uid,
  }) async {
    if (localImageFile != null) {
      // === determine the path in storing the image ===
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$uid.jpg');

      // === read the page as bytes ===
      Uint8List data = await localImageFile.readAsBytes();

      // === upload the file ===
      await storageRef.putData(data);

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
              "User Name";
        }
      }
    } catch (e) {
      print("⚠️ Could not fetch owner name: $e");
    }
    return ownerRealName;
  }

  Future<String?> getUserId({required String projectId}) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .get();
      if (doc.exists) {
        return doc.get('owner_id') as String?;
      }
    } catch (e) {
      throw "Error getting user ID: $e";
    }
    return null;
  }

  Future<void> isVerified(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isVerified': true,
    });
  }
}
