
local composer = require( "composer" )

local scene = composer.newScene()
local physics = require "physics"
physics.start()

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
local BRICK_W=20
local BRICK_H=50
local W_LEN=20
print ("Width "..display.contentWidth)
print ("Height "..display.contentHeight)
local size_x=display.contentWidth / W_LEN
local size_y=display.contentHeight / W_LEN
local levels = {}
local speedOvni=50

--matrcie de level
-- value 1 - objet fixe
 levels[1] =  {
						{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                         {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                         {0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0},
                          {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                           {0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                           {0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                           {0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                         {0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
                         {0,0,0,1,1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0},
                          {0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,0,1,0,0,1,2,0,0,0,0,0,0,0,1,0,0},
                          {0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0},
                          {0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0},
                           {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                           {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
                  }

	local blocs = display.newGroup()

local playerCollisionFilter = { categoryBits=1, maskBits=6 } --collision avec brick(2) et ovni(4)
local brikCollisionFilter = { categoryBits=2, maskBits=5 } --collision avec player(1) et ovni (4)
local ovniCollisionFilter = { categoryBits=4, maskBits=3 } --collision avec brick(2) et player(1)

--function pour calculer la distance entre deux points
local function distanceBetween( point1, point2 )
	local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
	local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
	return distanceBetween
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
		if ( followModule.ppg ) then
			for p = followModule.ppg.numChildren,1,-1 do display.remove( followModule.ppg[p] ) end
		end
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
	if ( event.phase == "began" ) then
		print ("draw path "..event.phase)
		clearPath()
		print ("Path point START "..#pathPoints)

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
		end
	elseif ( event.phase == "moved" and isMovedAvailable == 1) then
		
		--print ("draw path "..event.phase)

		local previousPoint = pathPoints[#pathPoints]
		local dist = distanceBetween( previousPoint, event )

		--create end point object for visualization
		if not ( anchorPoints[2].x ) then
			anchorPoints[2] = display.newCircle( event.x, event.y, 20 )
			anchorPoints[2]:setFillColor( 1, 0, 0.2 )
		end
		
		--affiche trace : cache premier point derriere cercle
		-- on suprime le chemin complet si premier point
		-- sinon on supprime objet segment memoire
		--Si trop loin pas de trcae 
		if isDragAvailable == 1 then
			if ( #pathPoints < 2 ) then
				if ( path ) then display.remove( path ) end
				print("pervious "..previousPoint.y)
				path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
				path:setStrokeColor( 0.5, 1, 1 )
				path.strokeWidth = 4
				path:toBack()
			else
				-- path:setStrokeColor( 0.5, 0.5, 0.5 )
				-- if ( leadingSegment ) then display.remove( leadingSegment ) end
				-- leadingSegment = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
				-- leadingSegment:setStrokeColor( 1, 1, 1 )
				-- leadingSegment.strokeWidth = 4
				-- leadingSegment:toBack()
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
	 print ("Relachement draw path "..event.phase)
		pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
		-- poitn arrivee devient le prochin pt de depart si non arrive
		
		print ("nb point à suivre"..#pathPoints)

		
		
		if ( leadingSegment ) then display.remove( leadingSegment ) end
		if ( path and path.x and #pathPoints > 2 ) then path:append( event.x, event.y ) end

		local distFinish=distanceBetween(event,arrivee) 
		
		--start follow module
		if ( #pathPoints > 1 ) then
			followModule.init( followParams, pathPoints, pathPrecision, anchorPoints[1],follower )
			--physics.addBody (followModule.obj, "dynamic", {bounce=0.8})

			startx = anchorPoints[2].x
			starty = anchorPoints[2].y
			anchorPoints[1].x = startx
			anchorPoints[1].y = starty
			--for i = #pathPoints,1,-1 do pathPoints[i] = nil end
		end
		if distFinish < 20 then
				print ("ARRIVEE !!!!")

		end
	end

	return true
end


local function finRebond()


	print ("Rebond - anchorPoints[1] "..anchorPoints[1].x.."/"..anchorPoints[1].y)
end


-- gestion de la colision du player avec un bloc
local function blocCollision(event)
	
	print ("Collision "..event.phase)
	if event.phase== 'began' then
			local nbcase_rebond=3
			if (follower.nextPoint < nbcase_rebond) then
				nbcase_rebond=follower.nextPoint - 1
			end 
			isFollowing = 0
			print ("Debut colision au point "..follower.nextPoint .." / "..#pathPoints)
			print ("je vais reculer de "..nbcase_rebond.." cases");
			if (nbcase_rebond > 0 and #pathPoints > 0) then
				anchorPoints[1].x = pathPoints[follower.nextPoint-nbcase_rebond].x
				anchorPoints[1].y = pathPoints[follower.nextPoint-nbcase_rebond].y
			
			end

			startx=anchorPoints[1].x
			starty=anchorPoints[1].y
			print ("anchorPoints[1] "..anchorPoints[1].x.."/"..anchorPoints[1].y)
			print ("pathPoint precedent "..follower.nextPoint.. " / "..#pathPoints)
			
		 	if (#pathPoints > 0) then
		  		print ("je recule de "..nbcase_rebond.." cases  "..pathPoints[follower.nextPoint-nbcase_rebond].x.. " / "..pathPoints[follower.nextPoint-nbcase_rebond].y)
		  		transition.to( follower, {
							tag = "rebondObject",
							x = pathPoints[follower.nextPoint-nbcase_rebond].x,
							y = pathPoints[follower.nextPoint-nbcase_rebond].y
				})

   				
   		 	end
				
	elseif event.phase == "ended" then
	-- pathPoints[#pathPoints].x = anchorPoints[1].x 
	-- pathPoints[#pathPoints].y = anchorPoints[1].y 
	print ("collision ended "..#pathPoints)
	clearPath()
	--clearPath()
	end

-- return true					
			
end


-- gestion de la colision ovni avec un bloc
local function ovniCollision(event)
	if event.phase== 'began' then
		print ("ovni collision began de "..event.target.name.." avec "..event.other.name)
		if event.other.name == 'brick'  then
		 		 print("colision avec "..event.other.name)
		 		
		 		 event.target:setLinearVelocity(event.target.speed, 0 )
		 		 event.target.speed = - event.target.speed
		 		 return true
		 		
			end
		
	elseif event.phase == "ended" then
		print ("ovni collision ended ")
		if event.other.name == 'player' then
			print ("ARRET Transition ")
			event.target:setLinearVelocity(0, 0 )
			transition.cancel("rebondObject")
			return true
		  		
		end
	end
end


--creation du level 
--  creation des brik et bloc selon matrice de level
function buildLevel(level)

    -- Level length, height

    local len = table.maxn(level)
    blocs:toFront()

    for i = 1, len do
        for j = 1, W_LEN do
            if(level[i][j] == 1) then
                --local brick = display.newImage('brick.png')
                  local brick=display.newRect(120,220,size_x,size_y)
                brick.name = 'brick'
                brick.x = size_x*j 
                brick.y = size_y*i
                physics.addBody(brick, {density = 1, friction = 0, bounce = 0,filter=brikCollisionFilter})
                brick.bodyType = 'static'
                blocs.insert(blocs, brick)
            end
            if(level[i][j] == 2) then
            	local ovni=display.newRect(120,220,size_x,size_y)
            	ovni.name = 'ovni'
            	ovni.x = size_x*j
            	ovni.y = size_y*i
            	physics.addBody(ovni,{density = 1, friction = 0, bounce = 0,filter=ovniCollisionFilter})
            	ovni.bodyType = 'dynamic'
            	ovni.gravityScale = 0
            	ovni.speed = speedOvni
            	ovni:setLinearVelocity( speedOvni, 0 )
            	ovni:addEventListener( 'collision', ovniCollision )
            	blocs.insert(blocs,ovni)
            end
        end
    end
end


----------------------------------------------------------------------
----------------------------------------------------------------------
-- "scene:create()"
function scene:create( event )
	local sceneGroup = self.view
	-- clear path
	clearPath()
	--objet depart



	entree = display.newCircle( startx, starty, 20 )
	entree:setFillColor(1)

		sceneGroup:insert(entree)

	arrivee = display.newCircle( endx, endy, 20 )
	arrivee:setFillColor(1)
	sceneGroup:insert(arrivee)
	sceneGroup.isVisible = true


	buildLevel(levels[1])
	

	-- bloc=display.newRect(120,220,20,20)
	
	-- physics.addBody (bloc, "static", {bounce=2})
	--blocs:insert(bloc)
	--bloc.isSleepingAllowed = false
	sceneGroup:insert(blocs)

	local playerTable = { 
		width = 32,
		height = 32, 
		numFrames = 736, 
		sheetContentHeight = 736, 
		sheetContentWidth = 1024
	}

	local sequenceData = {
		name = "run",
		frames = { 1, 2},
		time = 600 
	}

	--local follower = display.newPolygon( 0, 0, { 0,-28, 30,28, 0,20, -30,28 } )
	local playerSheet =  graphics.newImageSheet( "sprite_all.png", playerTable )

	--creation du sprite
	follower = display.newSprite( playerSheet, sequenceData ) 
	follower.x= -15
	follower.name = "player"

	physics.addBody (follower, {bounce=0.8},{filter=playerCollisionFilter})
	follower.isSleepingAllowed = false
	
	 
	 follower.gravityScale=0
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
	
  
   anchorPoints[1] = display.newCircle( startx, starty, 20 )
   display.currentStage:addEventListener( "touch", drawPath )  
   follower:addEventListener( 'collision', blocCollision )
    
end

----------------------------------------------------------------------
----------------------------------------------------------------------
function scene:willExit( event )
	local sceneGroup = self.view
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
