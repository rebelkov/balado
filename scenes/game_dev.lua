
local composer = require( "composer" )

local scene = composer.newScene()
local physics = require "physics"

local clock = require('classes.clockTimer')

local bestParcours = require('classes.bestParcours')
local score = require('classes.score')

local newParcours = require('classes.parcours').newParcours -- parcours du joueur
local newEndLevelPopup = require('classes.end_level_popup').newEndLevelPopup -- Win/Lose dialog windows
local newFollower = require('classes.follower').newFollower -- parcours du joueur
local newMap = require('classes.map').newMap -- Building blocks for the levels

physics.start()

physics.setGravity(0, 0) 

display.setStatusBar( display.HiddenStatusBar )

--require "follow.lua" module (remove if using only main draw code)


local followModule = require( "follow" )
--declare follow module parameters (remove if using only main draw code)
local followParams = { segmentTime=50, constantRate=true, showPoints=true }
local parcours
local path
local leadingSegment
local pathPoints = {}
local anchorPoints = { {},{} }
local nbarret = 0
--adjust this number to effect the "smoothness" of the path; lower value yields a more precise path
local pathPrecision = 20

local entree
local arrivee
local bloc
local startx = 20
local starty = 1000
local brouillard
local endx = display.viewableContentWidth-20
local endy = 100
local distStart = 0
local isDragAvailable = 1
local isMovedAvailable = 1
isFollowing = 0
local follower
local playerSprite
local BRICK_W=20
local BRICK_H=50
local W_LEN=20
-- print ("Width "..display.contentWidth)
-- print ("Height "..display.contentHeight)
local size_x= (display.contentWidth - 30) / W_LEN
local size_y=display.contentHeight / W_LEN

local speedOvni=50
local countDownTimer
local blocs = display.newGroup()

local playerCollisionFilter = { categoryBits=1, maskBits=6 } --collision avec brick(2) et ovni(4)



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


local function checkTimer()
	--print("checkTimer")
	if clock.millisecondsLeft <= 0 then 
		isMovedAvailable=0
		print(" AIE AIE fin TIMER !!!!!")
	end

	return clock:updateTime()
end

--Fonction de reinit du chemin et du trace
-- suppression des points et des segments utilises
-- supression de la transition
-- supression des objets du module follower encore presents
local function clearPath()
	--reset/clear core
		if ( path ) then display.remove( path ) end
		if leadingSegment then display.remove( leadingSegment ) end
		for i = #pathPoints,1,-1 do pathPoints[i] = nil end
		
		if ( anchorPoints[2] ) then display.remove( anchorPoints[2] ) end
		
		--reset/clear follow module items (remove these lines if not using "follow.lua")
		transition.cancel( "moveObject" )
		--if ( followModule.obj ) then display.remove( followModule.obj ) ; followModule.obj = nil end
		--suppression du trace 
		if ( followModule.ppg ) then
			for p = followModule.ppg.numChildren,1,-1 do display.remove( followModule.ppg[p] ) end
		end

		-- reinit clockTimer
		if clock.millisecondsLeft<=0 then 
			-- print("reinit timer .......")
			clock.clockText.text=" "
			clock.millisecondsLeft=25000
			countDownTimer = timer.performWithDelay( 100, checkTimer ,250 ) 
			
		end
		
end





----------------------------------------------------------------------
----------------------------------------------------------------------
-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	self.levelId = event.params
	print('level '..self.levelId)
	

	-- withBrouillard = self.level.withBrouillard
-- constrcution du niveau (bloc, trou, entree, arrivee)
	--buildLevel(self.level.blocs)
		
	self.map = newMap({size_x=size_x, size_y=size_y, levelId = self.levelId})

	-- sceneGroup:insert(self.map.entree)
	-- sceneGroup:insert(map.arrivee)
	sceneGroup.isVisible = true
	
	--sceneGroup:insert(blocs)

     
	


     --ajout du timer
     clock.newTimer({
     					durationPreparation=25000,
     					x=display.contentCenterX,
     					y=1,
     					size=40
     				})
     --clock.clockText:setfillcolor(0.7,0.7,1)
    
--     bestParcours.calculParcours(self.level.blocs,{pos1_x=map.depart_x,pos1_y=map.depart_y,
--     												pos2_x=map.finish_x,pos2_y=map.finish_y
--     												})
-- print('distance total cible '..bestParcours.listOfPoints.distance)

   --  for k, node in ipairs(bestParcours.listOfPoints) do
   --  		local dot = display.newCircle( node.x,node.y, 6 )
			-- dot:setFillColor( 1, 1, 1, 0.4 )
   --  end

    score.initScore()
    score.nbarret=5
    --score.distanceCible=bestParcours.listOfPoints.distance

 --    aff_score=display.newText("0".."/"..score.distanceCible, 80, 1, native.systemFontBold, 30)
	-- aff_ptarret=display.newText(score.nbarret, 700, 1, native.systemFontBold, 30)

 --   --followModule.init(follower,arrivee)


 --   sceneGroup:insert(aff_score)
 --   sceneGroup:insert(aff_ptarret)
   

local followParams = { segmentTime=50, constantRate=true, showPoints=true, 
					 pathPrecision=20 ,pointDepart=self.map.entree,pointArrivee=self.map.arrivee}
	--initialise simulaton pour calculer la distante restant effective
   self.simulation=newFollower(followParams)
   sceneGroup:insert(self.simulation)
   -- initialise le tracage du parcours
   	self.parcours = newParcours({start=map.entree, level = self.levelId,fin=map.arrivee},self.simulation)

   	--initialise le controle a tout instant de la fin du niveau
	self.endLevelPopup = newEndLevelPopup({g = sceneGroup, levelId = self.levelId})
end



-- Check if the player won or lost
function scene:endLevelCheck()

	if self.simulation.distancerestante<20 then
		 if not self.isPaused then
			print ("WIN !!!")
			clearPath()
			clock.clockText.text=" "
			clock=nil
			if ( anchorPoints[1] ) then display.remove( anchorPoints[1] ) end
			self:setIsPaused(true)
		    self.endLevelPopup:show({isWin = true})
		    timer.cancel(self.endLevelCheckTimer)
			self.endLevelCheckTimer = nil
		end
	elseif score.nbarret<=0 then
		 if not self.isPaused then
			print ("PERDU !!!")
			clearPath()
			clock.clockText.text=" "
			clock=nil
			if ( anchorPoints[1] ) then display.remove( anchorPoints[1] ) end
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
	
	-- g=display.newGroup()
  
 --   anchorPoints[1] = display.newCircle( entree.x, entree.y, 10 )
 -- --   brouillard = display.newImageRect( 'images/end_level.png', 480, 480)
	-- -- brouillard.fill.effect = "filter.iris"
	-- -- brouillard.fill.effect.center = { 0.5, 0.5 }
	-- -- brouillard.fill.effect.aperture = 0.5
	-- -- brouillard.fill.effect.aspectRatio = ( brouillard.width / brouillard.height )
	-- -- brouillard.fill.effect.smoothness = 0.5

 --    brouillard.x=entree.x
 --    brouillard.y=entree.y
   -- g:insert(anchorPoints[1])
   -- g:insert(brouillard)
   -- g:addEventListener( "touch", drawPath )  
   --brouillard:addEventListener("touch",movebrouillard)
   --follower:addEventListener( 'collision', blocCollision )
     
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
