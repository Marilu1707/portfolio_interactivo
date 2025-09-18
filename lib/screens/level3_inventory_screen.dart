import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/inventory_mouse.dart';
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
  final ScrollController _mobileCtrl = ScrollController();
  final Map<String, GlobalKey> _rowKeys = {};

  // Suma unidades al stock del queso seleccionado y muestra SnackBar.
  void _addOne(AppState app, InventoryItem row, int qty) {
    app.restock(row.name, qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se agregó $qty unidad${qty > 1 ? 'es' : ''} de ${row.name} (stock: ${row.stock})')),
    );
  }

  void _scrollToFirstLow(List<InventoryItem> rows) {
    final low = rows.where((e) => e.stock <= 5).toList();
    if (low.isEmpty) return;
    final key = _rowKeys[low.first.name];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        alignment: 0.1,
      );
    }
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
                Builder(builder: (context) {
                  final mouseItems = rows
                      .map((r) => InventoryMouseItem(name: r.name, stock: r.stock))
                      .toList();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InventoryMouse(
                        items: mouseItems,
                        lowThreshold: 3,
                        onTap: () => _scrollToFirstLow(rows),
                      ),
                    ),
                  );
                }),
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
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final isMobile = MediaQuery.of(context).size.width <= 600;
                      final table = Container(
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
                              headingRowHeight: 44,
                              dataRowMinHeight: 56,
                              dataRowMaxHeight: 64,
                              headingTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Stock')),
                                DataColumn(label: Text('Caducidad')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: rows.map((r) => DataRow(cells: [
                                DataCell(SizedBox(width: 220, child: Text(r.name, softWrap: true, style: const TextStyle(fontWeight: FontWeight.w700)))),
                                DataCell(Text(nf.format(r.stock))),
                                DataCell(Text(df.format(r.expiry))),
                                DataCell(SizedBox(width: 32, child: Align(alignment: Alignment.centerLeft, child: StockStatusDot(stock: r.stock)))) ,
                                DataCell(SizedBox(
                                  width: 220, // mantiene una sola línea para acciones
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _addOne(app, r, 1),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          minimumSize: const Size(0, 40),
                                        ),
                                        child: const Text('Agregar'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => _addOne(app, r, 5),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          minimumSize: const Size(0, 40),
                                        ),
                                        child: const Text('+5'),
                                      ),
                                    ],
                                  ),
                                )),
                              ])).toList(),
                            ),
                          ),
                        ),
                      );
                      if (!isMobile) return table;

                      // Mobile: list of row-cards
                      return ListView.builder(
                        controller: _mobileCtrl,
                        itemCount: rows.length,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemBuilder: (context, i) {
                          final r = rows[i];
                          _rowKeys.putIfAbsent(r.name, () => GlobalKey());
                          return KeyedSubtree(
                            key: _rowKeys[r.name],
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Text('Caduca: ' + df.format(r.expiry), style: const TextStyle(fontSize: 12)),
                                    ],
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: StockStatusDot(stock: r.stock),
                                  ),
                                  Wrap(spacing: 8, children: [
                                    OutlinedButton(onPressed: () => _addOne(app, r, 1), child: const Text('Agregar')),
                                    OutlinedButton(onPressed: () => _addOne(app, r, 5), child: const Text('+5')),
                                  ]),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
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


