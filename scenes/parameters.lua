--- ecran de parametres


local composer = require('composer')
local widget = require('widget')
local relayout = require('libs.relayout')
local sounds = require('libs.sounds')
local databox = require('libs.databox')

local scene = composer.newScene()

-- Handle press events for the checkbox
local function onSwitchPressSound( event )
    local switch = event.target
     databox.isSoundOn = not (switch.isOn)
     sounds.isSoundOn =  not(switch.isOn)

    if ( switch.isOn) then
        sounds.stop()

    end


end


-- Handle press events for the checkbox
local function onSwitchPressMusic( event )
    local switch = event.target
     databox.isMusicOn = not (switch.isOn)
    sounds.isMusicOn = not (switch.isOn)
       
  if ( switch.isOn) then
        sounds.stop()

    end


end

local function handleBackButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.gotoScene("scenes.menu", { effect = "crossFade", time = 333 })
    end
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
    
    

    local title = display.newText("Parametres", 100, 32, native.systemFontBold, 64 )
    title.x = display.contentCenterX
    title.y = 80
    title:setFillColor( 1 )
    sceneGroup:insert( title )

    local soundText=display.newText("Son ",180,210,native.systemFontBold, 48 )

   -- Create the widget
    local onOffSound = widget.newSwitch(
        {
            left = 350,
            top = 200,
            style = "onOff",
            id = "onOffSound",
            initialSwitchState=databox.isSoundOn,
            onPress = onSwitchPressSound
        }
    )
    
    sceneGroup:insert( soundText )
    sceneGroup:insert( onOffSound )


    local musicText=display.newText("Musique ",180,310,native.systemFontBold, 48 )

   -- Create the widget
    local onOffMusic = widget.newSwitch(
        {
            left = 350,
            top = 300,
            style = "onOff",
            id = "onOffMusic",
            initialSwitchState=databox.isMusicOn,
            onPress = onSwitchPressMusic
        }
    )


    sceneGroup:insert( musicText )
    sceneGroup:insert( onOffMusic )

 -- Create the widget
    local backButton = widget.newButton({
        id = "back",
        label = "Retour Menu",
        width = 100,
        height = 64,
         font= native.systemFontBold,
        fontSize= 48,
        onEvent = handleBackButtonEvent
    })
    backButton.x = display.contentCenterX
    backButton.y = display.contentCenterY + 300
    sceneGroup:insert( backButton )

   

end

function scene:show( event )
    local sceneGroup = self.view

  
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
