local ok, result = MZPopulationState.Bootstrap(
  MZPopulationData and MZPopulationData.Regions,
  MZPopulationData and MZPopulationData.Zones
)

if not ok then
  print(('[mz_population] bootstrap failed: %s'):format(tostring(result)))
  error(('[mz_population] invalid bootstrap dataset: %s'):format(tostring(result)), 0)
end

print(('[mz_population] loaded %s regions'):format(result.regionCount))
print(('[mz_population] loaded %s zones'):format(result.zoneCount))

local simulationStarted, simulationDetail = MZPopulationSimulation.Start()
if simulationStarted then
  print(('[mz_population] simulation enabled tickMs=%s'):format(tostring(simulationDetail)))
else
  print('[mz_population] simulation disabled')
end
