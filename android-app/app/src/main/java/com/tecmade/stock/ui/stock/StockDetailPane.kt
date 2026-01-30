package com.tecmade.stock.ui.stock

import androidx.compose.runtime.Composable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tecmade.stock.data.model.StockItem


// Panel de detalle para mostrar información de un artículo en tablets
// Se muestra en el lado derecho en layouts de dos paneles

@Composable
fun StockDetailPane(
    selectedItem: StockItem?,
    onMovimiento: (String, Int) -> Unit,
    modifier: Modifier = Modifier
){
    if (selectedItem == null) {
        // Estado vacío - sin selección
        Box(
            modifier = modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = null,
                    modifier = Modifier.size(64.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f)
                )
                Text(
                    text = "Selecciona un artículo",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    } else {
        // Mostrar detalle del artículo
        StockDetailContent(
            item = selectedItem,
            onMovimiento = onMovimiento,
            modifier = modifier
        )
    }
}

@Composable
private fun StockDetailContent(
    item: StockItem,
    onMovimiento: (String, Int) -> Unit,
    modifier: Modifier = Modifier
) {
    var cantidad by remember(item) { mutableStateOf("") }
    var isAdding by remember(item) { mutableStateOf(true) }

    Card(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // Header
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "Movimiento de Stock",
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = item.articulo,
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold
                )
            }

            HorizontalDivider()

            // Información
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                InfoRow(label = "ID Stock", value = item.idstock.toString())
                InfoRow(
                    label = "Cantidad Actual",
                    value = item.cantidad.toString(),
                    emphasized = true
                )
            }

            HorizontalDivider()

            // Selector Agregar/Restar (igual que en phone)
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

            // Campo de cantidad
            OutlinedTextField(
                value = cantidad,
                onValueChange = { cantidad = it.filter { char -> char.isDigit() } },
                label = { Text("Cantidad") },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                placeholder = { Text("Ingrese cantidad") }
            )

            Spacer(modifier = Modifier.weight(1f))

            // Botones Cancelar y Confirmar (igual que en phone)
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Botón Cancelar
                OutlinedButton(
                    onClick = {
                        cantidad = ""
                        isAdding = true
                    },
                    modifier = Modifier.weight(1f)
                ) {
                    Text("Cancelar")
                }

                // Botón Confirmar
                Button(
                    onClick = {
                        val delta = cantidad.toIntOrNull() ?: 0
                        if (delta > 0) {
                            onMovimiento(item.articulo, if (isAdding) delta else -delta)
                            cantidad = ""
                            isAdding = true
                        }
                    },
                    modifier = Modifier.weight(1f),
                    enabled = cantidad.isNotBlank() && cantidad.toIntOrNull() != null
                ) {
                    Text("Confirmar")
                }
            }

            // Nota informativa
            Surface(
                color = MaterialTheme.colorScheme.secondaryContainer,
                shape = MaterialTheme.shapes.small
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "💡",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = "Los cambios se reflejan inmediatamente en el listado",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
            }
        }
    }
}

@Composable
private fun InfoRow(
    label: String,
    value: String,
    emphasized: Boolean = false
){
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = if (emphasized) {
                MaterialTheme.typography.headlineSmall
            } else {
                MaterialTheme.typography.bodyLarge
            },
            fontWeight = if (emphasized) FontWeight.Bold else FontWeight.Normal,
            color = if (emphasized) {
                MaterialTheme.colorScheme.primary
            } else {
                MaterialTheme.colorScheme.onSurface
            }
        )
    }
}