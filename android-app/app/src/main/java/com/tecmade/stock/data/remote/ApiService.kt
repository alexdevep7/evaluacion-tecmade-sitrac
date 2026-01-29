package com.tecmade.stock.data.remote

import com.tecmade.stock.data.model.LoginRequest
import com.tecmade.stock.data.model.LoginResponse
import com.tecmade.stock.data.model.MovimientoRequest
import com.tecmade.stock.data.model.StockItem
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST

interface ApiService {

    @POST("api/login")
    suspend fun login(
        @Body request: LoginRequest
    ): Response<LoginResponse>

    @GET("api/stock")
    suspend fun getStock(
        @Header("Authorization") token: String
    ): Response<List<StockItem>>

    @POST("api/stock/movimiento")
    suspend fun movimiento(
        @Header("Authorization") token: String,
        @Body request: MovimientoRequest
    ): Response<Map<String, Any>>
}