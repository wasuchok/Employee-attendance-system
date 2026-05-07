class AttendanceSummary {
    final int present;
    final int late;
    final int absent;
    final int leave;

    const AttendanceSummary({
        required this.present,
        required this.late,
        required this.absent,
        required this.leave,
    });

    factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
        return AttendanceSummary(
            present: json['present'] ?? 0,
            late: json['late'] ?? 0,
            absent: json['absent'] ?? 0,
            leave: json['leave'] ?? 0,
        );
    }
}