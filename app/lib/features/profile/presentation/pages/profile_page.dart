import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8EEF7),
                        border: Border.all(color: AppColors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'lib/assets/image/profile/p1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Wasuchok',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Software Engineer • EMP-001',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Menu Sections
          _buildSectionTitle('Personal Information'),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.email_outlined,
              title: 'Email',
              trailing: 'wasuchok@example.com',
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildMenuItem(
              icon: Icons.phone_outlined,
              title: 'Phone',
              trailing: '+66 81 234 5678',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle('Settings & Preferences'),
          _buildMenuCard([
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: 'On',
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildMenuItem(
              icon: Icons.language_outlined,
              title: 'Language',
              trailing: 'English',
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            _buildMenuItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
            ),
          ]),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                foregroundColor: AppColors.danger,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
