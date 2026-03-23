import 'package:cloud_firestore/cloud_firestore.dart';

// ── User roles
enum UserRole { administrator, janitor }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.administrator;

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? 'Unknown',
      email: data['email'] as String? ?? '',
      role: (data['role'] as String? ?? '').toLowerCase() == 'administrator'
          ? UserRole.administrator
          : UserRole.janitor,
    );
  }
}

// ── Bin
class TrashBin {
  final String id;
  final String location;
  final String wasteType;
  final double fillLevel;
  final DateTime lastCollected;
  final bool sensorOnline;

  const TrashBin({
    required this.id,
    required this.location,
    required this.wasteType,
    required this.fillLevel,
    required this.lastCollected,
    required this.sensorOnline,
  });

  bool get isOverflowing => fillLevel >= 90;

  factory TrashBin.fromFirestore(Map<String, dynamic> data) {
    return TrashBin(
      id: data['id'] as String? ?? 'BIN-001',
      location: data['location'] as String? ?? 'TIP QC Canteen',
      wasteType: data['wasteType'] as String? ?? 'General',
      fillLevel: (data['fillLevel'] as num? ?? 0).toDouble(),
      lastCollected: data['lastCollected'] is Timestamp
          ? (data['lastCollected'] as Timestamp).toDate()
          : DateTime.now(),
      sensorOnline: data['sensorOnline'] as bool? ?? false,
    );
  }

  TrashBin copyWith({double? fillLevel, DateTime? lastCollected}) {
    return TrashBin(
      id: id,
      location: location,
      wasteType: wasteType,
      fillLevel: fillLevel ?? this.fillLevel,
      lastCollected: lastCollected ?? this.lastCollected,
      sensorOnline: sensorOnline,
    );
  }
}

// ── Sensor log entry
class SensorLog {
  final String id;
  final double fillLevel;
  final DateTime timestamp;

  const SensorLog({
    required this.id,
    required this.fillLevel,
    required this.timestamp,
  });

  factory SensorLog.fromFirestore(String id, Map<String, dynamic> data) {
    return SensorLog(
      id: id,
      fillLevel: (data['fillLevel'] as num? ?? 0).toDouble(),
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}

// ── Maintenance report
enum ReportStatus { pending, inProgress, resolved }

class Report {
  final String id;
  final String filedBy;
  final String filedByUid;
  final String issue;
  final ReportStatus status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.filedBy,
    required this.filedByUid,
    required this.issue,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromFirestore(String id, Map<String, dynamic> data) {
    final statusStr = data['status'] as String? ?? 'pending';
    return Report(
      id: id,
      filedBy: data['filedBy'] as String? ?? 'Unknown',
      filedByUid: data['filedByUid'] as String? ?? '',
      issue: data['issue'] as String? ?? '',
      status: statusStr == 'resolved'
          ? ReportStatus.resolved
          : statusStr == 'inProgress'
              ? ReportStatus.inProgress
              : ReportStatus.pending,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.resolved:   return 'Resolved';
      case ReportStatus.inProgress: return 'In Progress';
      case ReportStatus.pending:    return 'Pending';
    }
  }

  String get statusKey {
    switch (status) {
      case ReportStatus.resolved:   return 'resolved';
      case ReportStatus.inProgress: return 'inProgress';
      case ReportStatus.pending:    return 'pending';
    }
  }
}
