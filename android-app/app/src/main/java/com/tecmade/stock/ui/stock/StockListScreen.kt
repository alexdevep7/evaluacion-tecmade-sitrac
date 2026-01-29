package com.tecmade.stock.ui.stock

import android.app.Application
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tecmade.stock.data.model.StockItem

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StockListScreen(
    onLogout: () -> Unit
){
    val application = (LocalContext.current.applicationContext as Application)
    val viewModel: StockViewModel = viewModel(
        factory = object : androidx.lifecycle.ViewModelProvider.Factory {
            override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
                @Suppress("UNCHECKED_CAST")
                return StockViewModel(application) as T
            }
        }
    )

    val uiState by viewModel.uiState.collectAsState()

    val showDialog = remember { mutableStateOf(false) }
    var selectedItem by remember { mutableStateOf<StockItem?>(null) }

    LaunchedEffect(uiState.isTokenInvalid) {
        if (uiState.isTokenInvalid) {
            onLogout()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("TECMADE: Stock") },
                actions = {
                    IconButton(onClick = { viewModel.loadStock() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Actualizar")
                    }
                    IconButton(onClick = { viewModel.logout() }) {
                        Icon(Icons.AutoMirrored.Filled.ExitToApp, contentDescription = "Salir")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier.fillMaxSize().padding(paddingValues)
        ) {
            when {
                uiState.isLoading -> {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }

                uiState.error != null -> {
                    Column(
                        modifier = Modifier.align(Alignment.Center),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(text = uiState.error!!)
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(onClick = { viewModel.loadStock() }) {
                            Text("Reintentar")
                        }
                    }
                }

                uiState.stockItems.isEmpty() -> {
                    Text(
                        text = "No hay artículos en stock",
                        modifier = Modifier.align(Alignment.Center)
                    )
                }

                else -> {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(uiState.stockItems) { item ->
                            StockItemCard(
                                item = item,
                                onItemClick = {
                                    selectedItem = item
                                    showDialog.value = true
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    if (showDialog.value && selectedItem != null) {
        MovimientoDialog(
            item = selectedItem!!,
            onDismiss = { showDialog.value = false },
            onConfirm = { delta ->
                viewModel.movimiento(selectedItem!!.articulo, delta)
                showDialog.value = false
            }
        )
    }
}

@Composable
fun StockItemCard(
    item: StockItem,
    onItemClick: () -> Unit
){
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = onItemClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.articulo,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "ID: ${item.idstock}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Text(
                text = "${item.cantidad}",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}


@Composable
fun MovimientoDialog(
    item: StockItem,
    onDismiss: () -> Unit,
    onConfirm: (Int) -> Unit
){
    var cantidad by remember { mutableStateOf("") }
    var isAdding by remember { mutableStateOf(true) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Movimiento de Stock") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Artículo: ${item.articulo}")
                Text("Cantidad actual: ${item.cantidad}")

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    FilterChip(
                        selected = isAdding,
                        onClick = { isAdding = true },
                        label = { Text("Agregar") },
                        leadingIcon = { Icon(Icons.Default.Add, null) }
                    )
                    FilterChip(
                        selected = !isAdding,
                        onClick = { isAdding = false },
                        label = { Text("Restar") },
                        leadingIcon = { Icon(Icons.Default.Remove, null) }
                    )
                }

                OutlinedTextField(
                    value = cantidad,
                    onValueChange = { cantidad = it.filter { char -> char.isDigit() } },
                    label = { Text("Cantidad") },
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val delta = cantidad.toIntOrNull() ?: 0
                    if (delta > 0) {
                        onConfirm(if (isAdding) delta else -delta)
                    }
                },
                enabled = cantidad.isNotBlank() && cantidad.toIntOrNull() != null
            ) {
                Text("Confirmar")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancelar")
            }
        }
    )
}