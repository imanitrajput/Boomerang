import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';
import '../widgets/add_payment_sheet.dart';
import 'new_debt_screen.dart';

class DebtDetailsScreen extends StatelessWidget {
  final String debtId;

  const DebtDetailsScreen({super.key, required this.debtId});

  void _showAddPaymentSheet(BuildContext context, Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => AddPaymentSheet(debtId: debt.id, currency: debt.currency),
    );
  }

  void _deleteDebt(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this debt? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<DebtProvider>(context, listen: false).deleteDebt(id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<DebtProvider>(
      builder: (context, provider, child) {
        final debt = provider.debts.firstWhere((d) => d.id == debtId, orElse: () => Debt(type: TransactionType.borrow, personName: '', amount: 0, currency: 'USD', date: DateTime.now()));
        
        if (debt.personName.isEmpty) {
          return const Scaffold(body: Center(child: Text('Debt not found')));
        }

        final isLent = debt.type == TransactionType.lend;
        final color = isLent ? colorScheme.secondary : colorScheme.error;
        final progress = debt.amount > 0 ? (debt.totalPaid / debt.amount).clamp(0.0, 1.0) : 0.0;
        final formatter = NumberFormat.simpleCurrency(name: debt.currency);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Debt Details'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewDebtScreen(debt: debt)),
                    );
                  } else if (value == 'delete') {
                    _deleteDebt(context, debt.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                ],
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Text(debt.personName.isNotEmpty ? debt.personName[0].toUpperCase() : '?', style: textTheme.displaySmall),
                  ),
                  const SizedBox(height: 16),
                  Text(debt.personName, style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(debt.description, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                ],
              ),
              const SizedBox(height: 32),
              
              // Progress Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Repayment Progress', style: textTheme.titleLarge),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${(progress * 100).toInt()}%', style: textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                                    Text('Paid', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatRow('Amount Paid', formatter.format(debt.totalPaid), color, textTheme, colorScheme),
                              const SizedBox(height: 16),
                              _buildStatRow('Total Amount', formatter.format(debt.amount), colorScheme.onSurface, textTheme, colorScheme),
                              const SizedBox(height: 16),
                              _buildStatRow('Remaining', formatter.format(debt.remainingAmount), colorScheme.onSurface, textTheme, colorScheme),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Payment History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment History', style: textTheme.titleLarge),
                  if (debt.payments.length > 3)
                    TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 8),
              if (debt.payments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No payments yet.')),
                )
              else
                ...debt.payments.reversed.map((payment) => _buildPaymentItem(context, payment, debt.currency, colorScheme)).toList(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            onPressed: () => _showAddPaymentSheet(context, debt),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        Text(value, style: textTheme.titleMedium?.copyWith(color: valueColor)),
      ],
    );
  }

  Widget _buildPaymentItem(BuildContext context, Payment payment, String currency, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    final formatter = NumberFormat.simpleCurrency(name: currency);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(Icons.check_circle, color: colorScheme.onSecondaryContainer),
        ),
        title: Text(payment.note.isNotEmpty ? payment.note : 'Payment', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(payment.date), style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        trailing: Text(formatter.format(payment.amount), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
