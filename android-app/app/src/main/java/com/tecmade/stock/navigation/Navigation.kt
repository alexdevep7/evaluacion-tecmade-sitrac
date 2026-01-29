package com.tecmade.stock.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.tecmade.stock.data.TokenManager
import com.tecmade.stock.ui.login.LoginScreen
import com.tecmade.stock.ui.stock.StockListScreen
import kotlinx.coroutines.flow.first

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object StockList : Screen("stock_list")
}

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val context = LocalContext.current
    val tokenManager = remember { TokenManager(context) }

    // Verificar token al inicio
    var startDestination by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        val token = tokenManager.getToken().first()
        startDestination = if (token.isNullOrEmpty()) {
            Screen.Login.route
        } else {
            Screen.StockList.route
        }
    }

    // Mostrar solo cuando sepamos dónde empezar
    if (startDestination != null) {
        NavHost(
            navController = navController,
            startDestination = startDestination!!
        ) {
            composable(Screen.Login.route) {
                LoginScreen(
                    onLoginSuccess = {
                        navController.navigate(Screen.StockList.route) {
                            popUpTo(Screen.Login.route) { inclusive = true }
                        }
                    }
                )
            }

            composable(Screen.StockList.route) {
                StockListScreen(
                    onLogout = {
                        navController.navigate(Screen.Login.route) {
                            popUpTo(Screen.StockList.route) { inclusive = true }
                        }
                    }
                )
            }
        }
    }
}