import 'dart:async';

class TrainerProfile {
  final String name;
  final String subject;
  final String experience;
  final String email;

  TrainerProfile({
    required this.name,
    required this.subject,
    required this.experience,
    required this.email,
  });
}

class TrainerApiService {
  Future<TrainerProfile> fetchProfile() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return TrainerProfile(
      name: 'Meera Kapoor',
      subject: 'Mathematics & Physics',
      experience: '8 years teaching experience',
      email: 'meera.kapoor@pinesphere.com',
    );
  }

  Future<List<String>> fetchQualifications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return ['M.Sc Mathematics', 'B.Ed.', 'Certificate in Physics Education'];
  }

  Future<void> updateSetting(String key, bool value) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
