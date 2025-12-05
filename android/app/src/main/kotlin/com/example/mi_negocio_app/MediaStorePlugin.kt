package com.example.mi_negocio_app

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MediaStorePlugin {
    companion object {
        private const val CHANNEL = "com.example.mi_negocio_app/media_store"

        fun registerWith(flutterEngine: FlutterEngine, context: Context) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToMediaStore" -> {
                        try {
                            val fileName = call.argument<String>("fileName") ?: ""
                            val mimeType = call.argument<String>("mimeType") ?: "image/png"
                            val bytes = call.argument<ByteArray>("bytes") ?: ByteArray(0)
                            
                            val savedPath = saveToMediaStore(context, fileName, mimeType, bytes)
                            result.success(savedPath)
                        } catch (e: Exception) {
                            result.error("SAVE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }

        private fun saveToMediaStore(
            context: Context,
            fileName: String,
            mimeType: String,
            bytes: ByteArray
        ): String {
            val isPdf = mimeType.contains("pdf")
            
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // Android 10+
                    val relativePath = if (isPdf) {
                        Environment.DIRECTORY_DOCUMENTS + "/MiNegocio"
                    } else {
                        Environment.DIRECTORY_DCIM + "/MiNegocio"
                    }
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
            }

            val collection = if (isPdf) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                } else {
                    MediaStore.Files.getContentUri("external")
                }
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }

            val uri = context.contentResolver.insert(collection, contentValues)
                ?: throw Exception("Failed to create MediaStore entry")

            context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                outputStream.write(bytes)
                outputStream.flush()
            } ?: throw Exception("Failed to open output stream")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                context.contentResolver.update(uri, contentValues, null, null)
            }

            return uri.toString()
        }
    }
}