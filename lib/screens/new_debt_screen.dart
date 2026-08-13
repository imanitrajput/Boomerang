import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';

class NewDebtScreen extends StatefulWidget {
  final Debt? debt;

  const NewDebtScreen({super.key, this.debt});

  @override
  State<NewDebtScreen> createState() => _NewDebtScreenState();
}

class _NewDebtScreenState extends State<NewDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TransactionType _type;
  late String _personName;
  late double _amount;
  late String _currency;
  DateTime? _date;
  late String _description;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _type = widget.debt!.type;
      _personName = widget.debt!.personName;
      _amount = widget.debt!.amount;
      _currency = widget.debt!.currency;
      _date = widget.debt!.date;
      _description = widget.debt!.description;
    } else {
      _type = TransactionType.borrow;
      _personName = '';
      _amount = 0.0;
      _currency = 'USD';
      _date = null;
      _description = '';
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final debtProvider = Provider.of<DebtProvider>(context, listen: false);

      if (widget.debt != null) {
        final updatedDebt = Debt(
          id: widget.debt!.id,
          type: _type,
          personName: _personName,
          amount: _amount,
          currency: _currency,
          date: _date ?? DateTime.now(),
          description: _description,
          payments: widget.debt!.payments,
        );
        debtProvider.updateDebt(updatedDebt);
      } else {
        final newDebt = Debt(
          type: _type,
          personName: _personName,
          amount: _amount,
          currency: _currency,
          date: _date ?? DateTime.now(),
          description: _description,
        );
        debtProvider.addDebt(newDebt);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.debt != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              isEditing 
                ? 'Update the details of your transaction.' 
                : 'Record a new transaction accurately to keep your balances clear.', 
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
            ),
            const SizedBox(height: 24),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.borrow, label: Text('I Borrowed')),
                ButtonSegment(value: TransactionType.lend, label: Text('I Lent')),
              ],
              selected: {_type},
              onSelectionChanged: (Set<TransactionType> newSelection) {
                setState(() {
                  _type = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('Details', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _personName,
              decoration: const InputDecoration(labelText: 'Person or Entity Name'),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              onSaved: (value) => _personName = value!,
            ),
            const SizedBox(height: 24),
            Text('Financials', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Unit'),
                    value: _currency,
                    items: {
                      'USD': '\$ (USD)',
                      'EUR': '€ (EUR)',
                      'INR': '₹ (INR)',
                      'GBP': '£ (GBP)',
                      'AUD': 'A\$ (AUD)',
                      'CAD': 'C\$ (CAD)',
                      'JPY': '¥ (JPY)',
                    }.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _currency = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: isEditing ? _amount.toString() : '',
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid number';
                      return null;
                    },
                    onSaved: (value) => _amount = double.parse(value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Additional Info', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Expected Return Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(text: _date == null ? '' : DateFormat('MMM dd, yyyy').format(_date!)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _date = picked;
                  });
                }
              },
              validator: (value) => _date == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description / Note'),
              maxLines: 3,
              onSaved: (value) => _description = value ?? '',
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveForm,
              icon: Icon(isEditing ? Icons.update : Icons.save),
              label: Text(isEditing ? 'Update Transaction' : 'Save Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.labelLarge,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
