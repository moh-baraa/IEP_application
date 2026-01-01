import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';

AppColorScheme colors = AppColors.light;

class AppCatagoriesList extends StatefulWidget {
  const AppCatagoriesList({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  final List<String> categories;
  final Function(String) onSelected;

  @override
  State<AppCatagoriesList> createState() => _AppCatagoriesListState();
}

class _AppCatagoriesListState extends State<AppCatagoriesList> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              // modern radio button
              checkmarkColor: colors.background,
              label: Text(widget.categories[index]),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedIndex = index);
                // === excute onSelected function using the catagorie choosed ===
                widget.onSelected(widget.categories[index]);
              },
              selectedColor: colors.primary,
              labelStyle: isSelected
                  ? AppTextStyles.size14weight5(colors.background)
                  : AppTextStyles.size14weight4(colors.text),
              backgroundColor: colors.container,
              side: BorderSide.none, // without default border, for better look
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}
