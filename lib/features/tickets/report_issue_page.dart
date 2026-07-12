import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import 'models/ticket_model.dart';
import 'services/ticket_service.dart';

class ReportIssuePage extends StatefulWidget {
  final String roomId;
  final String roomNumber;
  final String tenantUid;
  final String tenantName;

  const ReportIssuePage({
    super.key,
    required this.roomId,
    required this.roomNumber,
    required this.tenantUid,
    required this.tenantName,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  IssueCategory _category = IssueCategory.listrik;
  UrgencyLevel _urgency = UrgencyLevel.low;
  final _descController = TextEditingController();
  bool _isLoading = false;
  final TicketService _ticketService = TicketService();

  Future<void> _handleSubmit() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi keluhan wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _ticketService.createTicket(TicketModel(
        id: '',
        roomId: widget.roomId,
        roomNumber: widget.roomNumber,
        tenantUid: widget.tenantUid,
        tenantName: widget.tenantName,
        category: _category,
        urgency: _urgency,
        description: _descController.text.trim(),
        status: TicketStatus.open,
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keluhan berhasil dilaporkan')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $e')),
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
        title: Text('Laporkan Keluhan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kategori Kerusakan', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: IssueCategory.values.map((cat) {
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
            Text('Tingkat Urgensi', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: UrgencyLevel.values.map((level) {
                final selected = _urgency == level;
                return ChoiceChip(
                  label: Text(level.label),
                  selected: selected,
                  selectedColor: level.color.withOpacity(0.18),
                  labelStyle: TextStyle(
                    color: selected ? level.color : AppColors.textGrey,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: selected ? level.color : AppColors.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => setState(() => _urgency = level),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Deskripsi', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan kerusakan yang terjadi...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Laporan'),
            ),
          ],
        ),
      ),
    );
  }
}