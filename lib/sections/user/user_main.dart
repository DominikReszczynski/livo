import 'package:cas_house/providers/user_provider.dart';
import 'package:cas_house/sections/login.dart';
import 'package:cas_house/sections/user/user_section_header.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/main_global.dart'; // dla loggedUser & chosenMode

class UserSectionMain extends StatefulWidget {
  const UserSectionMain({super.key});

  @override
  State<UserSectionMain> createState() => _UserSectionMainState();
}

class _UserSectionMainState extends State<UserSectionMain> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<UserProvider>(builder: (context, userProvider, _) {
      final email = loggedUser?.email ?? '';
      final username = loggedUser?.username ?? '';

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          const UserSectionHeader(),
          const SizedBox(height: 16),

          // KARTA: Dane i akcje
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(username,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(email),
                  trailing: IconButton(
                    tooltip: 'Kopiuj e-mail',
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: email.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(ClipboardData(text: email));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Adres e-mail skopiowany')),
                            );
                          },
                  ),
                ),
                const Divider(height: 1),

                // Przełącznik trybu
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: chosenMode,
                  builder: (context, mode, __) {
                    final isDark = mode == ThemeMode.dark;
                    return SwitchListTile.adaptive(
                      secondary:
                          Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                      title: const Text('Tryb ciemny'),
                      value: isDark,
                      onChanged: (v) => chosenMode.value =
                          v ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Wylogowanie
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Wyloguj się'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              userProvider.logout();
              UserServices().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      );
    });
  }
}
