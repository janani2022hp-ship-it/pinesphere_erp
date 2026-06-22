// core/utils/validators.dart

class Validators {

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter Email";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "Minimum 6 characters";
    }
    return null;
  }
}