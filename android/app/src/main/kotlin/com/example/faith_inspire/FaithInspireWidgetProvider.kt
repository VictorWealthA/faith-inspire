package com.example.faith_inspire

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class FaithInspireWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val title = widgetData.getString("faith_inspire_widget_title", "Today's Reflection")
            val text = widgetData.getString(
                "faith_inspire_widget_text",
                "Open Faith Inspire for a quote, affirmation, or scripture."
            )
            val itemId = widgetData.getString("faith_inspire_widget_item_id", null)
            val itemType = widgetData.getString("faith_inspire_widget_item_type", "quote")
            val footer = widgetData.getString(
                "faith_inspire_widget_footer",
                "Tap to open"
            )
            val reflectionUri = Uri.parse(
                "faithinspire://open?tab=${tabForType(itemType)}${itemId?.let { "&itemId=$it" } ?: ""}"
            )
            val favoritesUri = Uri.parse("faithinspire://open?tab=favorites")

            val views = RemoteViews(context.packageName, R.layout.faith_inspire_widget).apply {
                setTextViewText(R.id.widgetTitle, title)
                setTextViewText(R.id.widgetText, text)
                setTextViewText(R.id.widgetFooter, footer)
                setOnClickPendingIntent(
                    R.id.widgetRoot,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        reflectionUri
                    )
                )
                setOnClickPendingIntent(
                    R.id.widgetOpenToday,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        reflectionUri
                    )
                )
                setOnClickPendingIntent(
                    R.id.widgetOpenFavorites,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        favoritesUri
                    )
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun tabForType(type: String?): String {
        return when (type) {
            "affirmation" -> "affirmations"
            "scripture" -> "scriptures"
            else -> "quotes"
        }
    }
}