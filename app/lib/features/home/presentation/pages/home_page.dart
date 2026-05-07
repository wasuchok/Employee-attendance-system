import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/attendance/domain/models/today_attendance.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:app/features/office_location/data/datasources/office_location_remote_datasource.dart';
import 'package:app/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:app/features/weather/domain/models/rayong_weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        _HeroHeader(),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              _TodayCard(),
              SizedBox(height: 14),
              _QuickStats(),
              SizedBox(height: 14),
              _ScheduleCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatefulWidget {
  const _HeroHeader();

  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader> {
  late final Future<RayongWeather> _weatherFuture;

  @override
  void initState() {
    super.initState();

    _weatherFuture = context.read<WeatherRemoteDatasource>().getRayongWeather();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
      final greeting = now.hour < 12
      ? 'Good morning,'
      : now.hour < 17
      ? 'Good afternoon,'
      : 'Good evening,';
  final todayText = DateFormat('EEE, d MMM yyyy').format(now);
 
    return FutureBuilder<RayongWeather>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        final weatherIconPath =
            snapshot.data?.assetPath ??
            'lib/assets/image/weather/sun_behind_cloud_3d.png';

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D5BE1), Color(0xFF0647B9)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 12,
                bottom: -8,
                child: _CloudIcon(
                  size: 156,
                  opacity: 0.9,
                  assetPath: weatherIconPath,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 54, 20, 72),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Employee Attendance',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _HeaderIconButton(
                          icon: Icons.notifications_none_rounded,
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                     Text(
                      greeting,
                      style: TextStyle(
                        color: Color(0xFFEAF6FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Wasuchok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFFEAF6FF),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
  todayText,
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.94),
    fontSize: 13,
    fontWeight: FontWeight.w700,
  ),
),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}

class _CloudIcon extends StatelessWidget {
  final double size;
  final double opacity;
  final String assetPath;

  const _CloudIcon({
    required this.size,
    required this.opacity,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.22),
              blurRadius: 34,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}

class _TodayCard extends StatefulWidget {
  const _TodayCard();

  @override
  State<_TodayCard> createState() => _TodayCardState();
}

class _TodayCardState extends State<_TodayCard> {
  TodayAttendance? _todayAttendance;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
  throw Exception('Location services are disabled');
}
    
  var permission = await Geolocator.checkPermission();
 
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
 
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }
 
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  }
 
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
  }

  @override
  void initState() {
    super.initState();

    context.read<AttendanceBloc>().add(TodayAttendanceRequested());
  }

  String _formatWorkingTime(DateTime checkInTime) {
    final duration = DateTime.now().difference(checkInTime);

    if(duration.inMinutes < 1) {
      return '0m';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if(hours == 0) {
      return '${minutes}m';
    }
    
    return '${hours}h ${minutes}m';
  }

  Future<void> _checkIn() async {
    final officeLocationDs = context.read<OfficeLocationRemoteDatasource>();

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final officeLocations = await officeLocationDs.getOfficeLocations();
final position = await _getCurrentPosition();
      if (officeLocations.isEmpty) {
        throw Exception('No office locations available');
      }

      final officeLocation = officeLocations.first;

      if (!mounted) return;

      context.read<AttendanceBloc>().add(
        CheckInRequested(
          officeLocationId: officeLocation.id,
checkInLatitude: position.latitude,
checkInLongitude: position.longitude,
          note: '',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load office location: $e')),
      );
    }
  }

  Future<void> _checkOut() async {
    final officeLocationDs = context.read<OfficeLocationRemoteDatasource>();

    setState(() {
      _isCheckingOut = true;
    });

    try {
    final officeLocations = await officeLocationDs.getOfficeLocations();
    final position = await _getCurrentPosition();
 
    if (officeLocations.isEmpty) {
      throw Exception('No office locations available');
    }
 
    final officeLocation = officeLocations.first;
 
    if (!mounted) return;
 
    context.read<AttendanceBloc>().add(
      CheckOutRequested(
        officeLocationId: officeLocation.id,
        checkOutLatitude: position.latitude,
        checkOutLongitude: position.longitude,
      ),
    );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCheckingOut = false;
      });

        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Check-out failed: $e')),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = _todayAttendance != null;
    final checkInText = _todayAttendance == null
        ? '-'
        : DateFormat('HH:mm').format(_todayAttendance!.checkInTime);
    final checkOutText = _todayAttendance?.checkOutTime == null
        ? '-'
        : DateFormat('HH:mm').format(_todayAttendance!.checkOutTime!);
    final workingText = _todayAttendance == null ? '-' : _formatWorkingTime(_todayAttendance!.checkInTime);
    final distanceText = _todayAttendance == null ? '-' : '${_todayAttendance!.distanceMeters.round()} m';
    final isCheckedOut = _todayAttendance?.checkOutTime != null;


    return Transform.translate(
      offset: const Offset(0, -46),
      child: _DashboardCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today Attendance',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      _StatusPill(isCheckedIn: isCheckedIn),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8EEF7),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'lib/assets/image/profile/p1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    if (isCheckedIn)
                      Positioned(
                        right: -2,
                        bottom: 2,
                        child: Opacity(
                          opacity: isCheckedOut ? 1.0 : 0.5,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.login_rounded,
                    label: 'Check-in',
                    value: checkInText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.logout_rounded,
                    label: 'Check-out',
                    value: checkOutText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.timer_outlined,
                    label: 'Working',
                    value: workingText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.place_outlined,
                    label: 'Distance',
                    value: distanceText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
              if (state is! CheckInLoading && _isCheckingIn) {
  setState(() {
    _isCheckingIn = false;
  });
}
 
if (state is! CheckOutLoading && _isCheckingOut) {
  setState(() {
    _isCheckingOut = false;
  });
}

                if (state is TodayAttendanceLoaded) {
                  setState(() {
                    _todayAttendance = state.attendance;
                  });
                }

                if (state is AttendanceSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(_todayAttendance?.checkOutTime != null ? 'Check-out successful' : 'Check-in successful')),
                  );

                  context.read<AttendanceBloc>().add(
                    TodayAttendanceRequested(),
                  );
                }

                if (state is AttendanceFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));

                  if (state.message == 'Already checked in today') {
                    context.read<AttendanceBloc>().add(
                      TodayAttendanceRequested(),
                    );
                  }
                }
              },
            builder: (context, state) {
  final isCheckedOut = _todayAttendance?.checkOutTime != null;

  if (isCheckedIn && !isCheckedOut) {
    // Show Check-out button
    final isLoading = _isCheckingOut;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _checkOut,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isLoading ? 'Checking out...' : 'Check-out',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  if (isCheckedOut) {
    // Already checked out
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Checked out',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  // Show Check-in button
  final isLoading = _isCheckingIn;
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: isLoading ? null : _checkIn,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isLoading ? 'Checking in...' : 'Check-in',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    ),
  );
},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isCheckedIn;

  const _StatusPill({required this.isCheckedIn});

  @override
  Widget build(BuildContext context) {
    final color = isCheckedIn ? AppColors.success : AppColors.grey;
    final icon = isCheckedIn ? Icons.verified_rounded : Icons.schedule_rounded;
    final text = isCheckedIn ? 'Checked in' : 'Not checked in';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStrip extends StatelessWidget {
  final String distanceText;

  const _LocationStrip({required this.distanceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.place_outlined, color: AppColors.primary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Office distance',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            distanceText,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatefulWidget {
  const _QuickStats();

  @override
  State<_QuickStats> createState() => _QuickStatsState();
}

class _QuickStatsState extends State<_QuickStats> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(AttendanceSummaryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -46),
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        buildWhen: (prev, curr) => curr is AttendanceSummaryLoaded,
        builder: (context, state) {
          final summary = state is AttendanceSummaryLoaded ? state.summary : null;
          final present = summary?.present.toString() ?? '-';
          final late = summary?.late.toString() ?? '-';
          final absent = summary?.absent.toString() ?? '-';
          final leave = summary?.leave.toString() ?? '-';

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Present',
                      value: present,
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Late',
                      value: late,
                      color: AppColors.warning,
                      icon: Icons.access_time_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Absent',
                      value: absent,
                      color: AppColors.danger,
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Leave',
                      value: leave,
                      color: AppColors.primary,
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -46),
      child: const _DashboardCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today Schedule',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 14),
            _ScheduleRow(
              icon: Icons.business_center_outlined,
              title: 'Office hours',
              value: '08:30 - 17:30',
            ),
            SizedBox(height: 12),
            _ScheduleRow(
              icon: Icons.logout_rounded,
              title: 'Check-out opens',
              value: 'After 17:00',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ScheduleRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DashboardCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
