import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../invoices/models/invoice_model.dart';
import '../models/expense_model.dart';

class ExportService {
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> exportMonthlyReport({
    required DateTime month,
    required List<InvoiceModel> paidInvoices,
    required List<ExpenseModel> expenses,
  }) async {
    final buffer = StringBuffer();
    final monthLabel = '${_monthNames[month.month - 1]} ${month.year}';

    buffer.writeln('Laporan Keuangan SmartKost - $monthLabel');
    buffer.writeln();

    // Pemasukan
    buffer.writeln('PEMASUKAN');
    buffer.writeln('Tanggal,Kamar,Penghuni,Jumlah');
    int totalIncome = 0;
    for (final inv in paidInvoices) {
      final date = inv.paidAt ?? inv.createdAt;
      buffer.writeln(
        '${date.day}/${date.month}/${date.year},'
        '${_csvEscape(inv.roomNumber)},'
        '${_csvEscape(inv.tenantName)},'
        '${inv.amount}',
      );
      totalIncome += inv.amount;
    }
    buffer.writeln(',,Total Pemasukan,$totalIncome');
    buffer.writeln();

    // Pengeluaran
    buffer.writeln('PENGELUARAN');
    buffer.writeln('Tanggal,Kategori,Deskripsi,Jumlah');
    int totalExpense = 0;
    for (final exp in expenses) {
      buffer.writeln(
        '${exp.date.day}/${exp.date.month}/${exp.date.year},'
        '${_csvEscape(exp.category.label)},'
        '${_csvEscape(exp.description)},'
        '${exp.amount}',
      );
      totalExpense += exp.amount;
    }
    buffer.writeln(',,Total Pengeluaran,$totalExpense');
    buffer.writeln();

    // Ringkasan
    final netProfit = totalIncome - totalExpense;
    buffer.writeln('RINGKASAN');
    buffer.writeln('Total Pemasukan,$totalIncome');
    buffer.writeln('Total Pengeluaran,$totalExpense');
    buffer.writeln('Laba/Rugi Bersih,$netProfit');

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'laporan_keuangan_${month.month}_${month.year}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Laporan Keuangan SmartKost - $monthLabel',
      text: 'Laporan keuangan bulan $monthLabel',
    );
  }
}