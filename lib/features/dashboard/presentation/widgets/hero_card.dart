import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../couple/providers/couple_provider.dart';
import '../../providers/dashboard_providers.dart';

class HeroCard extends ConsumerStatefulWidget {
  const HeroCard({super.key});

  @override
  ConsumerState<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends ConsumerState<HeroCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} de ${months[dt.month]} de ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final couple = ref.watch(currentCoupleProvider).value;
    final currentUser = ref.watch(authStateProvider.select((s) => s.user));
    final partnerNameAsync = ref.watch(partnerNameProvider);
    final gold = Theme.of(context).extension<AppThemeExtension>()?.gold ?? AppColors.gold;

    if (couple == null) {
      return const SizedBox.shrink();
    }

    String capitalize(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

    final myName = capitalize(currentUser?.email.split('@').first ?? 'Tú');
    final partnerName = partnerNameAsync.value ?? 'Pareja';

    final now = DateTime.now();
    final createdAt = couple.createdAt;
    final duration = now.difference(createdAt);

    int years = now.year - createdAt.year;
    int months = now.month - createdAt.month;
    int days = now.day - createdAt.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month - 1, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final hours = duration.inHours % 24;
    final mins = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.favorite, color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text(
            '$myName & $partnerName',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: gold,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Juntos desde el ${_formatDate(couple.createdAt)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeBlock(context, years.toString(), 'Años', gold),
              _buildDivider(gold),
              _buildTimeBlock(context, months.toString(), 'Meses', gold),
              _buildDivider(gold),
              _buildTimeBlock(context, days.toString(), 'Días', gold),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeBlock(context, hours.toString().padLeft(2, '0'), 'Horas', gold),
              _buildDivider(gold),
              _buildTimeBlock(context, mins.toString().padLeft(2, '0'), 'Mins', gold),
              _buildDivider(gold),
              _buildTimeBlock(context, secs.toString().padLeft(2, '0'), 'Segs', gold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(BuildContext context, String value, String label, Color gold) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: gold,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color gold) {
    return Container(
      width: 1,
      height: 40,
      color: gold.withValues(alpha: 0.3),
    );
  }
}
