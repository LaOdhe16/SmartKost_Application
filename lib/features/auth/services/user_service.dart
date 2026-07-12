import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user_model.dart';

class UserService {
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection('users');

  Future<void> createUserProfile(AppUserModel user) {
    return _usersRef.doc(user.uid).set(user.toMap());
  }

  Future<void> updateIdentity(String uid, {
    required String phone,
    required String emergencyContact,
  }) {
    return _usersRef.doc(uid).update({
      'phone': phone,
      'emergencyContact': emergencyContact,
    });
  }

  Future<void> deleteUserProfile(String uid) {
  return _usersRef.doc(uid).delete();
  }

  Future<AppUserModel?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return AppUserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
  }

  Stream<AppUserModel?> streamUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
    });
  }
}