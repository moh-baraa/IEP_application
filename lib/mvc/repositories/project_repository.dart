import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:image_picker/image_picker.dart';

class ProjectsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === get the projects from firestore ===
  Stream<List<ProjectModel>> getProjectsStream(
    String category, {
    bool includeFrozen = false,
  }) {
    Query query = _firestore
        .collection('projects')
        .where('isApproved', isEqualTo: true);

    if (!includeFrozen) {
      query = query
          .where('isFrozen', isEqualTo: false)
          .where('isSatisfiesTarget', isEqualTo: false);
    }
    switch (category) {
      case 'Latest':
        query = query.orderBy('created_at', descending: true);
        break;
      case 'Oldest':
        query = query.orderBy('created_at', descending: false);
        break;
      case 'Lowest Goal':
        query = query.orderBy('target_amount', descending: false);
        break;
      case 'Highest Goal':
        query = query.orderBy('target_amount', descending: true);
        break;
      default:
        query = query.orderBy('created_at', descending: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<ProjectModel?> getProjectById(String projectId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('projects')
          .doc(projectId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ProjectModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching project: $e");
      return null;
    }
  }

  Stream<QuerySnapshot>? getUserProjects({required String currentUserId}) {
    return FirebaseFirestore.instance
        .collection('projects')
        .where('owner_id', isEqualTo: currentUserId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<String> addImageAndGetUrl({
    required String fileName,
    required XFile xFile,
  }) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('projects_images')
        .child(fileName);
    Uint8List data = await xFile.readAsBytes();
    UploadTask uploadTask = ref.putData(data);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> updateProject({
    required Map<String, dynamic> data,
    required String projectId,
  }) async {
    await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
        .update(data);
  }

  Future<DocumentReference> addNewProject({
    required Map<String, dynamic> data,
  }) async {
    data['created_at'] = FieldValue.serverTimestamp();
    return await FirebaseFirestore.instance.collection('projects').add(data);
  }
}
