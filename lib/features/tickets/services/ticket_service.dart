import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket_model.dart';

class TicketService {
  final CollectionReference _ticketsRef = FirebaseFirestore.instance.collection('tickets');

  Stream<List<TicketModel>> getAllTickets() {
    return _ticketsRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TicketModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Stream<List<TicketModel>> getTicketsByTenant(String uid) {
    return _ticketsRef.where('tenantUid', isEqualTo: uid).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => TicketModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<String> createTicket(TicketModel ticket) async {
    final doc = await _ticketsRef.add(ticket.toMap());
    return doc.id;
  }

  Future<void> updateStatus(String ticketId, TicketStatus status, {int? repairCost}) {
    final data = <String, dynamic>{'status': status.name};
    if (repairCost != null) data['repairCost'] = repairCost;
    return _ticketsRef.doc(ticketId).update(data);
  }
}