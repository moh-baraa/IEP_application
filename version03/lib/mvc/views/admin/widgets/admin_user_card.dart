import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

class AdminUserCard extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final String role; // user, admin, municipality
  final bool isBlocked;
  final VoidCallback onChatTap;
  final VoidCallback onBlockTap;

  const AdminUserCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
    required this.isBlocked,
    required this.onChatTap,
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isBlocked
            ? Border.all(color: colors.red.withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // === the image ===
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primary.withOpacity(0.1),
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Icon(Icons.person, color: colors.primary)
                    : null,
              ),
              
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isBlocked ? colors.red : colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // === informations ===
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.size14weight5(colors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: TextStyle(fontSize: 12, color: colors.secText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // === show the role ===
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role, colors).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(role, colors),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === buttons ===
          Row(
            children: [
              // === chat button ===
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: colors.primary,
                  size: 20,
                ),
                onPressed: onChatTap,
              ),
              // === block button ===
              IconButton(
                icon: Icon(
                  isBlocked ? Icons.lock_open : Icons.block,
                  color: isBlocked ? colors.green : colors.red,
                  size: 20,
                ),
                onPressed: onBlockTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Color _getRoleColor(String role, AppColorScheme colors) {
    // === all in lower case for comparsion ===
    switch (role) {
      case 'admin':
        return colors.primary; // color for admin
      case 'municipality':
        return Colors.orange; // color for municipality
      default:
        return colors.secText; // for normal user
    }
  }
}
