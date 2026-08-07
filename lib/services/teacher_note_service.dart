import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _dayDoc(String studentId, String dayKey) {
    return _firestore
        .collection('student_program_notes')
        .doc(studentId)
        .collection('days')
        .doc(dayKey);
  }

  Future<void> saveTeacherNote({
    required String studentId,
    required String dayKey,
    required String note,
  }) {
    final doc = _dayDoc(studentId, dayKey);

    return doc.set(
      {
        'note': note,
        'dayKey': dayKey,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<String> watchTeacherNote({
    required String studentId,
    required String dayKey,
  }) {
    return _dayDoc(studentId, dayKey).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return '';
      return (data['note'] ?? '') as String;
    });
  }
}
