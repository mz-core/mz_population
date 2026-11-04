# mz_population

## Overview

`mz_population` e o owner server-side do modelo virtual e estatistico de populacao da MZ Framework. Ele responde onde existem pessoas virtuais, quantas existem e quais agregados descrevem cada area. Uma populacao de `2840` nao cria 2.840 peds.

O MVP 1 e headless, deterministico, data-driven e independente de jogadores online. Nao possui client, NUI, eventos de rede, SQL ou dependencia de outro resource.

Adicione o resource ao boot da cidade quando o pacote estiver instalado:

```cfg
ensure mz_population
```

## Ownership

`mz_population` owns:

- regioes e zonas populacionais virtuais;
- populacao agregada por zona;
- workforce agregado por zona;
- demanda normalizada por zona;
- resolucao geografica populacional.

Nao owns:

- peds, NPCs, cenarios ou trafego GTA;
- spawn/despawn ou materializacao;
- economia, saldo, empresas, empregos, lojas ou estoque;
- crime, mercado ilegal ou IA.

## Architecture

```text
data/regions.lua + data/zones.lua
              |
              v
shared/validation.lua
              |
              v
server/state.lua (canonical, in-memory)
              |
              v
server/service.lua -> server/exports.lua
```

O bootstrap valida o dataset completo antes de um commit unico. Uma falha nao publica estado parcial. A API devolve deep copies; consumers nunca recebem referencia mutavel do estado canonico.

Nao existe `repository.lua`: sem persistencia, ele seria uma abstracao vazia. O limite entre dataset, state e service permite introduzir um repository real futuramente sem mudar os exports.

## Regions and zones

O bootstrap inicial possui duas regioes (`los_santos` e `blaine_county`) e sete zonas: Strawberry, Davis, Chamberlain Hills, Downtown Los Santos, Vespucci, Sandy Shores e Paleto Bay.

Coordenadas, raios e numeros sao bootstrap configuravel e aproximado do projeto; nao sao dados oficiais da Rockstar. O MVP nao tenta mapear toda San Andreas.

Cada zona possui ID estavel, nome, region, center, radius, priority, type e `density`. A `density` e um indicador virtual entre `0.0` e `1.0`; ela nunca chama `SetPedDensityMultiplierThisFrame` nem altera densidade GTA.

## Population model

Os grupos sao mutuamente exclusivos no snapshot de presenca da zona:

```text
total = residents + workers + visitors
```

Todos os campos sao inteiros nao negativos. `workers` representa pessoas virtuais presentes para trabalhar na zona; nao e a mesma metrica que `workforce.employed`, que pertence ao pool residente.

## Workforce model

```text
available = employed + unemployed
available <= residents
```

O modelo nao possui vagas, cargos, salario ou integracao com jobs.

## Demand model

`food`, `drinks`, `fuel`, `healthcare` e `transport` sao indicadores normalizados entre `0.0` e `1.0`. Eles nao geram consumo, transacao, preco ou alteracao de estoque.

O snapshot global calcula demanda media ponderada pela populacao total de cada zona.

## Runtime state

O estado vive somente em memoria e e reconstruido do dataset em todo restart. Consultas individuais copiam apenas o resultado solicitado; o agregado global e calculado uma vez no bootstrap.

## Public API

Todos os exports usam um envelope uniforme:

```lua
{ ok = true, data = value }
{ ok = false, error = 'error_code' }
```

Exports:

- `GetZone(zoneId)`;
- `GetZones()`;
- `GetRegion(regionId)`;
- `GetRegions()`;
- `GetZoneSnapshot(zoneId)`;
- `GetPopulationSnapshot()`;
- `GetZonePopulation(zoneId)`;
- `GetZoneWorkforce(zoneId)`;
- `GetZoneDemand(zoneId)`;
- `ResolveZoneByCoords(x, y, z)`.

Exemplo:

```lua
local result = exports['mz_population']:GetZoneDemand('strawberry')
if result.ok then
  print(result.data.food)
end
```

## Geographic resolution

`ResolveZoneByCoords` usa distancia 2D (`x`/`y`) contra `center + radius`; `z` e validado e mantido como metadado, mas nao participa do containment territorial.

Em overlap, a escolha e deterministica nesta ordem:

1. maior `priority`;
2. menor distancia ao center;
3. ID de zona em ordem lexicografica.

O contrato publico nao expoe o algoritmo como argumento, permitindo trocar o resolver interno por poligonos no futuro.

## Validation and initialization

O startup valida IDs, unicidade, nomes, regions, coordenadas finitas, radius, priority, tipos, density, population, workforce e demand. Dataset invalido gera erro explicito com o ID da zona e impede `ready`/estado parcial.

No startup valido, o resource registra somente:

```text
[mz_population] loaded X regions
[mz_population] loaded Y zones
[mz_population] simulation disabled
```

## Persistence decision

Nao ha persistencia no MVP 1. O bootstrap estatico mais estado em memoria e a fonte canonica, pois ainda nao existem mutacoes runtime que justifiquem tabela, migration, backfill ou writes por tick.

## Relationship with mz_settings

`mz_settings` continua owner dos controles fisicos e ambientais GTA: densidade de peds/cenarios, budgets, trafego, dispatch, wanted, cenarios e limpezas ambientais. `mz_population` nao chama natives GTA e nao depende de `mz_settings`.

## Relationship with mz_core

O MVP nao depende de account, character, citizenid, session ou player state. A separacao evita acoplamento sem consumer real.

## Relationship with mz_economy

`mz_economy` continua ledger/observabilidade financeira. `mz_population` nao registra transacoes, nao altera saldo e nao exige o ledger para iniciar.

## Simulation clock

`MZPopulationConfig.Simulation.Enabled` inicia como `false`. Se habilitado, o clock chama apenas um tick neutro no intervalo configurado; ele nao altera populacao, workforce ou demand.

## Tests

Execute offline a partir do workspace:

```powershell
lua .\mz_population\tests\population_harness.lua
```

O harness cobre bootstrap, invariantes, erros, snapshots imutaveis, resolucao geografica, overlap, reinicializacao e tick neutro.

## Known limitations

- dataset pequeno, aproximado e estatico;
- resolver circular 2D e busca linear O(n);
- sem persistencia ou API publica de escrita;
- sem peds, NPCs, IA, economia automatica, empresas ou empregos reais.

## Future evolution

Proxima wave natural: simulacao controlada de necessidades e demanda agregada, ainda sem consumo real ou dinheiro. Depois podem vir workforce, consumers de business/jobs, interacao economica, cohorts, citizens virtuais e, por ultimo, uma camada separada de materializacao fisica.

A divisao entre `mz_population`, `mz_settings` e uma eventual materialization layer permanece uma decisao futura; este MVP nao a antecipa.
