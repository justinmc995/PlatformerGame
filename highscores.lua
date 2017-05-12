-----------------------------------------------------------------------------------------
--
-- highscores.lua
--
-----------------------------------------------------------------------------------------

-- Shortcut variables
local Cx = display.contentCenterX
local Cy = display.contentCenterY
local H = Cy * 2
local W = Cx * 2

local composer = require( "composer" )
local scene = composer.newScene()



local json = require( "json" )

local scoresTable = {}
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )



local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end



local menuButton
local menuText

local function gotoMenu()
	composer.gotoScene( "menu", { params = {prevscene = 2} } )
end

local uiGroup = display.newGroup()

-- create()
function scene:create( event )
	-- Remove Menu
	composer.removeScene( "menu" )
	-- Create Menu Button
	menuButton = display.newRect(uiGroup, Cx, Cy/4, W/4, 100)
	menuButton.alpha = 0.5
	menuText = display.newText(uiGroup, "Menu", Cx, Cy/4, default, 30)
	menuButton:addEventListener("touch", gotoMenu)
	-- Load the scores
	loadScores()
	display.newText(uiGroup, "High Scores:", Cx, Cy/4 + 100, default, 30)
	for i = 1, 10, 1 do
		display.newText(uiGroup, i .. ") " .. scoresTable[i], Cx, Cy/4 + i*50 + 100, default, 30)
	end
end

-- show()
function scene:show( event )

end


-- hide()
function scene:hide( event )

end

-- destroy()
function scene:destroy( event )
	--menuButton:removeSelf()
	--menuText:removeSelf()
	while uiGroup.numChildren > 0 do
        local child = uiGroup[1]
        if child then child:removeSelf() end
    end
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