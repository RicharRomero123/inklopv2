class Campaign {
  final int id;
  final String title;
  final String image;
  final String businessName;
  final String description;
  final String creatorType;
  final List<String> categories;
  final bool allowsTiktok;
  final bool allowsInstagram;
  final CampaignBudget budget;
  final CampaignMetrics metrics;

  Campaign({
    required this.id,
    required this.title,
    required this.image,
    required this.businessName,
    required this.description,
    required this.creatorType,
    required this.categories,
    required this.allowsTiktok,
    required this.allowsInstagram,
    required this.budget,
    required this.metrics,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['idCampaign'],
      title: json['tittle'],
      image: json['image'],
      businessName: json['businessName'],
      description: json['description'],
      creatorType: json['creatorType'],
      categories: List<String>.from(json['categories']),
      allowsTiktok: json['allowsTiktok'] ?? false,
      allowsInstagram: json['allowsInstagram'] ?? false,
      budget: CampaignBudget.fromJson(json['budget']),
      metrics: CampaignMetrics.fromJson(json['metricsDates']),
    );
  }
}

class CampaignBudget {
  final double total;
  final double spent;
  final double percentage;
  final double cpm;

  CampaignBudget({required this.total, required this.spent, required this.percentage, required this.cpm});

  factory CampaignBudget.fromJson(Map<String, dynamic> json) {
    return CampaignBudget(
      total: (json['totalBudget'] as num).toDouble(),
      spent: (json['spentBudget'] as num).toDouble(),
      percentage: (json['percentageT'] as num).toDouble(),
      cpm: (json['cpm'] as num).toDouble(),
    );
  }
}

class CampaignMetrics {
  final String endDate;
  final int daysRemaining;

  CampaignMetrics({required this.endDate, required this.daysRemaining});

  factory CampaignMetrics.fromJson(Map<String, dynamic> json) {
    return CampaignMetrics(
      endDate: json['endDate'],
      daysRemaining: json['daysRemaining'],
    );
  }
}