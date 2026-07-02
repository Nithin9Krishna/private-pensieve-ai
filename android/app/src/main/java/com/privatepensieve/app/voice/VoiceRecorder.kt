package com.privatepensieve.app.voice

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.content.ContextCompat
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.util.UUID

/**
 * On-device audio recorder using AudioRecord API.
 * Records to WAV format for maximum STT compatibility.
 * No network. No cloud upload. File stays on device.
 */
class VoiceRecorder(private val context: Context) {

    private var audioRecord: AudioRecord? = null
    private var recordingJob: Job? = null
    private var outputFile: File? = null

    var isRecording: Boolean = false
        private set

    companion object {
        private const val SAMPLE_RATE = 16000
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
    }

    /**
     * Start recording audio to a local WAV file.
     * Returns the file path where recording will be saved.
     */
    fun startRecording(): String {
        val bufferSize = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT)

        if (!hasPermission()) throw SecurityException("RECORD_AUDIO permission not granted")

        val file = File(context.cacheDir, "pensieve_recording_${UUID.randomUUID()}.wav")
        outputFile = file

        @Suppress("MissingPermission")
        val recorder = AudioRecord(
            MediaRecorder.AudioSource.MIC,
            SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT, bufferSize
        )

        audioRecord = recorder
        recorder.startRecording()
        isRecording = true

        // Write PCM data in background
        recordingJob = CoroutineScope(Dispatchers.IO).launch {
            val fos = FileOutputStream(file)
            val buffer = ByteArray(bufferSize)

            // Write WAV header placeholder (44 bytes)
            fos.write(ByteArray(44))

            var totalBytes = 0L
            while (isActive && isRecording) {
                val read = recorder.read(buffer, 0, buffer.size)
                if (read > 0) {
                    fos.write(buffer, 0, read)
                    totalBytes += read
                }
            }

            fos.close()

            // Write actual WAV header
            writeWavHeader(file, totalBytes)
        }

        return file.absolutePath
    }

    /**
     * Stop recording and return the output file path.
     */
    fun stopRecording(): String? {
        isRecording = false
        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null
        runBlocking { recordingJob?.join() }
        recordingJob = null
        return outputFile?.absolutePath
    }

    /**
     * Delete the recording file from disk.
     */
    fun deleteRecording() {
        outputFile?.delete()
        outputFile = null
    }

    fun hasPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context, Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun writeWavHeader(file: File, dataSize: Long) {
        val raf = RandomAccessFile(file, "rw")
        val channels = 1
        val bitsPerSample = 16
        val byteRate = SAMPLE_RATE * channels * bitsPerSample / 8

        raf.seek(0)
        raf.writeBytes("RIFF")
        raf.writeInt(Integer.reverseBytes((36 + dataSize).toInt()))
        raf.writeBytes("WAVE")
        raf.writeBytes("fmt ")
        raf.writeInt(Integer.reverseBytes(16))  // Subchunk1Size
        raf.writeShort(Integer.reverseBytes(1 shl 16).ushr(16))  // PCM
        raf.writeShort(Integer.reverseBytes(channels shl 16).ushr(16))
        raf.writeInt(Integer.reverseBytes(SAMPLE_RATE))
        raf.writeInt(Integer.reverseBytes(byteRate))
        raf.writeShort(Integer.reverseBytes((channels * bitsPerSample / 8) shl 16).ushr(16))
        raf.writeShort(Integer.reverseBytes(bitsPerSample shl 16).ushr(16))
        raf.writeBytes("data")
        raf.writeInt(Integer.reverseBytes(dataSize.toInt()))
        raf.close()
    }
}
