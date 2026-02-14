import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';
import 'package:iep_app/mvc/views/auth/widgets/text_field2.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/models/project_model.dart';
import 'package:iep_app/mvc/controllers/project_page/add_project_controller.dart';

final colors = AppColors.light;

class AddProjectPage extends StatefulWidget {
  final ProjectModel? projectToEdit; // receving the project in edit mode

  const AddProjectPage({super.key, this.projectToEdit});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AddProjectController();

  @override
  void initState() {
    super.initState();
    // === get the data and show it if its in edit mode ===
    if (widget.projectToEdit != null) {
      _controller.initializeForEdit(widget.projectToEdit!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === depinding to the page add or edit? ===
    String pageTitle = widget.projectToEdit != null
        ? 'Edit Project'
        : 'Add New Project';
    String buttonText = widget.projectToEdit != null
        ? 'Update Project'
        : 'Submit Project';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(pageTitle, style: AppTextStyles.size18weight5(colors.text)),
        shape: Border(bottom: BorderSide(color: colors.secText)),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Title',
                  style: AppTextStyles.size14weight5(colors.text),
                ),
                const SizedBox(height: 8),
                AppTextField2(
                  textInside: 'Enter project title (max 30 words)',
                  controller: _controller.titleController,
                  validator: _controller.validateTitle,
                ),
                const SizedBox(height: 16),

                Text(
                  'Project Images',
                  style: AppTextStyles.size14weight5(colors.text),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 110,
                  child: ValueListenableBuilder<List<dynamic>>(
                    valueListenable: _controller.displayImages,
                    builder: (context, images, _) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            images.length +
                            1, // the additional element is add button
                        itemBuilder: (context, index) {
                          // === add button ===
                          if (index == images.length) {
                            // the last element always will be add button
                            return GestureDetector(
                              onTap: () => _controller.pickImages(
                                context,
                              ), //open file explorer and enable user pick imges
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.secondary),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 28,
                                        color: colors.text,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Add',
                                        style: AppTextStyles.size12weight4(
                                          colors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          // === itemis the image now (item can be image from your device or from firebase) ===
                          final item = images[index];
                          // === image and delete icon ===
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item is String
                                      ? Image.network(
                                          item,
                                          fit: BoxFit.cover,
                                        ) // if image from firebase
                                      : (kIsWeb
                                            ? Image.network(
                                                item.path,
                                                fit: BoxFit.cover,
                                              ) // for web
                                            : Image.file(
                                                File(item.path),
                                                fit: BoxFit.cover,
                                              )),
                                ),
                              ),
                              // === remove image icon ===
                              Positioned(
                                top: 6,
                                right: 14,
                                child: GestureDetector(
                                  onTap: () => _controller.removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: colors.background,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: AppTextStyles.size14weight5(colors.text),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller.descriptionController,
                  validator: _controller.validateDescription,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Write about the project...',
                    filled: true,
                    fillColor: colors.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.secondary, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.primary, width: 1.3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Investment Amount (JD)',
                  style: AppTextStyles.size14weight5(colors.text),
                ),
                const SizedBox(height: 8),
                AppTextField2(
                  textInside: 'Enter amount',
                  controller: _controller.amountController,
                  validator: _controller.validateAmount,
                ),

                const SizedBox(height: 24),

                ValueListenableBuilder<bool>(
                  valueListenable: _controller.isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AppFormButton(
                      buttonText: buttonText,
                      onPressed: () {
                        _controller.submit(context, _formKey);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
