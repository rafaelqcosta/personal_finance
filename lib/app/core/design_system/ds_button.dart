import 'package:flutter/material.dart';

class DSButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool enabled;

  final Color? backgroundColor;
  final Color? textColor;

  const DSButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.enabled = true,

    this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColorScheme = backgroundColor ?? colorScheme.primary;
    final minWidth = MediaQuery.of(context).size.width / 4;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: SizedBox(
        height: 45,
        child: Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          color: enabled ? backgroundColorScheme : backgroundColorScheme.withAlpha(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: IntrinsicWidth(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leftIcon != null) ...[
                      Icon(leftIcon, size: 18, color: enabled ? textColor : Colors.grey),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
                      ),
                    ),
                    if (rightIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(rightIcon, size: 18, color: enabled ? textColor : Colors.grey),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
