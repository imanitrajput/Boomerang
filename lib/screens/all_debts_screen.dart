import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';
import 'debt_details_screen.dart';

class AllDebtsScreen extends StatefulWidget {
  const AllDebtsScreen({super.key});

  @override
  State<AllDebtsScreen> createState() => _AllDebtsScreenState();
}

class _AllDebtsScreenState extends State<AllDebtsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt History'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Active', 'Repaid'].map((f) {
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _filter = f;
                        });
                      },
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<DebtProvider>(
              builder: (context, provider, child) {
                final allDebts = provider.debts;
                final filteredDebts = allDebts.where((d) {
                  if (_filter == 'Active') return !d.isPaidOff;
                  if (_filter == 'Repaid') return d.isPaidOff;
                  return true;
                }).toList();

                if (filteredDebts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No debts found.', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDebts.length,
                  itemBuilder: (context, index) {
                    final debt = filteredDebts[index];
                    return _buildDebtListItem(context, debt);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtListItem(BuildContext context, Debt debt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isLent = debt.type == TransactionType.lend;
    final isPaidOff = debt.isPaidOff;
    
    Color color = isLent ? colorScheme.secondary : colorScheme.error;
    if (isPaidOff) {
      color = colorScheme.outline;
    }

    final formatter = NumberFormat.simpleCurrency(name: debt.currency);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isPaidOff ? colorScheme.surfaceVariant : (isLent ? colorScheme.secondaryContainer : colorScheme.errorContainer),
          child: Icon(
            isPaidOff ? Icons.check : (isLent ? Icons.arrow_outward : Icons.arrow_downward),
            color: isPaidOff ? colorScheme.onSurfaceVariant : (isLent ? colorScheme.onSecondaryContainer : colorScheme.onErrorContainer),
          ),
        ),
        title: Text(debt.personName, style: theme.textTheme.titleMedium?.copyWith(
          decoration: isPaidOff ? TextDecoration.lineThrough : null,
          color: isPaidOff ? colorScheme.outline : null,
        )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(debt.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(DateFormat('MMM dd, yyyy').format(debt.date), style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isLent ? '+' : '-'}${formatter.format(debt.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isPaidOff)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('REPAID', style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.bold)),
              )
            else if (debt.totalPaid > 0)
               Text('Left: ${formatter.format(debt.remainingAmount)}', style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DebtDetailsScreen(debtId: debt.id)),
          );
        },
      ),
    );
  }
}
