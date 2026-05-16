import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../coree/colors/app_colors.dart';
import '../../coree/theme/app_page_style.dart';

/// Aligné sur `expo/app/settings/storage.tsx`
class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  static const int _quotaGb = 2;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return DecoratedBox(
      decoration: context.appPageDecoration,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPad + 24, 16, 16),
              child: Row(
                children: [
                  Material(
                    color: context.appCardColor,
                    elevation: 2,
                    shadowColor: AppColors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.maybePop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Stockage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.storage_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '142 MB',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Utilisé sur $_quotaGb GB',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.grayDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                shadowColor: AppColors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StorageBar(
                        label: 'Scans et photos',
                        used: 68,
                        total: 200,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      _StorageBar(
                        label: 'Cache application',
                        used: 45,
                        total: 100,
                        color: AppColors.skyBlue,
                      ),
                      const SizedBox(height: 16),
                      _StorageBar(
                        label: 'Documents',
                        used: 29,
                        total: 100,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Material(
                color: context.appCardColor,
                elevation: 2,
                shadowColor: AppColors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Vider le cache',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  const _StorageBar({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
  });

  final String label;
  final int used;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = math.min(used / total, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Text(
              '$used MB / $total MB',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.grayLight),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    child: ColoredBox(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
