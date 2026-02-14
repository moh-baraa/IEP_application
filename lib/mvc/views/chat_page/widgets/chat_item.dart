import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

final colors = AppColors.light;

class ChatListItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String subtitle;
  final String time;
  final int unreadCount;
  final VoidCallback? onTap;

  const ChatListItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // === to check if the message unread  ===
    bool isUnread = unreadCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            color: isUnread ? colors.secondary : colors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                // Avatar
                ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 52,
                      height: 52,
                      color: colors.container,
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: colors.secText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === the name and the data ===
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style:
                                  AppTextStyles.size16weight6(
                                    AppColors.light.text,
                                  ).copyWith(
                                    fontWeight: isUnread
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: isUnread
                                ? AppTextStyles.size14weight5(
                                    AppColors.light.primary,
                                  )
                                : AppTextStyles.size14weight4(
                                    AppColors.light.secText,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // === last message text ===
                      Text(
                        subtitle,
                        style: isUnread
                            ? AppTextStyles.size14weight5(AppColors.light.text)
                            : AppTextStyles.size14weight4(
                                AppColors.light.secText,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // === notification cyrcle ===
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.light.primary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: AppTextStyles.size14weight5(
                        AppColors.light.background,
                      ).copyWith(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
      ],
    );
  }
}
