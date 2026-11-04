MZPopulationValidation = MZPopulationValidation or {}

local function validateArray(value, label)
  if type(value) ~= 'table' then return false, label .. '_must_be_array' end

  local count, maximum = 0, 0
  for key in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key ~= math.floor(key) then
      return false, label .. '_must_be_array'
    end
    count = count + 1
    if key > maximum then maximum = key end
  end

  if count == 0 then return false, label .. '_must_not_be_empty' end
  if count ~= maximum then return false, label .. '_must_not_be_sparse' end
  return true
end

local function validId(value)
  return type(value) == 'string'
    and value:match('^[a-z][a-z0-9_]*$') ~= nil
    and #value <= 64
end

local function validName(value)
  return type(value) == 'string'
    and MZPopulationUtil.Trim(value) ~= ''
    and #value <= 128
end

local function zoneError(zoneId, field, reason)
  return ('zone[%s].%s_%s'):format(tostring(zoneId or 'unknown'), field, reason)
end

local function validatePopulation(zoneId, population)
  if type(population) ~= 'table' then
    return false, zoneError(zoneId, 'population', 'must_be_table')
  end

  for _, field in ipairs({ 'total', 'residents', 'workers', 'visitors' }) do
    if not MZPopulationUtil.IsNonNegativeInteger(population[field]) then
      return false, zoneError(zoneId, 'population.' .. field, 'must_be_non_negative_integer')
    end
  end

  if population.total ~= population.residents + population.workers + population.visitors then
    return false, zoneError(zoneId, 'population.total', 'must_equal_components')
  end
  return true
end

local function validateWorkforce(zoneId, workforce, population)
  if type(workforce) ~= 'table' then
    return false, zoneError(zoneId, 'workforce', 'must_be_table')
  end

  for _, field in ipairs({ 'available', 'employed', 'unemployed' }) do
    if not MZPopulationUtil.IsNonNegativeInteger(workforce[field]) then
      return false, zoneError(zoneId, 'workforce.' .. field, 'must_be_non_negative_integer')
    end
  end

  if workforce.available ~= workforce.employed + workforce.unemployed then
    return false, zoneError(zoneId, 'workforce.available', 'must_equal_employed_plus_unemployed')
  end
  if workforce.available > population.residents then
    return false, zoneError(zoneId, 'workforce.available', 'must_not_exceed_residents')
  end
  return true
end

local function validateDemand(zoneId, demand)
  if type(demand) ~= 'table' then
    return false, zoneError(zoneId, 'demand', 'must_be_table')
  end

  local dimensions = MZPopulationConfig and MZPopulationConfig.DemandDimensions or {}
  for key in pairs(demand) do
    if dimensions[key] ~= true then
      return false, zoneError(zoneId, 'demand.' .. tostring(key), 'unknown_dimension')
    end
  end

  for key, enabled in pairs(dimensions) do
    if enabled == true then
      local value = demand[key]
      if not MZPopulationUtil.IsFiniteNumber(value) or value < 0.0 or value > 1.0 then
        return false, zoneError(zoneId, 'demand.' .. key, 'must_be_between_0_and_1')
      end
    end
  end
  return true
end

function MZPopulationValidation.ValidateDataset(regions, zones)
  local regionsOk, regionsErr = validateArray(regions, 'regions')
  if not regionsOk then return false, regionsErr end
  local zonesOk, zonesErr = validateArray(zones, 'zones')
  if not zonesOk then return false, zonesErr end

  local regionIds = {}
  for index, region in ipairs(regions) do
    if type(region) ~= 'table' then
      return false, ('region[%s]_must_be_table'):format(index)
    end
    if not validId(region.id) then
      return false, ('region[%s].id_invalid'):format(tostring(region.id or index))
    end
    if regionIds[region.id] then
      return false, ('region[%s].id_duplicate'):format(region.id)
    end
    if not validName(region.name) then
      return false, ('region[%s].name_invalid'):format(region.id)
    end
    regionIds[region.id] = true
  end

  local zoneIds = {}
  local zoneTypes = MZPopulationConfig and MZPopulationConfig.ZoneTypes or {}
  for index, zone in ipairs(zones) do
    if type(zone) ~= 'table' then
      return false, ('zone[%s]_must_be_table'):format(index)
    end
    local zoneId = zone.id or index
    if not validId(zone.id) then return false, zoneError(zoneId, 'id', 'invalid') end
    if zoneIds[zone.id] then return false, zoneError(zone.id, 'id', 'duplicate') end
    if not validName(zone.name) then return false, zoneError(zone.id, 'name', 'invalid') end
    if not validId(zone.region) or not regionIds[zone.region] then
      return false, zoneError(zone.id, 'region', 'unknown')
    end
    if type(zone.center) ~= 'table' then
      return false, zoneError(zone.id, 'center', 'must_be_table')
    end
    for _, axis in ipairs({ 'x', 'y', 'z' }) do
      if not MZPopulationUtil.IsFiniteNumber(zone.center[axis]) then
        return false, zoneError(zone.id, 'center.' .. axis, 'must_be_finite_number')
      end
    end
    if not MZPopulationUtil.IsFiniteNumber(zone.radius) or zone.radius <= 0 then
      return false, zoneError(zone.id, 'radius', 'must_be_greater_than_zero')
    end
    if zone.priority ~= nil and (not MZPopulationUtil.IsFiniteNumber(zone.priority)
        or zone.priority ~= math.floor(zone.priority)) then
      return false, zoneError(zone.id, 'priority', 'must_be_integer')
    end
    if type(zone.type) ~= 'string' or zoneTypes[zone.type] ~= true then
      return false, zoneError(zone.id, 'type', 'unknown')
    end
    if not MZPopulationUtil.IsFiniteNumber(zone.density)
        or zone.density < 0.0 or zone.density > 1.0 then
      return false, zoneError(zone.id, 'density', 'must_be_between_0_and_1')
    end

    local populationOk, populationErr = validatePopulation(zone.id, zone.population)
    if not populationOk then return false, populationErr end
    local workforceOk, workforceErr = validateWorkforce(zone.id, zone.workforce, zone.population)
    if not workforceOk then return false, workforceErr end
    local demandOk, demandErr = validateDemand(zone.id, zone.demand)
    if not demandOk then return false, demandErr end

    zoneIds[zone.id] = true
  end

  return true
end
