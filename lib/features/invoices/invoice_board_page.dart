import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../shared/widgets/invoice_tile.dart';
import 'create_invoice_page.dart';
import 'models/invoice_model.dart';
import 'services/invoice_service.dart';

class InvoiceBoardPage extends StatefulWidget {
  const InvoiceBoardPage({super.key});

  @override
  State<InvoiceBoardPage> createState() => _InvoiceBoardPageState();
}

class _InvoiceBoardPageState extends State<InvoiceBoardPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final InvoiceService _invoiceService = InvoiceService();

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

  String _formatPrice(int price) =>
      price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _showInvoiceDetail(InvoiceModel invoice) {
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
                Text('Kamar ${invoice.roomNumber}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(invoice.tenantName, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    Text('Rp ${_formatPrice(invoice.amount)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jatuh Tempo', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    Text('${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year}'),
                  ],
                ),
                if (invoice.proofBase64 != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text('Bukti Transfer', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.memory(
                      base64Decode(invoice.proofBase64!),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                if (invoice.status == InvoiceStatus.menungguVerifikasi)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _invoiceService.rejectInvoice(invoice.id);
                            if (context.mounted) Navigator.pop(sheetContext);
                          },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.roomFilled)),
                          child: const Text('Tolak', style: TextStyle(color: AppColors.roomFilled)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _invoiceService.approveInvoice(invoice.id);
                            if (context.mounted) Navigator.pop(sheetContext);
                          },
                          child: const Text('Setujui'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Papan Tagihan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Belum Bayar'),
            Tab(text: 'Verifikasi'),
            Tab(text: 'Lunas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateInvoicePage()));
        },
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: StreamBuilder<List<InvoiceModel>>(
        stream: _invoiceService.getAllInvoices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final invoices = snapshot.data ?? [];

          Widget buildList(List<InvoiceStatus> statuses) {
            final filtered = invoices.where((i) => statuses.contains(i.status)).toList();
            if (filtered.isEmpty) {
              return const Center(
                child: Text('Tidak ada tagihan di sini', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final invoice = filtered[index];
                return InvoiceTile(invoice: invoice, showTenantName: true, onTap: () => _showInvoiceDetail(invoice));
              },
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              buildList([InvoiceStatus.belumBayar]),
              buildList([InvoiceStatus.menungguVerifikasi]),
              buildList([InvoiceStatus.lunas, InvoiceStatus.ditolak]),
            ],
          );
        },
      ),
    );
  }
}