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
    final lamps = apiProvider.smartHomeData?.lamps ?? [false, false, false, false, false, false];

    // Helper to check if a zone is active (if any lamp in zone is on)
    bool isYardOn = lamps.length > 1 && (lamps[0] || lamps[1]);
    bool isGarageOn = lamps.length > 3 && (lamps[2] || lamps[3]);
    bool isHouseOn = lamps.length > 4 && lamps[4];
    bool isSecondHouseOn = lamps.length > 5 && lamps[5];

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
                  'Light Control',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Yard (Lamps 1 and 2)
            _buildZoneItem(
              context, 
              'Yard', 
              Icons.wb_sunny, 
              isYardOn, 
              (val) {
                 apiProvider.toggleLamp(0);
                 // Simple toggle for both, relying on provider/api to update state eventually
                 // Or we could try to sync them if they are different, but toggle is simplest for now
                 // Ideally API should have "setZone"
                 if (lamps[1] != lamps[0]) {
                   // If they are different, just toggle the one that matches target? 
                   // No, simply toggle both to flip them. 
                   // Better UX: Set both to 'val' if we had a set method.
                   // Since we only have toggle, we toggle both. 
                   // If they were desynchronized (one on, one off), toggling both keeps them desynchronized.
                   // Let's assume they are synchronized or we accept this behavior for now.
                   // To fix desync, we'd need separate calls based on state.
                   apiProvider.toggleLamp(1);
                 } else {
                   apiProvider.toggleLamp(1);
                 }
                 // Actually, let's just toggle both to be safe, the backend handles it.
                 // But wait, if I toggle 0, state changes. Then I toggle 1.
              },
              [0, 1]
            ),
            
            const SizedBox(height: 12),

            // Garage (Lamps 3 and 4)
            _buildZoneItem(
              context, 
              'Garage', 
              Icons.local_activity, // Activity icon similar to web
              isGarageOn, 
              (val) {
                 apiProvider.toggleLamp(2);
                 apiProvider.toggleLamp(3);
              },
              [2, 3]
            ),

            const SizedBox(height: 12),

            // House (Lamp 5)
            _buildZoneItem(
              context, 
              'Home', 
              Icons.home, 
              isHouseOn, 
              (val) => apiProvider.toggleLamp(4),
              [4]
            ),

            const SizedBox(height: 12),

             // House 2 (Lamp 6)
            _buildZoneItem(
              context, 
              'Guest House', 
              Icons.home_work, 
              isSecondHouseOn, 
              (val) => apiProvider.toggleLamp(5),
              [5]
            ),
            
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successColor.withOpacity(0.2),
                      foregroundColor: AppColors.successColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => apiProvider.toggleAllLamps(true),
                    child: const Text('Turn All On'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerColor.withOpacity(0.2),
                      foregroundColor: AppColors.dangerColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => apiProvider.toggleAllLamps(false),
                    child: const Text('Turn All Off'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildZoneItem(
    BuildContext context, 
    String title, 
    IconData icon, 
    bool isActive, 
    Function(bool) onChanged,
    List<int> lampIndices
  ) {
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    
    // Better logic: ensure we actually set the state if possible, 
    // but with toggle API we have to be careful.
    // For zones with 2 lamps, if states are mixed, "isActive" is true if ANY is on.
    // Toggling should probably turn OFF if active, ON if inactive.
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.warningColor.withOpacity(0.5) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.warningColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                Text(
                  isActive ? 'On' : 'Off',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isActive ? AppColors.warningColor : AppColors.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeColor: AppColors.warningColor,
            onChanged: (val) {
               // Smart toggle logic for zones
               if (lampIndices.length > 1) {
                  final lamps = apiProvider.smartHomeData?.lamps;
                  if (lamps != null) {
                    for (var index in lampIndices) {
                      // If we want to turn ON (val=true), only toggle if currently OFF
                      // If we want to turn OFF (val=false), only toggle if currently ON
                      if (lamps[index] != val) {
                        apiProvider.toggleLamp(index);
                      }
                    }
                  }
               } else {
                 onChanged(val);
               }
            },
          ),
        ],
      ),
    );
  }
}

