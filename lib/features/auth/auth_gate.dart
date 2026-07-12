import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/auth_service.dart';
import 'models/app_user_model.dart';
import 'services/user_service.dart';
import 'login_page.dart';
import '../home/home_page.dart';
import '../resident/resident_home_page.dart';

class AuthGate extends StatelessWidget {
  final String uid;

  const AuthGate({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserModel?>(
      stream: UserService().streamUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final userProfile = snapshot.data;

        if (userProfile == null) {
          // Profil tidak ditemukan (misal sudah di-checkout admin) -> tolak akses, JANGAN anggap admin
          return _AccessRevokedPage(uid: uid);
        }

        switch (userProfile.role) {
          case UserRole.admin:
            return const HomePage(role: UserRole.admin);
          case UserRole.moderator:
            return const HomePage(role: UserRole.moderator);
          case UserRole.penghuni:
            return ResidentHomePage(tenantName: userProfile.name, uid: uid);
        }
      },
    );
  }
}

class _AccessRevokedPage extends StatelessWidget {
  final String uid;

  const _AccessRevokedPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.roomFilled.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block_rounded, color: AppColors.roomFilled, size: 34),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Akses Dicabut',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Akun ini sudah tidak terdaftar sebagai penghuni aktif. '
                'Hubungi pengelola kost jika Anda merasa ini keliru.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}