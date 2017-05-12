-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
display.setDefault("background", 0.2, 0.2, 0.2)

-- Go to the game
composer.gotoScene( "menu", { params = {gameover = false} } )