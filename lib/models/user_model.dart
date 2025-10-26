class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? address;
  final int? age;
  final String? number;
  final String accountType;
  final String badge;
  final String? profileImage;
  final String? verificationSelfie;
  final String? validId;
  final DateTime createdAt;
  final DateTime? lastLogon;

  User({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    required this.email,
    this.address,
    this.age,
    this.number,
    this.accountType = 'beneficiary',
    this.badge = 'pending',
    this.profileImage,
    this.verificationSelfie,
    this.validId,
    required this.createdAt,
    this.lastLogon,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('=== USER MODEL PARSING ===');
    print('JSON: $json');

    // Handle both API formats (old and new)
    String firstName;
    String lastName;

    // New API format: first_name, last_name
    if (json.containsKey('first_name') && json['first_name'] != null) {
      firstName = json['first_name'] as String? ?? '';
      lastName = json['last_name'] as String? ?? '';
      print('Using first_name/last_name format: $firstName $lastName');
    }
    // Legacy format: full_name (backward compatibility)
    else if (json.containsKey('full_name') && json['full_name'] != null) {
      final fullName = json['full_name'] as String;
      final parts = fullName.split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      print('Using full_name format: $fullName -> $firstName $lastName');
    } else {
      firstName = '';
      lastName = '';
      print('No name fields found');
    }

    final user = User(
      id: json['id'] as int,
      firstName: firstName,
      lastName: lastName,
      email: json['email'] as String,
      address: json['address'] as String?,
      age: json['age'] as int?,
      number: json['number'] as String?,
      accountType: json['account_type'] as String? ?? 'beneficiary',
      badge: json['badge'] as String? ?? json['status'] as String? ?? 'pending',
      profileImage: json['profile_image'] as String?,
      verificationSelfie: json['verification_selfie'] as String?,
      validId: json['valid_id'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String),
      lastLogon: json['last_logon'] != null
          ? _parseDateTime(json['last_logon'] as String)
          : (json['updated_at'] != null ? _parseDateTime(json['updated_at'] as String) : null),
    );

    print('Created user: ${user.fullName} (${user.email})');
    print('Badge: ${user.badge}, Account Type: ${user.accountType}');
    print('Profile Image URL: ${user.profileImage ?? "null"}');
    print('=== USER MODEL PARSING END ===');

    return user;
  }

  // Parse both ISO and RFC date formats
  static DateTime _parseDateTime(String dateStr) {
    try {
      // Try ISO format first
      return DateTime.parse(dateStr);
    } catch (e) {
      // Try RFC format (e.g., "Tue, 21 Oct 2025 19:35:01 GMT")
      try {
        return DateTime.parse(dateStr.replaceAll(' GMT', ''));
      } catch (e2) {
        // Manual parsing for RFC format
        final parts = dateStr.split(' ');
        if (parts.length >= 5) {
          final day = int.parse(parts[1]);
          final month = _monthToNumber(parts[2]);
          final year = int.parse(parts[3]);
          final timeParts = parts[4].split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = int.parse(timeParts[2]);
          return DateTime.utc(year, month, day, hour, minute, second);
        }
        // Fallback to current time if parsing fails
        return DateTime.now();
      }
    }
  }

  static int _monthToNumber(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
      'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
      'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[month] ?? 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'address': address,
      'age': age,
      'number': number,
      'account_type': accountType,
      'badge': badge,
      'profile_image': profileImage,
      'verification_selfie': verificationSelfie,
      'valid_id': validId,
      'created_at': createdAt.toIso8601String(),
      'last_logon': lastLogon?.toIso8601String(),
    };
  }

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return '';
    if (lastName.isEmpty) return firstName;
    if (firstName.isEmpty) return lastName;
    return '$firstName $lastName';
  }
}
