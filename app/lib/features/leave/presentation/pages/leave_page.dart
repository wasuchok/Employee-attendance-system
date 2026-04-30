import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Leave Requests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList(status: 'Pending', statusColor: AppColors.warning),
          _buildLeaveList(status: 'Approved', statusColor: AppColors.success),
          _buildLeaveList(status: 'Rejected', statusColor: AppColors.danger),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Request Leave',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveList({required String status, required Color statusColor}) {
    // Generate different number of items just for mock
    final itemCount = status == 'Pending' ? 2 : (status == 'Approved' ? 5 : 1);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _buildLeaveCard(
          type: index % 2 == 0 ? 'Annual Leave' : 'Sick Leave',
          dateRange: '12 Apr 2026 - 14 Apr 2026',
          days: index % 2 == 0 ? '3 Days' : '1 Day',
          reason: 'Family vacation trip',
          status: status,
          statusColor: statusColor,
          appliedOn: '10 Apr 2026',
        );
      },
    );
  }

  Widget _buildLeaveCard({
    required String type,
    required String dateRange,
    required String days,
    required String reason,
    required String status,
    required Color statusColor,
    required String appliedOn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 16,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateRange,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  days,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reason:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Applied On:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appliedOn,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
