package com.my_org.flutter_godot_widget

import android.app.Activity


import android.os.Bundle
import android.os.Handler
import android.os.Looper

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.dart.DartExecutor

/*import com.my_org.flutter_godot_widget_example.MainActivity*/

import org.godotengine.godot.Godot
import org.godotengine.godot.GodotFragment
import org.godotengine.godot.GodotHost
import org.godotengine.godot.plugin.GodotPlugin


import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import android.widget.TextView
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import io.flutter.plugin.platform.PlatformView
import android.content.ContextWrapper
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

import androidx.fragment.app.FragmentManager.FragmentLifecycleCallbacks
import androidx.fragment.app.Fragment
import android.util.Log
import android.view.ViewGroup

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.view.LayoutInflater;
import androidx.fragment.app.FragmentTransaction
import io.flutter.embedding.android.FlutterFragmentActivity
import org.godotengine.godot.plugin.GodotPlugin.emitSignal
import org.godotengine.godot.plugin.SignalInfo


/**
 * Implements the [GodotHost] interface so it can access functionality from the [Godot] instance.
 */


class GodotStarter(context: Context, id: Int, creationParams: Map<String?, Any?>?) : GodotHost, PlatformView {


    private var godotFragment: GodotFragment = GodotFragment()
    private val fragmentActivity: FragmentActivity = context as? FragmentActivity
            ?: throw IllegalStateException("Context must be an instance of FragmentActivity")

    private var viewReadyCallback: ((View) -> Unit)? = null

    private var godotView: View? = null


    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private var appPlugin: godotpluginMaster? = null

    private var methodChannel: MethodChannel? = null
    private lateinit var flutterEngine: FlutterEngine


    init {
        println("init called in godotstarter")
        initializegodot()
    }



    private fun initializegodot(){
        
        println("Initializinggodot")

        val fragmentManager: FragmentManager = fragmentActivity.supportFragmentManager

        fragmentManager.registerFragmentLifecycleCallbacks(object : FragmentLifecycleCallbacks() {
            override fun onFragmentViewCreated(fm: FragmentManager, f: Fragment, v: View, savedInstanceState: Bundle?) {
                super.onFragmentViewCreated(fm, f, v, savedInstanceState)
                println("onFragmentViewCreated $f")
                if (f === godotFragment) {
                    // The view is now created
                    fragmentManager.unregisterFragmentLifecycleCallbacks(this)
                    notifyFlutterViewReady()
                    viewReadyCallback?.invoke(v)
                    println("onfragmentviewcreated : fragment view is ready")

                }
            }
        }, false)

        /*val transaction = fragmentManager.beginTransaction()
        println("godotfragment in initializegodot: $godotFragment")
        //val parent = fragmentActivity.findViewById<FrameLayout>(android.R.id.content)
       // transaction.replace(R.id.content,godotFragment, "GodotFragment")
        if(fragmentManager.fragments.indexOf(godotFragment)==-1) {
            transaction.replace(android.R.id.content,godotFragment, "GodotFragment")
            transaction.commitNowAllowingStateLoss()
            getHostPlugins(godot)
        }else{
            transaction.replace(android.R.id.content,godotFragment, "GodotFragment")
            transaction.commitNowAllowingStateLoss()
        }
*/
        // Check if the Godot fragment exists
        val fragmentTransaction: FragmentTransaction = fragmentManager.beginTransaction()
        val godotFragmentOld = fragmentManager.findFragmentByTag("GodotFragment") as? GodotFragment

        if (godotFragmentOld == null) {
            godotFragment = GodotFragment()
            fragmentTransaction.add(android.R.id.content, godotFragment, "GodotFragment")
            fragmentTransaction.commitNowAllowingStateLoss()
            getHostPlugins(godot)
        }else{
            godotFragment = godotFragmentOld
        }
    }

    override fun getActivity(): FragmentActivity {
        return fragmentActivity
    }




    private fun notifyFlutterViewReady() {
        godotFragment.view?.viewTreeObserver?.addOnGlobalLayoutListener(
                object : ViewTreeObserver.OnGlobalLayoutListener {
                    override fun onGlobalLayout() {
                        godotFragment.view?.viewTreeObserver?.removeOnGlobalLayoutListener(this)
                        println("Fragment view is ready")
                    }
                })
    }

    override fun getGodot(): Godot {
        Log.d("GodotStarter", "getGodot: godot=$godotFragment.godot, view=$godotFragment.view")
        return godotFragment.godot ?: throw IllegalStateException("Godot instance is not initialized")
    }

    override fun getView(): View { //! NATIVE

       

        Log.d("GodotStarter", "getView called")

       return if (godotFragment.view != null) {
            Log.d("GodotStarter", "Returning existing view")
            //val parent = fragmentActivity.supportFragmentManager.findFragmentById(R.id.godot_fragment_container)?.view
           val parent = fragmentActivity.findViewById<FrameLayout>(android.R.id.content)
           godotFragment.view?.let { existingView ->
                 existingView.parent?.let { parent ->
                     // Remove the view from its current parent if it already has one
                     (parent as? ViewGroup)?.removeView(existingView)
                     //(parent as? ViewGroup)?.removeAllViews()
                     Log.d("$existingView", "removed")
                 }
               (parent as? ViewGroup)?.addView(godotFragment.view)
             }

            Log.d("GodotStarter", "Red view created and added to the parent")
            godotFragment.view!!
        } else {
            Log.d("GodotStarter", "Returning placeholder view, waiting for actual view to be ready")
            // Temporarily return an empty view and use a callback to notify when the actual view is ready
            View(fragmentActivity).also { placeholder ->
                viewReadyCallback = { actualView ->
                    (placeholder.parent as? ViewGroup)?.removeView(placeholder)
                    (placeholder.parent as? ViewGroup)?.addView(actualView)
                    Log.d("GodotStarter", "Actual view is now added to the parent view group")
                }
            }
        }


    }
    private fun initAppPluginIfNeeded(godot: Godot) {
        if (appPlugin == null) {
            appPlugin = godotpluginMaster(godot)
            //appPlugin?.setEventSink(godotpluginMaster)
        }
        else{println("we got plugin")}
    }

    lateinit var handler: Handler

    override fun getHostPlugins(godot: Godot): Set<GodotPlugin> {
        super.getHostPlugins(godot)
        Log.d("GodotStarter", "getHostPlugins called")
        initAppPluginIfNeeded(godot)

        return setOf(appPlugin!!)
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendData2Godot" ->{
                val data = call.argument<String>("data")
                println("Arguments: ${call.arguments}")
                data?.let {
                    /*GodotpluginMaster.send2Godot(data)*/
                    result.success("Data sent to Godot: $data")
                } ?: run {
                    result.error("MISSING_DATA", "Data argument is missing", null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun dispose() {}
}