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
    Key? key,
    required this.avatarUrl,
    required this.name,
    required this.subtitle,
    required this.time,
    this.unreadCount = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ متغير مساعد لمعرفة هل الرسالة غير مقروءة
    bool isUnread = unreadCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            // (اختياري) تغيير لون الخلفية قليلاً إذا كانت غير مقروءة
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

                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // السطر الأول: الاسم والوقت
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
                                    // ✅ إذا غير مقروءة، نجعل الخط أعرض (Bold)
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
                                // ✅ إذا غير مقروءة: الوقت بلون أساسي وخط عريض
                                ? AppTextStyles.size14weight5(
                                    AppColors.light.primary,
                                  )
                                // إذا مقروءة: الوقت رمادي وعادي
                                : AppTextStyles.size14weight4(
                                    AppColors.light.secText,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // السطر الثاني: نص الرسالة
                      Text(
                        subtitle,
                        style: isUnread
                            // ✅ إذا غير مقروءة: النص أسود وخط متوسط السماكة
                            ? AppTextStyles.size14weight5(AppColors.light.text)
                            // إذا مقروءة: النص رمادي وخط رفيع
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

                // دائرة الاشعارات
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
                      style:
                          AppTextStyles.size14weight5(
                            AppColors.light.background,
                          ).copyWith(
                            fontSize: 12,
                          ), // تصغير الخط قليلاً ليناسب الدائرة
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
