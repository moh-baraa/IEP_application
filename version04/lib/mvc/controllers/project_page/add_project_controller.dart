import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/services/notification_service.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/repositories/project_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:provider/provider.dart';

final colors = AppColors.light;

class AddProjectController {
  final _repo = ProjectsRepository();

  // === text feilds controllers ===
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // === image picker libary variable ===
  final ImagePicker _picker = ImagePicker();

  // === editing mode variables ===
  bool isEditMode = false;
  String? existingProjectId;

  // === images picked list ===
  final ValueNotifier<List<dynamic>> displayImages = ValueNotifier([]);

  // === old images that deleted, to delete from firebase ===
  List<String> keptOldImages = [];

  // === isloading button variable ===
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // === to get the data into the page on edit mode ===
  void initializeForEdit(ProjectModel project) {
    isEditMode = true;
    existingProjectId = project.id;

    titleController.text = project.title;
    descriptionController.text = project.description;
    amountController.text = (project.targetFunds).toStringAsFixed(
      0,
    ); // converting double to string without numbers after dot

    if (project.images.isNotEmpty) {
      keptOldImages = List.from(project.images);
      displayImages.value = List.from(project.images);
    }
  }

  int wordCount(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r"\s+")).length;
  }

  Future<void> pickImages(BuildContext context) async {
    try {
      final currentList = displayImages.value;
      final remaining = 5 - currentList.length;
      // === if there no remaining images stop ===
      if (remaining <= 0) {
        AppSnackBarState.show(
          context,
          color: Colors.orange,
          content: 'You can add up to 5 images only',
        );
        return;
      }
      // === pick multi images by image picker libary ===
      final List<XFile>? picked = await _picker.pickMultiImage();

      if (picked == null || picked.isEmpty) {
        return; // if the user didnt choose any image
      }

      final toAdd = picked
          .take(remaining)
          .toList(); // take the images up to 5, depending on remaining

      displayImages.value = [
        ...currentList,
        ...toAdd,
      ]; // add the previous list and the new list to the displayed list
    } catch (e) {
      if (context.mounted) {
        AppSnackBarState.show(context, content: "Error: $e", color: Colors.red);
      }
    }
  }

  void removeImage(int index) {
    final currentList = List<dynamic>.from(displayImages.value);
    final itemToRemove = currentList[index];

    // === if image was old (was comming from firebase), means its ,url/string ===
    if (itemToRemove is String) {
      keptOldImages.remove(itemToRemove);
    }

    currentList.removeAt(index);
    displayImages.value = currentList;
  }

  Future<void> submit(BuildContext context, GlobalKey<FormState> key) async {
    if (!key.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final currentList = displayImages.value;

    if (currentList.isEmpty) {
      AppSnackBarState.show(
        context,
        color: colors.red,
        content: 'Please add at least 1 image',
      );
      return;
    }

    final double amountCheck =
        double.tryParse(amountController.text.replaceAll(',', '')) ?? 0.0;
    if (amountCheck < 1000) {
      AppSnackBarState.show(
        context,
        color: colors.red,
        content: 'Investment amount must be at least 1000 JD',
      );
      return;
    }
    // === start the truely submit ===
    isLoading.value = true;

    try {
      List<String> finalImageUrls = [];

      // === at first adding the old images urls ====
      finalImageUrls.addAll(keptOldImages);

      // === adding the new images to storage ===
      for (var item in currentList) {
        if (item is XFile) {
          String fileName =
              '${DateTime.now().millisecondsSinceEpoch}_${item.name}'; // make the name uniqe as possible
          // === add the image to the storage and get the url ===
          String downloadUrl = await _repo.addImageAndGetUrl(
            fileName: fileName,
            xFile: item,
          );
          // === secondly adding new images urls ===
          finalImageUrls.add(downloadUrl);
        }
      }

      final double targetAmount =
          double.tryParse(amountController.text.replaceAll(',', '')) ??
          0.0; // get the target amount
      final String currentUserId =
          UserProvider.instance.currentUserId!; // and the id

      // all the data in the feilds at the page
      ProjectModel newProject = ProjectModel(
        images: finalImageUrls,
        targetFunds: targetAmount,
        title: titleController.text,
        description: descriptionController.text,
      );

      if (isEditMode && existingProjectId != null) {
        // === edit mode ===
        await _repo.updateProject(
          data: newProject.toMap(),
          projectId: existingProjectId!,
        );
        if (context.mounted) {
          AppSnackBarState.show(
            context,
            color: colors.green,
            content: 'Project updated successfully',
          );
        }
      } else {
        newProject.ownerId = currentUserId;
        // === adding the new project ===
        DocumentReference docRef = await _repo.addNewProject(
          data: newProject.toMap(),
        );

        // === sending notification to the admin(new project) ===
        NotificationService.sendAdminNotification(
          relatedId: docRef.id,
          title: 'New Project Request',
          body: 'A new project "${titleController.text}" needs approval.',
          type: 'project_request',
          relatedIdKey:
              'projectId', // what is the id key will be in the document
        );

        if (context.mounted) {
          // updating numbers at user dashboard
          Provider.of<UserProvider>(context, listen: false).refreshStats();

          AppSnackBarState.show(
            context,
            color: colors.green,
            content: 'Project submitted for review successfully',
          );
        }
      }

      isLoading.value = false;
      if (context.mounted) Navigator.of(context).pop(); // closing the page
    } catch (error) {
      if (context.mounted) {
        AppSnackBarState.show(
          context,
          color: colors.red,
          content: 'Failed: $error',
        );
        isLoading.value = false;
      }
    }
  }

  // ==================== Validators ====================
  String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter project title';
    final wc = wordCount(v);
    if (wc > 30) return 'Title must be at most 30 words (currently $wc)';
    return null;
  }

  String? validateDescription(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter description';
    final wc = wordCount(v);
    if (wc > 800) return 'Description must be at most 800 words';
    return null;
  }

  String? validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final val = double.tryParse(v.replaceAll(',', ''));
    if (val == null) return 'Invalid number';
    if (val < 1000.0) return 'Minimum 1000 JD';
    return null;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    displayImages.dispose();
    isLoading.dispose();
  }
}
