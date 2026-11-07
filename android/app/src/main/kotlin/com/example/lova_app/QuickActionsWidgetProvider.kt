package com.zoli.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/// Widget d'accueil : quatre raccourcis de recherche, sans lancer l'USSD
/// directement. L'application s'ouvre avec la recherche préremplie, ce qui
/// laisse Android gérer le choix de la carte SIM.
class QuickActionsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            appWidgetManager.updateAppWidget(appWidgetId, buildViews(context))
        }
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_quick_actions)
        views.setOnClickPendingIntent(
            R.id.widget_solde,
            pendingIntent(context, "solde", 1),
        )
        views.setOnClickPendingIntent(
            R.id.widget_internet,
            pendingIntent(context, "internet", 2),
        )
        views.setOnClickPendingIntent(
            R.id.widget_transfert,
            pendingIntent(context, "transfert", 3),
        )
        views.setOnClickPendingIntent(
            R.id.widget_forfait,
            pendingIntent(context, "forfait", 4),
        )
        return views
    }

    private fun pendingIntent(context: Context, action: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            this.action = Intent.ACTION_VIEW
            putExtra(MainActivity.EXTRA_QUICK_ACTION, action)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
