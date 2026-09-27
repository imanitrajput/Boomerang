import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/debt.dart';
import '../services/notification_service.dart';

class DebtProvider with ChangeNotifier {
  List<Debt> _debts = [];
  bool _isLoading = true;

  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;

  List<Debt> get activeDebts =>
      _debts.where((debt) => !debt.isPaidOff).toList();

  Map<String, double> get totalBorrowedByCurrency {
    final map = <String, double>{};
    for (var debt in activeDebts.where((d) => d.type == TransactionType.borrow)) {
      map[debt.currency] = (map[debt.currency] ?? 0.0) + debt.remainingAmount;
    }
    return map;
  }

  Map<String, double> get totalLentByCurrency {
    final map = <String, double>{};
    for (var debt in activeDebts.where((d) => d.type == TransactionType.lend)) {
      map[debt.currency] = (map[debt.currency] ?? 0.0) + debt.remainingAmount;
    }
    return map;
  }

  Set<String> get usedCurrencies {
    return activeDebts.map((d) => d.currency).toSet();
  }

  double get totalBorrowed => activeDebts
      .where((debt) => debt.type == TransactionType.borrow)
      .fold(0.0, (sum, debt) => sum + debt.remainingAmount);

  double get totalLent => activeDebts
      .where((debt) => debt.type == TransactionType.lend)
      .fold(0.0, (sum, debt) => sum + debt.remainingAmount);

  DebtProvider() {
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = prefs.getStringList('debts') ?? [];
    _debts = debtsJson.map((json) => Debt.fromJson(jsonDecode(json))).toList();
    
    // Sort debts by date, newest first
    _debts.sort((a, b) => b.date.compareTo(a.date));
    
    _isLoading = false;
    notifyListeners();

    _rescheduleActiveReminders();
  }

  Future<void> _rescheduleActiveReminders() async {
    for (var debt in activeDebts) {
      await NotificationService.scheduleDebtReminder(
        id: debt.id.hashCode,
        personName: debt.personName,
        amount: debt.amount,
        currency: debt.currency,
        scheduledDate: debt.date,
      );
    }
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = _debts.map((debt) => jsonEncode(debt.toJson())).toList();
    await prefs.setStringList('debts', debtsJson);
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    _debts.add(debt);
    _debts.sort((a, b) => b.date.compareTo(a.date));
    await _saveDebts();
    
    // Schedule reminder
    await NotificationService.scheduleDebtReminder(
      id: debt.id.hashCode,
      personName: debt.personName,
      amount: debt.amount,
      currency: debt.currency,
      scheduledDate: debt.date,
    );
  }

  Future<void> updateDebt(Debt updatedDebt) async {
    final index = _debts.indexWhere((d) => d.id == updatedDebt.id);
    if (index >= 0) {
      _debts[index] = updatedDebt;
      _debts.sort((a, b) => b.date.compareTo(a.date));
      await _saveDebts();

      // Reschedule reminder
      await NotificationService.cancelDebtReminder(updatedDebt.id.hashCode);
      if (!updatedDebt.isPaidOff) {
        await NotificationService.scheduleDebtReminder(
          id: updatedDebt.id.hashCode,
          personName: updatedDebt.personName,
          amount: updatedDebt.amount,
          currency: updatedDebt.currency,
          scheduledDate: updatedDebt.date,
        );
      }
    }
  }

  Future<void> deleteDebt(String debtId) async {
    _debts.removeWhere((d) => d.id == debtId);
    await _saveDebts();
    await NotificationService.cancelDebtReminder(debtId.hashCode);
  }

  Future<void> addPayment(String debtId, Payment payment) async {
    final index = _debts.indexWhere((d) => d.id == debtId);
    if (index >= 0) {
      _debts[index].payments.add(payment);
      await _saveDebts();
      
      // If paid off, cancel reminder
      if (_debts[index].isPaidOff) {
        await NotificationService.cancelDebtReminder(debtId.hashCode);
      }
    }
  }

  Future<void> replaceAllDebts(List<Debt> newDebts) async {
    _debts = newDebts;
    _debts.sort((a, b) => b.date.compareTo(a.date));
    await _saveDebts();
    _rescheduleActiveReminders();
  }
}
