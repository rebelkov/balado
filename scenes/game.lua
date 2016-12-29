
local composer = require( "composer" )
local relayout = require('libs.relayout')

local scene = composer.newScene()
local physics = require "physics"

local clock = require('classes.clockTimer')
local sounds = require('libs.sounds') -- Music and sounds manager

local bestParcours = require('classes.bestParcours')
local score = require('classes.score')

local newParcours = require('classes.parcours').newParcours -- parcours du joueur
local newEndLevelPopup = require('classes.end_level_popup').newEndLevelPopup -- Win/Lose dialog windows
local newFollower = require('classes.follower').newFollower -- parcours du joueur


physics.start()
physics.setGravity(0, 0) 
display.setStatusBar( display.HiddenStatusBar )
--require "follow.lua" module (remove if using only main draw code)
local followModule = require( "follow" )
--declare follow module parameters (remove if using only main draw code)
local followParams = { segmentTime=50, constantRate=true, showPoints=true }
local parcours

local pathPoints = {}
--adjust this number to effect the "smoothness" of the path; lower value yields a more precise path
local pathPrecision = 20

local entree
local arrivee
local bloc
local W_LEN=20
-- print ("Width "..display.contentWidth)
-- print ("Height "..display.contentHeight)
local size_x= (display.contentWidth - 30) / W_LEN
local size_y=display.contentHeight / W_LEN

local speedOvni=50
local countDownTimer
local blocs = display.newGroup()

local playerCollisionFilter = { categoryBits=1, maskBits=6 } --collision avec brick(2) et ovni(4)
local brikCollisionFilter = { categoryBits=2, maskBits=5 } --collision avec player(1) et ovni (4)
local ovniCollisionFilter = { categoryBits=4, maskBits=3 } --collision avec brick(2) et player(1)


local depart_x 
local depart_y
local finish_x
local finish_y

local aff_score
local aff_ptarret

local withBrouillard=false


--function pour calculer la distance entre deux points
local function distanceBetween( point1, point2 )
	local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
	local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
	return distanceBetween
end



-- gestion de la colision ovni avec un bloc
local function ovniCollision(event)
	if event.phase== 'began' then
		-- print ("ovni collision began de "..event.target.name.." avec "..event.other.name)
		if event.other.name == 'brick'  then
		 		
		 		 event.target:setLinearVelocity(event.target.speed, 0 )
		 		 event.target.speed = - event.target.speed
		 		 return true
		 		
			end
		
	elseif event.phase == "ended" then
		--print ("ovni collision ended ")
		if event.other.name == 'player' then
			print ("ARRET Transition ")
			--event.target:setLinearVelocity(0, 0 )
			transition.cancel("rebondObject")
			reinitFollower()
			return true
		  		
		end
	end
end


--creation du level 
--  creation des brik et bloc selon matrice de level
function buildLevel(level)
	local blocTable = { 
		width = 32,
		height = 32, 
		numFrames = 240,
		sheetContentWidth=512,
		sheetContentHeight=480
	}
	
	local blocSheet = graphics.newImageSheet( "images/fond2.png", blocTable )
    -- Level length, height

    local len = table.maxn(level)

   for i = 1, len do
        for j = 1, W_LEN do
  			
            if(level[i][j] == 5) then
                --local brick = display.newImage('brick.png')
                local brick=display.newImageRect( blocSheet, 201, size_x, size_y )
                brick.name = 'brick'
                brick.x = size_x*j 
                brick.y = size_y*i
                physics.addBody(brick, {density = 1, friction = 0, bounce = 0,filter=brikCollisionFilter})
                brick.bodyType = 'static'
                blocs.insert(blocs, brick)
            end
            if(level[i][j] == 2) then
            	--local ovni=display.newRect(120,220,size_x,size_y)
 				local ovni=display.newImageRect( blocSheet, 196, size_x, size_y )
            	ovni.name = 'ovni'
            	ovni.x = size_x*j
            	ovni.y = size_y*i
            	physics.addBody(ovni,{density = 1, friction = 0, bounce = 0,filter=ovniCollisionFilter})
            	ovni.bodyType = 'dynamic'
            	ovni.gravityScale = 0
            	speedOvni = math.random(50,100)
            	ovni.speed = speedOvni
            	ovni:setLinearVelocity( speedOvni, 0 )
            	ovni:addEventListener( 'collision', ovniCollision )
            	blocs.insert(blocs,ovni)
            end
           
            if(level[i][j] == 8) then
            	--print("entree ".. size_x*j..","..size_y*i)
            	depart_x=j
            	depart_y=i
  				entree=display.newImageRect( "images/start.png",  size_x, size_y )
  				entree.x=size_x*j
  				entree.y=size_y*i
            end
            if(level[i][j] == 9) then
            	--print("arrivee ".. size_x*j..","..size_y*i)
            	finish_x=j
            	finish_y=i
				arrivee=display.newImageRect( "images/finish.png",  size_x, size_y )
  				arrivee.x=size_x*j
  				arrivee.y=size_y*i
            end
  		
        end
    end

    blocs:toFront()
  
end


----------------------------------------------------------------------
----------------------------------------------------------------------
-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	self.levelId = event.params
	self.level = require('levels.' .. self.levelId)


	withBrouillard = self.level.withBrouillard
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
	local background = display.newRect(sceneGroup, _CX, _CY, _W, _H)
    background.fill = {
        type = 'gradient',
        color1 = {0.2, 0.45, 0.8},
        color2 = {0.7, 0.8, 1}
    }
    sceneGroup:insert(background)
    --relayout.add(background)
-- constrcution du niveau (bloc, trou, entree, arrivee)
	buildLevel(self.level.blocs)

	sceneGroup:insert(entree)
	sceneGroup:insert(arrivee)
	sceneGroup:insert(blocs)

	--calcul du parcours cible    
    bestParcours.calculParcours(self.level.blocs,{pos1_x=depart_x,pos1_y=depart_y,
    												pos2_x=finish_x,pos2_y=finish_y
    												})


    score.initScore()
    score.nbarret=5
    score.distanceCible=bestParcours.listOfPoints.distance

    aff_score=display.newText("0".."/"..score.distanceCible, 80, 1, native.systemFontBold, 30)

   sceneGroup:insert(aff_score)

   local followParams = { segmentTime=50, constantRate=true, showPoints=true, 
					 pathPrecision=20 ,pointDepart=entree,pointArrivee=arrivee}
	--initialise simulaton pour calculer la distante restant effective
   self.simulation=newFollower(followParams)
   sceneGroup:insert(self.simulation)
   -- initialise le tracage du parcours
   	self.parcours = newParcours({start=entree, level = self.levelId,fin=arrivee, nbArretMax= 5},self.simulation)

   	--initialise le controle a tout instant de la fin du niveau
	self.endLevelPopup = newEndLevelPopup({g = sceneGroup, levelId = self.levelId})
end



-- Check if the player won or lost

function scene:endLevelCheck()

	if self.simulation.distancerestante<20 then
		 if not self.isPaused then
			print ("WIN !!!")
			sounds.play('win')
			clock.clockText.text=" "
			clock=nil
			self:setIsPaused(true)
		    self.endLevelPopup:show({isWin = true})
		    timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
		end
	elseif self.parcours.perdu or self.simulation.perdu then
		 if not self.isPaused then
			print ("PERDU !!!")
			sounds.play('lose')
			clock.clockText.text=" "
			clock=nil
			self:setIsPaused(true)
		    self.endLevelPopup:show({isWin = false})
		    timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
		end
	end
end


function scene:setIsPaused(isPaused)
	self.isPaused = isPaused
	--self.cannon.isPaused = self.isPaused -- Pause adding trajectory points
	isFollowing=1
	if self.isPaused then
		physics.pause()
	else
		physics.start()
	end
end

----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:willEnter( event )
	--local sceneGroup = self.view
   
end
----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:didEnter( event )
	--local sceneGroup = self.view   
  	local sceneGroup = self.view
	
	-- Only check once in a while for level end
		self.endLevelCheckTimer = timer.performWithDelay(1000, function()
			self:endLevelCheck()
		end, 0)
    
end

----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:willExit( event )
	local sceneGroup = self.view
	if self.endLevelCheckTimer then
			timer.cancel(self.endLevelCheckTimer)
	end
	self.simulation:removeObj()
	self.simulation:removeSelf()
	self.simulation=nil
	self.parcours:removeObj()
	if 	self.parcours then
		display.remove(	self.parcours)
	end
end
----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:didExit( event )
	local sceneGroup = self.view
	-- display.currentStage:removeEventListener()
	-- follower.removeEventListener()
  
end

----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:destroy( event )
	local sceneGroup = self.view
	-- bloc.removeEventListener()
end

---------------------------------------------------------------------------------
-- Scene Dispatch Events, Etc. - Generally Do Not Touch Below This Line
---------------------------------------------------------------------------------
function scene:show( event )
	sceneGroup 	= self.view
	local willDid 	= event.phase
	if( willDid == "will" ) then
		self:willEnter( event )
	elseif( willDid == "did" ) then
		self:didEnter( event )
	end
end
function scene:hide( event )
	sceneGroup 	= self.view
	local willDid 	= event.phase
	if( willDid == "will" ) then
		self:willExit( event )
	elseif( willDid == "did" ) then
		self:didExit( event )
	end
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
---------------------------------------------------------------------------------
return scene
