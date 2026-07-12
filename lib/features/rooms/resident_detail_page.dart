import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../auth/models/app_user_model.dart';
import '../auth/services/user_service.dart';

class ResidentDetailPage extends StatefulWidget {
  final String tenantUid;
  final String roomNumber;

  const ResidentDetailPage({super.key, required this.tenantUid, required this.roomNumber});

  @override
  State<ResidentDetailPage> createState() => _ResidentDetailPageState();
}

class _ResidentDetailPageState extends State<ResidentDetailPage> {
  final _phoneController = TextEditingController();
  final _emergencyController = TextEditingController();
  final UserService _userService = UserService();
  bool _isSaving = false;
  bool _isInitialized = false;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await _userService.updateIdentity(
        widget.tenantUid,
        phone: _phoneController.text.trim(),
        emergencyContact: _emergencyController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data kontak berhasil disimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: Text('Detail Penghuni', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: FutureBuilder<AppUserModel?>(
        future: _userService.getUserProfile(widget.tenantUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Data penghuni tidak ditemukan', style: TextStyle(color: AppColors.textGrey)));
          }

          if (!_isInitialized) {
            _phoneController.text = user.phone ?? '';
            _emergencyController.text = user.emergencyContact ?? '';
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(user.email, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Kamar ${widget.roomNumber}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Kontak', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                CustomTextField(
                  label: 'Nomor Handphone',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  label: 'Kontak Darurat (Keluarga)',
                  controller: _emergencyController,
                  prefixIcon: Icons.emergency_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Simpan Data Kontak'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}