import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdPostWidget extends StatefulWidget {
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdClosed;

  const NativeAdPostWidget({Key? key, this.onAdLoaded, this.onAdClosed}) : super(key: key);

  @override
  State<NativeAdPostWidget> createState() => _NativeAdPostWidgetState();
}

class _NativeAdPostWidgetState extends State<NativeAdPostWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _nativeAd = NativeAd(
      adUnitId: dotenv.env['NATIVE_AD_MOB'] ?? '',
      factoryId: 'postAdFactory',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
          widget.onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('NativeAd failed to load: $error');
          widget.onAdClosed?.call();
        },
        onAdClosed: (ad) {
          widget.onAdClosed?.call();
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    widget.onAdClosed?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 350,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
