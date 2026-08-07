import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserProfileService {
  UserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<AppUserProfile?> getProfile(String uid) async {
    final snap = await _doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUserProfile.fromMap(snap.data()!);
  }

  Stream<AppUserProfile?> watchProfile(String uid) {
    return _doc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (!snap.exists || data == null) return null;
      return AppUserProfile.fromMap(data);
    });
  }

  Future<void> upsertProfile(AppUserProfile profile) {
    return _doc(profile.uid).set(
      {
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> addLinkedStudent({
    required String parentUid,
    required String studentUid,
  }) {
    return _doc(parentUid).set(
      {
        'linkedStudentIds': FieldValue.arrayUnion([studentUid]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<AppUserProfile>> watchProfilesByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value(const []);

    final limitedIds = ids.take(10).toList();
    return _firestore
        .collection('users')
        .where('uid', whereIn: limitedIds)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppUserProfile.fromMap(doc.data()))
            .toList());
  }
}
