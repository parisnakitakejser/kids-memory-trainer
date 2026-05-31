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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF22304A).withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'v${UpdateService.currentVersion}',
              style: TextStyle(
                color: Color(0xFF6C7890),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 7),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: LinkService.openGitHubProfile,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                child: Text(
                  strings.createdBy,
                  style: const TextStyle(
                    color: Color(0xFF6C7890),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
