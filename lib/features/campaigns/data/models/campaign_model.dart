// ── MODELO DE CAMPAÑA PRINCIPAL ──────────────────────────────────────────────
class Campaign {
  final int id;
  final String title;
  final String image;           // Imagen de portada (banner)
  final String businessImage;    // Logo de la empresa
  final String businessName;
  final String description;
  final String creatorType;
  final String status;           // campaignStatus
  final List<String> categories;
  final List<String> hashtags;
  final bool allowsTiktok;
  final bool allowsInstagram;
  final int quantitySubmissions; // 🚀 Clave para el filtro de "Más Populares"
  final CampaignBudget budget;
  final CampaignMetrics metrics;

  Campaign({
    required this.id,
    required this.title,
    required this.image,
    required this.businessImage,
    required this.businessName,
    required this.description,
    required this.creatorType,
    required this.status,
    required this.categories,
    required this.hashtags,
    required this.allowsTiktok,
    required this.allowsInstagram,
    required this.quantitySubmissions,
    required this.budget,
    required this.metrics,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['idCampaign'] ?? 0,
      title: json['tittle'] ?? '', // ⚠️ Mapeo del typo 'tittle'
      image: json['image'] ?? '',
      businessImage: json['businessImage'] ?? '',
      businessName: json['businessName'] ?? '',
      description: json['description'] ?? '',
      creatorType: json['creatorType'] ?? '',
      status: json['campaignStatus'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      allowsTiktok: json['allowsTiktok'] ?? false,
      allowsInstagram: json['allowsInstagram'] ?? false,
      quantitySubmissions: json['quantitySubmissions'] ?? 0,
      budget: CampaignBudget.fromJson(json['budget'] ?? {}),
      metrics: CampaignMetrics.fromJson(json['metricsDates'] ?? {}),
    );
  }
}

// ── MODELO DE PRESUPUESTO Y PAGOS ───────────────────────────────────────────
class CampaignBudget {
  final double total;
  final double spent;
  final double percentage;
  final double minPayment;
  final double maxPayment;
  final double cpm;

  CampaignBudget({
    required this.total,
    required this.spent,
    required this.percentage,
    required this.minPayment,
    required this.maxPayment,
    required this.cpm,
  });

  factory CampaignBudget.fromJson(Map<String, dynamic> json) {
    return CampaignBudget(
      total: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spentBudget'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentageT'] as num?)?.toDouble() ?? 0.0,
      minPayment: (json['minimunPayment'] as num?)?.toDouble() ?? 0.0, // ⚠️ Typo
      maxPayment: (json['maximunPayment'] as num?)?.toDouble() ?? 0.0,
      cpm: (json['cpm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── MODELO DE MÉTRICAS Y TIEMPO ──────────────────────────────────────────────
class CampaignMetrics {
  final String? startDate;
  final String? endDate;
  final int durationInDays;
  final int daysRemaining;
  final double percentageElapsed;

  CampaignMetrics({
    this.startDate,
    this.endDate,
    required this.durationInDays,
    required this.daysRemaining,
    required this.percentageElapsed,
  });

  factory CampaignMetrics.fromJson(Map<String, dynamic> json) {
    return CampaignMetrics(
      startDate: json['startDate'],
      endDate: json['endDate'],
      durationInDays: json['durationInDays'] ?? 0,
      daysRemaining: json['daysRemaining'] ?? 0,
      percentageElapsed: (json['percentageElapsed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── MODELO PARA SCRAPING DE VIDEOS ───────────────────────────────────────────
class SocialVideo {
  final String id;
  final String videoUrl;
  final String coverUrl;

  SocialVideo({required this.id, required this.videoUrl, required this.coverUrl});

  factory SocialVideo.fromJson(Map<String, dynamic> json) => SocialVideo(
    id: json['id']?.toString() ?? '',
    videoUrl: json['videoUrl'] ?? '',
    coverUrl: json['coverUrl'] ?? '',
  );

  // ✅ Para persistencia local (SharedPreferences)
  Map<String, dynamic> toJson() => {
    'id': id,
    'videoUrl': videoUrl,
    'coverUrl': coverUrl,
  };
}


// ── MODELO DE RESPUESTA DE POSTULACIÓN ───────────────────────────────────────
class SubmissionResponse {
  final int submissionId;
  final String? status;

  SubmissionResponse({required this.submissionId, this.status});

  factory SubmissionResponse.fromJson(Map<String, dynamic> json) => SubmissionResponse(
    submissionId: json['submissionId'] ?? 0,
    status: json['submissionStatus'],
  );
}

