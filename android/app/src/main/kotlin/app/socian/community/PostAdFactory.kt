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

        // New fields:
        adView.priceView = adView.findViewById(R.id.ad_price)
        adView.storeView = adView.findViewById(R.id.ad_store)
        adView.starRatingView = adView.findViewById(R.id.ad_stars)

        // Bind required and optional fields
        (adView.headlineView as TextView).text = nativeAd.headline

        (adView.bodyView as? TextView)?.let {
            if (!nativeAd.body.isNullOrEmpty()) {
                it.text = nativeAd.body
                it.visibility = View.VISIBLE
            } else it.visibility = View.GONE
        }

        (adView.callToActionView as? TextView)?.let {
            if (!nativeAd.callToAction.isNullOrEmpty()) {
                it.text = nativeAd.callToAction
                it.visibility = View.VISIBLE
            } else it.visibility = View.GONE
        }

        (adView.advertiserView as? TextView)?.let {
            if (!nativeAd.advertiser.isNullOrEmpty()) {
                it.text = nativeAd.advertiser
                it.visibility = View.VISIBLE
            } else it.visibility = View.GONE
        }

        if (nativeAd.icon != null) {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView?.visibility = View.VISIBLE
        } else {
            adView.iconView?.visibility = View.GONE
        }

        // Price
        (adView.priceView as TextView).let {
            if (!nativeAd.price.isNullOrEmpty()) {
                it.text = nativeAd.price
                it.visibility = View.VISIBLE
            } else it.visibility = View.GONE
        }

        // Store
        (adView.storeView as TextView).let {
            if (!nativeAd.store.isNullOrEmpty()) {
                it.text = nativeAd.store
                it.visibility = View.VISIBLE
            } else it.visibility = View.GONE
        }

        // Star rating
        (adView.starRatingView as android.widget.RatingBar).let {
    val rating = nativeAd.starRating ?: 0.0
    if (rating > 0) {
        it.rating = rating.toFloat()
        it.visibility = View.VISIBLE
    } else {
        it.visibility = View.GONE
    }
}


        adView.mediaView?.setMediaContent(nativeAd.mediaContent)

        adView.setNativeAd(nativeAd)

        return adView
    }
}
