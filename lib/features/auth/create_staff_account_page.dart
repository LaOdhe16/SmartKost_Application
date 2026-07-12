import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/custom_text_field.dart';
import 'models/app_user_model.dart';
import 'services/user_service.dart';

class CreateStaffAccountPage extends StatefulWidget {
  const CreateStaffAccountPage({super.key});

  @override
  State<CreateStaffAccountPage> createState() => _CreateStaffAccountPageState();
}

class _CreateStaffAccountPageState extends State<CreateStaffAccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua kolom (password minimal 6 karakter)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = await _authService.createTenantAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await UserService().createUserProfile(AppUserModel(
        uid: credential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: UserRole.moderator,
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun staf/moderator berhasil dibuat')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat akun: $e')),
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
        title: Text('Tambah Staf/Moderator', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Akun ini akan punya akses terbatas: bisa lihat denah kamar, daftarkan penghuni, dan respons keluhan — tapi tidak bisa lihat keuangan atau ubah data kamar.',
                      style: TextStyle(fontSize: 11, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Nama Staf',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Email Staf',
              controller: _emailController,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Password Awal',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Password ini dipakai staf untuk login pertama kali. Sampaikan langsung ke orangnya.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Buat Akun Staf'),
            ),
          ],
        ),
      ),
    );
  }
}