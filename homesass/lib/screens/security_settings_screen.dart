import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';
import '../utils/constants.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLoading = true;
  List<dynamic> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() => _isLoading = true);
      final cards = await Provider.of<ApiProvider>(context, listen: false).fetchCards();
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cards: $e')),
        );
      }
    }
  }

  Future<void> _addCard() async {
    final uidController = TextEditingController();
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Card', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: uidController,
              decoration: InputDecoration(
                labelText: 'Card UID',
                hintText: 'E.g. E2458A...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.nfc),
                  tooltip: 'Get last scanned card',
                  onPressed: () async {
                    // Refresh data to get the latest scan
                    await Provider.of<ApiProvider>(context, listen: false).fetchSmartHomeData();
                    
                    if (!mounted) return;
                    
                    final data = Provider.of<ApiProvider>(context, listen: false).smartHomeData;
                    if (data != null && data.lastAccess.isNotEmpty) {
                      // Parse "Last entry: UID"
                      String lastAccess = data.lastAccess;
                      String uid = lastAccess.replaceAll('Last entry: ', '').trim();
                      
                      if (uid.isNotEmpty && uid != 'System ready') {
                        uidController.text = uid;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Found UID: $uid')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No card scanned recently')),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (e.g. John)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (uidController.text.isNotEmpty && nameController.text.isNotEmpty) {
                Navigator.pop(context);
                try {
                  await Provider.of<ApiProvider>(context, listen: false)
                      .addCard(uidController.text, nameController.text);
                  _loadCards();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Card added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding card: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCard(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to remove access for $name ($uid)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<ApiProvider>(context, listen: false).deleteCard(uid);
        _loadCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card removed')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting card: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_accounts, size: 64, color: AppColors.hintColor),
                      const SizedBox(height: 16),
                      Text(
                        'No allowed cards found.',
                        style: GoogleFonts.poppins(color: AppColors.hintColor),
                      ),
                      Text(
                        'Add a card to restrict access.',
                        style: GoogleFonts.poppins(color: AppColors.hintColor, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.credit_card, color: AppColors.primaryColor),
                        ),
                        title: Text(
                          card['name'] ?? 'Unknown',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          card['uid'] ?? '',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: AppColors.textColor,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.dangerColor),
                          onPressed: () => _deleteCard(card['uid'], card['name']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
