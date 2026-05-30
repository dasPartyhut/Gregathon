-- Componets
local component = require('component')
local sides = require('sides')
local term = require('term')
local rsCapacitor = component.proxy(component.get("d7be4779"))
local rsBerthas = component.proxy(component.get("31360f7e"))
local rs Hughmungus = component.proxy(component.get("eceb460c"))

-- Takt Zyklus und Zeit-Konstanten
local WAITTIME = 60 --takt-zyklus 1min
local N = 60/WAITTIME*60*24*7 	--Takt Zyklen in einer Woche
local N1 = 60/WAITTIME*60*24	--Takt Zyklen an einem Tag

-- Redstone Schwellwerte
local berthasThresholdOn = 4
local berthasThresholdOff = 10
local hughmungusThresholdOn = 3
local hughmungusThresholdOff = 13

berthasOn = 0
berthasOnOld = 0
berthasRedstoneStrength = 0
hughmungusOn = 0
hughmungusOnOld = 0
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

for i = 0, (N-1) do
	--Array Initialisierungen
	berthasOnCyclesWeek[i] = 0
	hughmungusOnCyclesWeek[i] = 0
end

while nCycles <= 10 do
	therm.clear()
	print('Executing Power Management Cycle No. ' .. tostring(nCycles))
	redstoneStrength = rsCapacitor.getInput(sides.up)
	print()
	print('Energy Level: ' .. tostring(redstoneStrength) .. '/15')
	berthasOnAVG = berthasOnCycles / nCycles * 100
	hughmungusOnAVG = hughmungusOnCycles / nCycles * 100
	if redstoneStrength <= berthasThresholdOn then
		berthasOn = 1
		berthasOnCycles = berthasOnCycles + 1
		berthasRedstoneStrength = 255
	elseif redstoneStrength >= berthasThresholdOff then
		berthasOn = 0
		berthasRedstoneStrength = 0
	end
	if redstoneStrength <= hughmungusThresholdOn then
		hughmungusOn = 1
		hughmungusOnCycles = hughmungusOnCycles + 1
		hughmungusRedstoneStrength = 255
	elseif redstoneStrength >= hughmungusThresholdOff then
		hughmungusOn = 0
		hughmungusRedstoneStrength = 0
	end
	berthasOnDay = 0
	hughmungusOnDay = 0
	for i = 0, (N1-1) do
		berthasOnDay = berthasOnDay + berthasOnCyclesWeek[i]
		hughmungusOnDay = hughmungusOnDay + hughmungusOnCyclesWeek[i]
	end
	berthasOnAVGDay = berthasOnDay / N1 * 100
	hughmungusOnAVGDay = hughmungusOnDay / N1 * 100
	berthasOnWeek = 0
	hughmungusOnWeek = 0
	for i = 0, (N-1) do
		berthasOnWeek = berthasOnWeek + berthasOnCyclesWeek[i]
		hughmungusOnWeek = hughmungusOnWeek + hughmungusOnCyclesWeek[i]
	end
	berthasOnAVGWeek = berthasOnWeek / N * 100
	hughmungusOnAVGWeek = hughmungusOnWeek / N * 100	
	
	for i = 0, (N-2) do
		-- z-shift; reversed as to not overwrite entries
		z = N-2 - i
		berthasOnCyclesWeek[z+1] = berthasOnCyclesWeek
		hughmungusOnCyclesWeek[z+1] = hughmungusOnCyclesWeek[z]
	end
	berthasOnCyclesWeek[0] = berthasOn
	hughmungusOnCyclesWeek[0] = hughmungusOn
	
	if berthasOn ~= berthasOnOld then
		if berthasOn == 1 then
			print('Turning on the Berthas')
		else
			print('Turning off the Berthas')
		end
	end
	if hughmungusOn ~= hughmungusOnOld then
		if hughmungusOn == 1 then
			print('Turning on Hughmungus')
		else 
			print('Turning off the Hughmungus')
		end
	end
	rsBerthas.setOutput(sides.left, berthasRedstoneStrength)
	rsHughmungus.setOutput(sides.left, hughmungusRedstoneStrength)
	print()
	if berthasOn == 1 then
		print('Berthas running')
	else
		print('Berthas on standby')
	end
		if hughmungusOn == 1 then
		print('Hughmungus running')
	else
		print('Hughmungus on standby')
	end
	print()
	print'(Berthas running time relative: ' .. tostring(math.floor(berthasOnAVG*100)/100) .. '%')
	print'(Berthas running time AVG Day: ' .. tostring(math.floor(berthasOnAVGDay*100)/100) .. '%')
	print'(Berthas running time AVG Week: ' .. tostring(math.floor(berthasOnAVGWeek*100)/100) .. '%')
	print()
	print'(Hughmungus running time relative: ' .. tostring(math.floor(hughmungusOnAVG*100)/100) .. '%')
	print'(Hughmungus running time AVG Day: ' .. tostring(math.floor(hughmungusOnAVGDay*100)/100) .. '%')
	print'(Hughmungus running time AVG Week: ' .. tostring(math.floor(hughmungusOnAVGWeek*100)/100) .. '%')
	berthasOnOld = berthasOn
	hughmungusOnOld = hughmungusOn
	nCycles = nCycles + 1
	os.sleep(WAITTIME)
end