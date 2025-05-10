package com.my_org.flutter_godot_widget

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

internal class GodotViewFactory(
    private var flutterGodotPluginProvider: FlutterGodotPluginProvider
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    companion object {
        private const val TAG = "GodotViewFactory"
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.v(TAG, "create")
        return GodotView(context, flutterGodotPluginProvider, viewId)
    }
}
