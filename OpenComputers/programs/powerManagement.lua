-- Componets
local component = require('component')
local sides = require('sides')
local term = require('term')
local rsCapacitor = component.proxy(component.get("d7be4779"))
local rsBerthas = component.proxy(component.get("31360f7e"))
local rs Hughmungus = component.proxy(component.get("be40fe8f"))

-- Takt Zyklus und Zeit-Konstanten
local WAITTIME = 60 --takt-zyklus 1min
local N = 60/WAITTIME*60*24*7  --Takt Zyklen in einer Woche
local N1 = 60/WAITTIME*60*24   --Takt Zyklen an einem Tag

-- Redstone Schwellwerte
local berthasThresholdOn = 1
local berthasThresholdOff = 4
local hughmungusThresholdOn = 2
local hughmungusThresholdOff = 13

-- Variablen
berthasOn = 0
hughmungusOn = 0
berthasOnOld = 0
hughmungusOnOld = 0
berthasRedstoneStrength = 0
hughmungusRedstoneStrength = 0
redstoneStrength = 0
nCycles = 0
berthasOnCycles = 0
berthasOnCyclesWeek = {}
berthasOnDay = 0
berthasOnWeek = 0
hughmungusOnCycles = 0
hughmungusOnCyclesWeek = {}
hughmungusOnDay = 0
hughmungusOnWeek = 0
berthasOnAVG = 0.0
berthasOnAVGDay = 0.0
berthasOnAVGWeek = 0.0
hughmungusOnAVG = 0.0
hughmungusOnAVGDay = 0.0
hughmungusOnAVGWeek = 0.0

--Array Initialisierungen
--Arrays starten mit Index 0
for i = 0, (N-1) do
  berthasOnCyclesWeek[i] = 0
  hughmungusOnCyclesWeek[i] = 0
end

while nCycles <= 10 do
  term.clear()
  print('Executing Power Management Cycle No. ' .. tostring(nCycles))
  redstoneStrength = rsCapacitor.getInput(sides.up)
  print()
  print('Energy Level: ' .. tostring(redstoneStrength) .. '/15')
  --Einschalten oder Ausschalten?
  if redstoneStrength <= berthasThresholdOn then
    berthasOn = 1
    berthasRedstoneStrength = 255
  elseif redstoneStrength >= berthasThresholdOff then
    berthasOn = 0
    berthasRedstoneStrength = 0
  end
  if redstoneStrength <= hughmungusThresholdOn then
    hughmungusOn = 1
    hughmungusRedstoneStrength = 255
  elseif redstoneStrength >= hughmungusThresholdOff then
  hughmungusOn = 0
  hughmungusRedstoneStrength = 0
  end
  --Berechne Standzeit vom letzten Tag  
  berthasOnDay = 0
  hughmungusOnDay = 0
  for i = 0, (N1-1) do
    berthasOnDay = berthasOnDay + berthasOnCyclesWeek[i]
    hughmungusOnDay = hughmungusOnDay + hughmungusOnCyclesWeek[i]
  end
  berthasOnAVGDay = berthasOnDay / N1 * 100
  hughmungusOnAVGDay = hughmungusOnDay / N1 * 100
  --Berechne Standzeiten
  berthasOnCycles = berthasOnCycles + berthasOn
  hughmungusOnCycles = hughmungusOnCycles + hughmungusOn
  --Berechne mittlere Standzeiten
  -- + 1e-12 verhindert 0/0
  berthasOnAVG = berthasOnCycles / (nCycles + 1e-12) * 100  
  hughmungusOnAVG = hughmungusOnCycles / (nCycles + 1e-12) * 100
  --Berechne Standzeit von der letzten Woche  
  berthasOnWeek = 0
  hughmungusOnWeek = 0
  for i = 0, (N-1) do
    berthasOnWeek = berthasOnWeek + berthasOnCyclesWeek[i]
    hughmungusOnWeek = hughmungusOnWeek + hughmungusOnCyclesWeek[i]
  end
  berthasOnAVGWeek = berthasOnWeek / N * 100
  hughmungusOnAVGWeek = hughmungusOnWeek / N * 100
  -- z-Verschiebung; Index gespiegelt, dass nur die Alten Werte verloren gehen
  for i = 0, (N-2) do
    z = N-2 - i
    berthasOnCyclesWeek[z+1] = berthasOnCyclesWeek
    hughmungusOnCyclesWeek[z+1] = hughmungusOnCyclesWeek[z]
  end
  berthasOnCyclesWeek[0] = berthasOn
  hughmungusOnCyclesWeek[0] = hughmungusOn
  --Status melden
  if berthasOn == 1 then
    if berthasOn ~= berthasOnOld then
      print('Turning on the Berthas')
	end
	print('Berthas running')
  else
    if berthasOn ~= berthasOnOld then
      print('Turning off the Berthas')
    end
	print('Berthas on standby')
  end
  if hughmungusOn == 1 then
    if hughmungusOn ~= hughmungusOnOld then
      print('Turning on Dicker Gustav')
	end
	print('Dicker Gustav running')
  else
    if hughmungusOn ~= hughmungusOnOld then
      print('Turning off Dicker Gustav')
	end
      print('Dicker Gustav on standby')
    end
  end
  --Redstone Werte Setzen
  rsBerthas.setOutput(sides.left, berthasRedstoneStrength)
  rsHughmungus.setOutput(sides.front, hughmungusRedstoneStrength)
  --Statistik Anzeigen
  print()
  print('Berthas running time relative: ' .. tostring(math.floor(berthasOnAVG*100)/100) .. '%')
  print('Berthas running time AVG Day: ' .. tostring(math.floor(berthasOnAVGDay*100)/100) .. '%')
  print('Berthas running time AVG Week: ' .. tostring(math.floor(berthasOnAVGWeek*100)/100) .. '%')
  print()
  print('Dicker Gustav running time relative: ' .. tostring(math.floor(hughmungusOnAVG*100)/100) .. '%')
  print('Dicker Gustav running time AVG Day: ' .. tostring(math.floor(hughmungusOnAVGDay*100)/100) .. '%')
  print('Dicker Gustav running time AVG Week: ' .. tostring(math.floor(hughmungusOnAVGWeek*100)/100) .. '%')
  berthasOnOld = berthasOn
  hughmungusOnOld = hughmungusOn
  nCycles = nCycles + 1
  os.sleep(WAITTIME)
end