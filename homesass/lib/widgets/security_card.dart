import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../utils/constants.dart';

class SecurityCard extends StatelessWidget {
  const SecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiProvider>(
      builder: (context, apiProvider, child) {
        final data = apiProvider.smartHomeData;
        final isRelayOn = data?.relay ?? false;
        final isLockOn = data?.lock ?? false;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.dangerColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Security Control',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    if (apiProvider.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Main Relay Control
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isRelayOn 
                        ? AppColors.successColor.withOpacity(0.1) 
                        : AppColors.secondaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRelayOn ? AppColors.successColor : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isRelayOn ? AppColors.successColor : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.power_settings_new, 
                          color: Colors.white, 
                          size: 24
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Main Power Relay',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              isRelayOn ? 'Active (Power ON)' : 'Inactive (Power OFF)',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isRelayOn ? AppColors.successColor : AppColors.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isRelayOn,
                        activeColor: AppColors.successColor,
                        onChanged: (value) {
                          // Toggle relay
                          apiProvider.toggleRelay();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // System Lock Indicator (Read only for now based on data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSecurityItem(
                      'System Lock', 
                      isLockOn ? 'LOCKED' : 'UNLOCKED', 
                      isLockOn ? Icons.lock : Icons.lock_open, 
                      isLockOn ? AppColors.dangerColor : AppColors.successColor
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.hintColor,
          ),
        ),
      ],
    );
  }
}

