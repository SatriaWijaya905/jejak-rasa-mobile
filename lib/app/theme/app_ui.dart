import 'package:flutter/material.dart';

import 'app_theme.dart';

class AppPageScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool useSafeArea;

  const AppPageScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = useSafeArea ? SafeArea(child: child) : child;
    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.bgSoft,
      body: body,
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final Color? backgroundColor;

  const AppPageHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
      child: Row(
        children: [
          if (leading != null) leading!,
          if (leading == null) const SizedBox(width: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(children: actions),
        ],
      ),
    );
  }
}

class AppRecipeCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final String? imageUrl;

  const AppRecipeCard({
    super.key,
    required this.title,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow(),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade200),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.42),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
