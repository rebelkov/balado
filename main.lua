---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------
-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )
system.activate('multitouch')
if system.getInfo('build') >= '2015.2741' then -- Allow the game to be opened using an old Corona version
	display.setDefault('isAnchorClamped', false) -- Needed for scenes/reload_game.lua animation
end

local platform = system.getInfo('platformName')
if platform == 'tvOS' then
	system.setIdleTimer(false)
end

-- Hide navigation bar on Android
if platform == 'Android' then
	native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
end



display.setDefault("background", 0.5, 0.5, 0.5)

local composer = require('composer')
composer.recycleOnSceneChange = true -- Automatically remove scenes from memory
composer.setVariable('levelCount', 20) -- Set how many levels there are under levels/ directory


-- Exit and enter fullscreen mode
-- CMD+CTRL+F on OS X
-- F11 or ALT+ENTER on Windows
if platform == 'Mac OS X' or platform == 'Win' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and (
				(platform == 'Mac OS X' and event.keyName == 'f' and event.isCommandDown and event.isCtrlDown) or
					(platform == 'Win' and (event.keyName == 'f11' or (event.keyName == 'enter' and event.isAltDown)))
			) then
			if native.getProperty('windowMode') == 'fullscreen' then
				native.setProperty('windowMode', 'normal')
			else
				native.setProperty('windowMode', 'fullscreen')
			end
		end
	end)
end


-- Add support for back button on Android and Window Phone
-- When it's pressed, check if current scene has a special field gotoPreviousScene
-- If it's a function - call it, if it's a string - go back to the specified scene
if platform == 'Android' or platform == 'WinPhone' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and event.keyName == 'back' then
			local scene = composer.getScene(composer.getSceneName('current'))
            if scene then
				if type(scene.gotoPreviousScene) == 'function' then
                	scene:gotoPreviousScene()
                	return true
				elseif type(scene.gotoPreviousScene) == 'string' then
					composer.gotoScene(scene.gotoPreviousScene, {time = 500, effect = 'slideRight'})
					return true
				end
            end
		end
	end)
end

-- This library automatically loads and saves it's storage into databox.json inside Documents directory
-- And it uses iCloud KVS storage on iOS and tvOS
local databox = require('libs.databox')
databox({
	isSoundOn = false,
	isMusicOn = true,
	isHelpShown = false,
	overscanValue = 0
})

-- This library manages sound files and music files playback
-- Inside it there is a list of all used audio files
local sounds = require('libs.sounds')
sounds.isSoundOn = databox.isSoundOn
sounds.isMusicOn = databox.isMusicOn


-- This library helps position elements on the screen during the resize event
require('libs.relayout')

-- Show menu scene
composer.gotoScene('scenes.menu')
--composer.gotoScene( "main_algo" )
-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc)

