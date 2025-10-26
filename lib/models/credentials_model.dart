class Credentials {
  final String? verificationSelfie;
  final String? validId;

  Credentials({
    this.verificationSelfie,
    this.validId,
  });

  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      verificationSelfie: json['verification_selfie'],
      validId: json['valid_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verification_selfie': verificationSelfie,
      'valid_id': validId,
    };
  }
}

class CredentialsResponse {
  final Credentials credentials;

  CredentialsResponse({required this.credentials});

  factory CredentialsResponse.fromJson(Map<String, dynamic> json) {
    return CredentialsResponse(
      credentials: Credentials.fromJson(json['credentials'] ?? {}),
    );
  }
}

class UpdateCredentialsResponse {
  final String message;
  final Credentials credentials;

  UpdateCredentialsResponse({
    required this.message,
    required this.credentials,
  });

  factory UpdateCredentialsResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCredentialsResponse(
      message: json['message'] ?? '',
      credentials: Credentials.fromJson(json['credentials'] ?? {}),
    );
  }
}
