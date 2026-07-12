import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../shared/widgets/ticket_tile.dart';
import 'models/ticket_model.dart';
import 'services/ticket_service.dart';

class TicketBoardPage extends StatefulWidget {
  const TicketBoardPage({super.key});

  @override
  State<TicketBoardPage> createState() => _TicketBoardPageState();
}

class _TicketBoardPageState extends State<TicketBoardPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TicketService _ticketService = TicketService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTicketDetail(TicketModel ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ticket.urgency.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(ticket.category.icon, color: ticket.urgency.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${ticket.category.label} · Kamar ${ticket.roomNumber}',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text('Dilaporkan oleh ${ticket.tenantName}',
                              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    Chip(
                      label: Text('Urgensi: ${ticket.urgency.label}', style: TextStyle(color: ticket.urgency.color, fontSize: 11)),
                      backgroundColor: ticket.urgency.color.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                    Chip(
                      label: Text(ticket.status.label, style: TextStyle(color: ticket.status.color, fontSize: 11)),
                      backgroundColor: ticket.status.color.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Deskripsi', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                const SizedBox(height: 3),
                Text(ticket.description, style: const TextStyle(fontSize: 14)),
                if (ticket.repairCost != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text('Biaya Perbaikan', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  Text('Rp ${ticket.repairCost}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (ticket.status == TicketStatus.open)
                  ElevatedButton(
                    onPressed: () async {
                      await _ticketService.updateStatus(ticket.id, TicketStatus.inProgress);
                      if (context.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Tandai Sedang Diproses'),
                  ),
                if (ticket.status == TicketStatus.inProgress)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showResolveDialog(ticket);
                    },
                    child: const Text('Tandai Selesai'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResolveDialog(TicketModel ticket) {
    final costController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Selesaikan Tiket', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: costController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Biaya Perbaikan (opsional)', prefixText: 'Rp '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final cost = int.tryParse(costController.text.trim());
              await _ticketService.updateStatus(ticket.id, TicketStatus.resolved, repairCost: cost);
            },
            child: const Text('Selesaikan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Papan Keluhan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Menunggu'),
            Tab(text: 'Diproses'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: _ticketService.getAllTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final tickets = snapshot.data ?? [];

          Widget buildList(TicketStatus status) {
            final filtered = tickets.where((t) => t.status == status).toList();
            if (filtered.isEmpty) {
              return Center(
                child: Text('Belum ada tiket ${status.label.toLowerCase()}',
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final ticket = filtered[index];
                return TicketTile(ticket: ticket, showRoomNumber: true, onTap: () => _showTicketDetail(ticket));
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              buildList(TicketStatus.open),
              buildList(TicketStatus.inProgress),
              buildList(TicketStatus.resolved),
            ],
          );
        },
      ),
    );
  }
}