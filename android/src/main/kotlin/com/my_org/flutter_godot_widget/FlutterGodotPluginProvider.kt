package com.my_org.flutter_godot_widget

import android.app.Activity
import android.content.Context
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import org.godotengine.godot.Godot

interface FlutterGodotPluginProvider {
    fun getLifecycle(): Lifecycle

    fun getActivity(): Activity

    fun getPluginBinding(): FlutterPlugin.FlutterPluginBinding

    fun getCommandLineParams(): ArrayList<String>

    fun getGodot(context: Context): Godot

    fun shouldRecreateGodot(context: Context): Boolean
}