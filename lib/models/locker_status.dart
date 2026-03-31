class LockerStatus {
  const LockerStatus({
    required this.id,
    required this.isLocked,
    this.label,
    this.rfidUid,
  });

  final int id;
  final bool isLocked;
  final String? label;
  final String? rfidUid;

  bool get isOpen => !isLocked;

  factory LockerStatus.fromJson(Map<String, dynamic> json) {
    final dynamic lockedValue = json['is_locked'];

    return LockerStatus(
      id: (json['id'] as num).toInt(),
      label: json['locker_label']?.toString(),
      rfidUid: json['rfid_uid']?.toString(),
      isLocked: _parseLocked(lockedValue),
    );
  }

  static bool _parseLocked(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final String normalized = value.toLowerCase().trim();
      return normalized == '1' ||
          normalized == 'true' ||
          normalized == 'locked';
    }
    return true;
  }
}
