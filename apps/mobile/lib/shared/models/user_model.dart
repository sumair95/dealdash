class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.subscriptionStatus = 'free',
    this.searchCount = 0,
    this.fcmToken,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String subscriptionStatus;
  final int searchCount;
  final String? fcmToken;

  bool get isPremium => subscriptionStatus == 'premium';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      subscriptionStatus: json['subscription_status'] as String? ?? 'free',
      searchCount: json['search_count'] as int? ?? 0,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'subscription_status': subscriptionStatus,
        'search_count': searchCount,
        'fcm_token': fcmToken,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? subscriptionStatus,
    int? searchCount,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      searchCount: searchCount ?? this.searchCount,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
