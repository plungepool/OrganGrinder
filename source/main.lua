-- -- Below is a small example program where you can move a circle
-- -- around with the crank. You can delete everything in this file,
-- -- but make sure to add back in a playdate.update function since
-- -- one is required for every Playdate game!
-- -- =============================================================

-- -- Importing libraries used for drawCircleAtPoint and crankIndicator
-- import "CoreLibs/graphics"
-- import "CoreLibs/ui"

-- -- Localizing commonly used globals
-- local pd <const> = playdate
-- local gfx <const> = playdate.graphics

-- -- Defining player variables
-- local playerSize = 10
-- local playerVelocity = 3
-- local playerX, playerY = 200, 120

-- -- Drawing player image
-- local playerImage = gfx.image.new(32, 32)
-- gfx.pushContext(playerImage)
--     -- Draw outline
--     gfx.drawRoundRect(4, 3, 24, 26, 1)
--     -- Draw screen
--     gfx.drawRect(7, 6, 18, 12)
--     -- Draw eyes
--     gfx.drawLine(10, 12, 12, 10)
--     gfx.drawLine(12, 10, 14, 12)
--     gfx.drawLine(17, 12, 19, 10)
--     gfx.drawLine(19, 10, 21, 12)
--     -- Draw crank
--     gfx.drawRect(27, 15, 3, 9)
--     -- Draw A/B buttons
--     gfx.drawCircleInRect(16, 20, 4, 4)
--     gfx.drawCircleInRect(21, 20, 4, 4)
--     -- Draw D-Pad
--     gfx.drawRect(8, 22, 6, 2)
--     gfx.drawRect(10, 20, 2, 6)
-- gfx.popContext()

-- -- Defining helper function
-- local function ring(value, min, max)
-- 	if (min > max) then
-- 		min, max = max, min
-- 	end
-- 	return min + (value - min) % (max - min)
-- end

-- -- playdate.update function is required in every project!
-- function playdate.update()
--     -- Clear screen
--     gfx.clear()
--     -- Draw crank indicator if crank is docked
--     if pd.isCrankDocked() then
--         pd.ui.crankIndicator:draw()
--     else
--         -- Calculate velocity from crank angle 
--         local crankPosition = pd.getCrankPosition() - 90
--         local xVelocity = math.cos(math.rad(crankPosition)) * playerVelocity
--         local yVelocity = math.sin(math.rad(crankPosition)) * playerVelocity
--         -- Move player
--         playerX += xVelocity
--         playerY += yVelocity
--         -- Loop player position
--         playerX = ring(playerX, -playerSize, 400 + playerSize)
--         playerY = ring(playerY, -playerSize, 240 + playerSize)
--     end
--     -- Draw text
--     gfx.drawTextAligned("Template configured!", 200, 30, kTextAlignment.center)
--     -- Draw player
--     playerImage:drawAnchored(playerX, playerY, 0.5, 0.5)
-- end

local snd = playdate.sound
local gfx = playdate.graphics
import "CoreLibs/crank"

seq = snd.sequence.new('giveyouup.mid')

local synth = snd.synth.new(snd.kWaveSawtooth)
synth:setVolume(0.2)
synth:setAttack(0)
synth:setDecay(0.15)
synth:setSustain(0.2)
synth:setRelease(0)

function drumsynth(path, code)
	local sample = snd.sample.new(path)
	local s = snd.synth.new(sample)
	s:setVolume(0.5)
	return s
end

function newinst(n)
	local inst = snd.instrument.new()
	for i=1,n do
		inst:addVoice(synth:copy())
	end
	return inst
end

function druminst()
	local inst = snd.instrument.new()
	inst:addVoice(drumsynth("drums/kick"), 35)
	inst:addVoice(drumsynth("drums/kick"), 36)
	inst:addVoice(drumsynth("drums/snare"), 38)
	inst:addVoice(drumsynth("drums/clap"), 39)
	inst:addVoice(drumsynth("drums/tom-low"), 41)
	inst:addVoice(drumsynth("drums/tom-low"), 43)
	inst:addVoice(drumsynth("drums/tom-mid"), 45)
	inst:addVoice(drumsynth("drums/tom-mid"), 47)
	inst:addVoice(drumsynth("drums/tom-hi"), 48)
	inst:addVoice(drumsynth("drums/tom-hi"), 50)
	inst:addVoice(drumsynth("drums/hh-closed"), 42)
	inst:addVoice(drumsynth("drums/hh-closed"), 44)
	inst:addVoice(drumsynth("drums/hh-open"), 46)
	inst:addVoice(drumsynth("drums/cymbal-crash"), 49)
	inst:addVoice(drumsynth("drums/cymbal-ride"), 51)
	inst:addVoice(drumsynth("drums/cowbell"), 56)
	inst:addVoice(drumsynth("drums/clav"), 75)
	return inst
end

local ntracks = seq:getTrackCount()
local active = {}
local poly = 0
local tracks = {}

for i=1,ntracks do
	local track = seq:getTrackAtIndex(i)
	if track ~= nil then
		local n = track:getPolyphony(i)
		if n > 0 then active[#active+1] = i end
		if n > poly then poly = n end
		print("track "..i.." has polyphony "..n)
	
		if i == 10 then
			track:setInstrument(druminst(n))
		else
			track:setInstrument(newinst(n))
		end
	end
end

-- seq:play()

function playdate.update()
	gfx.clear(gfx.kColorWhite)
	gfx.setColor(gfx.kColorBlack)

	local ticks = math.abs(playdate.getCrankTicks(360))
	print("ticks: "..ticks) -- TODO: Remove print
	if ticks < 1 then
		seq:stop()
	else
		seq.setTempo(seq, ticks * 50)
		seq:play()
	end
	
	for i=1,#active do
		local track = seq:getTrackAtIndex(i)
		local n = track:getNotesActive(active[i])
		gfx.fillRect(400*(i-1)/#active, 240*(1-n/poly), 400/#active, 240)
	end
	
end
