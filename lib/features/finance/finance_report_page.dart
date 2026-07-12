import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../invoices/models/invoice_model.dart';
import '../invoices/services/invoice_service.dart';
import 'add_expense_page.dart';
import 'models/expense_model.dart';
import 'services/expense_service.dart';
import 'services/export_service.dart';

class FinanceReportPage extends StatefulWidget {
  const FinanceReportPage({super.key});

  @override
  State<FinanceReportPage> createState() => _FinanceReportPageState();
}

class _FinanceReportPageState extends State<FinanceReportPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  bool _isExporting = false;
  final ExportService _exportService = ExportService();

  String _formatPrice(int price) =>
      price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  Future<void> _handleExport(List<InvoiceModel> monthInvoices, List<ExpenseModel> monthExpenses) async {
    setState(() => _isExporting = true);
    try {
      await _exportService.exportMonthlyReport(
        month: _selectedMonth,
        paidInvoices: monthInvoices,
        expenses: monthExpenses,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _confirmDeleteExpense(String id, ExpenseService service) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Hapus Pengeluaran?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text('Data ini akan dihapus permanen.', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await service.deleteExpense(id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.roomFilled, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invoiceService = InvoiceService();
    final expenseService = ExpenseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Laporan Keuangan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage()));
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: StreamBuilder<List<InvoiceModel>>(
        stream: invoiceService.getAllInvoices(),
        builder: (context, invoiceSnapshot) {
          return StreamBuilder<List<ExpenseModel>>(
            stream: expenseService.getAllExpenses(),
            builder: (context, expenseSnapshot) {
              if (invoiceSnapshot.connectionState == ConnectionState.waiting ||
                  expenseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final allInvoices = invoiceSnapshot.data ?? [];
              final allExpenses = expenseSnapshot.data ?? [];

              final monthInvoices = allInvoices.where((inv) {
                return inv.status == InvoiceStatus.lunas &&
                    inv.paidAt != null &&
                    inv.paidAt!.year == _selectedMonth.year &&
                    inv.paidAt!.month == _selectedMonth.month;
              }).toList();

              final monthExpenses = allExpenses.where((exp) {
                return exp.date.year == _selectedMonth.year && exp.date.month == _selectedMonth.month;
              }).toList();

              final totalIncome = monthInvoices.fold<int>(0, (sum, inv) => sum + inv.amount);
              final totalExpense = monthExpenses.fold<int>(0, (sum, exp) => sum + exp.amount);
              final netProfit = totalIncome - totalExpense;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Month selector + tombol export
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => _changeMonth(-1),
                                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                              ),
                              Text(
                                '${_monthNames[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _changeMonth(1),
                                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                                  ),
                                  IconButton(
                                    onPressed: _isExporting
                                        ? null
                                        : () => _handleExport(monthInvoices, monthExpenses),
                                    icon: _isExporting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                          )
                                        : const Icon(Icons.ios_share_rounded, color: AppColors.primary, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Kartu Laba Bersih (paling menonjol)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: netProfit >= 0
                                    ? [AppColors.primary, AppColors.primaryDark]
                                    : [AppColors.roomFilled, const Color(0xFFB71C1C)],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  netProfit >= 0 ? 'Laba Bersih' : 'Rugi Bersih',
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Rp ${_formatPrice(netProfit.abs())}',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Kartu Pemasukan & Pengeluaran
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    boxShadow: AppShadows.tight,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.arrow_downward_rounded, color: AppColors.roomEmpty, size: 18),
                                      const SizedBox(height: 8),
                                      Text('Rp ${_formatPrice(totalIncome)}',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                                      const Text('Pemasukan', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    boxShadow: AppShadows.tight,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, color: AppColors.roomFilled, size: 18),
                                      const SizedBox(height: 8),
                                      Text('Rp ${_formatPrice(totalExpense)}',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                                      const Text('Pengeluaran', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Rincian Pengeluaran', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
                    ),
                  ),
                  if (monthExpenses.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.tight,
                          ),
                          child: const Text('Belum ada pengeluaran bulan ini.', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final exp = monthExpenses[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                boxShadow: AppShadows.tight,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.roomFilled.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Icon(exp.category.icon, color: AppColors.roomFilled, size: 18),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(exp.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        Text(exp.category.label, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Text('Rp ${_formatPrice(exp.amount)}',
                                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    onPressed: () => _confirmDeleteExpense(exp.id, expenseService),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: monthExpenses.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}