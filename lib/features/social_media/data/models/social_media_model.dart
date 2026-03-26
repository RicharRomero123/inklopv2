class SocialMediaAccount {
  final int id;
  final String platform;
  final String? nameAccount;
  final String? nickname;
  final String? avatar;
  final String link;
  final bool isVerified;
  final String verificationCode;

  SocialMediaAccount({
    required this.id,
    required this.platform,
    this.nameAccount,
    this.nickname,
    this.avatar,
    required this.link,
    required this.isVerified,
    required this.verificationCode,
  });

  factory SocialMediaAccount.fromJson(Map<String, dynamic> json) {
    return SocialMediaAccount(
      id: json['id'],
      platform: json['platform'],
      nameAccount: json['name_account'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      link: json['link'] ?? '',
      isVerified: json['isVerified'] ?? false,
      verificationCode: json['verificationCode'] ?? '',
    );
  }

  // Extrae el @usuario del link para mostrarlo en la UI
  String get displayUsername {
    if (link.contains('@')) {
      return '@${link.split('@').last.split('/').first}';
    }
    return link;
  }
}