import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'data_management_screen.dart';
import '../widgets/emoji_profile_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _editAvatar(BuildContext context, UserProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmojiProfilePicker(
        initialEmoji: provider.profileEmoji,
        onEmojiSelected: (emoji) {
          provider.setProfileEmoji(emoji);
        },
      ),
    );
  }

  void _editName(BuildContext context, UserProvider provider) {
    final controller = TextEditingController(text: provider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter your name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.setUserName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Row(
            children: [
              GestureDetector(
                onTap: () => _editAvatar(context, userProvider),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      child: Text(
                        userProvider.profileEmoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 2),
                        ),
                        child: Icon(Icons.camera_alt, size: 12, color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userProvider.userName, style: textTheme.titleLarge),
                    Text('Account Profile', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _editName(context, userProvider),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Appearance', style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Day')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Night')),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_system_daydream), label: Text('System')),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              themeProvider.setThemeMode(newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Data Management', style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Import or export your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DataManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('About', style: textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Disclaimer & Privacy Policy'),
            onTap: () {
               showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy & Disclaimer'),
                  content: const SingleChildScrollView(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                        children: [
                          TextSpan(text: 'Welcome to '),
                          TextSpan(text: 'Boomerang', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ', a free, open-source, and local-first debt management application. We believe that your financial data is yours alone. This document outlines how your data is handled and the limitations of liability when using the application.\n\n'),

                          TextSpan(text: 'Privacy Policy\n', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 2.0)),
                          TextSpan(text: '1. Local-First & Zero Data Collection\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'Boomerang is designed entirely as a local-first application. This means that all data you enter into the app is stored locally on your device.\n'),
                          TextSpan(text: 'We do not collect, harvest, or retain any personal or financial data.\n'),
                          TextSpan(text: 'We do not have servers that sync, back up, or process your information.\n\n'),

                          TextSpan(text: '2. No External Services, Third Parties, or Ads\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'Because your privacy is our priority:\n'),
                          TextSpan(text: '\u2022 We do not use your data for advertising purposes.\n'),
                          TextSpan(text: '\u2022 We do not integrate with third-party trackers, analytics, or external services that transmit your data off your device.\n'),
                          TextSpan(text: '\u2022 Your information is never sold, rented, or shared with anyone in any shape or form.\n\n'),

                          TextSpan(text: '3. Data Transfer and Import/Export\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'If you need to move your Boomerang data to a different device, you must manually use the provided Import/Export functionality. Because this process happens entirely outside of our control, you are solely responsible for securely handling the exported files and completing the transfer.\n\n'),

                          TextSpan(text: 'Disclaimer & Limitation of Liability\n', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 2.0)),
                          TextSpan(text: '1. User Responsibility for Data\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'As the user, you retain complete ownership of—and responsibility for—the data you input into Boomerang. Because the app does not back up your data to any external server, it is highly recommended that you independently back up your device and your exported files.\n\n'),

                          TextSpan(text: '2. No Liability for Data Loss\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'By using Boomerang, you acknowledge and agree that the developer(s) of this application are not responsible or liable for any lost, corrupted, or deleted data. This includes, but is not limited to:\n'),
                          TextSpan(text: '\u2022 Accidental deletion by the user.\n'),
                          TextSpan(text: '\u2022 Data loss due to device failure, software crashes, or operating system updates.\n'),
                          TextSpan(text: '\u2022 Data lost or corrupted during the Import/Export transit process between devices.\n\n'),

                          TextSpan(text: '3. Open Source & "As Is" Software\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'Boomerang is an open-source application provided on an "as is" and "as available" basis, without warranties of any kind, either express or implied. The developer(s) do not guarantee that the app will be error-free or completely uninterrupted.\n\n'),

                          TextSpan(text: '4. Not Financial Advice\n', style: TextStyle(fontWeight: FontWeight.bold, height: 1.8)),
                          TextSpan(text: 'Boomerang is a tool designed to help you track debts; it does not provide professional financial, legal, or accounting advice.\n\n'),

                          TextSpan(
                            text: 'By downloading and using Boomerang, you acknowledge that you have read, understood, and agreed to this Privacy Policy and Disclaimer.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'Version 0.1.9 Beta',
              style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
