package app.socian.community

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class PostAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val inflater = LayoutInflater.from(context)
        val adView = inflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

        // Assign views
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.mediaView = adView.findViewById(R.id.ad_media)
        adView.iconView = adView.findViewById(R.id.ad_icon)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)

        // Bind data
        (adView.headlineView as TextView).text = nativeAd.headline
        (adView.bodyView as? TextView)?.text = nativeAd.body
        (adView.advertiserView as? TextView)?.text = nativeAd.advertiser

        if (nativeAd.icon != null) {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView?.visibility = View.VISIBLE
        } else {
            adView.iconView?.visibility = View.GONE
        }


        if (!nativeAd.callToAction.isNullOrEmpty()) {
    (adView.callToActionView as TextView).text = nativeAd.callToAction
    adView.callToActionView?.visibility = View.VISIBLE
} else {
    adView.callToActionView?.visibility = View.GONE
    // Log or debug: callToAction is missing!
    val ctaText = nativeAd.callToAction ?: "Learn More"
(adView.callToActionView as TextView).text = ctaText
adView.callToActionView?.visibility = View.VISIBLE

}


        if (nativeAd.callToAction != null) {
            (adView.callToActionView as TextView).text = nativeAd.callToAction
            adView.callToActionView?.visibility = View.VISIBLE
        } else {
            adView.callToActionView?.visibility = View.GONE
        }

        adView.mediaView?.setMediaContent(nativeAd.mediaContent)
        adView.setNativeAd(nativeAd)

        return adView
    }
}

// package app.socian.community

// import android.content.Context
// import android.view.LayoutInflater
// import android.view.View
// import com.google.android.gms.ads.nativead.NativeAd
// import com.google.android.gms.ads.nativead.NativeAdView
// import com.google.android.gms.ads.nativead.MediaView
// import android.widget.TextView
// import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

// class PostAdFactory(private val context: Context) : NativeAdFactory {
//     override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
//         val inflater = LayoutInflater.from(context)
//         val adView = inflater.inflate(R.layout.native_ad_layout, null) as NativeAdView

//         adView.headlineView = adView.findViewById(R.id.ad_headline)
//         adView.bodyView = adView.findViewById(R.id.ad_body)
//         adView.mediaView = adView.findViewById(R.id.ad_media)

//         (adView.headlineView as TextView).text = nativeAd.headline
//         (adView.bodyView as TextView).text = nativeAd.body
//         adView.mediaView?.setMediaContent(nativeAd.mediaContent)

//         adView.iconView = adView.findViewById(R.id.ad_icon)
// if (nativeAd.icon != null) {
//     (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
//     adView.iconView?.visibility = View.VISIBLE
// } else {
//     adView.iconView?.visibility = View.GONE
// }

//         adView.setNativeAd(nativeAd)
//         return adView
//     }
// }
