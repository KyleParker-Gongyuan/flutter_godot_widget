package com.my_org.flutter_godot_widget


import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot


public class godotpluginMaster(godot: Godot?) :  GodotPlugin(godot), EventChannel.StreamHandler{
    class GodotPluginMaster:PlatformViewFactory(StandardMessageCodec.INSTANCE) {

        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            val creationParams = args as Map<String?, Any?>?
            println("Context in GodotPluginMaster: $context")
            val activityContext = unwrapActivity(context)
            println("Unwrapped activity: $activityContext")

            return GodotStarter(activityContext, viewId, creationParams) //! FACTORY
        }

        private fun unwrapActivity(context: Context): FragmentActivity {
            var unwrappedContext = context
            while (unwrappedContext is ContextWrapper) {
                println("Unwrapping context: ${unwrappedContext.javaClass.name}, Base Context: ${unwrappedContext.baseContext?.javaClass?.name}")
                if (unwrappedContext is FragmentActivity) {
                    return unwrappedContext
                }
                unwrappedContext = unwrappedContext.baseContext
            }
            throw IllegalStateException("Context is not a FragmentActivity : ${context.javaClass.name}")
        }
    }
    private var faf: String = ""



    //public var eventSink: EventChannel.EventSink? = null
    


    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        Log.d("-------------->  ", "event channel on listen");
        eventSink = events

        
        //eventSink?.success("EXAMPLE DATA")
        

    }
    override fun onCancel(arguments: Any?) {
        Log.d("-------------->  ", "event channel on Cancel");
        eventSink = null

    }

    override fun emitSignal(signalName: String?, vararg signalArgs: Any?) {
        println("signal received on Java")
        super.emitSignal(signalName, *signalArgs)
    }

    @UsedByGodot
    public fun sendData(string:String) { // send to flutter
        faf = string

        println("OLD lord of Data: GPM " + faf)
        runOnUiThread({
            eventSink?.success(faf)
        })
        GoBack()


    }
    @UsedByGodot
    public fun GoBack() {
        println("goback called")
        runOnUiThread {
            eventSink?.success("close_view")  // Send a specific message to Flutter to close the view
        }
    }



    fun setEventSink(eventSinkl: EventChannel.EventSink?) {
        eventSink = eventSinkl

    }
    companion object {
        val SHOW_STRANG = SignalInfo("get_stang", String::class.java)
        var eventSink: EventChannel.EventSink? = null
    }

    override fun getPluginName(): String {
        return "godotpluginMaster"
    }

    override fun getPluginSignals() = setOf(SHOW_STRANG)

    internal fun send2Godot(theString: String) {
        print("pre send to godot")
        emitSignal(
            SHOW_STRANG.name,
            theString
        ) // this send out a signal to get the string for x y Z
        //eventSink!!.success("we cook")
        eventSink?.success("we cook")

    }



    private fun sendDataToFlutter(FA: String) {

    }




    fun bysend(data: String) {
        print("we should have the data!!!!")
        //?.success(data)
        print("should have send the data")
    }


    private var methodCall: MethodChannel.Result? = null;




    /**
     * Example showing how to declare a method that's used by Godot.
     *
     * Shows a 'Hello World' toast.
     */

    // Function to send event via EventChannel
    @UsedByGodot
    private fun helloWorld() {
        // Call this function to send an event via EventChannel
        print("we got 2 helloworld")
        sendData2Flut("helloWorldEvent", "Hello from Godot!")
    }

    private fun sendData2Flut(eventName: String, eventData: Any) {
        Log.w("FUCKY", "SEND HELP")
       // GodotHandler.ourevent()// eventSink?.success("AHHh")


    }

    @UsedByGodot
    private fun otherworld() {
        print("godot gave us ")
        sendData2Flut("sup", "FUCK ME")
    }






}


