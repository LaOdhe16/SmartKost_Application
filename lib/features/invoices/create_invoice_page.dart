import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../rooms/models/room_model.dart';
import '../rooms/services/room_service.dart';
import 'models/invoice_model.dart';
import 'services/invoice_service.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String? _selectedRoomId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  final InvoiceService _invoiceService = InvoiceService();

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _handleCreate(List<RoomModel> occupiedRooms) async {
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kamar terlebih dahulu')),
      );
      return;
    }

    final selectedRoom = occupiedRooms.firstWhere((r) => r.id == _selectedRoomId);

    setState(() => _isLoading = true);
    try {
      await _invoiceService.createInvoice(InvoiceModel(
        id: '',
        roomId: selectedRoom.id,
        roomNumber: selectedRoom.number,
        tenantUid: selectedRoom.tenantUid!,
        tenantName: selectedRoom.tenantName ?? '-',
        amount: selectedRoom.price,
        dueDate: _dueDate,
        status: InvoiceStatus.belumBayar,
        createdAt: DateTime.now(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tagihan berhasil dibuat')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat tagihan: $e')),
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
        title: Text('Buat Tagihan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream: RoomService().getRooms(),
        builder: (context, snapshot) {
          final occupiedRooms = (snapshot.data ?? []).where((r) => r.tenantUid != null).toList();

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (occupiedRooms.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada kamar yang berpenghuni. Daftarkan akun penghuni terlebih dahulu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ),
            );
          }

          // Kalau room yang terpilih sebelumnya sudah tidak ada di list (misal di-checkout), reset pilihan
          final validIds = occupiedRooms.map((r) => r.id).toSet();
          if (_selectedRoomId != null && !validIds.contains(_selectedRoomId)) {
            _selectedRoomId = null;
          }

          final selectedRoom = _selectedRoomId == null
              ? null
              : occupiedRooms.firstWhere((r) => r.id == _selectedRoomId);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Pilih Kamar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Pilih kamar penghuni'),
                      value: _selectedRoomId,
                      items: occupiedRooms.map((room) {
                        return DropdownMenuItem<String>(
                          value: room.id,
                          child: Text('Kamar ${room.number} · ${room.tenantName}'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedRoomId = value),
                    ),
                  ),
                ),
                if (selectedRoom != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah Tagihan', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        Text('Rp ${selectedRoom.price}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text('Jatuh Tempo', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: _pickDueDate,
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider)),
                  child: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleCreate(occupiedRooms),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Buat Tagihan'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}