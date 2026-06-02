local component = require('component')
local sides = require('sides')
local term = require('term')

local rsTank = component.proxy(component.get("30801979"))
local rsController = component.proxy(component.get("9314a798"))
local rsStoredEnergy = component.proxy(component.get("8e5d91a3"))

local WAITTIME = 60 --takt-zyklus 1min
local N = 60/WAITTIME*60*24*7  --Takt Zyklen in einer Woche
local N1 = 60/WAITTIME*60*24   --Takt Zyklen an einem Tag

local onThreshold = 7
local offThreshold = 15

ncCycles = 1

runningCycles = 0
runningCyclesDay = 0
runningCyclesWeek = 0
runningCyclesWeek_arr = {}
runningAVG = 0.0
runningAVGDay = 0.0
runningAVGWeek = 0.0

redstoneIn = 0
reactorEnergy = 0
controllerActive = 0

--Array Initialisierungen
--Arrays starten mit Index 0
for i = 0, (N-1) do
  runningCyclesWeek_arr[i] = 0
end

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
 --Bewegtes Fenster
  --Wirf letztes Element raus und schiebe alles um 1
  for i = 0, (N-2) do
    z = N-2 - i
    runningCyclesWeek_arr[z+1] = runningCyclesWeek_arr[z]
  end
  runningCyclesWeek_arr[0] = controllerActive  
  runningCyclesDay = 0
  runnignCyclesWeek = 0
  for i = 0, (N-1) do
    runningCyclesWeek = runningCyclesWeek + runningCyclesWeek_arr[i]
	if i < N1 then
      runningCyclesDay = runningCyclesDay + runningCyclesWeek_arr[i]
    if i == (nCycles-1) then break end
  end

  weekDiv = N
  dayDiv = N1
  if nCycles < N1 then
    dayDiv = nCycles  
  end
  if nCycles < N then
    weekDiv = nCycles
  end
  
  runningCycles = runningCycles + controllerActive
  runningAVG = 100 * runningCycles / ncCycles
  runningAVGDay = runningCyclesDay / dayDiv
  runningAVGWeek = runnignCyclesWeek / weekDiv

  print()
  print('Fusion Reactor Running Cycles: ' .. tostring(runningCycles))
  print('Fusion Reactor Average Running Time: ' .. tostring(runningAVG) .. '%')
  print('Fusion Reactor Average Running Time this day: ' .. tostring(runningAVGDay) .. '%')
  print('Fusion Reactor Average Running Time last week: ' .. tostring(runningAVGWeek) .. '%')
  rsController.setOutput(sides.up, controllerActive*255)
  
  ncCycles = ncCycles + 1
  os.sleep(WAITTIME)
end