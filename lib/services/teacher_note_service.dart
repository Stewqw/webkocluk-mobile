import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherNoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTeacherNote({
    required String studentId,
    required String dayKey,
    required String note,
  }) {
    final doc = _firestore
        .collection('student_program_notes')
        .doc(studentId)
        .collection('days')
        .doc(dayKey);

    return doc.set(
      {
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
