import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Attendance History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMonthPicker(),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Attendance'),
                Tab(text: 'Leave Request'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildAttendanceTab(), _buildLeaveTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          color: AppColors.grey,
        ),
        const Text(
          'April 2026',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          color: AppColors.grey,
        ),
      ],
    );
  }

  Widget _buildAttendanceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final isLate = index % 4 == 0;
        final isAbsent = index == 7;

        return _buildHistoryCard(
          day: '${25 - index}',
          dayName: 'Thu',
          checkIn: isAbsent ? '-' : (isLate ? '09:12 AM' : '08:50 AM'),
          checkOut: isAbsent ? '-' : '06:00 PM',
          status: isAbsent ? 'Absent' : (isLate ? 'Late' : 'Present'),
          statusColor: isAbsent
              ? AppColors.danger
              : (isLate ? AppColors.warning : AppColors.success),
        );
      },
    );
  }

  Widget _buildLeaveTab() {
    return const Center(
      child: Text(
        'No leave requests in this month.',
        style: TextStyle(color: AppColors.grey),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String day,
    required String dayName,
    required String checkIn,
    required String checkOut,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date Area
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Details Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildTimeInfo('Check in', checkIn)),
                      Expanded(child: _buildTimeInfo('Check out', checkOut)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
