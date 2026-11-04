MZPopulationUtil = MZPopulationUtil or {}

function MZPopulationUtil.DeepCopy(value, seen)
  if type(value) ~= 'table' then return value end

  seen = seen or {}
  if seen[value] then return seen[value] end

  local copy = {}
  seen[value] = copy
  for key, child in pairs(value) do
    copy[MZPopulationUtil.DeepCopy(key, seen)] = MZPopulationUtil.DeepCopy(child, seen)
  end
  return copy
end

function MZPopulationUtil.Trim(value)
  return tostring(value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

function MZPopulationUtil.IsFiniteNumber(value)
  return type(value) == 'number'
    and value == value
    and value ~= math.huge
    and value ~= -math.huge
end

function MZPopulationUtil.IsNonNegativeInteger(value)
  return MZPopulationUtil.IsFiniteNumber(value)
    and value >= 0
    and value == math.floor(value)
end
