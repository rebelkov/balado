
local composer = require( "composer" )

local scene = composer.newScene()
local physics = require "physics"

local clock = require('classes.clockTimer')

local bestParcours = require('classes.bestParcours')

local score = require('classes.score')
local newEndLevelPopup = require('classes.end_level_popup').newEndLevelPopup -- Win/Lose dialog windows

physics.start()

physics.setGravity(0, 0) 

display.setStatusBar( display.HiddenStatusBar )

--require "follow.lua" module (remove if using only main draw code)


local followModule = require( "follow" )
--declare follow module parameters (remove if using only main draw code)
local followParams = { segmentTime=50, constantRate=true, showPoints=true }

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
local brikCollisionFilter = { categoryBits=2, maskBits=5 } --collision avec player(1) et ovni (4)
local ovniCollisionFilter = { categoryBits=4, maskBits=3 } --collision avec brick(2) et player(1)


local depart_x 
local depart_y
local finish_x
local finish_y

local aff_score
local aff_ptarret
local brouillard = {}
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
		-- if ( anchorPoints[1].x ) then display.remove( anchorPoints[1] ) end
		if ( anchorPoints[2].x ) then display.remove( anchorPoints[2] ) end
		
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


local function animation(event)
		timer.cancel(countDownTimer)

		clock.clockText.text="good luck "

		if ( leadingSegment ) then display.remove( leadingSegment ) end

		local distFinish=distanceBetween(event,arrivee) 
		
		--start follow module
		if ( #pathPoints > 1 ) then
			followModule.start( followParams, pathPoints, pathPrecision, anchorPoints[1],follower,playerSprite )
			--print('distance reel '..followModule.distancereel)
			score.distanceRealise=math.floor(score.distanceRealise+followModule.distancereel)
			startx = anchorPoints[2].x
			starty = anchorPoints[2].y
			anchorPoints[1].x = startx
			anchorPoints[1].y = starty
			playerSprite:toFront()
			score.nbarret=score.nbarret + 1
		
		end
		
		aff_score.text=score.distanceRealise.."/"..score.distanceCible
		aff_ptarret.text=score.nbarret
end

--fonction tracage du chemin - appel suite a evenement move
-- phase 1 - init
--  			nettoyage chemin 
--				calcul de distance avec point initial
--				if distance > 20 alors nouveaux point avec coordonnee
-- phase 2 - move -  mouvement et distance < 20 (arret du move)
-- cette phase ets execute tant que le user ne relache pas 
--  		calcul de la distance avec point precedent
--			affichage du point a la coordonnee si distance ok
--			affichage du segment de trace, ou non
--          sauvegarde du point final si distance ok en precision 
-- phase 3 - fin de move - relachement
--        sauvegarde du point arrive
--		 ajout du chemin 	
-- 		 calcul de la distance avec point arrivee
--       appel du module animation du parcours
--         update du nouveau point de depart
--       test si arrivee
local function drawPath( event, start )
	if (isFollowing == 1) then
		return true
	end
	local bx,by
	if ( event.phase == "began" ) then
		-- print ("draw path "..event.phase)
		clock.millisecondsLeft=25000
		countDownTimer = timer.performWithDelay( 100, checkTimer ,250 ) 
		clearPath()
		-- print ("Path point START "..#pathPoints)

		local distStart=distanceBetween(event,anchorPoints[1]) 
		
		if distStart > 20 then
			isMovedAvailable = 0
			-- display.getCurrentStage():setFocus(nil)
			-- anchorPoints[1]:setFillColor( 1, 0.1, 0.1 )
			-- pathPoints[#pathPoints+1] = { x=startx, y=starty }

		--create start point object for visualization
		else
			isMovedAvailable = 1
			anchorPoints[1]:setFillColor( 0.2, 0.8, 0.4 )
			display.getCurrentStage():setFocus( anchorPoints[1] )
			pathPoints[#pathPoints+1] = { x=startx, y=starty }
			  -- for j = 1, 2 do
			  -- 	brouillard
			  -- end

			  -- pos=(math.round(startx / size_x)+1) * (math.round(starty / size_y)+1)
			  --print ("position "..startx.."/"..starty.."/")

			  --print (" coord "..math.round(startx / size_x).."/"..math.round(starty / size_y))
			  bx=math.round(starty / size_y)
			  by=math.round(startx / size_x)
			  if bx < 18 and withBrouillard then
 				brouillard[bx][by].alpha=0
 				brouillard[bx][by+1].alpha=0.2
 				brouillard[bx+1][by+1].alpha=0.2
 				brouillard[bx+1][by].alpha=0.2
 				brouillard[bx+1][by+2].alpha=0.4
 				brouillard[bx+2][by+2].alpha=0.4
 				brouillard[bx+2][by+1].alpha=0.4
 				
 				
			  end
			 --  brouillard[pos].alpha=0.1
			 --  brouillard[pos-1].alpha=0.1
				-- brouillard[pos-2].alpha=0.1
			

		end
	elseif ( event.phase == "moved" and isMovedAvailable == 1) then
		
		--print ("draw path "..event.phase)

		local previousPoint = pathPoints[#pathPoints]
		local dist = distanceBetween( previousPoint, event )

		--create end point object for visualization
		if not ( anchorPoints[2].x ) then
			anchorPoints[2] = display.newCircle( event.x, event.y, 10 )
			anchorPoints[2]:setFillColor( 0.5, 0.5, 0.2 )
		end
		
		--affiche trace : cache premier point derriere cercle
		-- on suprime le chemin complet si premier point
		-- sinon on supprime objet segment memoire
		--Si trop loin pas de trcae 
		if isDragAvailable == 1 then
			if ( #pathPoints < 2 ) then
				if ( path ) then display.remove( path ) end
				-- print("pervious "..previousPoint.y)
				path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
				path:setStrokeColor( 0.5, 0.5, 1 )
				path.strokeWidth = 4
				--path:toBack()
				path:toFront()
			
			end

			  bx=math.round(event.y / size_y)
			  by=math.round(event.x / size_x)
			  --print(" nuage "..bx.."/"..by)
			  brouillard[bx][by].alpha=0

	
 				brouillard[bx][by+1].alpha=0
 				brouillard[bx+1][by+1].alpha=0
 				brouillard[bx+1][by].alpha=0
 				brouillard[bx+1][by+2].alpha=0
 				brouillard[bx+2][by+2].alpha=0
 				brouillard[bx+2][by+1].alpha=0

 				
 			 if bx > 1  and by > 1  then
			  	brouillard[bx-1][by].alpha=0
			  	brouillard[bx-1][by+1].alpha=0
			  	brouillard[bx-1][by-1].alpha=0
			  end
 				
			  if bx > 2  and by > 2  then
			  	brouillard[bx-2][by].alpha=0
			  	brouillard[bx-2][by+1].alpha=0
			  	brouillard[bx-2][by-1].alpha=0
			  end
		end

		--move end point in unison with touch
		anchorPoints[2].x = event.x
		anchorPoints[2].y = event.y

		-- si assez de distance ajout point et ajoute segment
		if ( dist >= pathPrecision and distStart < 20 ) then
			pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
			if (path and path.x and  #pathPoints > 2 ) then path:append( event.x, event.y ) end
		end

		--fin du deplacement - following
	elseif ( (event.phase == "ended" or event.phase == "cancelled") and isMovedAvailable ==1 ) then
	 -- print ("Relachement draw path "..event.phase)
		pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
		-- poitn arrivee devient le prochin pt de depart si non arrive
	   -- print ("nb point à suivre"..#pathPoints)

		
		if ( path and path.x and #pathPoints > 2 ) then path:append( event.x, event.y ) end

		--score.nbpoint=score.nbpoint + #pathPoints
		--aff_score.text=score.nbpoint.."/"..score.nbpointCible
		animation(event)

	end

	if isMovedAvailable==0 and event.phase ~= "began" then
		-- print("Animation forced")
		score.nbarret=score.nbarret + 1
		aff_ptarret.text=score.nbarret
		animation(event)
	end
	return true
end


local function finRebond()


	print ("Rebond - anchorPoints[1] "..anchorPoints[1].x.."/"..anchorPoints[1].y)
end


-- gestion de la colision du player avec un bloc
local function blocCollision(event)
	
	-- print ("Collision "..event.phase)
	if event.phase== 'began' then
			local nbcase_rebond=3
			if (follower.nextPoint <= nbcase_rebond) then
				nbcase_rebond=follower.nextPoint - 1
			end 
			local caseprec=follower.nextPoint-nbcase_rebond
			isFollowing = 0
			
			if (nbcase_rebond > 0 and #pathPoints > 0 and #pathPoints > caseprec ) then
				anchorPoints[1].x = pathPoints[caseprec].x
				anchorPoints[1].y = pathPoints[caseprec].y
			
			end

			startx=anchorPoints[1].x
			starty=anchorPoints[1].y
			
		 	if (#pathPoints > caseprec and caseprec > 0 ) then
		  		-- print ("je recule de "..nbcase_rebond.." cases  "..pathPoints[caseprec].x.. " / "..pathPoints[caseprec].y)
		  		transition.cancel("rebondObject")
		  		transition.to( follower, {
							tag = "rebondObject",
							x = pathPoints[caseprec].x,
							y = pathPoints[caseprec].y
				})
		  		transition.to( playerSprite, {
							tag = "rebondObject",
							x = pathPoints[caseprec].x,
							y = pathPoints[caseprec].y
				})
				
   				
   		 	end

   		 	score.nbarret=score.nbarret + 1
				
	elseif event.phase == "ended" then
	
	clearPath()
	--clearPath()
	end

-- return true					
			
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

    for   i = 1  , len +5 do
    	brouillard[i]={}
        for j = 1  , W_LEN +5 do
        	  brouillard[i][j]=display.newRect(120,220,size_x,size_y)
            		--print("new cx "..i.." "..j)
            		brouillard[i][j].x = size_x*j
            		brouillard[i][j].y = size_y*i
            		brouillard[i][j]:setFillColor( 1, 0, 0 )
            		brouillard[i][j].alpha= 0
        end
     end

    for i = 1, len do
    	
        for j = 1, W_LEN do
        	
			-- if(level[i][j] == 1 or level[i][j]==2) then
				-- local passage=display.newImageRect( blocSheet, 192, size_x, size_y )
				 -- passage.x = size_x*j 
                -- passage.y = size_y*i
                -- passage:toBack()
        	 -- end
			
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
  				-- entree = display.newCircle( size_x*j, size_y*i, 20 )
  				-- entree:setFillColor(1)
  				entree=display.newImageRect( "images/start.png",  size_x, size_y )
  				entree.x=size_x*j
  				entree.y=size_y*i


            end
            if(level[i][j] == 9) then
            	--print("arrivee ".. size_x*j..","..size_y*i)
            	finish_x=j
            	finish_y=i
				--arrivee = display.newCircle( size_x*j, size_y*i, 20 )
				--arrivee:setFillColor(1)
				arrivee=display.newImageRect( "images/finish1.png",  size_x, size_y )
  				arrivee.x=size_x*j
  				arrivee.y=size_y*i
	
            end

    		brouillard[i][j].x = size_x*j
    		brouillard[i][j].y = size_y*i
    		brouillard[i][j]:setFillColor( 1, 0, 0 )
    		if withBrouillard then
    			brouillard[i][j].alpha= 1
    		end
--print("cccx "..i.." "..j)
            if(level[i][j] >7) then
            	   
            		brouillard[i][j].alpha= 0
           

            end

        end
    end

    blocs:toFront()

    
end


function reinitFollower()
	follower.isSleepingAllowed = false
	follower.gravityScale=0
	follower.angularVelocity = 0
	follower:setLinearVelocity( 0, 0 )

end
----------------------------------------------------------------------
----------------------------------------------------------------------
-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	self.levelId = event.params
	print('level '..self.levelId)
	self.level = require('levels.' .. self.levelId)

	withBrouillard = self.level.withBrouillard
-- constrcution du niveau (bloc, trou, entree, arrivee)
	buildLevel(self.level.blocs)
	

sceneGroup:insert(entree)
sceneGroup:insert(arrivee)
	sceneGroup.isVisible = true
	-- bloc=display.newRect(120,220,20,20)
	
	-- physics.addBody (bloc, "static", {bounce=2})
	--blocs:insert(bloc)
	--bloc.isSleepingAllowed = false
	sceneGroup:insert(blocs)

	local playerTable = { 
		width = 16,
		height = 16, 
		numFrames = 16, 
		sheetContentHeight = 64, 
		sheetContentWidth = 64
	}

	local sequenceData = {
		name = "run",
		frames = {1, 2,3,4},
		time = 600 
	}

	--local follower = display.newPolygon( 0, 0, { 0,-28, 30,28, 0,20, -30,28 } )
	follower = display.newCircle(0,-15,10)
	local playerSheet =  graphics.newImageSheet( "images/ant.png", playerTable )

	--creation du sprite
	playerSprite = display.newSprite( playerSheet, sequenceData ) 
	playerSprite.x=-15
	playerSprite.y=entree.y
	follower.x= -15
	follower.y=entree.y
	follower.name = "player"
	follower.alpha=0.1

	physics.addBody (follower, {bounce=0.8},{filter=playerCollisionFilter})
	follower.isSleepingAllowed = false
	
	 
	 follower.gravityScale=0

     --ajout du timer
     clock.newTimer({
     					durationPreparation=25000,
     					x=display.contentCenterX,
     					y=1,
     					size=40
     				})
     --clock.clockText:setfillcolor(0.7,0.7,1)
    
    bestParcours.calculParcours(self.level.blocs,{pos1_x=depart_x,pos1_y=depart_y,
    												pos2_x=finish_x,pos2_y=finish_y
    												})
print('distance total cible '..bestParcours.listOfPoints.distance)

   --  for k, node in ipairs(bestParcours.listOfPoints) do
   --  		local dot = display.newCircle( node.x,node.y, 6 )
			-- dot:setFillColor( 1, 1, 1, 0.4 )
   --  end

    score.initScore()
    score.distanceCible=bestParcours.listOfPoints.distance

    aff_score=display.newText("0".."/"..score.distanceCible, 80, 1, native.systemFontBold, 30)
	aff_ptarret=display.newText(score.nbarret, 700, 1, native.systemFontBold, 30)

   followModule.init(follower,arrivee)

	self.endLevelPopup = newEndLevelPopup({g = sceneGroup, levelId = self.levelId})
end



-- Check if the player won or lost
function scene:endLevelCheck()
	-- if not self.isPaused then
	-- 	if #self.bugs == 0 then
	-- 		sounds.play('win')
	-- 		self:setIsPaused(true)
	-- 		self.endLevelPopup:show({isWin = true})
	-- 		timer.cancel(self.endLevelCheckTimer)
	-- 		self.endLevelCheckTimer = nil
	-- 		databox['level' .. self.levelId] = true -- Save level completion
	-- 	elseif self.cannon:getAmmoCount() == 0 then
	-- 		sounds.play('lose')
	-- 		self:setIsPaused(true)
	-- 		self.endLevelPopup:show({isWin = false})
	-- 		timer.cancel(self.endLevelCheckTimer)
	-- 		self.endLevelCheckTimer = nil
	-- 	end
	-- end

	if followModule.distancerestante<20 then
		 if not self.isPaused then
			print ("WIN !!!")
			self:setIsPaused(true)
		    self.endLevelPopup:show({isWin = true})
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
	
  
   anchorPoints[1] = display.newCircle( entree.x, entree.y, 10 )
   display.currentStage:addEventListener( "touch", drawPath )  
   follower:addEventListener( 'collision', blocCollision )
     
     -- Only check once in a while for level end
		self.endLevelCheckTimer = timer.performWithDelay(2000, function()
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
end
----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:didExit( event )
	local sceneGroup = self.view
	display.currentStage:removeEventListener()
	follower.removeEventListener()
  
end

----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:destroy( event )
	local sceneGroup = self.view
	bloc.removeEventListener()
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
