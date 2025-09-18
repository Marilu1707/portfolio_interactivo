import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';

// Pantalla Nivel 3 (Inventario): muestra stock por queso y permite reponer.
class Level3InventoryScreen extends StatefulWidget {
  const Level3InventoryScreen({super.key});

  @override
  State<Level3InventoryScreen> createState() => _Level3InventoryScreenState();
}

class _Level3InventoryScreenState extends State<Level3InventoryScreen> {
  static const bg = KawaiiTheme.bg;
  static const card = KawaiiTheme.card;
  final nf = NumberFormat.decimalPattern('es_AR');
  final df = DateFormat('dd/MM/yyyy', 'es_AR');

  // Suma unidades al stock del queso seleccionado y muestra SnackBar.
  void _addOne(AppState app, InventoryItem row, int qty) {
    app.restock(row.name, qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se agregó $qty unidad${qty > 1 ? 'es' : ''} de ${row.name} (stock: ${row.stock})')),
    );
  }

    @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    // Ordena por nombre para visualización consistente.
    final rows = app.inventory.values.toList()..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Nivel 3 – Inventario'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top ventas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: app.topCheeses(3)
                      .map((c) => Chip(
                            label: Text('${c.name} (${nf.format(c.count)})'),
                            backgroundColor: const Color(0xFFFFF4DA),
                            shape: StadiumBorder(side: BorderSide(color: Colors.brown)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    child: SingleChildScrollView(
                          child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          dataRowMinHeight: 48,
                          headingRowHeight: 44,
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
                          columns: const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Caducidad')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: rows
                              .map(
                                (r) {                                  return DataRow(cells: [
                                    DataCell(SizedBox(width: 200, child: Text(r.name, softWrap: true, style: const TextStyle(fontWeight: FontWeight.w700)))),
                                    DataCell(FittedBox(fit: BoxFit.scaleDown, child: Text(nf.format(r.stock)))),
                                    DataCell(Text(df.format(r.expiry))),
                                    DataCell(StockStatusDot(stock: r.stock)),
                                    DataCell(Row(
                                      children: [
                                        OutlinedButton(onPressed: () => _addOne(app, r, 1), child: const Text('Agregar')),
                                        const SizedBox(width: 8),
                                        OutlinedButton(onPressed: () => _addOne(app, r, 5), child: const Text('+5')),
                                      ],
                                    )),
                                  ]);
                                },
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const _Legend(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/level4'),
                        icon: const Icon(Icons.arrow_right_alt_rounded),
                        label: const Text('Siguiente nivel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StockStatusDot extends StatelessWidget {
  final int stock;
  const StockStatusDot({super.key, required this.stock});
  Color get color {
    if (stock <= 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.circle, color: color, size: 16);
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendDot(color: Colors.green, text: 'Stock suficiente'),
        _LegendDot(color: Colors.orange, text: 'Stock bajo'),
        _LegendDot(color: Colors.red, text: 'Sin stock'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}


