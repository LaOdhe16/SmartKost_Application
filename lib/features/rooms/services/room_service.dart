import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomService {
  final CollectionReference _roomsRef = FirebaseFirestore.instance.collection('rooms');

  Stream<List<RoomModel>> getRooms() {
    return _roomsRef.orderBy('number').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<RoomModel?> getRoomByTenantUid(String uid) {
    return _roomsRef.where('tenantUid', isEqualTo: uid).limit(1).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return RoomModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> addRoom(RoomModel room) {
    return _roomsRef.add(room.toMap());
  }

  Future<void> updateRoom(RoomModel room) {
    return _roomsRef.doc(room.id).update(room.toMap());
  }

  Future<void> deleteRoom(String roomId) {
    return _roomsRef.doc(roomId).delete();
  }

  Future<void> checkoutTenant(String roomId) {
    return _roomsRef.doc(roomId).update({
      'status': 'kosong',
      'tenantName': null,
      'tenantUid': null,
      'contractStart': null,
      'contractEnd': null,
    });
  }
}