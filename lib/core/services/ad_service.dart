import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/ad_placement.dart';
import 'api_service.dart';
import 'subscription_service.dart';

class AdService {
  final ApiService _apiService;
  final SubscriptionService _subscriptionService;

  AdConfig? _adConfig;
  bool _initialized = false;

  AdService(this._apiService, this._subscriptionService);

  /// Initialize the Google Mobile Ads SDK
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await MobileAds.instance.initialize();
      debugPrint('Google Mobile Ads SDK initialized');
      _initialized = true;

      // Fetch ad configuration from API
      await fetchAdConfig();
    } catch (e) {
      debugPrint('Error initializing Google Mobile Ads SDK: $e');
    }
  }

  /// Fetch ad configuration from the backend
  Future<void> fetchAdConfig() async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final response = await _apiService.get('/ads/config?platform=$platform');

      if (response.data['success'] == true) {
        _adConfig = AdConfig.fromJson(response.data);
        debugPrint('Ad config fetched: ${_adConfig?.placements.length} placements');
      }
    } catch (e) {
      debugPrint('Error fetching ad config: $e');
    }
  }

  /// Check if ads should be shown (not for premium users)
  Future<bool> shouldShowAds() async {
    try {
      final hasSubscription = await _subscriptionService.hasActiveSubscription();
      return !hasSubscription;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      // Default to showing ads if we can't determine subscription status
      return true;
    }
  }

  /// Get ad placement configuration
  AdPlacement? getPlacement(String placementKey) {
    return _adConfig?.getPlacement(placementKey);
  }

  /// Check if a placement exists and is configured
  bool hasPlacement(String placementKey) {
    return _adConfig?.hasPlacement(placementKey) ?? false;
  }

  /// Create a banner ad
  Future<BannerAd?> createBannerAd(String placementKey) async {
    // Check if user should see ads
    final showAds = await shouldShowAds();
    if (!showAds) {
      debugPrint('Not showing ads - user has premium subscription');
      return null;
    }

    // Get placement config
    final placement = getPlacement(placementKey);
    if (placement == null) {
      debugPrint('Ad placement not found: $placementKey');
      return null;
    }

    if (placement.adType != AdType.banner) {
      debugPrint('Ad placement $placementKey is not a banner ad');
      return null;
    }

    try {
      final bannerAd = BannerAd(
        adUnitId: placement.adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded: $placementKey');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $placementKey - $error');
            ad.dispose();
          },
          onAdOpened: (ad) {
            debugPrint('Banner ad opened: $placementKey');
          },
          onAdClosed: (ad) {
            debugPrint('Banner ad closed: $placementKey');
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      debugPrint('Error creating banner ad: $e');
      return null;
    }
  }

  /// Create an interstitial ad
  Future<InterstitialAd?> createInterstitialAd(String placementKey) async {
    // Check if user should see ads
    final showAds = await shouldShowAds();
    if (!showAds) {
      debugPrint('Not showing ads - user has premium subscription');
      return null;
    }

    // Get placement config
    final placement = getPlacement(placementKey);
    if (placement == null) {
      debugPrint('Ad placement not found: $placementKey');
      return null;
    }

    if (placement.adType != AdType.interstitial) {
      debugPrint('Ad placement $placementKey is not an interstitial ad');
      return null;
    }

    try {
      InterstitialAd? interstitialAd;

      await InterstitialAd.load(
        adUnitId: placement.adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Interstitial ad loaded: $placementKey');
            interstitialAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('Interstitial ad showed: $placementKey');
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Interstitial ad dismissed: $placementKey');
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Interstitial ad failed to show: $placementKey - $error');
                ad.dispose();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: $placementKey - $error');
          },
        ),
      );

      return interstitialAd;
    } catch (e) {
      debugPrint('Error creating interstitial ad: $e');
      return null;
    }
  }

  /// Create a rewarded ad
  Future<RewardedAd?> createRewardedAd(String placementKey) async {
    // Rewarded ads can be shown to premium users as they provide value

    // Get placement config
    final placement = getPlacement(placementKey);
    if (placement == null) {
      debugPrint('Ad placement not found: $placementKey');
      return null;
    }

    if (placement.adType != AdType.rewarded) {
      debugPrint('Ad placement $placementKey is not a rewarded ad');
      return null;
    }

    try {
      RewardedAd? rewardedAd;

      await RewardedAd.load(
        adUnitId: placement.adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded ad loaded: $placementKey');
            rewardedAd = ad;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('Rewarded ad showed: $placementKey');
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Rewarded ad dismissed: $placementKey');
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Rewarded ad failed to show: $placementKey - $error');
                ad.dispose();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: $placementKey - $error');
          },
        ),
      );

      return rewardedAd;
    } catch (e) {
      debugPrint('Error creating rewarded ad: $e');
      return null;
    }
  }

  /// Dispose of resources
  void dispose() {
    _adConfig = null;
    _initialized = false;
  }
}
