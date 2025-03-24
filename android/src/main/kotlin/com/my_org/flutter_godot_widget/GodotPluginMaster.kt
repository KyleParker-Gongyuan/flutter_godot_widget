package com.my_org.flutter_godot_widget


import android.util.Log
import io.flutter.plugin.common.MethodChannel
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot
import org.godotengine.godot.variant.Callable


class godotpluginMaster(godot: Godot) : GodotPlugin(godot){
    init {
        Log.v(TAG, "init")
    }

    private val eventsHandler = GodotEventsHandler.instance
    private val eventSink get() = eventsHandler.eventSink

    companion object {
        private const val TAG = "godotpluginMaster"
        const val PLUGIN_NAME = "godotpluginMaster"
        val SHOW_STRANG = SignalInfo("get_stang", String::class.java)
    }

    override fun emitSignal(signalName: String?, vararg signalArgs: Any?) {
        println("emitting signal to godot $signalName")
        super.emitSignal(signalName, *signalArgs)
    }

    @UsedByGodot
    fun sendData(string: String) {
        Log.d(TAG, "sendData")
        // send to flutter
        runOnUiThread {
            eventsHandler.sendEvent(
                mapOf(
                    "type" to "takeString",
                    "data" to string
                )
            )
        }
    }

    @UsedByGodot
    fun goBack() {
        println("goBack called")
        runOnUiThread {
            eventSink?.success("close_view")  // Send a specific message to Flutter to close the view
        }
    }


    override fun getPluginName() = PLUGIN_NAME

    @UsedByGodot
    fun getApplicationContext() = activity?.applicationContext

    @UsedByGodot
    override fun getActivity() = super.getActivity()

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        return mutableSetOf(
            SHOW_STRANG
        )
    }

    private fun sendDataToFlutter(FA: String) {

    }


    fun bysend(data: String) {
        print("we should have the data!!!!")
        //?.success(data)
        print("should have send the data")
    }


    private var methodCall: MethodChannel.Result? = null


    /**
     * Example showing how to declare a method that's used by Godot.
     *
     * Shows a 'Hello World' toast.
     */


}


