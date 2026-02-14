import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AppInputDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String hintText;
  final String actionText;
  final Color? actionColor;
  final Function(String) onSubmit;
  const AppInputDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.actionText,
    required this.onSubmit,
    this.actionColor,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String hintText,
    required String actionText,
    required Function(String) onSubmit,
    Color? actionColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppInputDialog(
        title: title,
        subtitle: subtitle,
        hintText: hintText,
        actionText: actionText,
        onSubmit: onSubmit,
        actionColor: actionColor,
      ),
    );
  }

  @override
  State<AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<AppInputDialog> {
  final TextEditingController _textController = TextEditingController();
  final colors = AppColors.light;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.actionColor ?? colors.primary;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      elevation: 5,

      title: Text(
        widget.title,
        style: AppTextStyles.size16weight5(colors.text),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: AppTextStyles.size14weight4(colors.secText),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: TextStyle(fontSize: 14, color: colors.text),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontSize: 12,
                color: colors.secText.withOpacity(0.7),
              ),
              filled: true,
              fillColor: colors.background,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.secText.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.secText.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),

      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: colors.secText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () {
            widget.onSubmit(_textController.text);
            Navigator.pop(context);
          },
          child: Text(
            widget.actionText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
