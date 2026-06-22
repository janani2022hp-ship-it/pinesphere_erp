// features/student/presentation/widgets/shared/student_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class StudentBottomNav extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,         label: "Home"),
    (icon: Icons.menu_book_outlined,  activeIcon: Icons.menu_book_rounded,    label: "Courses"),
    (icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded,   label: "Tasks"),
    (icon: Icons.smart_toy_outlined,  activeIcon: Icons.smart_toy_rounded,    label: "AI"),
    (icon: Icons.person_outline,      activeIcon: Icons.person_rounded,       label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),

      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primarySubtle
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textGrey,
                          size: 22,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}