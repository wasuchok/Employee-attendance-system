class ApiConstants {
  static const String baseUrl = 'http://10.17.3.239:6600/api';

  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/employees/me';
  static const String logout = '/auth/logout';
  static const String createEmployeeProfile = '/employees/me';

  static const String attendanceCheckIn = '/attendances/check-in';
  static const String attendanceCheckOut = '/attendances/check-out';
  static const String attendanceToday = '/attendances/today';
  static const String attendanceHistory = '/attendances/history';

  static const String officeLocationLists = '/office_locations/lists';
}
