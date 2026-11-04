exports('GetZone', function(zoneId)
  return MZPopulationService.GetZone(zoneId)
end)

exports('GetZones', function()
  return MZPopulationService.GetZones()
end)

exports('GetRegion', function(regionId)
  return MZPopulationService.GetRegion(regionId)
end)

exports('GetRegions', function()
  return MZPopulationService.GetRegions()
end)

exports('GetZoneSnapshot', function(zoneId)
  return MZPopulationService.GetZoneSnapshot(zoneId)
end)

exports('GetPopulationSnapshot', function()
  return MZPopulationService.GetPopulationSnapshot()
end)

exports('GetZonePopulation', function(zoneId)
  return MZPopulationService.GetZonePopulation(zoneId)
end)

exports('GetZoneWorkforce', function(zoneId)
  return MZPopulationService.GetZoneWorkforce(zoneId)
end)

exports('GetZoneDemand', function(zoneId)
  return MZPopulationService.GetZoneDemand(zoneId)
end)

exports('ResolveZoneByCoords', function(x, y, z)
  return MZPopulationService.ResolveZoneByCoords(x, y, z)
end)
