import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';

class AddPaymentSheet extends StatefulWidget {
  final String debtId;
  final String currency;

  const AddPaymentSheet({
    super.key,
    required this.debtId,
    required this.currency,
  });

  @override
  State<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _note = '';

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final payment = Payment(
        amount: _amount,
        date: DateTime.now(),
        note: _note,
      );

      Provider.of<DebtProvider>(context, listen: false).addPayment(widget.debtId, payment);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Payment', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${widget.currency} ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid number';
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
              maxLines: 2,
              onSaved: (value) => _note = value ?? '',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: const Text('Save Payment'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
