-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

-- Shortcut variables
local Cx = display.contentCenterX
local Cy = display.contentCenterY
local H = Cy * 2
local W = Cx * 2

local composer = require( "composer" )
local scene = composer.newScene()

local titleText
local playButton
local highScoresButton
local playText
local highScoresText

local function loadGame()
	composer.gotoScene( "game", { params = {lastscore = 0, lastlives = 10, prevscene = 1} } )
end

local function gotoHighScores()
	composer.gotoScene( "highscores" )
end

-- create()
function scene:create( event )
	if (event.params.prevscene == 1) then
		composer.removeScene( "complete" )
	end
	if (event.params.prevscene == 2) then
		composer.removeScene( "highscores" )
	end

	titleText = display.newText("Infinite Platformer", Cx, Cy/2, default, 100)
	titleText:setFillColor(1,0.5,0.5)
	
	playButton = display.newRect(Cx, Cy, W/4, 100)
	highScoresButton = display.newRect(Cx, 3*Cy/2, W/4, 100)
	playButton.alpha = 0.5
	highScoresButton.alpha = 0.5
	playText = display.newText("Play", Cx, Cy, default, 30)
	highScoresText = display.newText("High Scores", Cx, 3*Cy/2, default, 30)
	
	playButton:addEventListener("touch", loadGame)
	highScoresButton:addEventListener("touch", gotoHighScores)
end

-- show()
function scene:show( event )

end


-- hide()
function scene:hide( event )

end

-- destroy()
function scene:destroy( event )
	titleText:removeSelf()
	playButton:removeSelf()
	highScoresButton:removeSelf()
	playText:removeSelf()
	highScoresText:removeSelf()
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