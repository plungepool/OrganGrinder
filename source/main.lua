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

local tickIncrement = 360
local numberOfFrames = 16
local frameIndex = 1
local countedTicks = tickIncrement / numberOfFrames

local frame = gfx.image.new("/animation/"..frameIndex..".png")
if frame then
	gfx.clear(gfx.kColorWhite)
	gfx.setColor(gfx.kColorBlack)
	frame:draw(0, 0)
end

function playdate.update()

	local ticks = math.abs(playdate.getCrankTicks(tickIncrement))
	-- print("ticks: "..ticks) -- TODO: Remove print
	if ticks < 1 then
		seq:stop()
	else
		seq.setTempo(seq, ticks * 50)
		seq:play()
	end

	countedTicks -= ticks
	if countedTicks < 0 then
		frameIndex = frameIndex + 1
		if frameIndex > numberOfFrames then
			frameIndex = 1
		end
		frame = gfx.image.new("/animation/"..frameIndex..".png")
		if frame then
			gfx.clear(gfx.kColorWhite)
			gfx.setColor(gfx.kColorBlack)
			frame:draw(0, 0)
		end
		countedTicks = tickIncrement / numberOfFrames
	end
	
end
