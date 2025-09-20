import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/inventory_mouse.dart';
import '../models/inventory_item.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../utils/game_popup.dart';

void _showInvSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

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

  // Variante toast (overlay) para notificaciones kawaii
  void _addOneToast(AppState app, InventoryItem row, int qty) {
    final before = row.stock;
    final success = _tryRestock(
      context: context,
      app: app,
      row: row,
      qty: qty,
    );
    if (!success) return;
    final updated = app.inventory[row.name]?.stock ?? row.stock;
    final added = updated - before;
    final units = added > 0 ? added : 0;
    final plural = units == 1 ? '' : 'es';
    GamePopup.show(context,
        '🧀 +$units unidad$plural de ${row.name} (stock: $updated)',
        color: Colors.green, icon: Icons.check_circle);
  }

  bool _tryRestock({
    required BuildContext context,
    required AppState app,
    required InventoryItem row,
    required int qty,
  }) {
    if (qty <= 0) {
      _showInvSnack(context, 'Ingresá una cantidad positiva.');
      return false;
    }

    final next = (row.stock + qty).clamp(0, AppState.maxStock).toInt();
    if (next == row.stock) {
      _showInvSnack(context, 'Ya estás al máximo (${AppState.maxStock}).');
      return false;
    }

    app.restock(row.name, qty);
    return true;
  }

  // (Método _addOne removido; se usa _addOneToast con GamePopup)

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

  String _fmtDate(DateTime date) => df.format(date);

  DataRow _row(BuildContext context, AppState app, InventoryItem item) {
    final reorderPoint = item.reorderPoint > 0 ? item.reorderPoint : 5;
    final isEmpty = item.stock <= 0;
    final isLow = item.stock <= reorderPoint;
    final statusText = isEmpty
        ? 'Sin stock'
        : isLow
            ? 'Stock bajo'
            : 'Stock ok';

    return DataRow(cells: [
      DataCell(SizedBox(
        width: 220,
        child: Text(
          item.name,
          softWrap: true,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      )),
      DataCell(_StockBadge(value: item.stock)),
      DataCell(Text(_fmtDate(item.expiry))),
      DataCell(_StatePill(text: statusText, low: isLow, empty: isEmpty)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => _addOneToast(app, item, 1),
            child: const Text('Agregar'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _addOneToast(app, item, 5),
            child: const Text('+5'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              final before = item.stock;
              app.restockFull(item.name);
              if (before < AppState.maxStock) {
                _showInvSnack(context,
                    'Llevamos ${item.name} al máximo (${AppState.maxStock}).');
              } else {
                _showInvSnack(
                    context, '${item.name} ya estaba al máximo.');
              }
            },
            child: const Text('100%'),
          ),
        ],
      )),
    ]);
  }

  Widget _mobileCard(BuildContext context, AppState app, InventoryItem item) {
    final reorderPoint = item.reorderPoint > 0 ? item.reorderPoint : 5;
    final isEmpty = item.stock <= 0;
    final isLow = item.stock <= reorderPoint;
    final statusText = isEmpty
        ? 'Sin stock'
        : isLow
            ? 'Stock bajo'
            : 'Stock ok';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StockBadge(value: item.stock),
              const SizedBox(width: 12),
              _StatePill(text: statusText, low: isLow, empty: isEmpty),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Caduca: ${_fmtDate(item.expiry)}',
            style: const TextStyle(fontSize: 12),
          ),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No quedan unidades. Reabastecé para continuar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                softWrap: true,
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _addOneToast(app, item, 1),
                  child: const Text('Agregar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _addOneToast(app, item, 5),
                  child: const Text('+5'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final before = item.stock;
                    app.restockFull(item.name);
                    if (before < AppState.maxStock) {
                      _showInvSnack(context,
                          'Llevamos ${item.name} al máximo (${AppState.maxStock}).');
                    } else {
                      _showInvSnack(
                          context, '${item.name} ya estaba al máximo.');
                    }
                  },
                  child: const Text('100%'),
                ),
              ),
            ],
          ),
        ],
      ),
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      final table = MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          // Evita que Android aplique escalado grande y rompa DataTable
                          textScaler: const TextScaler.linear(1.0),
                        ),
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
                              headingRowHeight: 44,
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 68,
                              columns: const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Stock')),
                                DataColumn(label: Text('Caducidad')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: rows.map((item) => _row(context, app, item)).toList(),
                            ),
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
                        final item = rows[i];
                        _rowKeys.putIfAbsent(item.name, () => GlobalKey());
                        return KeyedSubtree(
                          key: _rowKeys[item.name],
                          child: _mobileCard(context, app, item),
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
                        onPressed: () {
                          context.read<AppState>().setLevelCompleted(3);
                          Navigator.pushNamed(context, '/level4');
                        },
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
    ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);

    Widget legendItem({
      required Widget child,
      required String label,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 4),
          Text(label, style: textStyle),
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        legendItem(
          child: const _StatePill(text: 'Stock ok', low: false),
          label: 'Stock suficiente',
        ),
        legendItem(
          child: const _StatePill(text: 'Stock bajo', low: true),
          label: 'Stock bajo',
        ),
        legendItem(
          child: const _StatePill(text: 'Sin stock', low: true, empty: true),
          label: 'Sin stock',
        ),
        legendItem(
          child: const _StockBadge(value: 3),
          label: 'Badge de stock',
        ),
      ],
    );
  }
}


class _StockBadge extends StatelessWidget {
  final int value;
  const _StockBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value == 0
        ? Colors.red
        : (value <= 5 ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text('$value',
          style: TextStyle(fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _StatePill extends StatelessWidget {
  final String text;
  final bool low;
  final bool empty;
  const _StatePill({required this.text, required this.low, this.empty = false});
  @override
  Widget build(BuildContext context) {
    final Color color;
    if (empty) {
      color = Theme.of(context).colorScheme.error;
    } else {
      color = low ? const Color(0xFFF9A825) : const Color(0xFF2E7D32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(text,
          style: TextStyle(fontWeight: FontWeight.w700, color: color)),
    );
  }
}



