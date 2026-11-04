package dev.xzero.xzifra

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders the Xzifra home-screen widget from the values written by
 * [dev.xzero.xzifra.WidgetDataSync].
 */
class XzifraWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val month = widgetData.getString(KEY_MONTH, null)
    val amount = widgetData.getString(KEY_AMOUNT, null)
    val emptyMessage =
        widgetData.getString(KEY_EMPTY_MESSAGE, null)
            ?: context.getString(R.string.xzifra_widget_empty)
    val nextUp = widgetData.getString(KEY_NEXT_UP, null)
    val hasData = !month.isNullOrBlank() && amount != null
    val hasNextUp = !nextUp.isNullOrBlank()

    appWidgetIds.forEach { widgetId ->
      val views =
          RemoteViews(context.packageName, R.layout.xzifra_widget).apply {
            // Opening the app normally: tapping anywhere except the "+" button.
            setOnClickPendingIntent(
                R.id.widget_container,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("xzifra://open"),
                ),
            )
            // Opening the new-expense form directly.
            setOnClickPendingIntent(
                R.id.widget_add,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("xzifra://add"),
                ),
            )
            setContentDescription(
                R.id.widget_add,
                context.getString(R.string.xzifra_widget_add),
            )

            setViewVisibility(
                R.id.widget_month,
                if (hasData) View.VISIBLE else View.GONE,
            )
            setViewVisibility(
                R.id.widget_amount,
                if (hasData) View.VISIBLE else View.GONE,
            )
            setViewVisibility(
                R.id.widget_empty,
                if (hasData) View.GONE else View.VISIBLE,
            )
            setViewVisibility(
                R.id.widget_next_up,
                if (hasNextUp) View.VISIBLE else View.GONE,
            )

            if (hasData) {
              setTextViewText(R.id.widget_month, month)
              setTextViewText(R.id.widget_amount, amount)
            } else {
              setTextViewText(R.id.widget_empty, emptyMessage)
            }
            if (hasNextUp) {
              setTextViewText(R.id.widget_next_up, nextUp)
            }
          }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  companion object {
    const val KEY_MONTH = "xzifra_widget_month"
    const val KEY_AMOUNT = "xzifra_widget_amount"
    const val KEY_EMPTY_MESSAGE = "xzifra_widget_empty"
    const val KEY_NEXT_UP = "xzifra_widget_next_up"
  }
}
