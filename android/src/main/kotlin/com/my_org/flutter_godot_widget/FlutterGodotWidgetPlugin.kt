package com.my_org.flutter_godot_widget

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.util.Log
import android.util.TypedValue
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin


/** FlutterGodotWidgetPlugin */
class FlutterGodotWidgetPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    companion object {
        private const val TAG = "FlutterGodotWidgetPlugin"
        const val EXTRA_COMMAND_LINE_PARAMS = "command_line_params"

        // This window must not match those in BaseGodotEditor.RUN_GAME_INFO etc
        const val DEFAULT_WINDOW_ID = 664
    }

    private var lifecycle: Lifecycle? = null
    private var flutterPluginBinding: FlutterPluginBinding? = null
    private var activity: Activity? = null
    private lateinit var channel: MethodChannel
    private val networkEventChannel = "kaiyo.ezgodot/generic"

    private var mGodot: Godot? = null
    private var initializationContext: Context? = null

    private fun initializeGodot(context: Context) {
            Log.v(TAG, "Initializing Godot")
            initializationContext = context
            mGodot = Godot(context)
    }

    private fun getGodot(context: Context): Godot {
        if (mGodot == null) {
            initializeGodot(context)
        }
        return mGodot!!
    }

    private val commandLineParams = ArrayList<String>()

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        flutterPluginBinding = binding

        EventChannel(binding.binaryMessenger, networkEventChannel).setStreamHandler(
            GodotEventsHandler.instance
        )

        binding.platformViewRegistry.registerViewFactory(
            "godot-view",
            GodotViewFactory(object : FlutterGodotPluginProvider {
                override fun getLifecycle(): Lifecycle {
                    return lifecycle!!
                }

                override fun getActivity(): Activity {
                    return activity!!
                }

                override fun getPluginBinding(): FlutterPluginBinding {
                    return flutterPluginBinding!!
                }

                override fun getCommandLineParams(): ArrayList<String> {
                    return commandLineParams
                }

                override fun getGodot(context: Context): Godot {
                    return this@FlutterGodotWidgetPlugin.getGodot(context)
                }

                override fun shouldRecreateGodot(context: Context): Boolean {
                    return mGodot != null && initializationContext != context
                }
            })
        )

        channel = MethodChannel(binding.binaryMessenger, "flutter_godot_widget_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        flutterPluginBinding = null
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d(TAG, "onMethodCall ${call.method}")
        when (call.method) {
            "sendData2Godot" -> {
                val data = call.argument<String>("data")
                println("Arguments: ${call.arguments}")
                data?.let {
                    Log.d(
                        TAG,
                        "Received data from flutter... passing to godot"
                    )
                    val godot = mGodot
                    if(godot != null) {
                        GodotPlugin.emitSignal(godot, godotpluginMaster.PLUGIN_NAME, godotpluginMaster.SHOW_STRANG, it)
                    }
                    result.success("Data sent to Godot: $data")
                } ?: run {
                    Log.e(TAG, "MISSING_DATA")
                    result.error("MISSING_DATA", "Data argument is missing", null)
                }
            }

            "getIntentData" -> {
                val intent = activity!!.intent
                val bundle = intent.extras
                val data = bundle?.let {
                    mapOf("showGodotView" to it.getBoolean(GodotView.KEY_SHOW_GODOT_VIEW, false))
                } ?: emptyMap<String, Any?>()
                result.success(data)
            }

            else -> {
                result.notImplemented()
            }
        }
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        handleActivityChange(binding.activity)
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)

        val params = binding.activity.intent.getStringArrayExtra(EXTRA_COMMAND_LINE_PARAMS)
        commandLineParams.addAll(params ?: emptyArray())
        if (params != null) {
            Log.d(TAG, "Command line params: ${params.joinToString(", ")}")
        } else {
            Log.d(TAG, "No command line params")
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        handleActivityChange(null)
        lifecycle = null
    }

    private fun handleActivityChange(newActivity: Activity?) {
        Log.d(TAG, "handleActivityChange")
        activity = newActivity
    }
}
