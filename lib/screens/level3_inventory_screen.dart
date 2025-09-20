import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/inventory_mouse.dart';
import '../models/inventory_item.dart';
import '../theme/kawaii_theme.dart';
import '../state/app_state.dart';
import '../utils/game_popup.dart';

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
    final success = _tryRestock(
      context: context,
      app: app,
      row: row,
      qty: qty,
    );
    if (!success) return;
    final plural = qty > 1 ? 's' : '';
    GamePopup.show(context,
        '🧀 +$qty unidad$plural de ${row.name} (stock: ${row.stock})',
        color: Colors.green, icon: Icons.check_circle);
  }

  bool _tryRestock({
    required BuildContext context,
    required AppState app,
    required InventoryItem row,
    required int qty,
  }) {
    if (qty <= 0) {
      _inventorySnack(context, 'Ingresá una cantidad positiva.');
      return false;
    }

    final reorderPoint = row.reorderPoint > 0 ? row.reorderPoint : 5;

    if (row.stock <= 0) {
      _inventorySnack(
        context,
        'Sin stock actual: sumamos $qty unidad${qty > 1 ? 'es' : ''} para reiniciar inventario.',
      );
      app.restock(row.name, qty);
      return true;
    }

    if (row.stock >= reorderPoint) {
      _inventorySnack(
        context,
        'Ya estás en el stock seguro ($reorderPoint). Usá el inventario actual antes de reponer más.',
      );
      return false;
    }

    final nextStock = row.stock + qty;
    if (nextStock > reorderPoint) {
      _inventorySnack(
        context,
        'Con esta reposición superarías el stock seguro ($reorderPoint). Reponé menos unidades.',
      );
      return false;
    }

    app.restock(row.name, qty);
    return true;
  }

  void _inventorySnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
                              rows: rows.map((r) {
                                final isOut = r.stock <= 0;
                                final reorderPoint = r.reorderPoint > 0 ? r.reorderPoint : 5;
                                final isLow = !isOut && r.stock <= reorderPoint;
                                return DataRow(cells: [
                                  DataCell(SizedBox(
                                      width: 220,
                                      child: Text(r.name,
                                          softWrap: true,
                                          style: const TextStyle(fontWeight: FontWeight.w700)))),
                                  DataCell(Align(
                                      alignment: Alignment.centerRight,
                                      child: _StockBadgeSmall(value: r.stock))),
                                  DataCell(Text(df.format(r.expiry))),
                                  DataCell(Align(
                                    alignment: Alignment.centerLeft,
                                    child: _InventoryStatusBadge(
                                      isOut: isOut,
                                      isLow: isLow,
                                      dense: true,
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 220,
                                    child: _buildTrailing(
                                      stock: r.stock,
                                      isOut: isOut,
                                      reorderPoint: reorderPoint,
                                      onAddOne: () => _addOneToast(app, r, 1),
                                      onAddFive: () => _addOneToast(app, r, 5),
                                      onRestockSafe: () => _addOneToast(app, r, reorderPoint),
                                      dotColor: _statusColor(r.stock),
                                    ),
                                  )),
                                ]);
                              }).toList(),
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
                          final r = rows[i];
                          final isOut = r.stock <= 0;
                          final reorderPoint = r.reorderPoint > 0 ? r.reorderPoint : 5;
                          final isLow = !isOut && r.stock <= reorderPoint;
                          _rowKeys.putIfAbsent(r.name, () => GlobalKey());
                          return KeyedSubtree(
                            key: _rowKeys[r.name],
                            child: Stack(
                              children: [
                                // Card principal
                                Container(
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
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  r.name,
                                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Caduca: ${df.format(r.expiry)}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildTrailing(
                                            stock: r.stock,
                                            isOut: isOut,
                                            reorderPoint: reorderPoint,
                                            onAddOne: () => _addOneToast(app, r, 1),
                                            onAddFive: () => _addOneToast(app, r, 5),
                                            onRestockSafe: () => _addOneToast(app, r, reorderPoint),
                                            dotColor: _statusColor(r.stock),
                                          ),
                                        ],
                                      ),
                                      if (isOut)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'No quedan unidades. Reabastecé para continuar.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            softWrap: true,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Badge de stock y estado accesible
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Semantics(
                                    label:
                                        '${isOut ? 'Sin stock' : isLow ? 'Stock bajo' : 'Stock disponible'} — ${r.stock} unidades',
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _InventoryStatusBadge(
                                          isOut: isOut,
                                          isLow: isLow,
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.10),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Stock: ${r.stock}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
      required bool isOut,
      required bool isLow,
      required String label,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InventoryStatusBadge(isOut: isOut, isLow: isLow, dense: true),
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
        legendItem(isOut: false, isLow: false, label: 'Stock suficiente'),
        legendItem(isOut: false, isLow: true, label: 'Stock bajo'),
        legendItem(isOut: true, isLow: false, label: 'Sin stock'),
      ],
    );
  }
}


class _StockDot extends StatelessWidget {
  final Color color;
  const _StockDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado de stock',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _InventoryStatusBadge extends StatelessWidget {
  final bool isOut;
  final bool isLow;
  final bool dense;

  const _InventoryStatusBadge({
    required this.isOut,
    required this.isLow,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    late final Color fg;
    late final Color bg;
    late final String label;

    if (isOut) {
      label = 'Sin stock';
      fg = theme.colorScheme.error;
      bg = fg.withValues(alpha: 0.12);
    } else if (isLow) {
      label = 'Stock bajo';
      fg = const Color(0xFFFF8F00);
      bg = const Color(0xFFFFECB3);
    } else {
      label = 'Stock ok';
      fg = const Color(0xFF2E7D32);
      bg = const Color(0xFFE8F5E9);
    }

    final border = fg.withValues(alpha: 0.35);
    final padding = dense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final textStyle = theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12);

    return Semantics(
      label: 'Estado: $label',
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}

  // Color para estado de stock
  Color _statusColor(int stock) {
    if (stock <= 0) return Colors.red;
    if (stock <= 5) return Colors.orange;
    return Colors.green;
  }

  // Trailing responsive: muestra siempre stock y botones
  Widget _buildTrailing({
    required int stock,
    required bool isOut,
    required int reorderPoint,
    required VoidCallback onAddOne,
    required VoidCallback onAddFive,
    required VoidCallback onRestockSafe,
    required Color dotColor,
  }) {
    return LayoutBuilder(
      builder: (context, cons) {
        final isTight = cons.maxWidth < 180 || MediaQuery.of(context).size.width < 380;
        final safePoint = reorderPoint > 0 ? reorderPoint : 5;
        final bool atCap = !isOut && stock >= safePoint;
        final Color baseColor = Colors.brown;
        void showOutSnack() {
          _inventorySnack(
            context,
            'Sin stock actual. Usá “Reponer stock seguro” para reiniciar inventario.',
          );
        }
        Color buttonColor(bool highlight) =>
            highlight ? baseColor.withValues(alpha: 0.45) : baseColor;
        BorderSide borderColor(bool highlight) => BorderSide(
              color: highlight
                  ? baseColor.withValues(alpha: 0.25)
                  : baseColor.withValues(alpha: 0.6),
              width: 1.6,
            );

        Widget quickAction({
          required String label,
          required String tooltip,
          required VoidCallback onTap,
          required bool highlight,
          bool disabled = false,
        }) {
          final style = OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            foregroundColor: buttonColor(highlight),
            side: borderColor(highlight),
          );
          final button = OutlinedButton(
            onPressed: disabled ? null : onTap,
            style: style,
            child: Text(label),
          );
          final semantics = Semantics(
            button: true,
            enabled: !disabled,
            label: disabled ? 'Sin stock disponible' : tooltip,
            child: button,
          );
          final actionChild = disabled
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: showOutSnack,
                  child: AbsorbPointer(
                    child: Opacity(opacity: 0.5, child: semantics),
                  ),
                )
              : semantics;
          final disabledTooltip =
              'Sin stock disponible. Reponé antes de usar accesos rápidos.';
          return Tooltip(
            message: disabled ? disabledTooltip : tooltip,
            child: actionChild,
          );
        }

        Widget restockButton({double? width}) => SizedBox(
              width: width,
              child: FilledButton.icon(
                onPressed: onRestockSafe,
                icon: const Icon(Icons.inventory_rounded),
                label: Text('Reponer stock seguro ($safePoint)'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            );

        if (isTight) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  quickAction(
                    label: 'Agregar',
                    tooltip: 'Agregar 1',
                    onTap: onAddOne,
                    highlight: isOut || atCap,
                    disabled: isOut,
                  ),
                  const SizedBox(width: 8),
                  quickAction(
                    label: '+5',
                    tooltip: 'Agregar 5',
                    onTap: onAddFive,
                    highlight: atCap || isOut,
                    disabled: isOut,
                  ),
                ],
              ),
              if (isOut) ...[
                const SizedBox(height: 8),
                restockButton(width: double.infinity),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StockDot(color: dotColor),
                  const SizedBox(width: 6),
                  Text('Stock: $stock', style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StockDot(color: dotColor),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('Stock: $stock', style: Theme.of(context).textTheme.labelMedium),
            ),
            quickAction(
              label: 'Agregar',
              tooltip: 'Agregar 1',
              onTap: onAddOne,
              highlight: isOut || atCap,
              disabled: isOut,
            ),
            quickAction(
              label: '+5',
              tooltip: 'Agregar 5',
              onTap: onAddFive,
              highlight: atCap || isOut,
              disabled: isOut,
            ),
            if (isOut) restockButton(width: 220),
          ],
        );
      },
    );
  }


class _StockBadgeSmall extends StatelessWidget {
  final int value;
  const _StockBadgeSmall({required this.value});
  Color get _color {
    if (value <= 0) return Colors.red;
    if (value <= 5) return Colors.orange;
    return Colors.green;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withValues(alpha: .5)),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: _color,
          fontSize: 14,
        ),
      ),
    );
  }
}

// (removido: _StockBadgeLarge no se usa)


