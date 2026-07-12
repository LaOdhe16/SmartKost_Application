import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import 'models/invoice_model.dart';
import 'services/invoice_service.dart';

class UploadProofPage extends StatefulWidget {
  final InvoiceModel invoice;

  const UploadProofPage({super.key, required this.invoice});

  @override
  State<UploadProofPage> createState() => _UploadProofPageState();
}

class _UploadProofPageState extends State<UploadProofPage> {
  File? _photo;
  bool _isLoading = false;
  final InvoiceService _invoiceService = InvoiceService();
  final ImagePicker _picker = ImagePicker();

  String _formatPrice(int price) =>
      price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    // Kompres agresif supaya ukuran base64 tetap kecil (di bawah batas 1MB Firestore)
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 35,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _handleSubmit() async {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambil atau pilih foto bukti transfer dulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final bytes = await _photo!.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (base64Image.length > 900000) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto masih terlalu besar, coba ambil ulang')),
        );
        setState(() => _isLoading = false);
        return;
      }

      await _invoiceService.submitProof(widget.invoice.id, base64Image);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti transfer berhasil dikirim, menunggu verifikasi')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim bukti: $e')),
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
        title: Text('Upload Bukti Transfer', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Padding(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kamar ${widget.invoice.roomNumber}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Rp ${_formatPrice(widget.invoice.amount)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Foto Bukti Transfer', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: _photo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: AppColors.textGrey.withOpacity(0.6), size: 32),
                          const SizedBox(height: 8),
                          const Text('Tap untuk tambah foto struk transfer', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim Bukti Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}