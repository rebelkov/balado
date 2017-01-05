local composer = require( "composer" )
 
local scene = composer.newScene()
local widget = require('widget')
local relayout = require('libs.relayout') -- Repositions elements on screen on window resize

local scene = composer.newScene()



--
-- Start the composer event handlers
--
function scene:create( event )
    local sceneGroup = self.view

      local background = display.newImageRect(sceneGroup, 'images/end_level.png', 480, 480)
	sceneGroup.x, sceneGroup.y = relayout._CX,relayout._CY
sceneGroup.x, sceneGroup.y = 0,0
print(sceneGroup.x, sceneGroup.y )

	relayout.add(background)

	local label = display.newText({
		parent = sceneGroup,
		text = 'GAGGNE !!',
		x = 0, y = -80,
		font = native.systemFontBold,
		fontSize = 64
	})

	relayout.add(label)

	local menuButton = widget.newButton({
		defaultFile = 'images/buttons/menu.png',
		overFile = 'images/buttons/menu-over.png',
		width = 96, height = 105,
		x = -120, y = 80,
		onRelease = function()
			sounds.play('tap')
			print('GO to Menu')
			composer.gotoScene('scenes.menu', {time = 500, effect = 'slideRight'})
		end,
		
	})
	menuButton.isRound = true
	relayout.add(menuButton)
	--sceneGroup:insert(menuButton)

	local restartButton = widget.newButton({
		defaultFile = 'images/buttons/restart.png',
		overFile = 'images/buttons/restart-over.png',
		width = 96, height = 105,
		x = 0, y = menuButton.y,
		onRelease = function()
			sounds.play('tap')
			composer.gotoScene('scenes.reload_game', {params = params.levelId})
		end
	})
	restartButton.isRound = true
	--sceneGroup:insert(restartButton)
	relayout.add(restartButton)
end

function scene:show( event )
    local sceneGroup = self.view

end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
   local parent = event.parent  -- Reference to the parent scene object
 

   if ( phase == "will" ) then
      -- Call the "resumeGame()" function in the parent scene
      --parent:resumeGame()
   end

end

function scene:destroy( event )
    local sceneGroup = self.view
    
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
