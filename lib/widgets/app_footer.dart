import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/link_service.dart';
import '../services/update_service.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22304A).withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'v${UpdateService.currentVersion}',
              style: TextStyle(
                color: Color(0xFF22304A),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: LinkService.openGitHubProfile,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  strings.createdBy,
                  style: const TextStyle(
                    color: Color(0xFF31415F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
