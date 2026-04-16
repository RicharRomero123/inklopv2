class CreatorMetrics {
  final int totalSubmissions;
  final int totalViews;
  final double engagement;

  CreatorMetrics({
    required this.totalSubmissions,
    required this.totalViews,
    required this.engagement,
  });

  factory CreatorMetrics.fromJson(Map<String, dynamic> json) {
    return CreatorMetrics(
      totalSubmissions: json['totalSubmissions'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      engagement: (json['engagement'] as num).toDouble(),
    );
  }
}