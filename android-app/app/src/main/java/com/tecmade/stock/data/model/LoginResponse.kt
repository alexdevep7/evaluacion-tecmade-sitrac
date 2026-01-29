package com.tecmade.stock.data.model

data class LoginResponse (
    val token: String,
    val user: User
)

data class User (
    val email: String,
    val legajo: String?
)