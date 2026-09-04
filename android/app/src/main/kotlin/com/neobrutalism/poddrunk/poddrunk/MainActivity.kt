package com.neobrutalism.poddrunk.poddrunk

import android.content.ContentUris
import android.content.ContentValues
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.Settings
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.neobrutalism.poddrunk/ringtone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkCanWriteSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.System.canWrite(this))
                    } else {
                        result.success(true)
                    }
                }
                "openWriteSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            // Fallback to generic settings if package URI fails
                            val intent = Intent(Settings.ACTION_MANAGE_WRITE_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "setRingtone" -> {
                    val filePath = call.argument<String>("filePath")
                    val trackId = call.argument<String>("trackId")
                    val typeStr = call.argument<String>("type") ?: "ringtone"

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.System.canWrite(this)) {
                        result.success("PERMISSION_NEEDED")
                        return@setMethodCallHandler
                    }

                    try {
                        val ringtoneType = when (typeStr) {
                            "notification" -> RingtoneManager.TYPE_NOTIFICATION
                            "alarm" -> RingtoneManager.TYPE_ALARM
                            else -> RingtoneManager.TYPE_RINGTONE
                        }

                        var contentUri: Uri? = null

                        // 1. Resolve via MediaStore trackId
                        if (!trackId.isNullOrEmpty()) {
                            val idLong = trackId.toLongOrNull()
                            if (idLong != null && idLong > 0) {
                                contentUri = ContentUris.withAppendedId(
                                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                    idLong
                                )
                            }
                        }

                        // 2. Resolve via filepath lookup if needed
                        if (contentUri == null && !filePath.isNullOrEmpty()) {
                            try {
                                val projection = arrayOf(MediaStore.Audio.Media._ID)
                                val cursor = contentResolver.query(
                                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                    projection,
                                    "${MediaStore.Audio.Media.DATA} = ?",
                                    arrayOf(filePath),
                                    null
                                )
                                cursor?.use {
                                    if (it.moveToFirst()) {
                                        val id = it.getLong(it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID))
                                        contentUri = ContentUris.withAppendedId(
                                            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                                            id
                                        )
                                    }
                                }
                            } catch (_: Exception) {}
                        }

                        // 3. Fallback: file URI if contentUri still null
                        if (contentUri == null && !filePath.isNullOrEmpty()) {
                            val file = File(filePath)
                            if (file.exists()) {
                                contentUri = Uri.fromFile(file)
                            }
                        }

                        val finalUri = contentUri
                        if (finalUri != null) {
                            // Update flag if permitted
                            try {
                                val values = ContentValues().apply {
                                    when (ringtoneType) {
                                        RingtoneManager.TYPE_NOTIFICATION -> put(MediaStore.Audio.Media.IS_NOTIFICATION, true)
                                        RingtoneManager.TYPE_ALARM -> put(MediaStore.Audio.Media.IS_ALARM, true)
                                        else -> put(MediaStore.Audio.Media.IS_RINGTONE, true)
                                    }
                                }
                                contentResolver.update(finalUri, values, null, null)
                            } catch (_: Exception) {}

                            RingtoneManager.setActualDefaultRingtoneUri(this, ringtoneType, finalUri)
                            result.success("SUCCESS")
                        } else {
                            result.error("NOT_FOUND", "Could not resolve audio file for ringtone", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

