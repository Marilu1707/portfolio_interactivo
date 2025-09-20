import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/inventory_mouse.dart';
import '../models/inventory_item.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';

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

  void _showSnack(
    String message, {
    Color? color,
    IconData icon = Icons.check_circle_outline,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color ?? Colors.green.shade500,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyRestock(AppState app, InventoryItem row, int qty) {
    final before = row.stock;
    final success = _tryRestock(app: app, row: row, qty: qty);
    if (!success) return;
    final updated = app.inventory[row.name]?.stock ?? row.stock;
    final added = (updated - before).clamp(0, qty);
    final plural = added == 1 ? '' : 'es';
    _showSnack('🧀 +$added unidad$plural de ${row.name} (stock: $updated)');
  }

  bool _tryRestock({
    required AppState app,
    required InventoryItem row,
    required int qty,
  }) {
    final next = (row.stock + qty).clamp(0, kStockMax).toInt();
    if (next == row.stock) {
      _showSnack(
        'Ya estás al máximo ($kStockMax).',
        color: Colors.orange.shade600,
        icon: Icons.info_outline,
      );
      return false;
    }

    app.restock(row.name, qty);
    return true;
  }

  // (Método _addOne removido; ahora usamos _applyRestock con SnackBar)

  void _scrollToFirstLow(List<InventoryItem> rows) {
    final low = rows.where((e) => e.stock < kStockYellowMin).toList();
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

  String _statusText(int stock) {
    if (stock < kStockYellowMin) return 'Stock crítico';
    if (stock < kStockGreenMin) return 'Stock medio';
    return 'Stock ok';
  }

  Color _statusColor(int stock) {
    if (stock < kStockYellowMin) return Colors.red;
    if (stock < kStockGreenMin) return Colors.orange;
    return Colors.green;
  }

  DataRow _row(BuildContext context, AppState app, InventoryItem item) {
    final status = _statusText(item.stock);
    final color = _statusColor(item.stock);
    final isAtMax = item.stock >= kStockMax;

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
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => _applyRestock(app, item, 1),
            child: const Text('Agregar (+1)'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _applyRestock(app, item, 5),
            child: const Text('+5'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: isAtMax
                ? null
                : () {
                    final diff = kStockMax - item.stock;
                    if (diff <= 0) {
                      _showSnack(
                        'Ya estás al máximo ($kStockMax).',
                        color: Colors.orange.shade600,
                        icon: Icons.info_outline,
                      );
                      return;
                    }
                    app.restock(item.name, diff);
                    _showSnack(
                      'Llevamos ${item.name} al máximo ($kStockMax).',
                      icon: Icons.upgrade_rounded,
                    );
                  },
            child: const Text('100%'),
          ),
        ],
      )),
    ]);
  }

  Widget _mobileCard(BuildContext context, AppState app, InventoryItem item) {
    final isEmpty = item.stock <= 0;
    final status = _statusText(item.stock);
    final color = _statusColor(item.stock);
    final isAtMax = item.stock >= kStockMax;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                  onPressed: () => _applyRestock(app, item, 1),
                  child: const Text('Agregar (+1)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isAtMax ? null : () => _applyRestock(app, item, 5),
                  child: const Text('+5'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: isAtMax
                      ? null
                      : () {
                          final diff = kStockMax - item.stock;
                          if (diff <= 0) {
                            _showSnack(
                              'Ya estás al máximo ($kStockMax).',
                              color: Colors.orange.shade600,
                              icon: Icons.info_outline,
                            );
                            return;
                          }
                          app.restock(item.name, diff);
                          _showSnack(
                            'Llevamos ${item.name} al máximo ($kStockMax).',
                            icon: Icons.upgrade_rounded,
                          );
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
        title: const Text('Inventario'),
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
                          lowThreshold: kStockYellowMin - 1,
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
                    children: app.topCheeses(3).map((c) {
                      return Chip(
                        avatar: const Text('🧀', style: TextStyle(fontSize: 16)),
                        label: Text('${c.name} (${nf.format(c.count)})'),
                        backgroundColor: const Color(0xFFFFF4DA),
                        shape: const StadiumBorder(side: BorderSide(color: Colors.brown)),
                      );
                    }).toList(),
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
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
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

class _StockBadge extends StatelessWidget {
  final int value;
  const _StockBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (value < kStockYellowMin) {
      color = Colors.red;
    } else if (value < kStockGreenMin) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text('$value',
          style: TextStyle(fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendDot(color: Colors.green, label: '20–30 Stock ok'),
        _LegendDot(color: Colors.orange, label: '10–19 Stock medio'),
        _LegendDot(color: Colors.red, label: '<10 Stock crítico'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

