import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/ticket_tile.dart';
import '../../shared/widgets/invoice_tile.dart';
import '../auth/login_page.dart';
import '../rooms/models/room_model.dart';
import '../rooms/services/room_service.dart';
import '../tickets/models/ticket_model.dart';
import '../tickets/services/ticket_service.dart';
import '../tickets/report_issue_page.dart';
import '../invoices/models/invoice_model.dart';
import '../invoices/services/invoice_service.dart';
import '../invoices/upload_proof_page.dart';

class ResidentHomePage extends StatelessWidget {
  final String tenantName;
  final String uid;

  const ResidentHomePage({super.key, required this.tenantName, required this.uid});

  String _formatPrice(int price) =>
      price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<RoomModel?>(
        stream: RoomService().getRoomByTenantUid(uid),
        builder: (context, roomSnapshot) {
          final room = roomSnapshot.data;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Halo, $tenantName 👋',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('Selamat datang kembali',
                                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
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
                        icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              if (roomSnapshot.connectionState == ConnectionState.waiting)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                )
              else if (room == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.textGrey),
                          const SizedBox(height: 10),
                          Text('Kamar belum ditautkan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Hubungi pengelola kost jika Anda merasa ini keliru.',
                              style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Kartu kamar ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: AppShadows.soft,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kamar No. ${room.number}',
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: room.status.color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(room.status.label,
                                      style: TextStyle(color: room.status.color, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Rp ${_formatPrice(room.price)}/bulan',
                                style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Kartu masa sewa ──
                      if (room.contractEnd != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: (room.daysUntilContractEnd ?? 0) <= 7
                                ? AppColors.roomFilled.withOpacity(0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: AppShadows.soft,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event_rounded,
                                      color: (room.daysUntilContractEnd ?? 0) <= 7 ? AppColors.roomFilled : AppColors.primary,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text('Masa Sewa', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                (room.daysUntilContractEnd ?? 0) >= 0
                                    ? '${room.daysUntilContractEnd} hari lagi'
                                    : 'Sudah lewat jatuh tempo',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: (room.daysUntilContractEnd ?? 0) <= 7 ? AppColors.roomFilled : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Berakhir pada ${room.contractEnd!.day}/${room.contractEnd!.month}/${room.contractEnd!.year}',
                                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Tagihan Saya ──
                      Text('Tagihan Saya', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.sm),
                      StreamBuilder<List<InvoiceModel>>(
                        stream: InvoiceService().getInvoicesByTenant(uid),
                        builder: (context, invoiceSnapshot) {
                          final invoices = invoiceSnapshot.data ?? [];
                          if (invoiceSnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            );
                          }
                          if (invoices.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Text('Belum ada tagihan.', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                            );
                          }
                          return Column(
                            children: invoices.map((inv) {
                              return InvoiceTile(
                                invoice: inv,
                                onTap: () {
                                  if (inv.status == InvoiceStatus.belumBayar) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => UploadProofPage(invoice: inv)),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Keluhan Saya ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Keluhan Saya', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReportIssuePage(
                                    roomId: room.id,
                                    roomNumber: room.number,
                                    tenantUid: uid,
                                    tenantName: tenantName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('Lapor', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StreamBuilder<List<TicketModel>>(
                        stream: TicketService().getTicketsByTenant(uid),
                        builder: (context, ticketSnapshot) {
                          final tickets = ticketSnapshot.data ?? [];
                          if (ticketSnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                            );
                          }
                          if (tickets.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                boxShadow: AppShadows.soft,
                              ),
                              child: const Text(
                                'Belum ada keluhan yang dilaporkan.',
                                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                              ),
                            );
                          }
                          return Column(
                            children: tickets.map((t) => TicketTile(ticket: t, onTap: () {})).toList(),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}