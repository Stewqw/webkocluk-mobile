enum AppUserRole {
  student,
  parent,
}

AppUserRole roleFromString(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'parent':
      return AppUserRole.parent;
    case 'student':
    default:
      return AppUserRole.student;
  }
}

String roleToString(AppUserRole role) {
  return role == AppUserRole.parent ? 'parent' : 'student';
}

class AppUserProfile {
  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.linkedStudentIds,
  });

  final String uid;
  final String email;
  final String displayName;
  final AppUserRole role;
  final List<String> linkedStudentIds;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': roleToString(role),
      'linkedStudentIds': linkedStudentIds,
    };
  }

  factory AppUserProfile.fromMap(Map<String, dynamic> map) {
    return AppUserProfile(
      uid: (map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      displayName: (map['displayName'] ?? '') as String,
      role: roleFromString(map['role'] as String?),
      linkedStudentIds: ((map['linkedStudentIds'] ?? const []) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }
}
