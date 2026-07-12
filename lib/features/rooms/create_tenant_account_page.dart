import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../auth/models/app_user_model.dart';
import '../auth/services/user_service.dart';
import 'models/room_model.dart';
import 'services/room_service.dart';

class CreateTenantAccountPage extends StatefulWidget {
  final RoomModel room;

  const CreateTenantAccountPage({super.key, required this.room});

  @override
  State<CreateTenantAccountPage> createState() => _CreateTenantAccountPageState();
}

class _CreateTenantAccountPageState extends State<CreateTenantAccountPage> {
  late final TextEditingController _nameController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final RoomService _roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.tenantName ?? '');
  }

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
        role: UserRole.penghuni,
        roomId: widget.room.id,
      ));

      final updatedRoom = RoomModel(
        id: widget.room.id,
        number: widget.room.number,
        status: widget.room.status,
        price: widget.room.price,
        tenantName: _nameController.text.trim(),
        tenantUid: credential.user!.uid,
      );
      await _roomService.updateRoom(updatedRoom);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun penghuni berhasil dibuat')),
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
        title: Text('Daftarkan Akun Penghuni', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kamar No. ${widget.room.number}', style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Nama Penghuni',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Email Penghuni',
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
              'Password ini dipakai penghuni untuk login pertama kali. Sampaikan langsung ke penghuninya.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleCreate,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Buat Akun'),
            ),
          ],
        ),
      ),
    );
  }
}