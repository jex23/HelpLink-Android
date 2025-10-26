class ProfileUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? address;
  final int? age;
  final String? number;

  ProfileUpdateRequest({
    this.firstName,
    this.lastName,
    this.address,
    this.age,
    this.number,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (address != null) data['address'] = address;
    if (age != null) data['age'] = age;
    if (number != null) data['number'] = number;

    return data;
  }
}

class ProfileUpdateResponse {
  final String message;
  final Map<String, dynamic> user;

  ProfileUpdateResponse({
    required this.message,
    required this.user,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message'] ?? '',
      user: json['user'] ?? {},
    );
  }
}

class ProfileImageResponse {
  final String? profileImage;

  ProfileImageResponse({this.profileImage});

  factory ProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageResponse(
      profileImage: json['profile']?['profile_image'],
    );
  }
}

class UpdateProfileImageResponse {
  final String message;
  final String? profileImage;

  UpdateProfileImageResponse({
    required this.message,
    this.profileImage,
  });

  factory UpdateProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileImageResponse(
      message: json['message'] ?? '',
      profileImage: json['profile']?['profile_image'],
    );
  }
}
