class AdPlacement {
  final String placementKey;
  final String adUnitId;
  final AdType adType;
  final int frequency;

  AdPlacement({
    required this.placementKey,
    required this.adUnitId,
    required this.adType,
    required this.frequency,
  });

  factory AdPlacement.fromJson(Map<String, dynamic> json) {
    return AdPlacement(
      placementKey: json['placement_key'] as String,
      adUnitId: json['ad_unit_id'] as String,
      adType: _adTypeFromString(json['ad_type'] as String),
      frequency: json['frequency'] as int? ?? 1,
    );
  }

  static AdType _adTypeFromString(String type) {
    switch (type) {
      case 'banner':
        return AdType.banner;
      case 'interstitial':
        return AdType.interstitial;
      case 'rewarded':
        return AdType.rewarded;
      case 'native':
        return AdType.native;
      default:
        return AdType.banner;
    }
  }
}

enum AdType {
  banner,
  interstitial,
  rewarded,
  native,
}

class AdConfig {
  final List<AdPlacement> placements;

  AdConfig({required this.placements});

  factory AdConfig.fromJson(Map<String, dynamic> json) {
    final placementsData = json['data']?['placements'] as List<dynamic>? ?? [];
    final placements = placementsData
        .map((p) => AdPlacement.fromJson(p as Map<String, dynamic>))
        .toList();

    return AdConfig(placements: placements);
  }

  AdPlacement? getPlacement(String key) {
    try {
      return placements.firstWhere((p) => p.placementKey == key);
    } catch (e) {
      return null;
    }
  }

  bool hasPlacement(String key) {
    return placements.any((p) => p.placementKey == key);
  }
}
