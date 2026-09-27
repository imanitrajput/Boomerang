import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:csv/csv.dart' as csv;
import '../models/debt.dart';

import '../utils/download_helper_stub.dart'
    if (dart.library.html) '../utils/download_helper_web.dart'
    if (dart.library.io) '../utils/download_helper_io.dart';

class StorageService {
  static Future<void> exportJson(List<Debt> debts) async {
    final jsonList = debts.map((d) => d.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonList);
    await downloadFile('debts_export.json', jsonString);
  }

  static Future<void> exportCsv(List<Debt> debts) async {
    List<List<dynamic>> rows = [];
    rows.add(['ID', 'Type', 'Person', 'Amount', 'Currency', 'Date', 'Description', 'Total Paid', 'Payments (JSON)']);
    
    for (var debt in debts) {
      rows.add([
        debt.id,
        debt.type.name,
        debt.personName,
        debt.amount,
        debt.currency,
        debt.date.toIso8601String(),
        debt.description,
        debt.totalPaid,
        jsonEncode(debt.payments.map((p) => p.toJson()).toList()),
      ]);
    }

    String csvString = const csv.CsvEncoder().convert(rows);
    await downloadFile('debts_export.csv', csvString);
  }

  static Future<List<Debt>?> importJson() async {
    // For FilePicker 11+, we don't strictly need to request storage permission manually
    // for just picking a file. The OS handles the permission in the picker UI.
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final String content = utf8.decode(result.files.single.bytes!);
        final List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((json) => Debt.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error picking JSON file: $e');
    }
    return null;
  }

  static Future<List<Debt>?> importCsv() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final String content = utf8.decode(result.files.single.bytes!);
        List<List<dynamic>> rowsAsListOfValues = const csv.CsvDecoder().convert(content);
        
        if (rowsAsListOfValues.length <= 1) return []; // Only header or empty
        
        List<Debt> debts = [];
        for (int i = 1; i < rowsAsListOfValues.length; i++) {
          var row = rowsAsListOfValues[i];
          if (row.length >= 7) {
            List<Payment> payments = [];
            if (row.length >= 9) {
              try {
                var pJson = jsonDecode(row[8].toString()) as List;
                payments = pJson.map((j) => Payment.fromJson(j)).toList();
              } catch (e) {
                print('Error parsing payments in CSV: $e');
              }
            }

            debts.add(Debt(
              id: row[0].toString(),
              type: row[1].toString() == 'borrow' ? TransactionType.borrow : TransactionType.lend,
              personName: row[2].toString(),
              amount: double.tryParse(row[3].toString()) ?? 0.0,
              currency: row[4].toString(),
              date: DateTime.tryParse(row[5].toString()) ?? DateTime.now(),
              description: row[6].toString(),
              payments: payments,
            ));
          }
        }
        return debts;
      }
    } catch (e) {
      print('Error picking CSV file: $e');
    }
    return null;
  }
}
