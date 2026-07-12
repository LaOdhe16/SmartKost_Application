import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'models/room_model.dart';
import 'services/room_service.dart';

class AddRoomPage extends StatefulWidget {
  final RoomModel? existingRoom; 

  const AddRoomPage({super.key, this.existingRoom});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  late final TextEditingController _numberController;
  late final TextEditingController _priceController;
  late final TextEditingController _tenantController;
  late RoomStatus _status;
  DateTime? _contractStart;
  DateTime? _contractEnd;
  bool _isLoading = false;
  final RoomService _roomService = RoomService();

  bool get _isEditMode => widget.existingRoom != null;

  @override
  void initState() {
    super.initState();
    final room = widget.existingRoom;
    _numberController = TextEditingController(text: room?.number ?? '');
    _priceController = TextEditingController(text: room?.price.toString() ?? '');
    _tenantController = TextEditingController(text: room?.tenantName ?? '');
    _status = room?.status ?? RoomStatus.kosong;
    _contractStart = room?.contractStart;
    _contractEnd = room?.contractEnd;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _priceController.dispose();
    _tenantController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _contractStart : _contractEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _contractStart = picked;
        } else {
          _contractEnd = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum diatur';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleSave() async {
    if (_numberController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor kamar dan tarif wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final room = RoomModel(
        id: widget.existingRoom?.id ?? '',
        number: _numberController.text.trim(),
        status: _status,
        price: int.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        tenantName: _tenantController.text.trim().isEmpty ? null : _tenantController.text.trim(),
        tenantUid: widget.existingRoom?.tenantUid,
        contractStart: _contractStart,
        contractEnd: _contractEnd,
      );

      if (_isEditMode) {
        await _roomService.updateRoom(room);
      } else {
        await _roomService.addRoom(room);
      }

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
        title: Text(
          _isEditMode ? 'Edit Kamar' : 'Tambah Kamar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Nomor Kamar',
              controller: _numberController,
              prefixIcon: Icons.tag_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Tarif per Bulan',
              controller: _priceController,
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Nama Penghuni (opsional)',
              controller: _tenantController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Masa Kontrak Sewa', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: true),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider)),
                    child: Text('Mulai: ${_formatDate(_contractStart)}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: false),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.divider)),
                    child: Text('Berakhir: ${_formatDate(_contractEnd)}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Status Kamar', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: RoomStatus.values.map((status) {
                final selected = _status == status;
                return ChoiceChip(
                  label: Text(status.label),
                  selected: selected,
                  selectedColor: status.color.withOpacity(0.18),
                  labelStyle: TextStyle(
                    color: selected ? status.color : AppColors.textGrey,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  side: BorderSide(color: selected ? status.color : AppColors.divider),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => setState(() => _status = status),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_isEditMode ? 'Simpan Perubahan' : 'Simpan Kamar'),
            ),
          ],
        ),
      ),
    );
  }
}