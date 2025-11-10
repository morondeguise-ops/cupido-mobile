import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/services_provider.dart';

/// A widget that displays a Google AdMob banner ad
class AdBannerWidget extends ConsumerStatefulWidget {
  final String placementKey;
  final EdgeInsetsGeometry? margin;

  const AdBannerWidget({
    super.key,
    required this.placementKey,
    this.margin,
  });

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adService = ref.read(adServiceProvider);
      final bannerAd = await adService.createBannerAd(widget.placementKey);

      if (mounted && bannerAd != null) {
        setState(() {
          _bannerAd = bannerAd;
          _isLoaded = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ad is not loaded or loading
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
