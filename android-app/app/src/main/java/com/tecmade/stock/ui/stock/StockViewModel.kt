package com.tecmade.stock.ui.stock

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.tecmade.stock.data.TokenManager
import com.tecmade.stock.data.model.StockItem
import com.tecmade.stock.data.repository.StockRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.net.ConnectException
import java.net.SocketTimeoutException
import java.net.UnknownHostException

data class StockUiState(
    val isLoading: Boolean = false,
    val stockItems: List<StockItem> = emptyList(),
    val error: String? = null,
    val isTokenInvalid: Boolean = false
)

class StockViewModel(application: Application) : AndroidViewModel(application) {

    private val repository = StockRepository()
    private val tokenManager = TokenManager(application.applicationContext)

    private val _uiState = MutableStateFlow(StockUiState())
    val uiState: StateFlow<StockUiState> = _uiState.asStateFlow()

    init {
        loadStock()
    }

    fun loadStock() {
        viewModelScope.launch {
            _uiState.value = StockUiState(isLoading = true)

            try {
                val token = tokenManager.getToken().first()

                if (token.isNullOrEmpty()) {
                    _uiState.value = StockUiState(isTokenInvalid = true)
                    return@launch
                }

                val response = repository.getStock(token)

                if (response.isSuccessful && response.body() != null) {
                    _uiState.value = StockUiState(
                        stockItems = response.body()!!.sortedBy { it.idstock }
                    )
                } else if (response.code() == 401) {
                    tokenManager.clearToken()
                    _uiState.value = StockUiState(isTokenInvalid = true)
                } else {
                    _uiState.value = StockUiState(
                        error = "Error al cargar stock (código ${response.code()})"
                    )
                }
            } catch (_: ConnectException) {
                _uiState.value = StockUiState(
                    error = "No se puede conectar al servidor. Verifica que el backend esté corriendo."
                )
            } catch (_: SocketTimeoutException) {
                _uiState.value = StockUiState(
                    error = "Tiempo de espera agotado. El servidor no responde."
                )
            } catch (_: UnknownHostException) {
                _uiState.value = StockUiState(
                    error = "No se puede encontrar el servidor."
                )
            } catch (e: Exception) {
                _uiState.value = StockUiState(
                    error = "Error de conexión: ${e.localizedMessage ?: "Error desconocido"}"
                )
            }
        }
    }

    fun movimiento(articulo: String, delta: Int) {
        viewModelScope.launch {
            try {
                val token = tokenManager.getToken().first()

                if (token.isNullOrEmpty()) {
                    _uiState.value = _uiState.value.copy(isTokenInvalid = true)
                    return@launch
                }

                val response = repository.movimiento(token, articulo, delta)

                if (response.isSuccessful) {
                    loadStock() // Recargar la lista
                } else if (response.code() == 401) {
                    tokenManager.clearToken()
                    _uiState.value = _uiState.value.copy(isTokenInvalid = true)
                } else {
                    _uiState.value = _uiState.value.copy(
                        error = "Error al realizar movimiento (código ${response.code()})"
                    )
                }
            } catch (_: ConnectException) {
                _uiState.value = _uiState.value.copy(
                    error = "No se puede conectar al servidor."
                )
            } catch (_: SocketTimeoutException) {
                _uiState.value = _uiState.value.copy(
                    error = "Tiempo de espera agotado."
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    error = "Error: ${e.localizedMessage ?: "Error desconocido"}"
                )
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            tokenManager.clearToken()
            _uiState.value = StockUiState(isTokenInvalid = true)
        }
    }
}