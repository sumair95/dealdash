import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final adServiceProvider = Provider<AdService>((ref) => AdService());

class AdService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  BannerAd? loadBannerAd({required bool isPremium}) {
    if (isPremium) return null;
    final adUnitId = defaultTargetPlatform == TargetPlatform.iOS
        ? dotenv.env['ADMOB_BANNER_ID_IOS']
        : dotenv.env['ADMOB_BANNER_ID_ANDROID'];
    if (adUnitId == null || adUnitId.isEmpty) return null;

    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    banner.load();
    return banner;
  }
}
