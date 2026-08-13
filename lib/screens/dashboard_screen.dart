import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../providers/user_provider.dart';
import '../models/debt.dart';
import 'new_debt_screen.dart';
import 'debt_details_screen.dart';
import 'all_debts_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Boomerang', style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeDebts = provider.activeDebts;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        child: Text(userProvider.profileEmoji, style: const TextStyle(fontSize: 20)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hello, ${userProvider.userName}', style: textTheme.titleLarge),
                            Text('Here\'s your summary for today.', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              ),
              const SizedBox(height: 24),
              Consumer<DebtProvider>(
                builder: (context, debtProvider, child) {
                  final currencies = debtProvider.usedCurrencies.toList();
                  if (currencies.isEmpty) {
                    // Show empty state or default USD zero cards
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildSummaryCard(context, title: 'Money Coming Back', amount: 0, currency: 'USD', isPositive: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSummaryCard(context, title: 'Money I Owe', amount: 0, currency: 'USD', isPositive: false)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: currencies.map((currency) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  title: 'Money Coming Back',
                                  amount: debtProvider.totalLentByCurrency[currency] ?? 0,
                                  currency: currency,
                                  isPositive: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSummaryCard(
                                  context,
                                  title: 'Money I Owe',
                                  amount: debtProvider.totalBorrowedByCurrency[currency] ?? 0,
                                  currency: currency,
                                  isPositive: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Debts', style: textTheme.titleLarge),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllDebtsScreen()),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activeDebts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No active debts.')),
                )
              else
                ...activeDebts.map((debt) => _buildDebtItem(context, debt)).toList(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewDebtScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, {required String title, required double amount, required String currency, required bool isPositive}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final color = isPositive ? colorScheme.secondary : colorScheme.error;
    final bgColor = isPositive ? colorScheme.secondaryContainer.withOpacity(0.2) : colorScheme.errorContainer.withOpacity(0.3);
    final icon = isPositive ? Icons.arrow_downward : Icons.arrow_upward;
    final bgIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    // Determine symbol
    String symbol = '\$';
    switch (currency.toUpperCase()) {
      case 'AUD': symbol = 'A\$'; break;
      case 'INR': symbol = '₹'; break;
      case 'EUR': symbol = '€'; break;
      case 'GBP': symbol = '£'; break;
    }
    
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: amount == amount.toInt() ? 0 : 2);

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              bgIcon,
              size: 80,
              color: color.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${isPositive ? '' : '-'}${formatter.format(amount.abs())}',
                    style: textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currency,
                style: textTheme.bodySmall?.copyWith(color: color.withOpacity(0.6), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(BuildContext context, Debt debt) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    final isLent = debt.type == TransactionType.lend;
    final color = isLent ? colorScheme.secondary : colorScheme.error;
    final iconColor = isLent ? colorScheme.secondaryContainer : colorScheme.errorContainer;
    
    final progress = debt.amount > 0 ? (debt.totalPaid / debt.amount) : 0.0;
    
    final formatter = NumberFormat.currency(symbol: debt.currencySymbol, decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DebtDetailsScreen(debtId: debt.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: iconColor,
                    child: Text(debt.personName.isNotEmpty ? debt.personName[0].toUpperCase() : '?', style: TextStyle(color: colorScheme.onSurface)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(debt.personName, style: textTheme.titleMedium),
                        Text(debt.description, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${isLent ? '+' : '-'}${formatter.format(debt.remainingAmount)}', style: textTheme.titleMedium?.copyWith(color: color)),
                      Text(DateFormat('MMM dd, yyyy').format(debt.date), style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
