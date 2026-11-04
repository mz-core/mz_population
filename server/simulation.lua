MZPopulationSimulation = MZPopulationSimulation or {}

function MZPopulationSimulation.Tick()
  -- MVP 1: clock neutro; nenhuma mutacao populacional e executada.
  return true
end

function MZPopulationSimulation.Start()
  local config = MZPopulationConfig and MZPopulationConfig.Simulation or {}
  if config.Enabled ~= true then return false, 'simulation_disabled' end

  local tickMs = math.max(1000, math.floor(tonumber(config.TickMs) or 60000))
  CreateThread(function()
    while MZPopulationState.ready == true do
      Wait(tickMs)
      MZPopulationSimulation.Tick()
    end
  end)
  return true, tickMs
end
