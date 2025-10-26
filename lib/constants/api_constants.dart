class ApiConstants {
  // Base URL for the API
  // For Android Emulator: use 10.0.2.2
  // For Physical Device: use your computer's IP address (e.g., 192.168.100.2)
  static const String baseUrl = 'http://10.0.2.2:5001';
  //static const String baseUrl = 'https://jamesgalos.shop';


  // Auth endpoints
  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String fileUrlEndpoint = '/api/auth/file-url';
  static const String changePasswordEndpoint = '/api/auth/change-password';
  static const String profileEndpoint = '/api/auth/profile';
  static const String forgotPasswordEndpoint = '/api/auth/forgot-password';
  static const String verifyOtpEndpoint = '/api/auth/verify-otp';
  static const String resetPasswordEndpoint = '/api/auth/reset-password';

  // Credentials endpoints
  static const String credentialsEndpoint = '/api/credentials';
  static const String idsEndpoint = '/api/ids';
  static const String profileImageEndpoint = '/api/profile-image';

  // Post endpoints
  static const String postEndpoint = '/api/posts';
  static const String donationsEndpoint = '/api/posts/donations';
  static const String requestsEndpoint = '/api/posts/requests';
  static const String donatorsEndpoint = '/api/posts/donators';
  static const String supportersEndpoint = '/api/posts/supporters';

  // Chat endpoints
  static const String chatEndpoint = '/api/chats';

  // Full URLs
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get meUrl => '$baseUrl$meEndpoint';
  static String fileUrl(String path) => '$baseUrl$fileUrlEndpoint/$path';
  static String get changePasswordUrl => '$baseUrl$changePasswordEndpoint';
  static String get profileUrl => '$baseUrl$profileEndpoint';
  static String get forgotPasswordUrl => '$baseUrl$forgotPasswordEndpoint';
  static String get verifyOtpUrl => '$baseUrl$verifyOtpEndpoint';
  static String get resetPasswordUrl => '$baseUrl$resetPasswordEndpoint';
  static String get credentialsUrl => '$baseUrl$credentialsEndpoint';
  static String get idsUrl => '$baseUrl$idsEndpoint';
  static String get profileImageUrl => '$baseUrl$profileImageEndpoint';
  static String get postUrl => '$baseUrl$postEndpoint';
  static String get donationsUrl => '$baseUrl$donationsEndpoint';
  static String get requestsUrl => '$baseUrl$requestsEndpoint';
  static String get donatorsUrl => '$baseUrl$donatorsEndpoint';
  static String get supportersUrl => '$baseUrl$supportersEndpoint';
  static String postDetailUrl(int postId) => '$baseUrl$postEndpoint/$postId';
  static String postCloseUrl(int postId) => '$baseUrl$postEndpoint/$postId/close';
  static String postReactionUrl(int postId) => '$baseUrl$postEndpoint/$postId/reaction';
  static String postDonateUrl(int postId) => '$baseUrl$postEndpoint/$postId/donate';
  static String postSupportUrl(int postId) => '$baseUrl$postEndpoint/$postId/support';
  static String postCommentsUrl(int postId) => '$baseUrl$postEndpoint/$postId/comments';
  static String commentUrl(int commentId) => '$baseUrl$postEndpoint/comments/$commentId';
  static String donatorDetailUrl(int donatorId) => '$baseUrl$donatorsEndpoint/$donatorId';
  static String supporterDetailUrl(int supporterId) => '$baseUrl$supportersEndpoint/$supporterId';
  static String get chatUrl => '$baseUrl$chatEndpoint';
  static String chatDetailUrl(int chatId) => '$baseUrl$chatEndpoint/$chatId';
  static String chatMessagesUrl(int chatId) => '$baseUrl$chatEndpoint/$chatId/messages';
  static String chatMessagesSeenUrl(int chatId) => '$baseUrl$chatEndpoint/$chatId/messages/seen';
  static String chatParticipantsUrl(int chatId) => '$baseUrl$chatEndpoint/$chatId/participants';
}
