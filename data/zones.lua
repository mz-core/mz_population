MZPopulationData = MZPopulationData or {}

-- Bootstrap configuravel do MVP 1. Coordenadas, raios e numeros populacionais
-- sao aproximacoes de projeto; nao representam dados oficiais da Rockstar.
MZPopulationData.Zones = {
  {
    id = 'strawberry',
    name = 'Strawberry',
    region = 'los_santos',
    center = { x = 284.4, y = -1203.2, z = 29.3 },
    radius = 650.0,
    priority = 10,
    type = 'mixed',
    density = 0.82,
    population = { total = 2840, residents = 2310, workers = 410, visitors = 120 },
    workforce = { available = 1200, employed = 950, unemployed = 250 },
    demand = { food = 0.75, drinks = 0.62, fuel = 0.41, healthcare = 0.28, transport = 0.55 }
  },
  {
    id = 'davis',
    name = 'Davis',
    region = 'los_santos',
    center = { x = 94.0, y = -1709.0, z = 29.3 },
    radius = 580.0,
    priority = 10,
    type = 'residential',
    density = 0.88,
    population = { total = 3200, residents = 2600, workers = 450, visitors = 150 },
    workforce = { available = 1380, employed = 1040, unemployed = 340 },
    demand = { food = 0.81, drinks = 0.70, fuel = 0.46, healthcare = 0.35, transport = 0.61 }
  },
  {
    id = 'chamberlain_hills',
    name = 'Chamberlain Hills',
    region = 'los_santos',
    center = { x = -180.0, y = -1510.0, z = 34.0 },
    radius = 520.0,
    priority = 10,
    type = 'residential',
    density = 0.74,
    population = { total = 2450, residents = 2000, workers = 350, visitors = 100 },
    workforce = { available = 1040, employed = 760, unemployed = 280 },
    demand = { food = 0.77, drinks = 0.64, fuel = 0.38, healthcare = 0.39, transport = 0.66 }
  },
  {
    id = 'downtown',
    name = 'Downtown Los Santos',
    region = 'los_santos',
    center = { x = 215.0, y = -790.0, z = 30.8 },
    radius = 750.0,
    priority = 10,
    type = 'commercial',
    density = 0.95,
    population = { total = 5200, residents = 1600, workers = 3000, visitors = 600 },
    workforce = { available = 920, employed = 820, unemployed = 100 },
    demand = { food = 0.69, drinks = 0.73, fuel = 0.52, healthcare = 0.44, transport = 0.89 }
  },
  {
    id = 'vespucci',
    name = 'Vespucci',
    region = 'los_santos',
    center = { x = -1180.0, y = -1180.0, z = 7.0 },
    radius = 850.0,
    priority = 10,
    type = 'mixed',
    density = 0.79,
    population = { total = 3600, residents = 2100, workers = 1000, visitors = 500 },
    workforce = { available = 1180, employed = 1040, unemployed = 140 },
    demand = { food = 0.72, drinks = 0.78, fuel = 0.40, healthcare = 0.33, transport = 0.71 }
  },
  {
    id = 'sandy_shores',
    name = 'Sandy Shores',
    region = 'blaine_county',
    center = { x = 1700.0, y = 3600.0, z = 35.0 },
    radius = 1000.0,
    priority = 10,
    type = 'rural',
    density = 0.31,
    population = { total = 1250, residents = 900, workers = 250, visitors = 100 },
    workforce = { available = 510, employed = 390, unemployed = 120 },
    demand = { food = 0.58, drinks = 0.55, fuel = 0.76, healthcare = 0.51, transport = 0.43 }
  },
  {
    id = 'paleto_bay',
    name = 'Paleto Bay',
    region = 'blaine_county',
    center = { x = -110.0, y = 6400.0, z = 31.0 },
    radius = 900.0,
    priority = 10,
    type = 'rural',
    density = 0.27,
    population = { total = 980, residents = 760, workers = 160, visitors = 60 },
    workforce = { available = 420, employed = 340, unemployed = 80 },
    demand = { food = 0.54, drinks = 0.48, fuel = 0.69, healthcare = 0.57, transport = 0.38 }
  }
}
