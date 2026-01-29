package com.tecmade.stock.data.repository

import com.tecmade.stock.data.model.LoginRequest
import com.tecmade.stock.data.model.LoginResponse
import com.tecmade.stock.data.model.MovimientoRequest
import com.tecmade.stock.data.model.StockItem
import com.tecmade.stock.data.remote.RetrofitInstance
import retrofit2.Response

class StockRepository {

    private val api = RetrofitInstance.api

    suspend fun login(email: String, password: String): Response<LoginResponse> {
        return api.login(LoginRequest(email, password))
    }

    suspend fun getStock(token: String): Response<List<StockItem>> {
        return api.getStock("Bearer $token")
    }

    suspend fun movimiento(token: String, articulo: String, delta: Int): Response<Map<String, Any>> {
        return api.movimiento("Bearer $token", MovimientoRequest(articulo, delta))
    }
}