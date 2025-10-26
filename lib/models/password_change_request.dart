class PasswordChangeRequest {
  final String oldPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }
}

class PasswordChangeResponse {
  final String message;

  PasswordChangeResponse({required this.message});

  factory PasswordChangeResponse.fromJson(Map<String, dynamic> json) {
    return PasswordChangeResponse(
      message: json['message'] ?? '',
    );
  }
}
