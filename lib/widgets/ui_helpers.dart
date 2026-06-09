import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF64748B);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF6F8FC);
  static const teal = Color(0xFF0F766E);
  static const blue = Color(0xFF2563EB);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFE11D48);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, blue],
  );
}

class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: .08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: isLoading || onPressed == null
              ? null
              : AppColors.primaryGradient,
          color: isLoading || onPressed == null
              ? AppColors.muted.withValues(alpha: .35)
              : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (!isLoading && onPressed != null)
              BoxShadow(
                color: AppColors.blue.withValues(alpha: .28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: isLoading ? null : onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  Icon(icon ?? Icons.arrow_forward_rounded,
                      color: Colors.white),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showAppMessage(BuildContext context, String message,
    {bool error = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.rose : AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content:
          Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}
