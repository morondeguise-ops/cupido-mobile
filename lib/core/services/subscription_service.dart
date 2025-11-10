import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY'; // Replace with actual key

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(revenueCatApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(revenueCatApiKey);
      } else {
        debugPrint('Platform not supported for subscriptions');
        return;
      }

      await Purchases.configure(configuration);
      debugPrint('RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('Error initializing RevenueCat: $e');
    }
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      debugPrint('RevenueCat user ID set: $userId');
    } catch (e) {
      debugPrint('Error setting RevenueCat user ID: $e');
    }
  }

  /// Logout user from RevenueCat
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      debugPrint('RevenueCat user logged out');
    } catch (e) {
      debugPrint('Error logging out from RevenueCat: $e');
    }
  }

  /// Get available offerings/products
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('RevenueCat offerings retrieved: ${offerings.all.length}');
      return offerings;
    } catch (e) {
      debugPrint('Error getting RevenueCat offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<PurchaseResult?> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      debugPrint('Purchase successful: ${package.identifier}');
      return PurchaseResult(
        success: true,
        customerInfo: purchaserInfo.customerInfo,
        error: null,
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('Purchase error: $errorCode - ${e.message}');

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult(
          success: false,
          customerInfo: null,
          error: 'Purchase was cancelled',
        );
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        return PurchaseResult(
          success: false,
          customerInfo: null,
          error: 'You already own this subscription',
        );
      } else {
        return PurchaseResult(
          success: false,
          customerInfo: null,
          error: e.message ?? 'Purchase failed',
        );
      }
    } catch (e) {
      debugPrint('Unexpected purchase error: $e');
      return PurchaseResult(
        success: false,
        customerInfo: null,
        error: 'An unexpected error occurred',
      );
    }
  }

  /// Restore purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('Purchases restored successfully');
      return RestoreResult(
        success: true,
        customerInfo: customerInfo,
        error: null,
      );
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return RestoreResult(
        success: false,
        customerInfo: null,
        error: e.toString(),
      );
    }
  }

  /// Get customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('Customer info retrieved');
      return customerInfo;
    } catch (e) {
      debugPrint('Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription({String? entitlementId}) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      if (entitlementId != null) {
        return customerInfo.entitlements.active.containsKey(entitlementId);
      }

      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      return false;
    }
  }

  /// Check if user has specific entitlement
  Future<bool> hasEntitlement(String entitlementId) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return false;

      final entitlement = customerInfo.entitlements.all[entitlementId];
      return entitlement != null && entitlement.isActive;
    } catch (e) {
      debugPrint('Error checking entitlement: $e');
      return false;
    }
  }

  /// Get active subscription details
  Future<SubscriptionDetails?> getActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) return null;

      if (customerInfo.entitlements.active.isEmpty) return null;

      final activeEntitlement = customerInfo.entitlements.active.values.first;

      return SubscriptionDetails(
        productIdentifier: activeEntitlement.productIdentifier,
        isActive: activeEntitlement.isActive,
        willRenew: activeEntitlement.willRenew,
        periodType: activeEntitlement.periodType,
        expirationDate: activeEntitlement.expirationDate,
        originalPurchaseDate: activeEntitlement.originalPurchaseDate,
      );
    } catch (e) {
      debugPrint('Error getting active subscription: $e');
      return null;
    }
  }

  /// Listen to customer info updates
  Stream<CustomerInfo> get customerInfoStream {
    return Purchases.customerInfoStream;
  }

  /// Set custom attributes for the user
  Future<void> setUserAttributes(Map<String, String> attributes) async {
    try {
      for (final entry in attributes.entries) {
        await Purchases.setAttributes({entry.key: entry.value});
      }
      debugPrint('User attributes set');
    } catch (e) {
      debugPrint('Error setting user attributes: $e');
    }
  }
}

class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}

class RestoreResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  RestoreResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}

class SubscriptionDetails {
  final String productIdentifier;
  final bool isActive;
  final bool willRenew;
  final String periodType;
  final String? expirationDate;
  final String? originalPurchaseDate;

  SubscriptionDetails({
    required this.productIdentifier,
    required this.isActive,
    required this.willRenew,
    required this.periodType,
    this.expirationDate,
    this.originalPurchaseDate,
  });
}
