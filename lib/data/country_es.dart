const Map<String, String> kCountryEs = {
  'Italy': 'Italia',
  'Spain': 'España',
  'France': 'Francia',
  'Switzerland': 'Suiza',
  'Netherlands': 'Países Bajos',
  'The Netherlands': 'Países Bajos',
  'United Kingdom': 'Reino Unido',
  'UK': 'Reino Unido',
  'Greece': 'Grecia',
  'Portugal': 'Portugal',
  'Germany': 'Alemania',
  'United States': 'Estados Unidos',
  'USA': 'Estados Unidos',
};

String toCountryEs(String any) => kCountryEs[any] ?? any;

