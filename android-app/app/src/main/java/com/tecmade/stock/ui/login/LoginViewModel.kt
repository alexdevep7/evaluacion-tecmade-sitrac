package com.tecmade.stock.ui.login

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tecmade.stock.data.TokenManager
import com.tecmade.stock.data.repository.StockRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class LoginUiState(
    val isLoading: Boolean = false,
    val isSuccess: Boolean = false,
    val error: String? = null
)

class LoginViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = StockRepository()
    private val tokenManager = TokenManager(application.applicationContext)

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    companion object {
        private const val TAG = "LoginViewModel"
    }

    fun login(email: String, password: String) {
        viewModelScope.launch {
            Log.d(TAG, "Iniciando login con email: $email")
            _uiState.value = LoginUiState(isLoading = true)

            try {
                Log.d(TAG, "Llamando a repository.login()")
                val response = repository.login(email, password)

                Log.d(TAG, "Respuesta recibida. Code: ${response.code()}, isSuccessful: ${response.isSuccessful}")

                if (response.isSuccessful && response.body() != null) {
                    val loginResponse = response.body()!!
                    Log.d(TAG, "Login exitoso. Token: ${loginResponse.token.take(10)}...")
                    tokenManager.saveToken(loginResponse.token)
                    _uiState.value = LoginUiState(isSuccess = true)
                } else {
                    val errorBody = response.errorBody()?.string()
                    Log.e(TAG, "Login fallido. Code: ${response.code()}, Error: $errorBody")
                    _uiState.value = LoginUiState(
                        error = "Credenciales inválidas (código ${response.code()})"
                    )
                }
            } catch (e: java.net.ConnectException) {
                Log.e(TAG, "ConnectException: ${e.message}", e)
                _uiState.value = LoginUiState(
                    error = "No se puede conectar al servidor. Verifica que el backend esté corriendo."
                )
            } catch (e: java.net.SocketTimeoutException) {
                Log.e(TAG, "SocketTimeoutException: ${e.message}", e)
                _uiState.value = LoginUiState(
                    error = "Tiempo de espera agotado. El servidor no responde."
                )
            } catch (e: java.net.UnknownHostException) {
                Log.e(TAG, "UnknownHostException: ${e.message}", e)
                _uiState.value = LoginUiState(
                    error = "No se puede encontrar el servidor. Verifica la URL."
                )
            } catch (e: Exception) {
                Log.e(TAG, "Exception: ${e.message}", e)
                _uiState.value = LoginUiState(
                    error = "Error de conexión: ${e.localizedMessage ?: "Error desconocido"}"
                )
            }
        }
    }
}