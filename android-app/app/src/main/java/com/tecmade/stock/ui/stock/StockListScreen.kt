package com.tecmade.stock.ui.stock

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.material3.CardDefaults
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
import androidx.compose.material3.VerticalDivider
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.tecmade.stock.data.model.StockItem


// Detectar si es tablet basándose en el ancho de pantalla
// Tablets: >= 600dp (criterio estándar de Android)
//@Composable
//fun isTablet(): Boolean {
//    val configuration = LocalConfiguration.current
//    return configuration.screenWidthDp >= 600
//}

@Composable
fun shouldUseTwoPaneLayout(): Boolean {
    val configuration = LocalConfiguration.current
    val isTabletSize = configuration.screenWidthDp >= 600
    val isLandscape = configuration.screenWidthDp > configuration.screenHeightDp
    return isTabletSize && isLandscape
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StockListScreen(
    onLogout: () -> Unit
) {
//    val context = LocalContext.current
    val application = (LocalContext.current.applicationContext as android.app.Application)
    val viewModel: StockViewModel = viewModel(
        factory = object : androidx.lifecycle.ViewModelProvider.Factory {
            override fun <T : androidx.lifecycle.ViewModel> create(modelClass: Class<T>): T {
                @Suppress("UNCHECKED_CAST")
                return StockViewModel(application) as T
            }
        }
    )

    val uiState by viewModel.uiState.collectAsState()
    val useTwoPaneLayout = shouldUseTwoPaneLayout()

    val showDialog = remember { mutableStateOf(false) }
    val selectedItem = remember { mutableStateOf<StockItem?>(null) }

    LaunchedEffect(uiState.isTokenInvalid) {
        if (uiState.isTokenInvalid) {
            onLogout()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("TECMADE - Stock") },
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
        if (useTwoPaneLayout) {
            // Layout para TABLET (dos paneles)
            TabletLayout(
                paddingValues = paddingValues,
                uiState = uiState,
                selectedItem = selectedItem.value,
                onItemSelected = { selectedItem.value = it },
                onMovimiento = { articulo, delta ->
                    viewModel.movimiento(articulo, delta)
                },
                onRetry = { viewModel.loadStock() }
            )
        } else {
            // Layout para PHONE (pantalla completa con dialog)
            PhoneLayout(
                paddingValues = paddingValues,
                uiState = uiState,
                showDialog = showDialog.value,
                selectedItem = selectedItem.value,
                onItemClick = {
                    selectedItem.value = it
                    showDialog.value = true
                },
                onDismissDialog = { showDialog.value = false },
                onConfirmDialog = { delta ->
                    viewModel.movimiento(selectedItem.value!!.articulo, delta)
                    showDialog.value = false
                },
                onRetry = { viewModel.loadStock() }
            )
        }
    }
}

/**
 * Layout para tablets - Dos paneles (lista + detalle)
 */
@Composable
private fun TabletLayout(
    paddingValues: PaddingValues,
    uiState: StockUiState,
    selectedItem: StockItem?,
    onItemSelected: (StockItem) -> Unit,
    onMovimiento: (String, Int) -> Unit,
    onRetry: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
    ) {
        // Panel izquierdo - Lista (40% del ancho)
        Box(
            modifier = Modifier
                .weight(0.4f)
                .fillMaxHeight()
        ) {
            StockListContent(
                uiState = uiState,
                selectedItemId = selectedItem?.idstock,
                onItemClick = onItemSelected,
                onRetry = onRetry,
                isCompactView = true
            )
        }

        // Divisor vertical
        VerticalDivider()

        // Panel derecho - Detalle (60% del ancho)
        Box(
            modifier = Modifier
                .weight(0.6f)
                .fillMaxHeight()
        ) {
            StockDetailPane(
                selectedItem = selectedItem,
                onMovimiento = onMovimiento
            )
        }
    }
}

/**
 * Layout para phones - Pantalla completa con dialog
 */
@Composable
private fun PhoneLayout(
    paddingValues: PaddingValues,
    uiState: StockUiState,
    showDialog: Boolean,
    selectedItem: StockItem?,
    onItemClick: (StockItem) -> Unit,
    onDismissDialog: () -> Unit,
    onConfirmDialog: (Int) -> Unit,
    onRetry: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(paddingValues)
    ) {
        StockListContent(
            uiState = uiState,
            selectedItemId = null,
            onItemClick = onItemClick,
            onRetry = onRetry,
            isCompactView = false
        )
    }

    if (showDialog && selectedItem != null) {
        MovimientoDialog(
            item = selectedItem,
            onDismiss = onDismissDialog,
            onConfirm = onConfirmDialog
        )
    }
}

/**
 * Contenido común de la lista de stock
 */
@Composable
private fun StockListContent(
    uiState: StockUiState,
    selectedItemId: Int?,
    onItemClick: (StockItem) -> Unit,
    onRetry: () -> Unit,
    isCompactView: Boolean
) {
    when {
        uiState.isLoading -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }

        uiState.error != null -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(text = uiState.error)
                    Button(onClick = onRetry) {
                        Text("Reintentar")
                    }
                }
            }
        }

        uiState.stockItems.isEmpty() -> {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Text(text = "No hay artículos en stock")
            }
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
                        isSelected = item.idstock == selectedItemId,
                        onItemClick = { onItemClick(item) },
                        isCompactView = isCompactView
                    )
                }
            }
        }
    }
}

@Composable
fun StockItemCard(
    item: StockItem,
    isSelected: Boolean,
    onItemClick: () -> Unit,
    isCompactView: Boolean
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        onClick = onItemClick,
        colors = if (isSelected) {
            CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        } else {
            CardDefaults.cardColors()
        }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = item.articulo,
                    style = if (isCompactView) {
                        MaterialTheme.typography.bodyLarge
                    } else {
                        MaterialTheme.typography.titleMedium
                    },
                    fontWeight = FontWeight.Bold,
                    color = if (isSelected) {
                        MaterialTheme.colorScheme.onPrimaryContainer
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    }
                )
                if (!isCompactView) {
                    Text(
                        text = "ID: ${item.idstock}",
                        style = MaterialTheme.typography.bodySmall,
                        color = if (isSelected) {
                            MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        }
                    )
                }
            }

            Text(
                text = "${item.cantidad}",
                style = if (isCompactView) {
                    MaterialTheme.typography.headlineSmall
                } else {
                    MaterialTheme.typography.headlineMedium
                },
                fontWeight = FontWeight.Bold,
                color = if (isSelected) {
                    MaterialTheme.colorScheme.onPrimaryContainer
                } else {
                    MaterialTheme.colorScheme.primary
                }
            )
        }
    }
}

@Composable
fun MovimientoDialog(
    item: StockItem,
    onDismiss: () -> Unit,
    onConfirm: (Int) -> Unit
) {
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