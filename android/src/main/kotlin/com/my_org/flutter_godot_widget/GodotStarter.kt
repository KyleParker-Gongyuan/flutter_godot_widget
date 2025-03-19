package com.my_org.flutter_godot_widget

import android.R.integer
import android.app.ActionBar
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

    private var width: Int? = null;
    private var height: Int? = null;
    private var x: Float? = null;
    private var y: Float? = null;


    init {
        println("init called in godotstarter")
        width = (creationParams?.get("width") as? Double)?.toInt()
        height = (creationParams?.get("height") as? Double)?.toInt()
        x = (creationParams?.get("x") as? Number)?.toFloat()
        y = (creationParams?.get("y") as? Number)?.toFloat()
        initializegodot()
    }

    private fun initializegodot() {
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

    override fun getView(): View {
        Log.d("GodotStarter", "getView called")

        return if (godotFragment.view != null) {
            Log.d("GodotStarter", "Returning existing view")
            val parent = fragmentActivity.findViewById<FrameLayout>(android.R.id.content)
            godotFragment.view?.let { existingView ->
                if (existingView.parent != null) {
                    (existingView.parent as? ViewGroup)?.removeView(existingView)
                }
                if (existingView.parent == null) {
                    (parent as? ViewGroup)?.addView(godotFragment.view)
                }

                Log.d("GodotStarter", "Width: ${(width ?: -1)}, Height: ${(height ?: -1)}")

                existingView.layoutParams = FrameLayout.LayoutParams(
                    width ?: FrameLayout.LayoutParams.MATCH_PARENT, // Set the desired width
                    height ?: FrameLayout.LayoutParams.MATCH_PARENT  // Set the desired height
                )

                if (x != null)
                {
                    existingView.x = (x ?: 0) as Float
                }

                if (y != null)
                {
                    existingView.y = (y ?: 0) as Float
                }

                FlutterGodotWidgetPlugin.godotView = existingView

            }

            Log.d("GodotStarter", "View created and added to the parent")
            godotFragment.requireView()
        } else {
            Log.d("GodotStarter", "Returning placeholder view, waiting for actual view to be ready")
            View(fragmentActivity).also { placeholder ->
                viewReadyCallback = { actualView ->
                    if (placeholder.parent != null) {
                        (placeholder.parent as? ViewGroup)?.removeView(placeholder)
                    }
                    if (actualView.parent == null) {
                        (placeholder.parent as? ViewGroup)?.addView(actualView)
                    }
                    actualView.layoutParams = FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT, // Set the desired width
                        FrameLayout.LayoutParams.MATCH_PARENT  // Set the desired height
                    )
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
                    GodotpluginMaster(godot).send2Godot(data)
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