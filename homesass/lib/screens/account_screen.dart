import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryColor,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.userName ?? 'User',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.userEmail ?? 'user@example.com',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.hintColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(height: 1, color: AppColors.borderColor),
                      const SizedBox(height: 16),
                      _buildAccountItem(
                        context,
                        Icons.edit,
                        'Edit Profile',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Edit profile functionality coming soon')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAccountItem(
                        context,
                        Icons.security,
                        'Change Password',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Change password functionality coming soon')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAccountItem(
                        context,
                        Icons.notifications,
                        'Notification Settings',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Notification settings coming soon')),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildAccountItem(
                        context,
                        Icons.logout,
                        'Logout',
                        () {
                          authProvider.logout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logged out successfully')),
                          );
                        },
                        color: AppColors.dangerColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppColors.textColor,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
