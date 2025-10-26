import 'dart:io';

class SignupRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? address;
  final int? age;
  final String? number;
  final String accountType;
  final File? profileImage;
  final File? verificationSelfie; // Selfie with ID (live or uploaded)
  final File? validId;

  SignupRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.address,
    this.age,
    this.number,
    this.accountType = 'beneficiary',
    this.profileImage,
    this.verificationSelfie, // Selfie with ID
    this.validId,
  });

  Map<String, String> toFormFields() {
    final Map<String, String> fields = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'account_type': accountType.toLowerCase(),
    };

    if (address != null && address!.isNotEmpty) {
      fields['address'] = address!;
    }
    if (age != null) {
      fields['age'] = age.toString();
    }
    if (number != null && number!.isNotEmpty) {
      fields['number'] = number!;
    }

    return fields;
  }
}
