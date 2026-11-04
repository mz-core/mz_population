MZPopulationState = MZPopulationState or {
  ready = false,
  revision = 0,
  initializationError = nil,
  regions = {},
  regionsById = {},
  zones = {},
  zonesById = {},
  populationSnapshot = nil
}

local function buildPopulationSnapshot(zones)
  local snapshot = {
    regionCount = 0,
    zoneCount = #zones,
    population = { total = 0, residents = 0, workers = 0, visitors = 0 },
    workforce = { available = 0, employed = 0, unemployed = 0 },
    demand = {}
  }
  local weightedDemand = {}
  local totalWeight = 0

  for _, zone in ipairs(zones) do
    for key, value in pairs(zone.population) do
      snapshot.population[key] = snapshot.population[key] + value
    end
    for key, value in pairs(zone.workforce) do
      snapshot.workforce[key] = snapshot.workforce[key] + value
    end
    local weight = zone.population.total
    totalWeight = totalWeight + weight
    for key, value in pairs(zone.demand) do
      weightedDemand[key] = (weightedDemand[key] or 0) + value * weight
    end
  end

  for key in pairs(MZPopulationConfig.DemandDimensions or {}) do
    snapshot.demand[key] = totalWeight > 0 and weightedDemand[key] / totalWeight or 0.0
  end
  return snapshot
end

function MZPopulationState.Bootstrap(regions, zones)
  local valid, validationError = MZPopulationValidation.ValidateDataset(regions, zones)
  if not valid then
    MZPopulationState.initializationError = validationError
    return false, validationError
  end

  local canonicalRegions = MZPopulationUtil.DeepCopy(regions)
  local canonicalZones = MZPopulationUtil.DeepCopy(zones)
  local regionsById, zonesById = {}, {}

  for _, region in ipairs(canonicalRegions) do
    region.zoneIds = {}
    regionsById[region.id] = region
  end
  for _, zone in ipairs(canonicalZones) do
    zonesById[zone.id] = zone
    local region = regionsById[zone.region]
    region.zoneIds[#region.zoneIds + 1] = zone.id
  end

  local populationSnapshot = buildPopulationSnapshot(canonicalZones)
  populationSnapshot.regionCount = #canonicalRegions

  -- Commit unico: nenhum consumer observa bootstrap parcialmente construido.
  MZPopulationState.regions = canonicalRegions
  MZPopulationState.regionsById = regionsById
  MZPopulationState.zones = canonicalZones
  MZPopulationState.zonesById = zonesById
  MZPopulationState.populationSnapshot = populationSnapshot
  MZPopulationState.revision = (tonumber(MZPopulationState.revision) or 0) + 1
  MZPopulationState.initializationError = nil
  MZPopulationState.ready = true

  return true, {
    regionCount = #canonicalRegions,
    zoneCount = #canonicalZones,
    revision = MZPopulationState.revision
  }
end

function MZPopulationState.GetZoneInternal(zoneId)
  return MZPopulationState.zonesById[zoneId]
end

function MZPopulationState.GetRegionInternal(regionId)
  return MZPopulationState.regionsById[regionId]
end
