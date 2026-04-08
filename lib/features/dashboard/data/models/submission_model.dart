class UserSubmission {
  final int submissionId;
  final String videoUrl;
  final String submissionStatus;
  final String description;
  final DateTime createdAt;
  final SocialMediaMini socialMedia;
  final CampaignMini campaign;
  final PostStats post;
  final PaymentData? payment;

  UserSubmission({
    required this.submissionId,
    required this.videoUrl,
    required this.submissionStatus,
    required this.description,
    required this.createdAt,
    required this.socialMedia,
    required this.campaign,
    required this.post,
    this.payment,
  });

  factory UserSubmission.fromJson(Map<String, dynamic> json) => UserSubmission(
    submissionId: json['submissionId'] ?? 0,
    videoUrl: json['videoUrl'] ?? '',
    submissionStatus: json['submissionStatus'] ?? 'PENDING',
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    socialMedia: SocialMediaMini.fromJson(json['socialMedia'] ?? {}),
    campaign: CampaignMini.fromJson(json['campaign'] ?? {}),
    post: PostStats.fromJson(json['post'] ?? {}),
    payment: json['payment'] != null
        ? PaymentData.fromJson(json['payment'])
        : null,
  );

  // Helpers de estado
  bool get isApproved => submissionStatus == 'APPROVED';
  bool get isRejected => submissionStatus == 'REJECTED';
  bool get isPending  => submissionStatus == 'PENDING';
  bool get isError    => submissionStatus == 'ERROR';
  bool get isOnAppeal => submissionStatus == 'ON_APPEAL';
}

// ── SOCIAL MEDIA ──────────────────────────────────────────────────────────────
class SocialMediaMini {
  final int id;
  final String platform;
  final String nameAccount;
  final String nickname;
  final String avatar;
  final String link;
  final bool isVerified;

  SocialMediaMini({
    required this.id,
    required this.platform,
    required this.nameAccount,
    required this.nickname,
    required this.avatar,
    required this.link,
    required this.isVerified,
  });

  factory SocialMediaMini.fromJson(Map<String, dynamic> json) =>
      SocialMediaMini(
        id: json['id'] ?? 0,
        platform: json['platform'] ?? '',
        nameAccount: json['name_account'] ?? '',
        nickname: json['nickname'] ?? '',
        avatar: json['avatar'] ?? '',
        link: json['link'] ?? '',
        isVerified: json['isVerified'] ?? false,
      );
}

// ── CAMPAIGN MINI ─────────────────────────────────────────────────────────────
class CampaignMini {
  final int idCampaign;
  final String title;
  final String image;
  final String description;
  final String creatorType;
  final String campaignStatus;
  final List<String> categories;
  final List<String> hashtags;
  final CampaignBudgetMini budget;

  CampaignMini({
    required this.idCampaign,
    required this.title,
    required this.image,
    required this.description,
    required this.creatorType,
    required this.campaignStatus,
    required this.categories,
    required this.hashtags,
    required this.budget,
  });

  factory CampaignMini.fromJson(Map<String, dynamic> json) => CampaignMini(
    idCampaign: json['idCampaign'] ?? 0,
    title: json['tittle'] ?? '',       // ⚠️ typo del backend
    image: json['image'] ?? '',
    description: json['description'] ?? '',
    creatorType: json['creatorType'] ?? '',
    campaignStatus: json['campaignStatus'] ?? '',
    categories: List<String>.from(json['categories'] ?? []),
    hashtags: List<String>.from(json['hashtags'] ?? []),
    budget: CampaignBudgetMini.fromJson(json['budget'] ?? {}),
  );
}

class CampaignBudgetMini {
  final double totalBudget;
  final double spentBudget;
  final double percentage;
  final double minPayment;
  final double maxPayment;
  final double cpm;

  CampaignBudgetMini({
    required this.totalBudget,
    required this.spentBudget,
    required this.percentage,
    required this.minPayment,
    required this.maxPayment,
    required this.cpm,
  });

  factory CampaignBudgetMini.fromJson(Map<String, dynamic> json) =>
      CampaignBudgetMini(
        totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
        spentBudget: (json['spentBudget'] as num?)?.toDouble() ?? 0.0,
        percentage:  (json['percentageT'] as num?)?.toDouble() ?? 0.0,
        minPayment:  (json['minimunPayment'] as num?)?.toDouble() ?? 0.0,
        maxPayment:  (json['maximunPayment'] as num?)?.toDouble() ?? 0.0,
        cpm:         (json['cpm'] as num?)?.toDouble() ?? 0.0,
      );
}

// ── POST STATS ────────────────────────────────────────────────────────────────
class PostStats {
  final String id;
  final String externalId;
  final String platform;
  final String caption;
  final int views;
  final int likes;
  final int comments;
  final int shares;
  final int bookmarks;
  final String displayImage;   // display_image
  final String videoUrl;       // video_url
  final String channelUrl;     // channel_url — link al perfil
  final String channelImage;   // channel_image — avatar del creador
  final DateTime? timestamp;   // fecha original del post

  PostStats({
    required this.id,
    required this.externalId,
    required this.platform,
    required this.caption,
    required this.views,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.bookmarks,
    required this.displayImage,
    required this.videoUrl,
    required this.channelUrl,
    required this.channelImage,
    this.timestamp,
  });

  factory PostStats.fromJson(Map<String, dynamic> json) => PostStats(
    id: json['id']?.toString() ?? '',
    externalId: json['externalId'] ?? '',
    platform: json['platform'] ?? '',
    caption: json['caption'] ?? '',
    views: (json['views'] as num?)?.toInt() ?? 0,
    likes: (json['likes'] as num?)?.toInt() ?? 0,
    comments: (json['comments'] as num?)?.toInt() ?? 0,
    shares: (json['shares'] as num?)?.toInt() ?? 0,
    bookmarks: (json['bookmarks'] as num?)?.toInt() ?? 0,
    displayImage: json['display_image'] ?? '',
    videoUrl: json['video_url'] ?? '',
    channelUrl: json['channel_url'] ?? '',
    channelImage: json['channel_image'] ?? '',
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'])
        : null,
  );
}

// ── PAYMENT ───────────────────────────────────────────────────────────────────
class PaymentData {
  final double netPayment;

  PaymentData({required this.netPayment});

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    // El endpoint /all/creator devuelve payment directo
    // El endpoint /submissions/{id} puede tener paymentData anidado
    netPayment: json['netPayment'] != null
        ? (json['netPayment'] as num).toDouble()
        : json['paymentData'] != null
        ? (json['paymentData']['netPayment'] as num).toDouble()
        : 0.0,
  );
}