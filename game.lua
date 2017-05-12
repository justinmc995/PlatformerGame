-----------------------------------------------------------------------------------------
--
-- game.lua
--
-----------------------------------------------------------------------------------------

--[[ TODO:
	Add more level pieces
	Add running and jumping animations for the player
	Fix jumping bugs?
]]

-- Shortcut variables
local Cx = display.contentCenterX
local Cy = display.contentCenterY
local H = Cy * 2
local W = Cx * 2
local unitwidth = W/3

local composer = require( "composer" )



-- Game Constants
local jumpHeight = 500
local walkSpeed = 5
local leftpatterns = 9
local midpatterns = 9
local rightpatterns = 9
local numcolors = 12
local grav = 20



-- Working Variables
local gameActive = true
local playerHasJump = true
local playerInContact = true
local xmovement = 0
isDead = false
isShielded = false
canTeleport = false
needTeleport = false
Tx = 0
Ty = 0
playerfacing = "left"
isJumping = false
leveldeaths = 0
shieldcounter = 8
keys = 0
needlivechange = 0
gamecounter = 0
lives = 0
score = 0


-- Startup

local scene = composer.newScene()

local physics = require("physics")
system.activate("multitouch")

local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

-- create()
function scene:create( event )
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if (event.params.prevscene == 1) then
	composer.removeScene( "menu" )
elseif (event.params.prevscene == 2) then
	composer.removeScene( "complete" )
end

lives = event.params.lastlives
score = event.params.lastscore



physics.start()
physics.setContinuous( enabled )
physics.setGravity(0, grav)
--physics.setDrawMode("hybrid")

-- Create Player and Start Platform
local colorrand = math.random(numcolors)
--colorrand = 12

if (colorrand == 1) then
	color = {0.4,0.4,0.4} --grey
elseif (colorrand == 2) then
	color = {0.5,0,0} --red
elseif (colorrand == 3) then
	color = {0,0,0.5} --blue
elseif (colorrand == 4) then
	color = {0,0.5,0} --green
elseif (colorrand == 5) then
	color = {0.5,0.2,0} --orange
elseif (colorrand == 6) then
	color = {0.25,0,0.25} --purple
elseif (colorrand == 7) then
	color = {0.5,0.5,0} --yellow
elseif (colorrand == 8) then
	color = {0,0,0} --black
elseif (colorrand == 9) then
	color = {0.85,0.85,0.85} --white
elseif (colorrand == 10) then
	color = {0.4,0,0.2} --magenta
elseif (colorrand == 11) then
	color = {0,0.4,0.25} --teal
elseif (colorrand == 12) then
	color = {0.27,0.13,0.04} --brown
end

local startplatform = display.newRect(mainGroup, Cx, H-25, unitwidth, 50)
startplatform:setFillColor(color[1],color[2],color[3])
startplatform.type = "platform"

local door = display.newImage(mainGroup, "door.png")
door.x = Cx
door.y = H-100
physics.addBody(door, "static", {isSensor = true})
door.type = "door"

local playerSheetData = {width = 96, height = 96, numFrames = 16}
local playerSheet = graphics.newImageSheet("captainplatform.png", playerSheetData)

local uglySheetData = {width = 96, height = 96, numFrames = 2}
local uglySheet = graphics.newImageSheet("ugly.png", uglySheetData)

local playerSequences =
{
	{
		name="idleLeft",
		frames = {1,2,3,4},
		time = 1750,
		loopCount = 0
	},
	{
		name="idleRight",
		frames = {5,6,7,8},
		time = 1750,
		loopCount = 0
	},
	{
		name="jumpLeft",
		frames = {9,10},
		time = 800,
		loopCount = 0
	},
	{
		name="jumpRight",
		frames = {11,12},
		time = 800,
		loopCount = 0
	},
	{
		name="walkLeft",
		frames = {13,14},
		time = 400,
		loopCount = 0
	},
	{
		name="walkRight",
		frames = {15,16},
		time = 400,
		loopCount = 0
	}
}

local uglySequences =
{
	{
		name="move",
		frames = {1,2},
		time = 600,
		loopCount = 0
	}
}

lasercolor1 = {1,0,0}
lasercolor2 = {1,0.85,0.85}
barriercolor1 = {0,1,0}
barriercolor2 = {0.85,1,0.85}

local player = display.newSprite(mainGroup, playerSheet, playerSequences)
player.x = Cx
player.y = H-100
player:play()
player.type = "player"
player.isSleepingAllowed = false

local jumpsfx = audio.loadSound("Jump_03.wav")
local collectsfx = audio.loadSound("Collect_Point_01.wav")
local completesfx = audio.loadSound("Pickup_04.wav")
local deathsfx = audio.loadSound("sfx_sounds_negative1.wav")
local gainlifesfx = audio.loadSound("sfx_sounds_powerup2.wav")
local gainshieldsfx = audio.loadSound("sfx_sounds_powerup4.wav")
local gainteleportsfx = audio.loadSound("sfx_sounds_powerup6.wav")
local firesfx = audio.loadSound("sfx_wpn_laser3.wav")
local lasersfx = audio.loadSound("sfx_wpn_laser7.wav")
local barriersfx = audio.loadSound("sfx_movement_portal3.wav")

physics.addBody(startplatform, "static", {bounce = 0.0})
physics.addBody(player, "dynamic", {bounce = 0.0, box = {halfWidth = 36, halfHeight = 48}}, {box = {halfWidth = 18, halfHeight = 5, x = 0, y = 50, angle = 0}, isSensor = true})
player.isFixedRotation = true

local lkey = display.newImage(mainGroup, "key.png")
local rkey = display.newImage(mainGroup, "key.png")
lkey.isActive = true
rkey.isActive = true
lkey.type = "key"
rkey.type = "key"
physics.addBody(lkey, "static", {isSensor = true})
physics.addBody(rkey, "static", {isSensor = true})



-- Generation Functions
local function leftPattern1() 
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth, H-25, unitwidth/2, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-200, unitwidth/2, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-375, unitwidth/2, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-525, unitwidth/2, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	lplatform2.type = "platform"
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	
	local lugly = display.newSprite(mainGroup, uglySheet, uglySequences)
	lugly.x = Cx-unitwidth*1.25-unitwidth/6
	lugly.y = H-275
	physics.addBody(lugly, "static", {bounce = 0.0, box = {halfWidth = 40, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lugly.isFixedRotation = true
	lugly:play()
	lugly.type = "monster"
	lugly.startpoint = Cx-unitwidth*1.25-unitwidth/6
	lugly.endpoint = Cx-unitwidth*1.25+unitwidth/4
	lugly.movetime = 14
	lugly.timedelay = 6
	
	lkey.x = Cx-unitwidth*1.25
	lkey.y = H-600
end

local function leftPattern2()
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth*0.67, H-175, unitwidth/3, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth, H-325, unitwidth/2, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*1.33, H-475, unitwidth/2, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*0.67, H-625, unitwidth/3, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	lplatform2.type = "platform"
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	
	local lugly = display.newSprite(mainGroup, uglySheet, uglySequences)
	lugly.x = Cx-unitwidth-unitwidth/4
	lugly.y = H-400
	physics.addBody(lugly, "static", {bounce = 0.0, box = {halfWidth = 40, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lugly.isFixedRotation = true
	lugly:play()
	lugly.type = "monster"
	lugly.startpoint = Cx-unitwidth-unitwidth/4
	lugly.endpoint = Cx-unitwidth+unitwidth/4
	lugly.movetime = 16
	lugly.timedelay = 8
	
	lkey.x = Cx-unitwidth*0.67
	lkey.y = H-700
end

local function leftPattern3()
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth, H*0.67, 50, H*0.67)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth, H-150, unitwidth/2, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth+150, H-300, unitwidth/6, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth-150, H-300, unitwidth/6, 50)
	local lplatform5 = display.newRect(mainGroup, Cx-unitwidth-150, H-25, unitwidth/6, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])
	lplatform5:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	physics.addBody(lplatform5, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	
	lplatform2.type = "disappearing"
	lplatform2.timedelay = 30
	lplatform2.visibletime = 20
	lplatform2.transitiontime = 10
	lplatform2.invisibletime = 20
	lplatform2.totaltime = lplatform2.visibletime + 2*lplatform2.transitiontime + lplatform2.invisibletime
	
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	lplatform5.type = "platform"
	
	lkey.x = Cx-unitwidth-150
	lkey.y = H-100
end

local function leftPattern4()
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-25, unitwidth/2, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.25, (H+100)/2, unitwidth/2, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth/2-50, Cy/2, 100, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	
	lplatform1.type = "moving"
	lplatform1.movetype = "vertical"
	lplatform1.startpoint = H-25
	lplatform1.endpoint = (H+100)/2
	lplatform1.movetime = 16
	lplatform1.timedelay = 0
	
	lplatform2.type = "moving"
	lplatform2.movetype = "vertical"
	lplatform2.startpoint = (H+100)/2
	lplatform2.endpoint = 125
	lplatform2.movetime = 16
	lplatform2.timedelay = 8
	
	local lsentry1 = display.newImage(mainGroup, "sentryL.png")
	lsentry1:setFillColor(0,1,0.15)
	lsentry1.x = Cx-unitwidth/2-50
	lsentry1.y = Cy/2-75
	physics.addBody(lsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry1.type = "homing"
	lsentry1.facing = "left"
	lsentry1.firerate = 30
	lsentry1.firedelay = 0
	
	lkey.x = Cx-unitwidth-150
	lkey.y = 50
end

local function leftPattern5()
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-175, unitwidth/3, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-325, unitwidth/3, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-475, unitwidth/3, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-625, unitwidth/3, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	
	lplatform1.type = "moving"
	lplatform1.movetype = "horizontal"
	lplatform1.startpoint = Cx-unitwidth*1.25
	lplatform1.endpoint = Cx-unitwidth*0.75
	lplatform1.movetime = 16
	lplatform1.timedelay = 12
	
	lplatform2.type = "moving"
	lplatform2.movetype = "horizontal"
	lplatform2.startpoint = Cx-unitwidth*1.25
	lplatform2.endpoint = Cx-unitwidth*0.75
	lplatform2.movetime = 16
	lplatform2.timedelay = 4
	
	lplatform3.type = "moving"
	lplatform3.movetype = "horizontal"
	lplatform3.startpoint = Cx-unitwidth*1.25
	lplatform3.endpoint = Cx-unitwidth*0.75
	lplatform3.movetime = 16
	lplatform3.timedelay = 8
	
	lplatform4.type = "moving"
	lplatform4.movetype = "horizontal"
	lplatform4.startpoint = Cx-unitwidth*1.25
	lplatform4.endpoint = Cx-unitwidth*0.75
	lplatform4.movetime = 16
	lplatform4.timedelay = 0
	
	lkey.x = Cx-unitwidth
	lkey.y = H-700
end

local function leftPattern6() 
	local lplatform1 = display.newRect(mainGroup, 25, Cy, 50, H)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.3, H-25, unitwidth/4, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*1.3, 3*Cy/2-25, unitwidth/4, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*1.3, Cy-25, unitwidth/4, 50)
	local lplatform5 = display.newRect(mainGroup, Cx-unitwidth*1.3, Cy/2-25, unitwidth/4, 50)
	local lplatform6 = display.newRect(mainGroup, Cx-unitwidth, H-25, unitwidth/4, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])
	lplatform5:setFillColor(color[1],color[2],color[3])
	lplatform6:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	physics.addBody(lplatform5, "static", {bounce = 0.0})
	physics.addBody(lplatform6, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	lplatform2.type = "platform"
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	lplatform5.type = "platform"
	
	lplatform6.type = "moving"
	lplatform6.movetype = "vertical"
	lplatform6.startpoint = H-25
	lplatform6.endpoint = Cy/2-25
	lplatform6.movetime = 16
	lplatform6.timedelay = 0
	
	if ( math.random(100) > score ) then
		local lheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
		lheart.x = Cx-unitwidth
		lheart.y = Cy/2-75
		physics.addBody(lheart, "static", {isSensor = true})
		lheart.type = "heart"
		lheart.isActive = true
	end
	
	local lsentry1 = display.newImage(mainGroup, "sentryR.png")
	lsentry1.x = Cx-unitwidth*1.3
	lsentry1.y = H-100
	physics.addBody(lsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry1.type = "sentry"
	lsentry1.facing = "right"
	lsentry1.firerate = 40
	lsentry1.firedelay = 0
	
	local lsentry2 = display.newImage(mainGroup, "sentryR.png")
	lsentry2.x = Cx-unitwidth*1.3
	lsentry2.y = 3*Cy/2-100
	physics.addBody(lsentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry2.type = "sentry"
	lsentry2.facing = "right"
	lsentry2.firerate = 40
	lsentry2.firedelay = 10
	
	local lsentry3 = display.newImage(mainGroup, "sentryR.png")
	lsentry3.x = Cx-unitwidth*1.3
	lsentry3.y = Cy-100
	physics.addBody(lsentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry3.type = "sentry"
	lsentry3.facing = "right"
	lsentry3.firerate = 40
	lsentry3.firedelay = 20
	
	local lsentry4 = display.newImage(mainGroup, "sentryR.png")
	lsentry4.x = Cx-unitwidth*1.3
	lsentry4.y = Cy/2-100
	physics.addBody(lsentry4, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry4.type = "sentry"
	lsentry4.facing = "right"
	lsentry4.firerate = 40
	lsentry4.firedelay = 30
	
	lkey.x = Cx-unitwidth
	lkey.y = Cy-100
end

local function leftPattern7() 
	local lplatform1 = display.newRect(mainGroup, 25, Cy, 50, H)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.3, H-25, unitwidth/4, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*1.3, 3*Cy/2-25, unitwidth/4, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*1.3, Cy-25, unitwidth/4, 50)
	local lplatform5 = display.newRect(mainGroup, Cx-unitwidth*1.3, Cy/2-25, unitwidth/4, 50)
	local lplatform6 = display.newRect(mainGroup, Cx-unitwidth+25, H-25, unitwidth/4, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])
	lplatform5:setFillColor(color[1],color[2],color[3])
	lplatform6:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	physics.addBody(lplatform5, "static", {bounce = 0.0})
	physics.addBody(lplatform6, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	lplatform2.type = "platform"
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	lplatform5.type = "platform"
	
	lplatform6.type = "moving"
	lplatform6.movetype = "vertical"
	lplatform6.startpoint = H-25
	lplatform6.endpoint = Cy/2-25
	lplatform6.movetime = 16
	lplatform6.timedelay = 0
	
	if ( math.random(100) > score ) then
		local lheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
		lheart.x = Cx-unitwidth+25
		lheart.y = Cy/2-75
		physics.addBody(lheart, "static", {isSensor = true})
		lheart.type = "heart"
		lheart.isActive = true
	end
	
	local lsentry1 = display.newImage(mainGroup, "sentryR.png")
	lsentry1.x = Cx-unitwidth*1.3
	lsentry1.y = H-100
	physics.addBody(lsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry1.type = "sentry"
	lsentry1.facing = "right"
	lsentry1.firerate = 20
	lsentry1.firedelay = 0
	
	local lsentry2 = display.newImage(mainGroup, "sentryR.png")
	lsentry2.x = Cx-unitwidth*1.3
	lsentry2.y = 3*Cy/2-100
	physics.addBody(lsentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry2.type = "sentry"
	lsentry2.facing = "right"
	lsentry2.firerate = 20
	lsentry2.firedelay = 0
	
	local lsentry3 = display.newImage(mainGroup, "sentryR.png")
	lsentry3.x = Cx-unitwidth*1.3
	lsentry3.y = Cy-100
	physics.addBody(lsentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry3.type = "sentry"
	lsentry3.facing = "right"
	lsentry3.firerate = 20
	lsentry3.firedelay = 0
	
	local lsentry4 = display.newImage(mainGroup, "sentryR.png")
	lsentry4.x = Cx-unitwidth*1.3
	lsentry4.y = Cy/2-100
	physics.addBody(lsentry4, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	lsentry4.type = "sentry"
	lsentry4.facing = "right"
	lsentry4.firerate = 20
	lsentry4.firedelay = 0
	
	local lbarrier = display.newRect(mainGroup, Cx-unitwidth-50, Cy, 25, H)
	lbarrier:setFillColor(barriercolor1[1],barriercolor1[2],barriercolor1[3])
	physics.addBody(lbarrier, "static", {isSensor = true})
	lbarrier.alpha = 0.5
	lbarrier.type = "barrier"
	lbarrier.activetime = 40
	lbarrier.offtime = 20
	lbarrier.totaltime = 60
	lbarrier.timedelay = 0
	
	lkey.x = Cx-unitwidth+25
	lkey.y = Cy-100
end

local function leftPattern8() 
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-25, unitwidth/2-50, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-200, unitwidth/2-50, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-375, unitwidth/2-50, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-525, unitwidth/2-50, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	
	lplatform1.type = "platform"
	lplatform2.type = "platform"
	lplatform3.type = "platform"
	lplatform4.type = "platform"
	
	local llaser1 = display.newRect(mainGroup, Cx-unitwidth, Cy, 25, H)
	llaser1:setFillColor(lasercolor1[1],lasercolor1[2],lasercolor1[3])
	physics.addBody(llaser1, "static", {isSensor = true})
	llaser1.alpha = 0.5
	llaser1.type = "laser"
	llaser1.activetime = 20
	llaser1.offtime = 10
	llaser1.totaltime = 30
	llaser1.timedelay = 0
	
	lkey.x = Cx-unitwidth*1.25
	lkey.y = H-600
end

local function leftPattern9() 
	local lplatform1 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-25, unitwidth/2-50, 50)
	local lplatform2 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-200, unitwidth/2-50, 50)
	local lplatform3 = display.newRect(mainGroup, Cx-unitwidth*0.75, H-375, unitwidth/2-50, 50)
	local lplatform4 = display.newRect(mainGroup, Cx-unitwidth*1.25, H-525, unitwidth/2-50, 50)

	lplatform1:setFillColor(color[1],color[2],color[3])
	lplatform2:setFillColor(color[1],color[2],color[3])
	lplatform3:setFillColor(color[1],color[2],color[3])
	lplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(lplatform1, "static", {bounce = 0.0})
	physics.addBody(lplatform2, "static", {bounce = 0.0})
	physics.addBody(lplatform3, "static", {bounce = 0.0})
	physics.addBody(lplatform4, "static", {bounce = 0.0})
	
	lplatform4.type = "platform"
	
	lplatform1.type = "disappearing"
	lplatform1.timedelay = 10
	lplatform1.visibletime = 10
	lplatform1.transitiontime = 5
	lplatform1.invisibletime = 10
	lplatform1.totaltime = lplatform1.visibletime + 2*lplatform1.transitiontime + lplatform1.invisibletime
	
	lplatform2.type = "disappearing"
	lplatform2.timedelay = 5
	lplatform2.visibletime = 10
	lplatform2.transitiontime = 5
	lplatform2.invisibletime = 10
	lplatform2.totaltime = lplatform2.visibletime + 2*lplatform2.transitiontime + lplatform2.invisibletime
	
	lplatform3.type = "disappearing"
	lplatform3.timedelay = 0
	lplatform3.visibletime = 10
	lplatform3.transitiontime = 5
	lplatform3.invisibletime = 10
	lplatform3.totaltime = lplatform3.visibletime + 2*lplatform3.transitiontime + lplatform3.invisibletime
	
	lkey.x = Cx-unitwidth*1.25
	lkey.y = H-600
end

local function rightPattern1() 
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth, H-25, unitwidth/2, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-200, unitwidth/2, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-375, unitwidth/2, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-525, unitwidth/2, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	rplatform2.type = "platform"
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	
	local rugly = display.newSprite(mainGroup, uglySheet, uglySequences)
	rugly.x = Cx+unitwidth*1.25-unitwidth/4
	rugly.y = H-275
	physics.addBody(rugly, "static", {bounce = 0.0, box = {halfWidth = 40, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rugly.isFixedRotation = true
	rugly:play()
	rugly.type = "monster"
	rugly.startpoint = Cx+unitwidth*1.25-unitwidth/4
	rugly.endpoint = Cx+unitwidth*1.25+unitwidth/6
	rugly.movetime = 14
	rugly.timedelay = 6
	
	rkey.x = Cx+unitwidth*1.25
	rkey.y = H-600
end

local function rightPattern2()
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth*0.67, H-175, unitwidth/3, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth, H-325, unitwidth/2, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*1.33, H-475, unitwidth/2, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*0.67, H-625, unitwidth/3, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	rplatform2.type = "platform"
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	
	local rugly = display.newSprite(mainGroup, uglySheet, uglySequences)
	rugly.x = Cx+unitwidth-unitwidth/4
	rugly.y = H-400
	physics.addBody(rugly, "static", {bounce = 0.0, box = {halfWidth = 40, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rugly.isFixedRotation = true
	rugly:play()
	rugly.type = "monster"
	rugly.startpoint = Cx+unitwidth-unitwidth/4
	rugly.endpoint = Cx+unitwidth+unitwidth/4
	rugly.movetime = 16
	rugly.timedelay = 8
	
	rkey.x = Cx+unitwidth*0.67
	rkey.y = H-700
end

local function rightPattern3()
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth, H*0.67, 50, H*0.67)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth, H-150, unitwidth/2, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth-150, H-300, unitwidth/6, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth+150, H-300, unitwidth/6, 50)
	local rplatform5 = display.newRect(mainGroup, Cx+unitwidth+150, H-25, unitwidth/6, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])
	rplatform5:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	physics.addBody(rplatform5, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	
	rplatform2.type = "disappearing"
	rplatform2.timedelay = 30
	rplatform2.visibletime = 20
	rplatform2.transitiontime = 10
	rplatform2.invisibletime = 20
	rplatform2.totaltime = rplatform2.visibletime + 2*rplatform2.transitiontime + rplatform2.invisibletime
	
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	rplatform5.type = "platform"
	
	rkey.x = Cx+unitwidth+150
	rkey.y = H-100
end

local function rightPattern4()
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-25, unitwidth/2, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.25, (H+100)/2, unitwidth/2, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth/2+50, Cy/2, 100, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	
	rplatform1.type = "moving"
	rplatform1.movetype = "vertical"
	rplatform1.startpoint = H-25
	rplatform1.endpoint = (H+100)/2
	rplatform1.movetime = 16
	rplatform1.timedelay = 0
	
	rplatform2.type = "moving"
	rplatform2.movetype = "vertical"
	rplatform2.startpoint = (H+100)/2
	rplatform2.endpoint = 125
	rplatform2.movetime = 16
	rplatform2.timedelay = 8
	
	local rsentry1 = display.newImage(mainGroup, "sentryR.png")
	rsentry1:setFillColor(0,1,0.15)
	rsentry1.x = Cx+unitwidth/2+50
	rsentry1.y = Cy/2-75
	physics.addBody(rsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry1.type = "homing"
	rsentry1.facing = "right"
	rsentry1.firerate = 30
	rsentry1.firedelay = 0
	
	rkey.x = Cx+unitwidth+150
	rkey.y = 50
end

local function rightPattern5()
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-175, unitwidth/3, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-325, unitwidth/3, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-475, unitwidth/3, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-625, unitwidth/3, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	
	rplatform1.type = "moving"
	rplatform1.movetype = "horizontal"
	rplatform1.startpoint = Cx+unitwidth*0.75
	rplatform1.endpoint = Cx+unitwidth*1.25
	rplatform1.movetime = 16
	rplatform1.timedelay = 12
	
	rplatform2.type = "moving"
	rplatform2.movetype = "horizontal"
	rplatform2.startpoint = Cx+unitwidth*0.75
	rplatform2.endpoint = Cx+unitwidth*1.25
	rplatform2.movetime = 16
	rplatform2.timedelay = 4
	
	rplatform3.type = "moving"
	rplatform3.movetype = "horizontal"
	rplatform3.startpoint = Cx+unitwidth*0.75
	rplatform3.endpoint = Cx+unitwidth*1.25
	rplatform3.movetime = 16
	rplatform3.timedelay = 8
	
	rplatform4.type = "moving"
	rplatform4.movetype = "horizontal"
	rplatform4.startpoint = Cx+unitwidth*0.75
	rplatform4.endpoint = Cx+unitwidth*1.25
	rplatform4.movetime = 16
	rplatform4.timedelay = 0
	
	rkey.x = Cx+unitwidth
	rkey.y = H-700
end

local function rightPattern6() 
	local rplatform1 = display.newRect(mainGroup, W-25, Cy, 50, H)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.3, H-25, unitwidth/4, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*1.3, 3*Cy/2-25, unitwidth/4, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*1.3, Cy-25, unitwidth/4, 50)
	local rplatform5 = display.newRect(mainGroup, Cx+unitwidth*1.3, Cy/2-25, unitwidth/4, 50)
	local rplatform6 = display.newRect(mainGroup, Cx+unitwidth, H-25, unitwidth/4, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])
	rplatform5:setFillColor(color[1],color[2],color[3])
	rplatform6:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	physics.addBody(rplatform5, "static", {bounce = 0.0})
	physics.addBody(rplatform6, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	rplatform2.type = "platform"
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	rplatform5.type = "platform"
	
	rplatform6.type = "moving"
	rplatform6.movetype = "vertical"
	rplatform6.startpoint = H-25
	rplatform6.endpoint = Cy/2-25
	rplatform6.movetime = 16
	rplatform6.timedelay = 0
	
	if ( math.random(100) > score ) then
		local rheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
		rheart.x = Cx+unitwidth
		rheart.y = Cy/2-75
		physics.addBody(rheart, "static", {isSensor = true})
		rheart.type = "heart"
		rheart.isActive = true
	end
	
	local rsentry1 = display.newImage(mainGroup, "sentryL.png")
	rsentry1.x = Cx+unitwidth*1.3
	rsentry1.y = H-100
	physics.addBody(rsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry1.type = "sentry"
	rsentry1.facing = "left"
	rsentry1.firerate = 40
	rsentry1.firedelay = 0
	
	local rsentry2 = display.newImage(mainGroup, "sentryL.png")
	rsentry2.x = Cx+unitwidth*1.3
	rsentry2.y = 3*Cy/2-100
	physics.addBody(rsentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry2.type = "sentry"
	rsentry2.facing = "left"
	rsentry2.firerate = 40
	rsentry2.firedelay = 10
	
	local rsentry3 = display.newImage(mainGroup, "sentryL.png")
	rsentry3.x = Cx+unitwidth*1.3
	rsentry3.y = Cy-100
	physics.addBody(rsentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry3.type = "sentry"
	rsentry3.facing = "left"
	rsentry3.firerate = 40
	rsentry3.firedelay = 20
	
	local rsentry4 = display.newImage(mainGroup, "sentryL.png")
	rsentry4.x = Cx+unitwidth*1.3
	rsentry4.y = Cy/2-100
	physics.addBody(rsentry4, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry4.type = "sentry"
	rsentry4.facing = "left"
	rsentry4.firerate = 40
	rsentry4.firedelay = 30
	
	rkey.x = Cx+unitwidth
	rkey.y = Cy-100
end

local function rightPattern7() 
	local rplatform1 = display.newRect(mainGroup, W-25, Cy, 50, H)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.3, H-25, unitwidth/4, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*1.3, 3*Cy/2-25, unitwidth/4, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*1.3, Cy-25, unitwidth/4, 50)
	local rplatform5 = display.newRect(mainGroup, Cx+unitwidth*1.3, Cy/2-25, unitwidth/4, 50)
	local rplatform6 = display.newRect(mainGroup, Cx+unitwidth-25, H-25, unitwidth/4, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])
	rplatform5:setFillColor(color[1],color[2],color[3])
	rplatform6:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	physics.addBody(rplatform5, "static", {bounce = 0.0})
	physics.addBody(rplatform6, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	rplatform2.type = "platform"
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	rplatform5.type = "platform"
	
	rplatform6.type = "moving"
	rplatform6.movetype = "vertical"
	rplatform6.startpoint = H-25
	rplatform6.endpoint = Cy/2-25
	rplatform6.movetime = 16
	rplatform6.timedelay = 0
	
	if ( math.random(100) > score ) then
		local rheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
		rheart.x = Cx+unitwidth-25
		rheart.y = Cy/2-75
		physics.addBody(rheart, "static", {isSensor = true})
		rheart.type = "heart"
		rheart.isActive = true
	end
	
	local rsentry1 = display.newImage(mainGroup, "sentryL.png")
	rsentry1.x = Cx+unitwidth*1.3
	rsentry1.y = H-100
	physics.addBody(rsentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry1.type = "sentry"
	rsentry1.facing = "left"
	rsentry1.firerate = 20
	rsentry1.firedelay = 0
	
	local rsentry2 = display.newImage(mainGroup, "sentryL.png")
	rsentry2.x = Cx+unitwidth*1.3
	rsentry2.y = 3*Cy/2-100
	physics.addBody(rsentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry2.type = "sentry"
	rsentry2.facing = "left"
	rsentry2.firerate = 20
	rsentry2.firedelay = 0
	
	local rsentry3 = display.newImage(mainGroup, "sentryL.png")
	rsentry3.x = Cx+unitwidth*1.3
	rsentry3.y = Cy-100
	physics.addBody(rsentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry3.type = "sentry"
	rsentry3.facing = "left"
	rsentry3.firerate = 20
	rsentry3.firedelay = 0
	
	local rsentry4 = display.newImage(mainGroup, "sentryL.png")
	rsentry4.x = Cx+unitwidth*1.3
	rsentry4.y = Cy/2-100
	physics.addBody(rsentry4, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	rsentry4.type = "sentry"
	rsentry4.facing = "left"
	rsentry4.firerate = 20
	rsentry4.firedelay = 0
	
	local rbarrier = display.newRect(mainGroup, Cx+unitwidth+50, Cy, 25, H)
	rbarrier:setFillColor(barriercolor1[1],barriercolor1[2],barriercolor1[3])
	physics.addBody(rbarrier, "static", {isSensor = true})
	rbarrier.alpha = 0.5
	rbarrier.type = "barrier"
	rbarrier.activetime = 40
	rbarrier.offtime = 20
	rbarrier.totaltime = 60
	rbarrier.timedelay = 0
	
	rkey.x = Cx+unitwidth-25
	rkey.y = Cy-100
end

local function rightPattern8() 
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-25, unitwidth/2-50, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-200, unitwidth/2-50, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-375, unitwidth/2-50, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-525, unitwidth/2-50, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	
	rplatform1.type = "platform"
	rplatform2.type = "platform"
	rplatform3.type = "platform"
	rplatform4.type = "platform"
	
	local rlaser1 = display.newRect(mainGroup, Cx+unitwidth, Cy, 25, H)
	rlaser1:setFillColor(lasercolor1[1],lasercolor1[2],lasercolor1[3])
	physics.addBody(rlaser1, "static", {isSensor = true})
	rlaser1.alpha = 0.5
	rlaser1.type = "laser"
	rlaser1.activetime = 20
	rlaser1.offtime = 10
	rlaser1.totaltime = 30
	rlaser1.timedelay = 0
	
	rkey.x = Cx+unitwidth*1.25
	rkey.y = H-600
end

local function rightPattern9() 
	local rplatform1 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-25, unitwidth/2-50, 50)
	local rplatform2 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-200, unitwidth/2-50, 50)
	local rplatform3 = display.newRect(mainGroup, Cx+unitwidth*0.75, H-375, unitwidth/2-50, 50)
	local rplatform4 = display.newRect(mainGroup, Cx+unitwidth*1.25, H-525, unitwidth/2-50, 50)

	rplatform1:setFillColor(color[1],color[2],color[3])
	rplatform2:setFillColor(color[1],color[2],color[3])
	rplatform3:setFillColor(color[1],color[2],color[3])
	rplatform4:setFillColor(color[1],color[2],color[3])

	physics.addBody(rplatform1, "static", {bounce = 0.0})
	physics.addBody(rplatform2, "static", {bounce = 0.0})
	physics.addBody(rplatform3, "static", {bounce = 0.0})
	physics.addBody(rplatform4, "static", {bounce = 0.0})
	
	rplatform4.type = "platform"
	
	rplatform1.type = "disappearing"
	rplatform1.timedelay = 10
	rplatform1.visibletime = 10
	rplatform1.transitiontime = 5
	rplatform1.invisibletime = 10
	rplatform1.totaltime = rplatform1.visibletime + 2*rplatform1.transitiontime + rplatform1.invisibletime
	
	rplatform2.type = "disappearing"
	rplatform2.timedelay = 5
	rplatform2.visibletime = 10
	rplatform2.transitiontime = 5
	rplatform2.invisibletime = 10
	rplatform2.totaltime = rplatform2.visibletime + 2*rplatform2.transitiontime + rplatform2.invisibletime
	
	rplatform3.type = "disappearing"
	rplatform3.timedelay = 0
	rplatform3.visibletime = 10
	rplatform3.transitiontime = 5
	rplatform3.invisibletime = 10
	rplatform3.totaltime = rplatform3.visibletime + 2*rplatform3.transitiontime + rplatform3.invisibletime
	
	rkey.x = Cx+unitwidth*1.25
	rkey.y = H-600
end

local function midPattern1()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy/2, 50, H)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
end

local function midPattern2()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	
	local mugly = display.newSprite(mainGroup, uglySheet, uglySequences)
	mugly.x = Cx-unitwidth/4
	mugly.y = Cy-75
	physics.addBody(mugly, "static", {bounce = 0.0, box = {halfWidth = 40, halfHeight = 36, x = 0, y = 12, angle = 0}})
	mugly.isFixedRotation = true
	mugly:play()
	mugly.type = "monster"
	mugly.startpoint = Cx-unitwidth/4
	mugly.endpoint = Cx+unitwidth/4
	mugly.movetime = 16
	mugly.timedelay = 0
end

local function midPattern3()
	local mplatform1 = display.newRect(mainGroup, Cx-unitwidth/2+25, Cy/2-150, 50, H)
	local mplatform2 = display.newRect(mainGroup, Cx+unitwidth/2-25, Cy/2-150, 50, H)
	local mplatform3 = display.newRect(mainGroup, Cx, H-200, unitwidth/3, 50)
	local mplatform4 = display.newRect(mainGroup, Cx+unitwidth/3, H-350, unitwidth/3, 50)
	local mplatform5 = display.newRect(mainGroup, Cx-unitwidth/3, H-475, unitwidth/3, 50)
	local mplatform6 = display.newRect(mainGroup, Cx+unitwidth/3, H-600, unitwidth/3, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	mplatform2:setFillColor(color[1],color[2],color[3])
	mplatform3:setFillColor(color[1],color[2],color[3])
	mplatform4:setFillColor(color[1],color[2],color[3])
	mplatform5:setFillColor(color[1],color[2],color[3])
	mplatform6:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	physics.addBody(mplatform2, "static", {bounce = 0.0})
	physics.addBody(mplatform3, "static", {bounce = 0.0})
	physics.addBody(mplatform4, "static", {bounce = 0.0})
	physics.addBody(mplatform5, "static", {bounce = 0.0})
	physics.addBody(mplatform6, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	mplatform2.type = "platform"
	mplatform3.type = "platform"
	mplatform4.type = "platform"
	mplatform5.type = "platform"
	mplatform6.type = "platform"
	
	if ( math.random(100) > score ) then
		local mitemrand = math.random(4)
		if (mitemrand == 1) then
			local mteleport = display.newImageRect(mainGroup, "teleport.png", 48, 48)
			mteleport.x = Cx+unitwidth/3-50
			mteleport.y = H-650
			physics.addBody(mteleport, "static", {isSensor = true})
			mteleport.type = "teleport"
			mteleport.isActive = true
		elseif (mitemrand == 2) then
			local mshield = display.newImageRect(mainGroup, "shield.png", 48, 48)
			mshield.x = Cx+unitwidth/3-50
			mshield.y = H-650
			physics.addBody(mshield, "static", {isSensor = true})
			mshield.type = "shield"
			mshield.isActive = true
		elseif (mitemrand == 3 or mitemrand == 4) then
			local mheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
			mheart.x = Cx+unitwidth/3-50
			mheart.y = H-650
			physics.addBody(mheart, "static", {isSensor = true})
			mheart.type = "heart"
			mheart.isActive = true
		end
	end
end

local function midPattern4()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy/2, 50, H)
	local mplatform2 = display.newRect(mainGroup, Cx, Cy/2, unitwidth/2, 50)
	local mplatform3 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	mplatform2:setFillColor(color[1],color[2],color[3])
	mplatform3:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	physics.addBody(mplatform2, "static", {bounce = 0.0})
	physics.addBody(mplatform3, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	mplatform2.type = "platform"
	mplatform3.type = "platform"
	
	local msentry1 = display.newImage(mainGroup, "sentryL.png")
	msentry1.x = Cx-75
	msentry1.y = Cy/2-75
	physics.addBody(msentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry1.type = "sentry"
	msentry1.facing = "left"
	msentry1.firerate = 40
	msentry1.firedelay = 0
	
	local msentry2 = display.newImage(mainGroup, "sentryL.png")
	msentry2.x = Cx-75
	msentry2.y = Cy-75
	physics.addBody(msentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry2.type = "sentry"
	msentry2.facing = "left"
	msentry2.firerate = 40
	msentry2.firedelay = 20
	
	local msentry3 = display.newImage(mainGroup, "sentryR.png")
	msentry3.x = Cx+75
	msentry3.y = Cy/2-75
	physics.addBody(msentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry3.type = "sentry"
	msentry3.facing = "right"
	msentry3.firerate = 40
	msentry3.firedelay = 0
	
	local msentry4 = display.newImage(mainGroup, "sentryR.png")
	msentry4.x = Cx+75
	msentry4.y = Cy-75
	physics.addBody(msentry4, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry4.type = "sentry"
	msentry4.facing = "right"
	msentry4.firerate = 40
	msentry4.firedelay = 20
end

local function midPattern5()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy/2, 50, H)
	local mplatform2 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	mplatform2:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	physics.addBody(mplatform2, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	mplatform2.type = "platform"
	
	local msentry1 = display.newImage(mainGroup, "sentryL.png")
	msentry1:setFillColor(0,1,0.15)
	msentry1.x = Cx-75
	msentry1.y = Cy-75
	physics.addBody(msentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry1.type = "homing"
	msentry1.facing = "left"
	msentry1.firerate = 50
	msentry1.firedelay = 0
	
	local msentry2 = display.newImage(mainGroup, "sentryR.png")
	msentry2:setFillColor(0,1,0.15)
	msentry2.x = Cx+75
	msentry2.y = Cy-75
	physics.addBody(msentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry2.type = "homing"
	msentry2.facing = "right"
	msentry2.firerate = 50
	msentry2.firedelay = 0
end

local function midPattern6()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	
	local mlaser = display.newRect(mainGroup, Cx, Cy/2-25, 25, Cy)
	mlaser:setFillColor(lasercolor1[1],lasercolor1[2],lasercolor1[3])
	physics.addBody(mlaser, "static", {isSensor = true})
	mlaser.alpha = 0.5
	mlaser.type = "laser"
	mlaser.activetime = 40
	mlaser.offtime = 20
	mlaser.totaltime = 60
	mlaser.timedelay = 0
end

local function midPattern7()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	
	local mbarrier = display.newRect(mainGroup, Cx, Cy/2-25, 25, Cy)
	mbarrier:setFillColor(barriercolor1[1],barriercolor1[2],barriercolor1[3])
	physics.addBody(mbarrier, "static", {isSensor = true})
	mbarrier.alpha = 0.5
	mbarrier.type = "barrier"
	mbarrier.activetime = 40
	mbarrier.offtime = 20
	mbarrier.totaltime = 60
	mbarrier.timedelay = 0
end

local function midPattern8()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy/2, 50, H)
	local mplatform2 = display.newRect(mainGroup, Cx-unitwidth/8, Cy/2, unitwidth/4, 50)
	local mplatform3 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	mplatform2:setFillColor(color[1],color[2],color[3])
	mplatform3:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	physics.addBody(mplatform2, "static", {bounce = 0.0})
	physics.addBody(mplatform3, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	mplatform2.type = "platform"
	mplatform3.type = "platform"
	
	local msentry1 = display.newImage(mainGroup, "sentryL.png")
	msentry1.x = Cx-75
	msentry1.y = Cy/2-75
	physics.addBody(msentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry1.type = "sentry"
	msentry1.facing = "left"
	msentry1.firerate = 40
	msentry1.firedelay = 0
	
	local msentry2 = display.newImage(mainGroup, "sentryL.png")
	msentry2.x = Cx-75
	msentry2.y = Cy-75
	physics.addBody(msentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry2.type = "sentry"
	msentry2.facing = "left"
	msentry2.firerate = 40
	msentry2.firedelay = 20
	
	local msentry3 = display.newImage(mainGroup, "sentryR.png")
	msentry3:setFillColor(0,1,0.15)
	msentry3.x = Cx+75
	msentry3.y = Cy-75
	physics.addBody(msentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry3.type = "homing"
	msentry3.facing = "right"
	msentry3.firerate = 50
	msentry3.firedelay = 0
end

local function midPattern9()
	local mplatform1 = display.newRect(mainGroup, Cx, Cy/2, 50, H)
	local mplatform2 = display.newRect(mainGroup, Cx+unitwidth/8, Cy/2, unitwidth/4, 50)
	local mplatform3 = display.newRect(mainGroup, Cx, Cy, unitwidth/2, 50)
	
	mplatform1:setFillColor(color[1],color[2],color[3])
	mplatform2:setFillColor(color[1],color[2],color[3])
	mplatform3:setFillColor(color[1],color[2],color[3])
	
	physics.addBody(mplatform1, "static", {bounce = 0.0})
	physics.addBody(mplatform2, "static", {bounce = 0.0})
	physics.addBody(mplatform3, "static", {bounce = 0.0})
	
	mplatform1.type = "platform"
	mplatform2.type = "platform"
	mplatform3.type = "platform"
	
	local msentry1 = display.newImage(mainGroup, "sentryL.png")
	msentry1:setFillColor(0,1,0.15)
	msentry1.x = Cx-75
	msentry1.y = Cy-75
	physics.addBody(msentry1, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry1.type = "homing"
	msentry1.facing = "left"
	msentry1.firerate = 50
	msentry1.firedelay = 0
	
	local msentry2 = display.newImage(mainGroup, "sentryR.png")
	msentry2.x = Cx+75
	msentry2.y = Cy/2-75
	physics.addBody(msentry2, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry2.type = "sentry"
	msentry2.facing = "right"
	msentry2.firerate = 40
	msentry2.firedelay = 0
	
	local msentry3 = display.newImage(mainGroup, "sentryR.png")
	msentry3.x = Cx+75
	msentry3.y = Cy-75
	physics.addBody(msentry3, "static", {bounce = 0.0, box = {halfWidth = 48, halfHeight = 36, x = 0, y = 12, angle = 0}})
	msentry3.type = "sentry"
	msentry3.facing = "right"
	msentry3.firerate = 40
	msentry3.firedelay = 20
end



-- Generate Level
	
local left = math.random(leftpatterns)
local right = math.random(rightpatterns)
local mid = math.random(midpatterns)

--left = 10
if (left == 1) then
	leftPattern1()
elseif (left == 2) then
	leftPattern2()
elseif (left == 3) then
	leftPattern3()
elseif (left == 4) then
	leftPattern4()
elseif (left == 5) then
	leftPattern5()
elseif (left == 6) then
	leftPattern6()
elseif (left == 7) then
	leftPattern7()
elseif (left == 8) then
	leftPattern8()
elseif (left == 9) then
	leftPattern9()
end

--right = 9
if (right == 1) then
	rightPattern1()
elseif (right == 2) then
	rightPattern2()
elseif (right == 3) then
	rightPattern3()
elseif (right == 4) then
	rightPattern4()
elseif (right == 5) then
	rightPattern5()
elseif (right == 6) then
	rightPattern6()
elseif (right == 7) then
	rightPattern7()
elseif (right == 8) then
	rightPattern8()
elseif (right == 9) then
	rightPattern9()
end

--mid = 3
if (mid == 1) then
	midPattern1()
elseif (mid == 2) then
	midPattern2()
elseif (mid == 3) then
	midPattern3()
elseif (mid == 4) then
	midPattern4()
elseif (mid == 5) then
	midPattern5()
elseif (mid == 6) then
	midPattern6()
elseif (mid == 7) then
	midPattern7()
elseif (mid == 8) then
	midPattern8()
elseif (mid == 9) then
	midPattern9()
end



-- Control Buttons

local leftButton = display.newRect(100, H-100, 150, 150)
leftButton:setFillColor(0,0,0)
local leftText = display.newText("<", 100, H-100, default, 100)
leftButton.alpha = 0.5

local rightButton = display.newRect(275, H-100, 150, 150)
rightButton:setFillColor(0,0,0)
local rightText = display.newText(">", 275, H-100, default, 100)
rightButton.alpha = 0.5

local jumpButton = display.newRect(W-100, H-100, 150, 150)
jumpButton:setFillColor(0,0,0)
local jumpText = display.newText("^", W-100, H-100, default, 100)
jumpButton.alpha = 0.5

local shieldButton = display.newRect(W-275, H-100, 150, 150)
shieldButton:setFillColor(0,0,0)
local shieldText = display.newText("( )", W-275, H-100, default, 100)
shieldButton.alpha = 0.5

uiGroup:insert(leftButton)
uiGroup:insert(rightButton)
uiGroup:insert(jumpButton)
uiGroup:insert(shieldButton)
uiGroup:insert(leftText)
uiGroup:insert(rightText)
uiGroup:insert(jumpText)
uiGroup:insert(shieldText)

local livesText = display.newText("Lives: " .. lives, Cx*0.25, 50)
local scoreText = display.newText("Score: " .. score, Cx*1.75, 50)
shieldStatusText = display.newText("Shield Charged", Cx, 50)
shieldStatusText:setFillColor(0.5,0.5,1)
teleportStatusText = display.newText(" ", Cx, 100)
teleportStatusText:setFillColor(1,0.5,0)

uiGroup:insert(livesText)
uiGroup:insert(scoreText)
uiGroup:insert(shieldStatusText)



-- Update Text
local function updateText(liveschange)
	lives = lives + liveschange
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end

-- Shield Activation Function
local function activateShield()
	isShielded = true
	player.alpha = 0.25
	shieldStatusText.text = "Shield Active"
	shieldStatusText:setFillColor(0.5,1,0.5)
end

-- Teleport Activation Function
local function activateTeleport()
	canTeleport = true
	teleportStatusText.text = "Tap to Teleport!"
end

-- Respawn Player
local function respawnPlayer()
	player.x = Cx
	player.y = H-100
	shieldcounter = 23
	activateShield()
	leveldeaths = leveldeaths + 1
end

--Game Loop
local function gameLoop()

	local child
	
	-- Shield Management
	if (isShielded == true) then
		shieldcounter = shieldcounter - 1
		if (shieldcounter == 8) then
			isShielded = false
			player.alpha = 1
			shieldStatusText.text = "Shield Charged"
			shieldStatusText:setFillColor(0.5,0.5,1)
		end
	elseif (shieldcounter < 8 and math.fmod(gamecounter, 8) == 0) then
		shieldcounter = shieldcounter + 1
	elseif (shieldcounter == 8) then
		shieldStatusText.text = "Shield Charged"
		shieldStatusText:setFillColor(0.5,0.5,1)
	end
	
	if (isShielded == true and shieldcounter <= 0) then
		isShielded = false
		player.alpha = 1
		shieldStatusText.text = "Shield Charging"
		shieldStatusText:setFillColor(1,0.5,0.5)
	end
	
	-- If player is dying a lot, give them a powerup
	local itemrand = math.random(4)
	--itemrand = 1
	if (leveldeaths >= 3) then
		if (itemrand == 1) then -- teleport
			local xteleport = display.newImageRect(mainGroup, "teleport.png", 48, 48)
			xteleport.x = Cx-unitwidth/4
			xteleport.y = H-75
			physics.addBody(xteleport, "static", {isSensor = true})
			xteleport.type = "teleport"
			xteleport.isActive = true
			leveldeaths = 0
		elseif (itemrand == 2) then -- shield
			local xshield = display.newImageRect(mainGroup, "shield.png", 48, 48)
			xshield.x = Cx-unitwidth/4
			xshield.y = H-75
			physics.addBody(xshield, "static", {isSensor = true})
			xshield.type = "shield"
			xshield.isActive = true
			leveldeaths = 0
		elseif (itemrand == 3 or itemrand == 4) then -- heart
			local xheart = display.newImageRect(mainGroup, "heart.png", 48, 48)
			xheart.x = Cx-unitwidth/4
			xheart.y = H-75
			physics.addBody(xheart, "static", {isSensor = true})
			xheart.type = "heart"
			xheart.isActive = true
			leveldeaths = 0
		end
	end
	
	-- This calculation prevents the player from floating in the air after standing on a vertically moving platform
	player.y = player.y - 1
	player.y = player.y + 1
	
	-- If Player Died, Respawn Them
	if (isDead == true) then
		respawnPlayer()
		isDead = false
	end

	-- If player used a teleport, perform the action
	if (needTeleport == true) then
		needTeleport = false
		player.x = Tx
		player.y = Ty
	end
	
	-- Make Sure That Player Has No Horizontal Velocity
	local vx, vy = player:getLinearVelocity()
	player:setLinearVelocity(0, vy)
	
	-- Increment Game Counter
	gamecounter = gamecounter + 1
	
	--If player fell of map, take a life and respawn them
	if (player.y > 2*H) then
		respawnPlayer()
		audio.play(deathsfx)
		updateText(-1)
	end
	
	-- If player is touching the ground give them a life
	if (playerInContact == true) then
		playerHasJump = true
	end
	
	-- If player triggered a live change, do it
	if (needlivechange ~= 0) then
		updateText(needlivechange)
		needlivechange = 0
	end
	
	-- Make Sentries Fire
	local makefiresound = false
	local ximpulse = 1
	local yimpulse = 1
	local temp = 1
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "sentry") then
			if (math.fmod(gamecounter + child.firedelay, child.firerate) == 0) then
				if (child.facing == "left") then
					local newbullet = display.newImage(mainGroup, "bullet.png", child.x-100, child.y)
					physics.addBody(newbullet, "dynamic", {box = {halfWidth = 12, halfHeight = 12}})
					newbullet.type = "bullet"
					newbullet.isActive = true
					newbullet.gravityScale = 0
					newbullet:applyLinearImpulse(-0.1,0, newbullet.x, newbullet.y)
					makefiresound = true
				end
				if (child.facing == "right") then
					local newbullet = display.newImage(mainGroup, "bullet.png", child.x+100, child.y)
					physics.addBody(newbullet, "dynamic", {box = {halfWidth = 12, halfHeight = 12}})
					newbullet.type = "bullet"
					newbullet.isActive = true
					newbullet.gravityScale = 0
					newbullet:applyLinearImpulse(0.1,0, newbullet.x, newbullet.y)
					makefiresound = true
				end
			end
		end
		if (child.type == "homing") then
			if (math.fmod(gamecounter + child.firedelay, child.firerate) == 0) then
				if (child.facing == "left" and (child.x > player.x) ) then
					local newbullet = display.newImage(mainGroup, "bullet.png", child.x-100, child.y)
					physics.addBody(newbullet, "dynamic", {box = {halfWidth = 12, halfHeight = 12}})
					newbullet.type = "bullet"
					newbullet.isActive = true
					newbullet.gravityScale = 0
					
					-- Calculate direction and speed to fire using pythagorean theorem
					ximpulse = player.x - newbullet.x
					yimpulse = player.y - newbullet.y
					temp = ximpulse * ximpulse + yimpulse * yimpulse
					temp = math.sqrt(temp)
					ximpulse = ximpulse/temp * 0.075
					yimpulse = yimpulse/temp * 0.075
					
					newbullet:applyLinearImpulse(ximpulse,yimpulse, newbullet.x, newbullet.y)
					makefiresound = true
				end
				if (child.facing == "right" and (child.x < player.x)) then
					local newbullet = display.newImage(mainGroup, "bullet.png", child.x+100, child.y)
					physics.addBody(newbullet, "dynamic", {box = {halfWidth = 12, halfHeight = 12}})
					newbullet.type = "bullet"
					newbullet.isActive = true
					newbullet.gravityScale = 0
					
					-- Calculate direction and speed to fire using pythagorean theorem
					ximpulse = player.x - newbullet.x
					yimpulse = player.y - newbullet.y
					temp = ximpulse * ximpulse + yimpulse * yimpulse
					temp = math.sqrt(temp)
					ximpulse = ximpulse/temp * 0.075
					yimpulse = yimpulse/temp * 0.075
					
					newbullet:applyLinearImpulse(ximpulse,yimpulse, newbullet.x, newbullet.y)
					makefiresound = true
				end
			end
		end
	end
	
	if (makefiresound == true) then
		audio.play(firesfx)
	end
	
	-- Remove Inactive Bullets, Keys, and Hearts
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child ~= nil and (child.type == "bullet" or child.type == "heart" or child.type == "key" or child.type == "shield" or child.type == "teleport")) then
			if (child.x < -100 or child.x > W+100) then
				child.isActive = false
			end
			if (child.isActive == false) then
				child:removeSelf()
			end
		end
	end
	
	-- Make Moving Platforms Move
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "moving") then
			if (child.movetype == "vertical") then
				if ( math.fmod(gamecounter + child.timedelay, child.movetime) == 0 ) then
					if ( child.y > (child.startpoint + child.endpoint)/2 ) then
						transition.to( child, { time=child.movetime*100, y= child.endpoint} )
					else
						transition.to( child, { time=child.movetime*100, y= child.startpoint} )
					end
				end
			end
			if (child.movetype == "horizontal") then
				if ( math.fmod(gamecounter + child.timedelay, child.movetime) == 0 ) then
					if ( child.x < (child.startpoint + child.endpoint)/2 ) then
						transition.to( child, { time=child.movetime*100, x= child.endpoint} )
					else
						transition.to( child, { time=child.movetime*100, x= child.startpoint} )
					end
				end
			end
		end
	end
	
	--[[ Make Disappearing Platforms Disappear
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "disappearing") then
			if ( math.fmod(gamecounter + child.timedelay + child.visibletime, child.totaltime) == 0 ) then
				transition.to( child, { time=child.transitiontime*100, alpha = 0} )
			end
			if ( math.fmod(gamecounter + child.timedelay + child.visibletime + child.transitiontime, child.totaltime) == 0 ) then
				physics.removeBody(child)
			end
			if ( math.fmod(gamecounter + child.timedelay + child.visibletime + child.transitiontime + child.invisibletime, child.totaltime) == 0 ) then
				physics.addBody(child, "static", {bounce = 0.0})
				transition.to( child, { time=child.transitiontime*100, alpha = 1} )
			end
		end
	end
	]]
	
	-- Make Disappearing Platforms Disappear
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "disappearing") then
			if ( math.fmod(gamecounter + child.timedelay, child.totaltime) == child.visibletime ) then
				transition.to( child, { time=child.transitiontime*100, alpha = 0} )
			end
			if ( math.fmod(gamecounter + child.timedelay, child.totaltime) == child.visibletime + child.transitiontime ) then
				physics.removeBody(child)
			end
			if ( math.fmod(gamecounter + child.timedelay, child.totaltime) == child.visibletime + child.transitiontime + child.invisibletime ) then
				physics.addBody(child, "static", {bounce = 0.0})
				transition.to( child, { time=child.transitiontime*100, alpha = 1} )
			end
		end
	end
	
	-- Make Lasers and Barriers Work
	local tempcolor1 = 1
	local tempcolor2 = 1
	local tempcolor3 = 1
	local tempcalc = 0
	local makelasersound = false
	local makebarriersound = false
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "laser") then
			tempcalc = math.fmod(gamecounter, child.totaltime)
			tempcolor1 = (lasercolor1[1] * (child.totaltime - tempcalc) + tempcalc * lasercolor2[1])/child.totaltime
			tempcolor2 = (lasercolor1[2] * (child.totaltime - tempcalc) + tempcalc * lasercolor2[2])/child.totaltime
			tempcolor3 = (lasercolor1[3] * (child.totaltime - tempcalc) + tempcalc * lasercolor2[3])/child.totaltime
			child:setFillColor(tempcolor1, tempcolor2, tempcolor3)
			if ( math.fmod(gamecounter + child.timedelay + child.offtime, child.totaltime) == 0 ) then
				physics.removeBody(child)
				child.alpha = 0
			end
			if ( math.fmod(gamecounter + child.timedelay + child.activetime + child.offtime, child.totaltime) == 0 ) then
				child.alpha = 0.5
				physics.addBody(child, "static", {isSensor = true})
				makelasersound = true
			end
		end
		if (child.type == "barrier") then
			tempcalc = math.fmod(gamecounter, child.totaltime)
			tempcolor1 = (barriercolor1[1] * (child.totaltime - tempcalc) + tempcalc * barriercolor2[1])/child.totaltime
			tempcolor2 = (barriercolor1[2] * (child.totaltime - tempcalc) + tempcalc * barriercolor2[2])/child.totaltime
			tempcolor3 = (barriercolor1[3] * (child.totaltime - tempcalc) + tempcalc * barriercolor2[3])/child.totaltime
			child:setFillColor(tempcolor1, tempcolor2, tempcolor3)
			if ( math.fmod(gamecounter + child.timedelay + child.offtime, child.totaltime) == 0 ) then
				physics.removeBody(child)
				child.alpha = 0
			end
			if ( math.fmod(gamecounter + child.timedelay + child.activetime + child.offtime, child.totaltime) == 0 ) then
				child.alpha = 0.5
				physics.addBody(child, "static", {isSensor = true})
				makebarriersound = true
			end
		end
	end
	
	if (makelasersound == true) then
		audio.play(lasersfx)
	end
	if (makebarriersound == true) then
		audio.play(barriersfx)
	end
	
	-- Make Monsters Move
	for i = 1, mainGroup.numChildren, 1 do
		child = mainGroup[i]
		if (child.type == "monster") then
			if ( math.fmod(gamecounter + child.timedelay, child.movetime) == 0 ) then
				if ( child.x < (child.startpoint + child.endpoint)/2 ) then
					transition.to( child, { time=child.movetime*100, x= child.endpoint} )
				else
					transition.to( child, { time=child.movetime*100, x= child.startpoint} )
				end
			end
		end
	end
	
	-- If player is out of lives, give them a game over
	if (lives <= 0) then
		composer.gotoScene( "complete" , {params = {lastscore = score, lastlives = lives, lost = true} })
	end
	
	-- Update Text
	updateText(0)
end
gameLoopTimer = timer.performWithDelay( 100, gameLoop, 0 )



-- Generic Collision Detection
local function onCollision(event)
	
	if ( event.phase == "began" ) then
	
		local obj1 = event.object1
		local obj2 = event.object2
	
		--print(obj1.type)
		--print(obj2.type)
	
		if (obj1.type == "player") then
	
			if (obj2.type == "key" and obj2.isActive == true) then
				keys = keys + 1
				obj2.isActive = false
				obj2.alpha = 0
				audio.play(collectsfx)
			end
			
			if (obj2.type == "door" and keys >= 2) then
				keys = 0
				audio.play(completesfx)
				composer.gotoScene( "complete" , {params = {lastscore = score, lastlives = lives, lost = false} })
			end
			
			
			if (obj2.type == "heart" and obj2.isActive == true) then
				needlivechange = needlivechange + 1
				obj2.isActive = false
				obj2.alpha = 0
				audio.play(gainlifesfx)
			end
	
			if (obj2.type == "shield" and obj2.isActive == true) then
				shieldcounter = 88
				activateShield()
				obj2.isActive = false
				obj2.alpha = 0
				audio.play(gainshieldsfx)
			end
			
			if (obj2.type == "teleport" and obj2.isActive == true) then
				activateTeleport()
				obj2.isActive = false
				obj2.alpha = 0
				audio.play(gainteleportsfx)
			end
			
			if (obj2.type == "bullet" and obj2.isActive == true) then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
				obj2.isActive = false
			end
			
			if (obj2.type == "monster") then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
			end
			
			if (obj2.type == "laser") then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
			end
		
		end
	
		if (obj2.type == "player") then
		
			if (obj1.type == "key" and obj1.isActive == true) then
				keys = keys + 1
				obj1.isActive = false
				obj1.alpha = 0
				audio.play(collectsfx)
			end

			if (obj1.type == "door" and keys >= 2) then
				keys = 0
				audio.play(completesfx)
				composer.gotoScene( "complete" , {params = {lastscore = score, lastlives = lives, lost = false} })
			end
			
			
			if (obj1.type == "heart" and obj1.isActive == true) then
				needlivechange = needlivechange + 1
				obj1.isActive = false
				obj1.alpha = 0
				audio.play(gainlifesfx)
			end
			
			if (obj1.type == "shield" and obj1.isActive == true) then
				shieldcounter = 88
				activateShield()
				obj1.isActive = false
				obj1.alpha = 0
				audio.play(gainshieldsfx)
			end
			
			if (obj1.type == "teleport" and obj1.isActive == true) then
				activateTeleport()
				obj1.isActive = false
				obj1.alpha = 0
				audio.play(gainteleportsfx)
			end
		
			if (obj1.type == "bullet" and obj1.isActive == true) then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
				obj1.isActive = false
			end
			
			if (obj1.type == "monster") then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
			end
			
			if (obj1.type == "laser") then
				if (isDead == false and isShielded == false) then
					needlivechange = needlivechange - 1
					audio.play(deathsfx)
					isDead = true
				end
			end
		
		end
		
		if (obj1.type == "bullet" and obj2.type ~= "key" and obj2.type ~= "heart" and obj2.type ~= "shield" and obj2.type ~= "teleport") then
			obj1.isActive = false
		end
		
		if (obj2.type == "bullet" and obj1.type ~= "key" and obj1.type ~= "heart" and obj1.type ~= "shield" and obj1.type ~= "teleport") then
			obj2.isActive = false
		end
	
	end
	
end
Runtime:addEventListener( "collision", onCollision )



--[[ Key Collision Checkers
local function keyCollision(self, event)

	if ( event.phase == "began" ) then
	
		local obj1 = event.object1
		local obj2 = event.object2

		if ( self.isActive == true ) then
			keys = keys + 1
			self.isActive = false
			self.alpha = 0
			audio.play(collectsfx)
		end
	
	end
end
lkey.collision = keyCollision
rkey.collision = keyCollision
lkey:addEventListener("collision")
rkey:addEventListener("collision")
]]



--[[ Door Collision Checker
local function doorCollision(self,event)
	if (keys >= 2) then
		audio.play(completesfx)
		composer.gotoScene( "complete" , {params = {lastscore = score, lastlives = lives, lost = false} })
	end
end
door.collision = doorCollision
door:addEventListener("collision")
]]



-- Player Collision Checker
local function playerCollision( self, event )
	if (event.contact ~= nil) then
		if (event.selfElement == 2 and event.contact.isTouching == true) then	
			playerInContact = true
			isJumping = false
			if (playerfacing == "left") then
				player:setSequence("idleLeft")
				player:play()
			end
			if (playerfacing == "right") then
				player:setSequence("idleRight")
				player:play()
			end
		end
	end
end
player.collision = playerCollision
player:addEventListener("collision")



-- Player Movement
local function left(event)
	if (gameActive == true) then
	
	playerfacing = "left"
	if (player.sequence ~= "walkLeft" and isJumping == false) then
		player:setSequence("walkLeft")
		player:play()
	end
	xmovement = -walkSpeed
	
	end
end
leftButton:addEventListener("touch", left)

local function right(event)
	if (gameActive == true) then
	
	playerfacing = "right"
	if (player.sequence ~= "walkRight" and isJumping == false) then
		player:setSequence("walkRight")
		player:play()
	end
	xmovement = walkSpeed
	
	end
end
rightButton:addEventListener("touch", right)

local function movePlayer(event)
	if (gameActive == true) then
		player.x = player.x + xmovement;
	end
end
Runtime:addEventListener("enterFrame", movePlayer)



-- Stop Moving
local function stop()
	if (gameActive == true) then
	
	xmovement = 0;
	if (isJumping == false) then
		if (playerfacing == "left") then
			player:setSequence("idleLeft")
			player:play()
		end
		if (playerfacing == "right") then
			player:setSequence("idleRight")
			player:play()
		end
	end
	
	end
end


-- Generic Touch Handler
local function touchHandler(event)
	if (event.phase =="ended") then
		-- Make the player stop moving if the control buttons are no longer being touched
		if (event.x < Cx) then
			stop()
		end
	end
end
Runtime:addEventListener("touch", touchHandler)



-- Generic Tap Handler
local function tapHandler(event)
	if (canTeleport == true and ((event.x > 400 and event.x < W-400) or (event.y < H-225)) and event.x ~= nil and event.y ~= nil) then
		needTeleport = true
		canTeleport = false
		Tx = event.x
		Ty = event.y
		teleportStatusText.text = " "
	end
end
Runtime:addEventListener("tap", tapHandler)



-- Make player jump
local function jump(event)
	if (gameActive == true) then
		local vx, vy = player:getLinearVelocity()
		if (playerHasJump == true) then
			player:setLinearVelocity(vx, -jumpHeight)
			audio.play(jumpsfx)
			isJumping = true
			if (playerfacing == "left") then
				player:setSequence("jumpLeft")
				player:play()
			end
			if (playerfacing == "right") then
				player:setSequence("jumpRight")
				player:play()
			end
		end
		playerHasJump = false
		playerInContact = false
	end
end
jumpButton:addEventListener("touch", jump)



-- Allow the player to shield
local function shieldButtonHandler(event)
	if (shieldcounter == 8) then
		activateShield()
	end
end
shieldButton:addEventListener("touch", shieldButtonHandler)


-- Keyboard and gamepad controls
local function keyEventHandler(event)
	-- Jump
	if (event.keyName == "space") then
		jump(event)
	end
	if (event.keyName == "w") then
		jump(event)
	end
	if (event.keyName == "up") then
		jump(event)
	end
	if (event.keyName == "buttonA") then
		jump(event)
	end
	if (event.keyName == "buttonB") then
		jump(event)
	end
	
	-- Shield
	if (event.keyName == "leftShift") then
		if (shieldcounter == 8) then
			activateShield()
		end
	end
	if (event.keyName == "buttonX") then
		if (shieldcounter == 8) then
			activateShield()
		end
	end
	if (event.keyName == "buttonY") then
		if (shieldcounter == 8) then
			activateShield()
		end
	end
	
	-- Left
	if (event.keyName == "a") then
		left(event)
		if (event.phase == "up") then
			stop()
		end
	end
	if (event.keyName == "left") then
		left(event)
		if (event.phase == "up") then
			stop()
		end
	end
	
	-- Right
	if (event.keyName == "d") then
		right(event)
		if (event.phase == "up") then
			stop()
		end
	end
	if (event.keyName == "right") then
		right(event)
		if (event.phase == "up") then
			stop()
		end
	end
	
	-- Teleport to the left key
	if (event.keyName == "leftShoulderButton1") then
		if (canTeleport == true) then
			needTeleport = true
			canTeleport = false
			Tx = lkey.x
			Ty = lkey.y
			teleportStatusText.text = " "
		end
	end
	if (event.keyName == "leftShoulderButton2") then
		if (canTeleport == true) then
			needTeleport = true
			canTeleport = false
			Tx = lkey.x
			Ty = lkey.y
			teleportStatusText.text = " "
		end
	end
	
	-- Teleport to the right key
	if (event.keyName == "rightShoulderButton1") then
		if (canTeleport == true) then
			needTeleport = true
			canTeleport = false
			Tx = rkey.x
			Ty = rkey.y
			teleportStatusText.text = " "
		end
	end
	if (event.keyName == "rightShoulderButton2") then
		if (canTeleport == true) then
			needTeleport = true
			canTeleport = false
			Tx = rkey.x
			Ty = rkey.y
			teleportStatusText.text = " "
		end
	end
	
end
Runtime:addEventListener("key", keyEventHandler)

-- Analog Stick Movement
local function onAxisEvent( event )
    if (event.axis.descriptor == "Gamepad 1: Axis 1") then
		if (event.normalizedValue < -0.5) then
			left(event)
		elseif (event.normalizedValue > 0.5) then
			right(event)
		else
			stop()
		end
	end
end

-- Add the axis event listener
Runtime:addEventListener( "axis", onAxisEvent )

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end

-- show()
function scene:show( event )

end


-- hide()
function scene:hide( event )
	timer.cancel( gameLoopTimer )
	physics.pause()
end

-- destroy()
function scene:destroy( event )
	gameActive = false
	-- Remove the main game group
	while mainGroup.numChildren > 0 do
        local child = mainGroup[1]
        if child then child:removeSelf() end
    end
	
	-- Remove the ui group
	while uiGroup.numChildren > 0 do
        local child = uiGroup[1]
        if child then child:removeSelf() end
    end
	
	-- Dispose audio!
	audio.dispose( jumpsfx )
	audio.dispose( collectsfx )
	audio.dispose( completesfx )
	audio.dispose( deathsfx )
	audio.dispose( gainlifesfx )
	audio.dispose( gainshieldsfx )
	audio.dispose( gainteleportsfx )
	audio.dispose( firesfx )
	audio.dispose( lasersfx )
	audio.dispose( barriersfx )
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene