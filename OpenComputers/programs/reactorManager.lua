local component = require('component')
local sides = require('sides')
local term = require('term')

local rsTank = component.proxy(component.get("30801979"))
local rsController = component.proxy(component.get("9314a798"))
local rsStoredEnergy = component.proxy(component.get("8e5d91a3"))

local WAITTIME = 60 --takt-zyklus 1min

local onThreshold = 7
local offThreshold = 15

ncCycles = 1

runningCycles = 0
runningAVG = 0.0

redstoneIn = 0
reactorEnergy = 0
controllerActive = 0

while 1 do
  term.clear()
  print('Executing Reactor Management Cycle No. ' .. tostring(ncCycles))
  print()
  storedHelium = rsTank.getInput(sides.up)
  reactorEnergy = rsStoredEnergy.getInput(sides.down)

  print('Helium Plasma Stored: ' .. tostring(storedHelium) .. '/15')
  print('Reactor Energy: ' .. tostring(reactorEnergy) .. '/15')

  if storedHelium <= onThreshold then
    if controllerActive == 1 then
      print('Reactor is already running')
      break
    end
    if enoughEnergy == 0 then
      print('Not enough energy to start the reactor! Waiting for next cycle')
      break
    end
    controllerActive = 1
    print('Reactor turned ON')
  elseif storedHelium >= offThreshold then
    if controllerActive == 0 then
      print('Reactor is on standby')
      break
    end
    controllerActive = 0
    print('Reactor turned OFF')
  end

  runningCycles = runningCycles + controllerActive
  runningAVG = 100 * runningCycles / ncCycles

  print()
  print('Fusion Reactor Running Cycles: ' .. tostring(runningCycles))
  print('Fusion Reactor Average Running Time AVG: ' .. tostring(runningAVG) .. '%')
  rsController.setOutput(sides.up, controllerActive*255)
  
  ncCycles = ncCycles + 1
  os.sleep(WAITTIME)
end