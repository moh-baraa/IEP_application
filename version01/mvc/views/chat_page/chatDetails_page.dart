import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/core/widgets/snack_bar_state.dart';
import 'package:iep_app/mvc/controllers/chat_page/chat_controller.dart';
import 'package:iep_app/mvc/repositories/project_details.repositories.dart';
import 'package:iep_app/core/widgets/app_input_dialog.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late FocusNode _focusNode; // controlling the keyboard

  void _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isNotEmpty) {
      _controller.clear();
      await _chatController.sendMessage(widget.receiverId, msg);
    }
  }

  late Stream<QuerySnapshot> _messagesStream;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // intial the focusnode
    // === initial the stream ===
    _messagesStream = _chatController.getMessages(
      widget.receiverId,
      _auth.currentUser!.uid,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // === calc max message width ===
    final double messageMaxWidth = MediaQuery.of(context).size.width * 0.75;

    // === open report dialog ===
    void _showReportUserDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) => AppInputDialog(
          title: "Report User",
          subtitle: "Why are you reporting ${widget.chatName}?",
          hintText: "Reason (e.g. Harassment, Spam...)",
          actionText: "Report",
          actionColor: Colors.red,
          onSubmit: (reason) async {
            if (reason.trim().isEmpty) return;

            // // ✅ الحل الجذري للخطأ: حفظ الـ Messenger قبل العمليات غير المتزامنة
            // // هذا يمنع البحث عن الـ Ancestor بعد أن تكون الصفحة قد أُغلقت أو تغيرت حالتها
            // final messenger = ScaffoldMessenger.of(context); //?
            // final navigator = Navigator.of(
            //   //?
            //   context,
            // ); // مرجع للتنقل إذا احتجت إغلاق الديالوج يدوياً

            try {
              final repo = ProjectDetailsRepository();

              await repo.submitUserReport(
                reportedUserId: widget.receiverId,
                reporterId: _auth.currentUser!.uid,
                reason: reason,
              );

              if (context.mounted) {
                AppSnackBarState.show(
                  context,
                  color: colors.green,
                  content: 'User reported successfully',
                );
              }
            } catch (e) {
              if (context.mounted) {
                AppSnackBarState.show(
                  context,
                  color: colors.red,
                  content: 'Error: $e',
                );
              }
            }
          },
        ),
      );
    }

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
            onPressed: () => _showReportUserDialog(),
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
                        .map((doc) => _buildMessageItem(doc, messageMaxWidth))
                        .toList(),
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document, double maxWidth) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isMe = (data['senderId'] == _auth.currentUser!.uid);

    // === get message time ===
    Timestamp? timestamp = data['timestamp'] as Timestamp?;
    String formattedTime = '';
    if (timestamp != null) {
      // === 12 hour mode time ===
      formattedTime = TimeOfDay.fromDateTime(
        timestamp.toDate(),
      ).format(context);
    }
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xff375392) : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // === the message text ===
              Text(
                data['message'],
                style: TextStyle(
                  color: isMe ? colors.background : colors.text,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              // === the message time ===
              Text(
                formattedTime,
                style: AppTextStyles.size10weight4(
                  isMe ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode, // ✅ ربط الـ FocusNode
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xff375392)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
