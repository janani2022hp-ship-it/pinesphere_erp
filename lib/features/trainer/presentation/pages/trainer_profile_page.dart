import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinesphere_erp/core/theme/app_colors.dart';
import 'package:pinesphere_erp/features/trainer/data/services/trainer_api_service.dart';
import '../widgets/profile/qualification_card.dart';
import '../widgets/profile/settings_tile.dart';
import '../widgets/profile/trainer_info_card.dart';

class TrainerProfilePage extends StatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {
  final TrainerApiService service = TrainerApiService();
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight.withAlpha((.12 * 255).round()),
      appBar: AppBar(
        title: Text('Trainer Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: FutureBuilder<TrainerProfile>(
        future: service.fetchProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              TrainerInfoCard(profile: profile),
              const SizedBox(height: 16),
              QualificationCard(qualifications: const ['M.Sc Mathematics', 'B.Ed.', 'Physics Education Program']),
              const SizedBox(height: 16),
              SettingsTile(label: 'Notifications', value: notificationsEnabled, onChanged: (value) {
                setState(() { notificationsEnabled = value; });
                service.updateSetting('notifications', value);
              }),
              const SettingsTile(label: 'Dark mode', value: false, onChanged: null),
            ],
          );
        },
      ),
    );
  }
}
