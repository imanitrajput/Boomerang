import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../services/storage_service.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final debtProvider = Provider.of<DebtProvider>(context, listen: false);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Export Data', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export JSON'),
            subtitle: const Text('Backup all data to a file'),
            onTap: () async {
              await StorageService.exportJson(debtProvider.debts);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export triggered')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export CSV'),
            subtitle: const Text('For spreadsheet apps'),
            onTap: () async {
              await StorageService.exportCsv(debtProvider.debts);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export triggered')));
              }
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          Text('Import Data', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Warning: Importing data will completely overwrite your existing records.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import JSON'),
            subtitle: const Text('Restore from backup'),
            onTap: () async {
              final debts = await StorageService.importJson();
              if (debts != null && context.mounted) {
                await debtProvider.replaceAllDebts(debts);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imported JSON successfully')));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_view),
            title: const Text('Import CSV'),
            subtitle: const Text('Restore from spreadsheet'),
            onTap: () async {
              final debts = await StorageService.importCsv();
              if (debts != null && context.mounted) {
                await debtProvider.replaceAllDebts(debts);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imported CSV successfully')));
              }
            },
          ),
        ],
      ),
    );
  }
}
