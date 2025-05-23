
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class NativeAdPostWidget extends StatefulWidget {
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdClosed;

  NativeAdPostWidget({this.onAdLoaded, this.onAdClosed});

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
          setState(() {
            _isAdLoaded = true;
          });
          if (widget.onAdLoaded != null) widget.onAdLoaded!();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('NativeAd failed to load: $error');
          if (widget.onAdClosed != null) widget.onAdClosed!();
        },
        onAdClosed: (ad) {
          if (widget.onAdClosed != null) widget.onAdClosed!();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    if (widget.onAdClosed != null) widget.onAdClosed!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(height: 350, child: AdWidget(ad: _nativeAd!))
        : SizedBox.shrink();
  }
}
