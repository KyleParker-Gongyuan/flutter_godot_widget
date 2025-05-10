package com.my_org.flutter_godot_widget

import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.util.concurrent.atomic.AtomicBoolean

class GodotEventsHandler private constructor() : EventChannel.StreamHandler {
    companion object {
        private const val TAG = "GodotEventsHandler"

       @Volatile private var _instance: GodotEventsHandler? = null
        val instance: GodotEventsHandler
            get() {
                if (_instance == null) {
                    Log.d(TAG, "Creating new GodotEventsHandler instance")
                    _instance = GodotEventsHandler()
                }
                return _instance!!
            }
    }

    var eventSink : EventChannel.EventSink? = null
    private val isListening = AtomicBoolean(false)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen -> starting listening")

        if(events == null) {
            Log.e(TAG, "onListen -> EventSink is null, cannot setup event listening")
            return
        }

        eventSink = events

        if (isListening.getAndSet(true)) {
            Log.w(TAG, "Already listening for events, ignoring duplicate request")
            return
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel -> Stopping Godot event listening")

        if (isListening.getAndSet(false)) {
            eventSink = null
        }
    }


    fun sendEvent(event: Map<String, Any?>) {
        if (!isListening.get()) {
            Log.w(TAG, "Attempted to send event while not listening: $event")
            return
        }

        try {
            val sink = eventSink
            if (sink != null) {
                sink.success(event)
                Log.d(TAG, "Event sent to Flutter: ${event["type"]}")
            } else {
                Log.e(TAG, "EventSink is null, cannot send event")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send event to Flutter", e)
            eventSink?.error("GODOT_EVENT_ERROR", e.message, null)
        }
    }
}