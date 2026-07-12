import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

class InvoiceService {
  final CollectionReference _invoicesRef = FirebaseFirestore.instance.collection('invoices');

  Stream<List<InvoiceModel>> getAllInvoices() {
    return _invoicesRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<InvoiceModel>> getInvoicesByTenant(String uid) {
    return _invoicesRef.where('tenantUid', isEqualTo: uid).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => InvoiceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> createInvoice(InvoiceModel invoice) {
    return _invoicesRef.add(invoice.toMap());
  }

  Future<void> submitProof(String invoiceId, String base64Image) {
    return _invoicesRef.doc(invoiceId).update({
      'proofBase64': base64Image,
      'status': InvoiceStatus.menungguVerifikasi.name,
    });
  }

  Future<void> approveInvoice(String invoiceId) {
    return _invoicesRef.doc(invoiceId).update({
      'status': InvoiceStatus.lunas.name,
      'paidAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> rejectInvoice(String invoiceId) {
    return _invoicesRef.doc(invoiceId).update({
      'status': InvoiceStatus.belumBayar.name,
      'proofBase64': null,
    });
  }
}