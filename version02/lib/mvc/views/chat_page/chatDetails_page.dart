import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';
import 'package:iep_app/mvc/views/chat_page/message_text_input.dart';
import 'package:iep_app/mvc/views/chat_page/widgets/message_item.dart';
import 'package:iep_app/mvc/views/layout/un_found_page.dart';

final colors = AppColors.light;

class ChatDetailsPage extends StatefulWidget {
  final String chatName;
  final String avatarUrl;
  final String receiverId;

  const ChatDetailsPage({
    super.key,
    required this.chatName,
    required this.avatarUrl,
    required this.receiverId,
  });

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatController _chatController = ChatController();

  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    final provider = UserProvider.instance;
    super.initState();
    // === initial the stream ===
    _messagesStream = _chatController.getMessages(
      widget.receiverId,
      provider.currentUserId!,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === calc max message width ===
    final double messageMaxWidth = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        backgroundColor: colors.background,
        elevation: 1,
        title: Row(
          children: [
            ClipOval(
              child: widget.avatarUrl.isNotEmpty
                  ? Image.network(
                      widget.avatarUrl,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.chatName,
                style: AppTextStyles.size18weight5(colors.text),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // === report button ===
        actions: [
          IconButton(
            onPressed: () => AppInputDialog.show(
              title: "Report User",
              subtitle: "Why are you reporting ${widget.chatName}?",
              hintText: "Reason (e.g. Harassment, Spam...)",
              actionText: "Report",
              actionColor: Colors.red,
              onSubmit: (reason) async => await _chatController.onReportTap(
                // open report dialog
                context,
                reason: reason,
                receiverId: widget.receiverId,
              ),
              context: context,
            ),
            icon: Icon(Icons.flag, color: Colors.red, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: _messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return AppUnFoundPage(text: 'Error');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    // === to show the messages from bottom ===
                    children: snapshot.data!.docs
                        .map(
                          (doc) => AppMessageItem(
                            document: doc,
                            maxWidth: messageMaxWidth,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            AppMessageTextInput(
              controller: _controller,
              receiverId: widget.receiverId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 20, color: Colors.grey.shade600),
    );
  }
}
