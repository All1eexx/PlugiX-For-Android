package com.all1eexxx

import android.content.Context
import android.util.Log
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.*

class KotlinCoroutinesPlugin private constructor(private val context: Context) {
    companion object {
        private const val TAG = "CoroutinesPlugin"
        
        @JvmStatic
        fun OnPluginCreate(ctx: Context) {
            val plugin = KotlinCoroutinesPlugin(ctx)
            plugin.startAllFeatures()
        }
    }

    private val scope = CoroutineScope(Dispatchers.Default + CoroutineName("PluginScope"))
    private val eventChannel = Channel<String>(Channel.UNLIMITED)
    private val stateFlow = MutableStateFlow("Initial state")

    fun startAllFeatures() {
        startBasicCoroutine()
        
        startChannelCommunication()
        
        startFlowCollection()
        
        startParallelOperations()
        
        demonstrateDispatchers()
        
        startErrorHandlingExample()
    }

    private fun startBasicCoroutine() {
        scope.launch {
            repeat(5) { i ->
                delay(1000)
                val message = "Basic coroutine iteration $i"
                Log.d(TAG, message)
                eventChannel.send(message)
                stateFlow.value = message
            }
        }
    }

    private fun startChannelCommunication() {
        scope.launch {
            repeat(10) { i ->
                delay(800)
                val msg = "Channel message $i"
                eventChannel.send(msg)
                Log.d(TAG, "Sent: $msg")
            }
            eventChannel.close()
        }
        
        repeat(3) { consumerId ->
            scope.launch {
                for (msg in eventChannel) {
                    Log.d(TAG, "Consumer $consumerId received: $msg")
                    delay(200)
                }
            }
        }
    }

    private fun startFlowCollection() {
        val countFlow = flow {
            repeat(10) { i ->
                delay(1200)
                emit(i)
            }
        }
        
        scope.launch {
            countFlow
                .filter { it % 2 == 0 }
                .map { "Even number: $it" }
                .collect { value ->
                    Log.d(TAG, "Flow collected: $value")
                    stateFlow.value = value
                }
        }
    }

    private fun startParallelOperations() {
        scope.launch {
            val results = listOf(
                async { fetchDataFromNetwork("Data1", 1000) },
                async { fetchDataFromNetwork("Data2", 1500) },
                async { fetchDataFromNetwork("Data3", 800) }
            )
            
            val combined = results.awaitAll().joinToString()
            Log.d(TAG, "Parallel results: $combined")
            stateFlow.value = "Parallel ops completed: $combined"
        }
    }

    private suspend fun fetchDataFromNetwork(name: String, delay: Long): String {
        delay(delay)
        return "$name-response"
    }

    private fun demonstrateDispatchers() {
        scope.launch {
            Log.d(TAG, "Default dispatcher: ${Thread.currentThread().name}")
            
            withContext(Dispatchers.IO) {
                Log.d(TAG, "IO dispatcher: ${Thread.currentThread().name}")
                delay(500)
            }
            
            withContext(Dispatchers.Main.immediate) {
                Log.d(TAG, "Main dispatcher (would be UI thread in Android)")
            }
        }
    }

    private fun startErrorHandlingExample() {
        scope.launch {
            try {
                riskyOperation()
            } catch (e: Exception) {
                Log.e(TAG, "Caught exception: ${e.message}")
                stateFlow.value = "Error occurred: ${e.message}"
            }
        }
        
        scope.launch {
            supervisorScope {
                launch {
                    delay(300)
                    throw RuntimeException("Simulated error in child coroutine")
                }
                
                launch {
                    repeat(5) { i ->
                        delay(500)
                        Log.d(TAG, "Child coroutine unaffected by error: $i")
                    }
                }
            }
        }
    }

    private suspend fun riskyOperation() {
        delay(2000)
        if (System.currentTimeMillis() % 2 == 0L) {
            throw IllegalStateException("Random failure in risky operation")
        }
        Log.d(TAG, "Risky operation succeeded")
    }
}