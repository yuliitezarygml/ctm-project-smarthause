import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/api_provider.dart';

class LampControlCard extends StatelessWidget {
  const LampControlCard({super.key});

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

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
                Icon(Icons.lightbulb, color: AppColors.warningColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Lamp Control',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: apiProvider.smartHomeData?.lamps.every((lamp) => lamp) ?? false,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: (value) {
                    apiProvider.toggleAllLamps(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(6, (index) => _buildLampItem(context, index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLampItem(BuildContext context, int lampIndex) {
    final apiProvider = Provider.of<ApiProvider>(context);
    final lampState = apiProvider.smartHomeData?.lamps[lampIndex] ?? false;
    final isLoading = apiProvider.isLoading;

    return Column(
      children: [
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.lightbulb,
                size: 32,
                color: lampState ? AppColors.lampOn : AppColors.lampOff,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                      apiProvider.toggleLamp(lampIndex);
                    },
            ),
            if (isLoading)
              Positioned(
                right: 0,
                top: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withAlpha(178), // 0.7 opacity equivalent
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
              ),
          ],
        ),
        Text(
          'Lamp ${lampIndex + 1}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }
}
