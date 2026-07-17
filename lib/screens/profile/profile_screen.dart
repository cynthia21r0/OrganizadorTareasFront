import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    await auth.refreshFamilyMembers();
    if (auth.currentUser != null) {
      await context.read<TaskProvider>().loadMyTasks(auth.currentUser!.id);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() => _isLoadingImage = true);

      try {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        String base64String = base64Encode(imageBytes);

        await context.read<AuthProvider>().updateProfilePicture(base64String);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil actualizada con éxito'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la foto: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoadingImage = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox.shrink();
    final String inviteCode = user.familyInviteCode ?? 'Sin código';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.summaryCardEnd,
                      backgroundImage: user.profilePicture != null
                          ? MemoryImage(base64Decode(user.profilePicture!))
                          : null,
                      child: user.profilePicture == null
                          ? Text(
                              user.avatarInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (_isLoadingImage)
                      const Positioned.fill(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    if (!_isLoadingImage)
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.priorityLow,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'En línea',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.priorityLow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Código de Invitación Familiar',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inviteCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.priorityLow),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Código copiado al portapapeles'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Rendimiento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricChip(
                'Total',
                '${taskProvider.totalCount}',
                AppColors.pendingChipBg,
                AppColors.pendingChipText,
              ),
              const SizedBox(width: 10),
              _metricChip(
                'Hechas',
                '${taskProvider.completedCount}',
                AppColors.completedBg,
                AppColors.completedCheck,
              ),
              const SizedBox(width: 10),
              _metricChip(
                'Pendientes',
                '${taskProvider.pendingCount}',
                AppColors.priorityHighBg,
                AppColors.priorityHigh,
              ),
            ],
          ),

          const SizedBox(height: 40),

          OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11.5, color: fg)),
          ],
        ),
      ),
    );
  }
}
