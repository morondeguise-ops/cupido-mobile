# Google AdMob Setup Guide

This guide explains how to configure Google AdMob for the Cupido Flutter app.

## Prerequisites

1. Create a Google AdMob account at https://admob.google.com
2. Register your app in AdMob console for both Android and iOS
3. Create ad units for each placement (feed_banner, discover_banner, etc.)
4. Get your AdMob App IDs and Ad Unit IDs

## Android Configuration

### 1. Update AndroidManifest.xml

Add the AdMob App ID to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add this meta-data inside the application tag -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your actual AdMob App ID from the AdMob console.

### 2. Update build.gradle

No additional changes needed - the `google_mobile_ads` plugin handles Gradle configuration automatically.

## iOS Configuration

### 1. Update Info.plist

Add the AdMob App ID to `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your actual iOS AdMob App ID.

### 2. Update Info.plist for App Tracking Transparency

Add the user tracking description (required for iOS 14+):

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

### 3. Update Podfile (if needed)

The `google_mobile_ads` plugin should handle this automatically. If you encounter issues, ensure iOS deployment target is at least 12.0 in `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Admin Panel Configuration

1. Log in to the admin panel at `/admin`
2. Navigate to **Monetization > Ad Placements**
3. Edit each ad placement and replace the test ad unit IDs with your production IDs:
   - **feed_banner**: Your feed banner ad unit ID
   - **discover_banner**: Your discover banner ad unit ID

### Test Ad Unit IDs (Default)

The system comes with Google's test ad unit IDs pre-configured:
- **Android Banner**: `ca-app-pub-3940256099942544/6300978111`
- **iOS Banner**: `ca-app-pub-3940256099942544/2934735716`

These show test ads and are safe to use during development. Replace them with production IDs before releasing.

## Ad Placement Configuration

### Feed Banner
- **Placement Key**: `feed_banner`
- **Description**: Banner ads shown between posts in the feed
- **Frequency**: Default is 5 (shows ad every 5 posts)
- **Ad Type**: Banner

### Discover Banner
- **Placement Key**: `discover_banner`
- **Description**: Banner ad at the bottom of discover/swipe screen
- **Frequency**: 1 (always shown)
- **Ad Type**: Banner

## Premium Subscription (No Ads)

Users with active premium subscriptions will not see ads. This is handled automatically by the `AdService` which checks subscription status via the `SubscriptionService`.

## Testing

1. **Development Testing**: Use test ad unit IDs during development
2. **Real Ads Testing**:
   - Add your device as a test device in AdMob console
   - Replace test IDs with production IDs in admin panel
   - Enable test mode in the app

## Troubleshooting

### Ads Not Showing
1. Verify AdMob App IDs are correctly set in AndroidManifest.xml and Info.plist
2. Check that ad placements are enabled in admin panel
3. Ensure ad unit IDs are correct for the platform
4. Wait 1-2 hours after creating new ad units (AdMob propagation time)
5. Check device logs for AdMob errors

### AdMob App ID Format
- App ID: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` (with tilde ~)
- Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY` (with slash /)

### iOS Build Issues
- Run `cd ios && pod install` after adding the package
- Clean build folder: `flutter clean && flutter pub get`

## Additional Resources

- [Google AdMob Documentation](https://developers.google.com/admob)
- [Flutter google_mobile_ads Package](https://pub.dev/packages/google_mobile_ads)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)
