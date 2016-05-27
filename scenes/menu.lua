

local composer = require('composer')
local widget = require('widget')
local relayout = require('libs.relayout')
local sounds = require('libs.sounds')

local scene = composer.newScene()


local params

local function handlePlayButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.removeScene( "scenes.level_select", false )
        composer.gotoScene("scenes.level_select", { effect = "crossFade", time = 333 })
    end
end

local function handleHelpButtonEvent( event )
    if ( "ended" == event.phase ) then
        composer.gotoScene("scenes.help", { effect = "crossFade", time = 333, isModal = true })
    end
end

local function handleCreditsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("scenes.gamecredits", { effect = "crossFade", time = 333 })
    end
end

local function handleSettingsButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("scenes.gamesettings", { effect = "crossFade", time = 333 })
    end
end


-- Android's back button action
function scene:gotoPreviousScene()
    native.showAlert('Parcourarum', 'Are you sure you want to exit the game?', {'Yes', 'Cancel'}, function(event)
        if event.action == 'clicked' and event.index == 1 then
            native.requestExit()
        end
    end)
end
--
-- Start the composer event handlers
--
function scene:create( event )
    local sceneGroup = self.view

    params = event.params
        
    --
    -- setup a page background, really not that important though composer
    -- crashes out if there isn't a display object in the view.
    --
    
    

    local title = display.newText("PARCOURARUM", 100, 32, native.systemFontBold, 64 )
    title.x = display.contentCenterX
    title.y = 80
    title:setFillColor( 1 )
    sceneGroup:insert( title )

    -- Create the widget
    local playButton = widget.newButton({
        id = "button1",
        label = "Jouer",
        labelColor = { default={1,1,0}, over={0,0,0,0.5}},
        width = 200,
        height = 64,
        font= native.systemFontBold,
        fontSize= 48,
        onEvent = handlePlayButtonEvent
    })
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY - 200
    sceneGroup:insert( playButton )

    -- Create the widget
    local settingsButton = widget.newButton({
        id = "button2",
        label = "Paramètres",
        width = 100,
        height = 64,
           font= native.systemFontBold,
        fontSize= 48,
        onEvent = handleSettingsButtonEvent
    })
    settingsButton.x = display.contentCenterX
    settingsButton.y = display.contentCenterY - 100
    sceneGroup:insert( settingsButton )

    -- Create the widget
    local helpButton = widget.newButton({
        id = "button3",
        label = "Aide",
        width = 100,
        height = 64,
         font= native.systemFontBold,
        fontSize= 48,
        onEvent = handleHelpButtonEvent
    })
    helpButton.x = display.contentCenterX
    helpButton.y = display.contentCenterY 
    sceneGroup:insert( helpButton )

    -- Create the widget
    local creditsButton = widget.newButton({
        id = "button4",
        label = "Credits",
        width = 100,
        height = 64,
         font= native.systemFontBold,
        fontSize= 48,
        onEvent = handleCreditsButtonEvent
    })
    creditsButton.x = display.contentCenterX
    creditsButton.y = display.contentCenterY + 100
    sceneGroup:insert( creditsButton )

end

function scene:show( event )
    local sceneGroup = self.view

  
    if event.phase == "did" then
        composer.removeScene( "scenes.game" ) 
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
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
