import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../utils/constants.dart';

class ClimateCard extends StatelessWidget {
  const ClimateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiProvider>(
      builder: (context, apiProvider, child) {
        final data = apiProvider.smartHomeData;
        
        // Show simulated loading/empty state if no data, or real values if available
        final temp = data?.temperature.toStringAsFixed(1) ?? '--';
        final hum = data?.humidity.toStringAsFixed(1) ?? '--';
        final soil = data?.soilMoisture.toStringAsFixed(1) ?? '--';
        final light = data?.lightLevel.toStringAsFixed(1) ?? '--';

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
                        const Icon(Icons.thermostat, color: AppColors.successColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Climate Data',
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildClimateItem('Temperature', '$temp°C', Icons.thermostat),
                    _buildClimateItem('Humidity', '$hum%', Icons.water_drop),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildClimateItem('Soil', '$soil%', Icons.grass),
                    _buildClimateItem('Light', '$light%', Icons.light_mode),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClimateItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.successColor),
        const SizedBox(height: 8),
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

