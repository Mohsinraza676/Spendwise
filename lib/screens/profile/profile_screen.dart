import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final db = Provider.of<DatabaseService?>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: db == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
          : StreamBuilder<DocumentSnapshot>(
              stream: db.userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentColor));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found'));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentColor.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person_rounded, size: 50, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'User Name',
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        userData['email'] ?? 'email@example.com',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      
                      _buildSectionTitle('Account'),
                      const SizedBox(height: 12),
                      _buildProfileOption(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'My Wallets',
                        onTap: () {},
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle('Preferences'),
                      const SizedBox(height: 12),
                      _buildProfileOption(
                        context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        context,
                        icon: Icons.security_rounded,
                        title: 'Security',
                        onTap: () {},
                      ),
                      
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => _showLogoutDialog(context, authService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(color: AppTheme.errorColor.withOpacity(0.1)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary.withOpacity(0.8),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out from SpendWise?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
