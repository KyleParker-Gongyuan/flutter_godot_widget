package com.my_org.flutter_godot_widget

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.platform.PlatformView
import org.godotengine.godot.Godot
import org.godotengine.godot.GodotHost
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.utils.ProcessPhoenix

class GodotView(
    private val context: Context,
    private val pluginProvider: FlutterGodotPluginProvider,
    viewId: Int
) : PlatformView, GodotHost, DefaultLifecycleObserver {
    private val container: FrameLayout = FrameLayout(context).apply {
        id = viewId
    }

    init {
        if (pluginProvider.shouldRecreateGodot(context)) {
            Log.v(TAG, "Recreating Godot")
            onNewGodotInstanceRequested(emptyArray())
        } else {
            pluginProvider.getLifecycle().addObserver(this)
        }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        Log.v(TAG, "dispose")
        godot.destroyAndKillProcess()
    }

    companion object {
        private const val TAG = "GodotView"
        const val KEY_SHOW_GODOT_VIEW = "SHOW_GODOT_VIEW"
    }

    override fun getActivity(): Activity {
        return pluginProvider.getActivity()
    }

    override fun getGodot(): Godot {
        return pluginProvider.getGodot(context)
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)

        Log.v(TAG, "onCreate")
        godot.onCreate(this)

        if (godot.onInitNativeLayer(this)) {
            godot.onInitRenderView(this, container)
        }
    }

    override fun onStart(owner: LifecycleOwner) {
        super.onStart(owner)
        Log.v(TAG, "onStart")
        godot.onStart(this)
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        Log.v(TAG, "onResume")
        godot.onResume(this)
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        Log.v(TAG, "onPause")
        godot.onPause(this)
    }

    override fun onStop(owner: LifecycleOwner) {
        super.onStop(owner)
        Log.v(TAG, "onStop")
        godot.onStop(this)
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        Log.v(TAG, "onDestroy")
        godot.onDestroy(this)
    }

    override fun onNewGodotInstanceRequested(args: Array<String>): Int {
        Log.d(TAG, "Restarting with parameters ${args.contentToString()}")
        val intent = Intent()
            .setComponent(ComponentName(activity, activity.javaClass.name))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
            .putExtra(FlutterGodotWidgetPlugin.EXTRA_COMMAND_LINE_PARAMS, args)
            .putExtra(KEY_SHOW_GODOT_VIEW, true)

        triggerRebirth(null, intent)
        // fake 'process' id returned by create_instance() etc
        return FlutterGodotWidgetPlugin.DEFAULT_WINDOW_ID
    }

    private fun triggerRebirth(bundle: Bundle?, intent: Intent) {
        godot.destroyAndKillProcess()
        ProcessPhoenix.triggerRebirth(activity, bundle, intent)
    }

    override fun getHostPlugins(engine: Godot): MutableSet<GodotPlugin> {
        Log.v(TAG, "getHostPlugins")
        return mutableSetOf(godotpluginMaster(engine))
    }
}