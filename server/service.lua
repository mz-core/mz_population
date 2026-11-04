MZPopulationService = MZPopulationService or {}

local function success(data)
  return { ok = true, data = data }
end

local function failure(errorCode)
  return { ok = false, error = errorCode }
end

local function ready()
  if MZPopulationState and MZPopulationState.ready == true then return true end
  return false, failure('population_not_ready')
end

local function normalizedId(value, errorCode)
  if type(value) ~= 'string' then return nil, failure(errorCode) end
  value = MZPopulationUtil.Trim(value)
  if value == '' then return nil, failure(errorCode) end
  return value
end

function MZPopulationService.GetZone(zoneId)
  local isReady, readyError = ready()
  if not isReady then return readyError end
  local normalized, idError = normalizedId(zoneId, 'invalid_zone_id')
  if not normalized then return idError end
  local zone = MZPopulationState.GetZoneInternal(normalized)
  if not zone then return failure('zone_not_found') end
  return success(MZPopulationUtil.DeepCopy(zone))
end

function MZPopulationService.GetZoneSnapshot(zoneId)
  return MZPopulationService.GetZone(zoneId)
end

function MZPopulationService.GetZones()
  local isReady, readyError = ready()
  if not isReady then return readyError end
  return success(MZPopulationUtil.DeepCopy(MZPopulationState.zones))
end

function MZPopulationService.GetRegion(regionId)
  local isReady, readyError = ready()
  if not isReady then return readyError end
  local normalized, idError = normalizedId(regionId, 'invalid_region_id')
  if not normalized then return idError end
  local region = MZPopulationState.GetRegionInternal(normalized)
  if not region then return failure('region_not_found') end
  return success(MZPopulationUtil.DeepCopy(region))
end

function MZPopulationService.GetRegions()
  local isReady, readyError = ready()
  if not isReady then return readyError end
  return success(MZPopulationUtil.DeepCopy(MZPopulationState.regions))
end

function MZPopulationService.GetPopulationSnapshot()
  local isReady, readyError = ready()
  if not isReady then return readyError end
  return success(MZPopulationUtil.DeepCopy(MZPopulationState.populationSnapshot))
end

local function getZoneField(zoneId, field)
  local isReady, readyError = ready()
  if not isReady then return readyError end
  local normalized, idError = normalizedId(zoneId, 'invalid_zone_id')
  if not normalized then return idError end
  local zone = MZPopulationState.GetZoneInternal(normalized)
  if not zone then return failure('zone_not_found') end
  return success(MZPopulationUtil.DeepCopy(zone[field]))
end

function MZPopulationService.GetZonePopulation(zoneId)
  return getZoneField(zoneId, 'population')
end

function MZPopulationService.GetZoneWorkforce(zoneId)
  return getZoneField(zoneId, 'workforce')
end

function MZPopulationService.GetZoneDemand(zoneId)
  return getZoneField(zoneId, 'demand')
end

function MZPopulationService.ResolveZoneByCoords(x, y, z)
  local isReady, readyError = ready()
  if not isReady then return readyError end
  if not MZPopulationUtil.IsFiniteNumber(x)
      or not MZPopulationUtil.IsFiniteNumber(y)
      or not MZPopulationUtil.IsFiniteNumber(z) then
    return failure('invalid_coordinates')
  end

  local bestZone, bestDistanceSquared, bestPriority
  for _, zone in ipairs(MZPopulationState.zones) do
    local dx, dy = x - zone.center.x, y - zone.center.y
    local distanceSquared = dx * dx + dy * dy
    if distanceSquared <= zone.radius * zone.radius then
      local priority = tonumber(zone.priority) or 0
      local replaces = not bestZone
        or priority > bestPriority
        or (priority == bestPriority and distanceSquared < bestDistanceSquared)
        or (priority == bestPriority and distanceSquared == bestDistanceSquared and zone.id < bestZone.id)
      if replaces then
        bestZone, bestDistanceSquared, bestPriority = zone, distanceSquared, priority
      end
    end
  end

  if not bestZone then return failure('no_zone_found') end
  local snapshot = MZPopulationUtil.DeepCopy(bestZone)
  snapshot.resolution = {
    method = 'radius_2d',
    distance = math.sqrt(bestDistanceSquared)
  }
  return success(snapshot)
end
