package ec.com.sidesoft.workorders

import android.os.Bundle
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var locationCallback: LocationCallback? = null

    // Notification channel ID for Android 8.0 (Oreo) and above
    private val channelId = "ec.com.sidesoft.workorders.notification_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        // Create Notification Channel for Android 8.0 and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Background Location Updates",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for background location updates."
            }

            val notificationManager: NotificationManager =
                getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }

        // Set up the method channel
        MethodChannel(flutterEngine!!.dartExecutor, "ec.com.sidesoft.workorders/methods")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "set_android_notification" -> {
                        val title = call.argument<String>("title")
                        val message = call.argument<String>("message")
                        val icon = call.argument<String>("icon")
                        setAndroidNotification(title, message, icon)
                        result.success(null)
                    }
                    "start_location_service" -> {
                        val distanceFilter = call.argument<Double>("distance_filter") ?: 0.0
                        val forceLocationManager = call.argument<Boolean>("force_location_manager") ?: false
                        startLocationService(distanceFilter, forceLocationManager)
                        result.success(null)
                    }
                    "stop_location_service" -> {
                        stopLocationService()
                        result.success(null)
                    }
                    "set_configuration" -> {
                        val interval = call.argument<String>("interval")?.toIntOrNull() ?: 1000
                        setLocationUpdateInterval(interval)
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    // Method to set the Android notification
    private fun setAndroidNotification(title: String?, message: String?, icon: String?) {
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setContentTitle(title ?: "Background Service")
            .setContentText(message ?: "Service is running")
            .setSmallIcon(android.R.drawable.ic_notification_overlay) // Default icon or use your own icon
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(1, notificationBuilder.build())
    }

    // Method to start the location service
    private fun startLocationService(distanceFilter: Double, forceLocationManager: Boolean) {
        val locationRequest = LocationRequest.create().apply {
            interval = 1000 // Default interval in milliseconds
            fastestInterval = 500 // Fastest interval in milliseconds
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            smallestDisplacement = distanceFilter.toFloat()
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: com.google.android.gms.location.LocationResult) {
                super.onLocationResult(result)
                val location = result.lastLocation

                location?.let {
                    sendLocationToFlutter(it)
                }
            }
        }
        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback!!, null)
    }

    // Method to stop the location service
    private fun stopLocationService() {
        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
        }
    }

    // Method to set location update interval
    private fun setLocationUpdateInterval(interval: Int) {
        val locationRequest = LocationRequest.create().apply {
            this.interval = interval.toLong() // Set the new interval
            this.fastestInterval = (interval / 2).toLong() // Optional: fastest interval
            this.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        locationCallback?.let {
            fusedLocationClient.removeLocationUpdates(it)
            fusedLocationClient.requestLocationUpdates(locationRequest, it, null)
        }
    }

    // Send location back to Flutter side
    private fun sendLocationToFlutter(location: android.location.Location) {
        val locationMap = mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy,
            "altitude" to location.altitude,
            "speed" to location.speed
        )

        MethodChannel(flutterEngine!!.dartExecutor, "ec.com.sidesoft.workorders/methods")
            .invokeMethod("location", locationMap)
    }
}
