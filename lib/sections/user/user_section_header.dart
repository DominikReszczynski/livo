import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/main_global.dart';
import 'package:flutter/material.dart';

class UserSectionHeader extends StatelessWidget {
  const UserSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = loggedUser?.username ?? '';
    final email = loggedUser?.email ?? '';
    final initial = (username.isNotEmpty ? username : email).isNotEmpty
        ? (username.isNotEmpty ? username[0] : email[0]).toUpperCase()
        : '?';

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 44,
                  color: Colors.grey.shade700,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nazwa
            AutoSizeText(
              username.isNotEmpty ? username : email,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),

            // Email
            if (username.isNotEmpty && email.isNotEmpty)
              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(.65),
                  fontWeight: FontWeight.w600,
                ),
              ),

            const SizedBox(height: 16),
            const Divider(indent: 24, endIndent: 24, height: 1),
          ],
        ),
      ),
    );
  }
}
