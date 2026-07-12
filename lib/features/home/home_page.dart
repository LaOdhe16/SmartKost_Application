import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/room_tile.dart';
import '../auth/login_page.dart';
import '../rooms/models/room_model.dart';
import '../rooms/services/room_service.dart';
import '../rooms/add_room_page.dart';
import '../rooms/create_tenant_account_page.dart';
import '../auth/services/user_service.dart';
import '../tickets/ticket_board_page.dart';
import '../invoices/invoice_board_page.dart';
import '../rooms/resident_detail_page.dart';
import '../finance/finance_report_page.dart';
import '../auth/models/app_user_model.dart';
import '../auth/create_staff_account_page.dart';

class HomePage extends StatefulWidget {
  final UserRole role;

  const HomePage({super.key, this.role = UserRole.admin});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RoomService _roomService = RoomService();
  bool get _isModerator => widget.role == UserRole.moderator;

  void _showRoomDetail(RoomModel room) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: room.status.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.meeting_room_rounded, color: room.status.color),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kamar No. ${room.number}',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(room.status.label,
                          style: TextStyle(color: room.status.color, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (room.tenantName != null) ...[
                const Text('Penghuni', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(room.tenantName!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    if (room.tenantUid != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResidentDetailPage(tenantUid: room.tenantUid!, roomNumber: room.number),
                            ),
                          );
                        },
                        child: const Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const Text('Tarif Sewa', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: 3),
              Text('Rp ${room.price}/bulan', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: AppSpacing.xl),
              if (!_isModerator)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _confirmDelete(room);
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.roomFilled, size: 18),
                        label: const Text('Hapus', style: TextStyle(color: AppColors.roomFilled)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.roomFilled),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddRoomPage(existingRoom: room)),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              if (room.tenantUid == null) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateTenantAccountPage(room: room)),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.primary),
                    label: const Text('Daftarkan Akun Penghuni', style: TextStyle(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
                  ),
                ),
              ],
              if (room.tenantUid != null && !_isModerator) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmCheckout(room);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.roomFilled),
                    label: const Text('Checkout / Hapus Penghuni', style: TextStyle(color: AppColors.roomFilled)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.roomFilled)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _confirmCheckout(RoomModel room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text(
          'Checkout ${room.tenantName ?? "penghuni"}?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: const Text(
          'Kamar akan kembali berstatus Kosong, dan data profil penghuni akan dihapus. '
          'Penghuni tetap bisa login, tapi tidak akan melihat kamar manapun lagi. '
          'Untuk keamanan akses, sarankan penghuni mengganti password atau hubungi mereka langsung.',
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (room.tenantUid != null) {
                  await UserService().deleteUserProfile(room.tenantUid!);
                }
                await _roomService.checkoutTenant(room.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${room.tenantName ?? "Penghuni"} berhasil di-checkout')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal checkout: $e')),
                );
              }
            },
            child: const Text('Checkout', style: TextStyle(color: AppColors.roomFilled, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(RoomModel room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Hapus Kamar No. ${room.number}?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text(
          'Data kamar ini akan dihapus permanen dan tidak bisa dikembalikan.',
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _roomService.deleteRoom(room.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kamar No. ${room.number} berhasil dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.roomFilled, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _isModerator
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.accent,
              elevation: 2,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddRoomPage()));
              },
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
      body: StreamBuilder<List<RoomModel>>(
        stream: _roomService.getRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final rooms = snapshot.data ?? [];
          final total = rooms.length;
          final kosong = rooms.where((r) => r.status == RoomStatus.kosong).length;
          final terisi = rooms.where((r) => r.status == RoomStatus.terisi).length;
          final booking = rooms.where((r) => r.status == RoomStatus.booking).length;

          return CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Baris atas: sapaan + logout ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${user?.displayName ?? "Admin"} 👋',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isModerator ? 'Mode Moderator' : 'Kondisi kost hari ini',
                                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
                            icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Baris bawah: action bar horizontal ──
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (!_isModerator)
                              _headerAction(
                                icon: Icons.badge_outlined,
                                label: 'Staf',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStaffAccountPage())),
                              ),
                            if (!_isModerator) const SizedBox(width: AppSpacing.sm),
                            if (!_isModerator)
                              _headerAction(
                                icon: Icons.bar_chart_rounded,
                                label: 'Keuangan',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceReportPage())),
                              ),
                            if (!_isModerator) const SizedBox(width: AppSpacing.sm),
                            if (!_isModerator)
                              _headerAction(
                                icon: Icons.receipt_long_rounded,
                                label: 'Tagihan',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoiceBoardPage())),
                              ),
                            if (!_isModerator) const SizedBox(width: AppSpacing.sm),
                            _headerAction(
                              icon: Icons.confirmation_number_outlined,
                              label: 'Tiket',
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketBoardPage())),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Kartu statistik ──
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: StatCard(label: 'Total Kamar', value: '$total', accentColor: AppColors.primary, icon: Icons.apartment_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Kosong', value: '$kosong', accentColor: AppColors.roomEmpty, icon: Icons.meeting_room_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Terisi', value: '$terisi', accentColor: AppColors.roomFilled, icon: Icons.person_rounded)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Booking', value: '$booking', accentColor: AppColors.roomBooked, icon: Icons.event_available_rounded)),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

              // ── Judul + legenda ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Denah Kamar', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _legendDot(AppColors.roomEmpty, 'Kosong'),
                          _legendDot(AppColors.roomFilled, 'Terisi'),
                          _legendDot(AppColors.roomBooked, 'Booking'),
                          _legendDot(AppColors.roomRepair, 'Perbaikan'),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── Grid kamar / empty state ──
              if (rooms.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.textGrey.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text('Belum ada kamar', style: TextStyle(color: AppColors.textGrey)),
                        const Text('Tekan tombol + untuk menambah kamar pertama', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.05,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final room = rooms[index];
                        return RoomTile(room: room, onTap: () => _showRoomDetail(room));
                      },
                      childCount: rooms.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
      ],
    );
  }

  Widget _headerAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}