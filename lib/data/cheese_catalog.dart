// Catálogo único de quesos permitido en toda la app.

class Cheese {
  final String id; // clave interna estable
  final String nombre; // etiqueta UI (español)
  final String pais; // país de origen (para EDA)
  const Cheese(this.id, this.nombre, this.pais);
}

// ÚNICO listado permitido
const List<Cheese> kCheeses = [
  Cheese('mozzarella', 'Mozzarella', 'Italia'),
  Cheese('cheddar', 'Cheddar', 'Reino Unido'),
  Cheese('parmesano', 'Parmesano', 'Italia'),
  Cheese('gouda', 'Gouda', 'Países Bajos'),
  Cheese('brie', 'Brie', 'Francia'),
  Cheese('Provolone', 'Provolone', 'Francia'), // "Blue" → "Provolone"
];

// IDs permitidos
const Set<String> kAllowedIds = {
  'mozzarella', 'cheddar', 'parmesano', 'gouda', 'brie', 'Provolone'
};

// Normalizador de entradas externas → id interno
String normalizeCheese(String raw) {
  final r = raw.trim().toLowerCase();
  if (r.startsWith('moza') || r.contains('mozza') || r.contains('muzz')) return 'mozzarella';
  if (r.startsWith('ched')) return 'cheddar';
  if (r.startsWith('parme') || r.contains('parmig')) return 'parmesano';
  if (r.startsWith('gouda')) return 'gouda';
  if (r.startsWith('brie')) return 'brie';
  if (r.contains('blue') || r.contains('Provolone') || r.contains('roquefort') || r.contains('gorgonzola')) return 'Provolone';
  return '';
}

Cheese? cheeseById(String id) {
  for (final c in kCheeses) {
    if (c.id == id) return c;
  }
  return null;
}

