import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class SolarPanelCard extends StatelessWidget {
  const SolarPanelCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              children: [
                Icon(Icons.solar_power, color: AppColors.accentColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Solar Panel',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.solarStable,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Stable',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSolarItem('Power', '2450 W'),
                _buildSolarItem('Voltage', '24.2 V'),
                _buildSolarItem('Current', '10.1 A'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSolarItem('Efficiency', '88%', Icons.trending_up),
                _buildSolarItem('Temp', '28°C', Icons.thermostat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarItem(String label, String value, [IconData? icon]) {
    return Column(
      children: [
        if (icon != null) Icon(icon, size: 20, color: AppColors.accentColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
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
