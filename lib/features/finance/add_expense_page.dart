import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'models/expense_model.dart';
import 'services/expense_service.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  ExpenseCategory _category = ExpenseCategory.listrik;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;
  final ExpenseService _expenseService = ExpenseService();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _handleSave() async {
    final amount = int.tryParse(_amountController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (_descController.text.trim().isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi dan jumlah wajib diisi dengan benar')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _expenseService.addExpense(ExpenseModel(
        id: '',
        category: _category,
        description: _descController.text.trim(),
        amount: amount,
        date: _date,
      ));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text('Tambah Pengeluaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kategori', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ExpenseCategory.values.map((cat) {
                final selected = _category == cat;
                return ChoiceChip(
                  avatar: Icon(cat.icon, size: 16, color: selected ? AppColors.primary : AppColors.textGrey),
                  label: Text(cat.label),
                  selected: selected,
                  selectedColor: AppColors.primary.withOpacity(0.12),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textGrey,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Deskripsi',
              controller: _descController,
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Jumlah',
              controller: _amountController,
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tanggal', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: _pickDate,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider)),
              child: Text('${_date.day}/${_date.month}/${_date.year}'),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Pengeluaran'),
            ),
          ],
        ),
      ),
    );
  }
}