-----------------------------------------------------------------------------------------
--
-- complete.lua
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

local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end



local completeText

local function loadNextLevel()
	composer.gotoScene( "game", { params = {lastscore = score, lastlives = lives, prevscene = 2} } )
end

local function returnToMenu()
	-- Load the previous scores
	loadScores()
	-- Insert the saved score from the last game into the table
	table.insert( scoresTable, score )
	-- Sort the table entries from highest to lowest
	local function compare( a, b )
		return a > b
	end
	table.sort( scoresTable, compare )
	-- Save the scores
	saveScores()
	-- Return to Menu
	composer.gotoScene( "menu", { params = {prevscene = 1} } )
end

-- create()
function scene:create( event )
	lives = event.params.lastlives
	score = event.params.lastscore + 1	
	composer.removeScene( "game" )
	if (event.params.lost == false) then
		completeText = display.newText("Level Completed!", Cx, Cy, default, 50)
		timer.performWithDelay( 3000, loadNextLevel )
	else
		score = score - 1
		completeText = display.newText("Game Over!", Cx, Cy, default, 50)
		timer.performWithDelay( 3000, returnToMenu )
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
	completeText:removeSelf()
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