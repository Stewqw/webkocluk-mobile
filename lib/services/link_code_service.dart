import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class LinkCodeService {
  LinkCodeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  CollectionReference<Map<String, dynamic>> get _codes {
    return _firestore.collection('student_link_codes');
  }

  String _generateCode() {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i += 1) {
      buffer.write(_chars[random.nextInt(_chars.length)]);
    }
    return buffer.toString();
  }

  Stream<String> watchActiveCode(String studentId) {
    return _codes
        .where('studentId', isEqualTo: studentId)
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return '';
      return snap.docs.first.id;
    });
  }

  Future<String> createOrRotateCode(String studentId) async {
    final activeDocs = await _codes
        .where('studentId', isEqualTo: studentId)
        .where('active', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in activeDocs.docs) {
      batch.set(
        doc.reference,
        {
          'active': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    final code = _generateCode();
    batch.set(_codes.doc(code), {
      'studentId': studentId,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 7)),
      ),
    });

    await batch.commit();
    return code;
  }

  Future<String> claimCode({
    required String parentUid,
    required String rawCode,
  }) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) throw Exception('Kod bos olamaz.');

    final codeDoc = await _codes.doc(code).get();
    if (!codeDoc.exists || codeDoc.data() == null) {
      throw Exception('Kod bulunamadi.');
    }

    final data = codeDoc.data()!;
    final isActive = data['active'] == true;
    final studentId = (data['studentId'] ?? '') as String;
    final expiresAt = data['expiresAt'] as Timestamp?;

    if (!isActive) throw Exception('Kod aktif degil.');
    if (studentId.isEmpty) throw Exception('Kod gecersiz.');
    if (studentId == parentUid) throw Exception('Kendi hesabinizi baglayamazsiniz.');
    if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
      throw Exception('Kod suresi dolmus.');
    }

    await _firestore.collection('users').doc(parentUid).set(
      {
        'linkedStudentIds': FieldValue.arrayUnion([studentId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return studentId;
  }
}
