--construction de la map



-- --Fonction de reinit du chemin et du trace
-- -- suppression des points et des segments utilises
-- -- supression de la transition
-- -- supression des objets du module follower encore presents
-- local function clearPath()
-- 	--reset/clear core
-- 		if ( path ) then display.remove( path ) end
-- 		if leadingSegment then display.remove( leadingSegment ) end
-- 		for i = #pathPoints,1,-1 do pathPoints[i] = nil end
		
-- 		if ( anchorPoints[2] ) then display.remove( anchorPoints[2] ) end
		
-- 		--reset/clear follow module items (remove these lines if not using "follow.lua")
-- 		transition.cancel( "moveObject" )
-- 		--if ( followModule.obj ) then display.remove( followModule.obj ) ; followModule.obj = nil end
-- 		--suppression du trace 
-- 		if ( followModule.ppg ) then
-- 			for p = followModule.ppg.numChildren,1,-1 do display.remove( followModule.ppg[p] ) end
-- 		end

-- 		-- reinit clockTimer
-- 		if clock.millisecondsLeft<=0 then 
-- 			-- print("reinit timer .......")
-- 			clock.clockText.text=" "
-- 			clock.millisecondsLeft=25000
-- 			countDownTimer = timer.performWithDelay( 100, checkTimer ,250 ) 
			
-- 		end
		
-- end


-- local function animation(event)
-- 		timer.cancel(countDownTimer)

-- 		clock.clockText.text="good luck "
-- 		if (path) then display.remove(path) end
-- 		if ( leadingSegment ) then display.remove( leadingSegment ) end

-- 		local distFinish=distanceBetween(event,arrivee) 
		
-- 		--start follow module
-- 		if ( #pathPoints > 1 ) then
-- 			followModule.start( followParams, pathPoints, pathPrecision, anchorPoints[1],follower,playerSprite )
-- 			--print('distance reel '..followModule.distancereel)
-- 			score.distanceRealise=math.floor(score.distanceRealise+followModule.distancereel)
-- 			startx = anchorPoints[2].x
-- 			starty = anchorPoints[2].y
-- 			anchorPoints[1].x = startx
-- 			anchorPoints[1].y = starty
-- 			playerSprite:toFront()
-- 			score.nbarret=score.nbarret - 1
		
-- 		end
		
-- 		aff_score.text=score.distanceRealise.."/"..score.distanceCible
-- 		aff_ptarret.text=score.nbarret
-- end

-- --fonction tracage du chemin - appel suite a evenement move
-- -- phase 1 - init
-- --  			nettoyage chemin 
-- --				calcul de distance avec point initial
-- --				if distance > 20 alors nouveaux point avec coordonnee
-- -- phase 2 - move -  mouvement et distance < 20 (arret du move)
-- -- cette phase ets execute tant que le user ne relache pas 
-- --  		calcul de la distance avec point precedent
-- --			affichage du point a la coordonnee si distance ok
-- --			affichage du segment de trace, ou non
-- --          sauvegarde du point final si distance ok en precision 
-- -- phase 3 - fin de move - relachement
-- --        sauvegarde du point arrive
-- --		 ajout du chemin 	
-- -- 		 calcul de la distance avec point arrivee
-- --       appel du module animation du parcours
-- --         update du nouveau point de depart
-- --       test si arrivee
-- local function drawPath( event, start )
-- 	if (isFollowing == 1 or score.nbarret<=0) then
-- 		return true
-- 	end
-- 	local bx,by
-- 	if ( event.phase == "began" ) then
-- 		-- print ("draw path "..event.phase)
-- 		clock.millisecondsLeft=25000
-- 		countDownTimer = timer.performWithDelay( 100, checkTimer ,250 ) 
-- 		clearPath()
-- 		-- print ("Path point START "..#pathPoints)

-- 		local distStart=distanceBetween(event,anchorPoints[1]) 
		
-- 		if distStart > 20 then
-- 			isMovedAvailable = 0
		
-- 		--create start point object for visualization
-- 		else
-- 			isMovedAvailable = 1
-- 			anchorPoints[1]:setFillColor( 0.8, 0.8, 0.9 )
-- 			display.getCurrentStage():setFocus( anchorPoints[1] )
-- 			pathPoints[#pathPoints+1] = { x=startx, y=starty }
					

-- 		end
-- 	elseif ( event.phase == "moved" and isMovedAvailable == 1) then
-- 		local previousPoint = pathPoints[#pathPoints]
-- 		local dist = distanceBetween( previousPoint, event )

-- 		--create end point object for visualization
-- 		if not ( anchorPoints[2] ) then
-- 			anchorPoints[2] = display.newCircle( event.x, event.y, 10 )
-- 			anchorPoints[2]:setFillColor( 0.5, 0.5, 0.8 )
-- 		end
		
-- 		--affiche trace : cache premier point derriere cercle
-- 		-- on suprime le chemin complet si premier point
-- 		-- sinon on supprime objet segment memoire
-- 		--Si trop loin pas de trcae 
-- 		if isDragAvailable == 1 then
-- 			if ( #pathPoints < 2 ) then
-- 				if ( path ) then display.remove( path ) end
-- 				-- print("pervious "..previousPoint.y)
-- 				path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
-- 				path:setStrokeColor( 0.5, 0.5, 1 )
-- 				path.strokeWidth = 4
-- 				--path:toBack()
-- 				path:toFront()
			
-- 			end

							
 			
-- 		end

-- 		--move end point in unison with touch
-- 		anchorPoints[2].x = event.x
-- 		anchorPoints[2].y = event.y
		
-- 		-- si assez de distance ajout point et ajoute segment
-- 		if ( dist >= pathPrecision and distStart < 20 ) then
-- 			pathPoints[#pathPoints+1] = { x=event.x, y=event.y }

-- 			if (path and path.x and  #pathPoints > 2 ) then path:append( event.x, event.y ) end
-- 		end

-- 		--fin du deplacement - following
-- 	elseif ( (event.phase == "ended" or event.phase == "cancelled") and isMovedAvailable ==1 ) then
-- 	 -- print ("Relachement draw path "..event.phase)
-- 		pathPoints[#pathPoints+1] = { x=event.x, y=event.y }
-- 		if ( path and path.x and #pathPoints > 2 ) then path:append( event.x, event.y ) end
	
-- 		animation(event)
-- 		display.getCurrentStage():setFocus( nil )
-- 		anchorPoints[1].isFocus = nil

-- 	end

-- 	if isMovedAvailable==0 and event.phase ~= "began" then
-- 		-- print("Animation forced")
-- 		score.nbarret=score.nbarret - 1
-- 		aff_ptarret.text=score.nbarret
-- 		animation(event)
-- 	end
-- 	return true
-- end

-- -- touch listener function
-- function movebrouillard( event )
--     if event.phase == "began" then
	
--         self.markX = self.x    -- store x location of object
--         self.markY = self.y    -- store y location of object
	
--     elseif event.phase == "moved" then
	
--         local x = (event.x - event.xStart) + self.markX
--         local y = (event.y - event.yStart) + self.markY
        
--         self.x, self.y = x, y    -- move object based on calculations above
--     end
    
--     return true
-- end

-- local function finRebond()
-- 	print ("Rebond - anchorPoints[1] "..anchorPoints[1].x.."/"..anchorPoints[1].y)
-- end


-- -- gestion de la colision du player avec un bloc
-- local function blocCollision(event)
	
-- 	-- print ("Collision "..event.phase)
-- 	if event.phase== 'began' then
-- 			local nbcase_rebond=3
-- 			if (follower.nextPoint <= nbcase_rebond) then
-- 				nbcase_rebond=follower.nextPoint - 1
-- 			end 
-- 			local caseprec=follower.nextPoint-nbcase_rebond
-- 			isFollowing = 0
			
-- 			if (nbcase_rebond > 0 and #pathPoints > 0 and #pathPoints > caseprec ) then
-- 				anchorPoints[1].x = pathPoints[caseprec].x
-- 				anchorPoints[1].y = pathPoints[caseprec].y
			
-- 			end

-- 			startx=anchorPoints[1].x
-- 			starty=anchorPoints[1].y
			
-- 		 	if (#pathPoints > caseprec and caseprec > 0 ) then
-- 		  		-- print ("je recule de "..nbcase_rebond.." cases  "..pathPoints[caseprec].x.. " / "..pathPoints[caseprec].y)
-- 		  		transition.cancel("rebondObject")
-- 		  		transition.to( follower, {
-- 							tag = "rebondObject",
-- 							x = pathPoints[caseprec].x,
-- 							y = pathPoints[caseprec].y
-- 				})
-- 		  		transition.to( playerSprite, {
-- 							tag = "rebondObject",
-- 							x = pathPoints[caseprec].x,
-- 							y = pathPoints[caseprec].y
-- 				})
				
   				
--    		 	end

--    		 	score.nbarret=score.nbarret + 1
				
-- 	elseif event.phase == "ended" then
	
-- 	clearPath()
-- 	--clearPath()
-- 	end

-- -- return true					
			
-- end










local _M = {}


function _M.newMap(params)

	local map={}
	local brikCollisionFilter = { categoryBits=2, maskBits=5 } --collision avec player(1) et ovni (4)
	local ovniCollisionFilter = { categoryBits=4, maskBits=3 } --collision avec brick(2) et player(1)

	level = require('levels.' .. params.levelId)
		--creation du level 
		--  creation des brik et bloc selon matrice de level
		--local function map:buildLevel(params)

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
		                local brick=display.newImageRect( blocSheet, 201, params.size_x, params.size_y )
		                brick.name = 'brick'
		                brick.x = params.size_x*j 
		                brick.y = params.size_y*i
		                physics.addBody(brick, {density = 1, friction = 0, bounce = 0,filter=brikCollisionFilter})
		                brick.bodyType = 'static'
		                blocs.insert(blocs, brick)
		            end
		            if(level[i][j] == 2) then
		            	--local ovni=display.newRect(120,220,size_x,size_y)
		 				local ovni=display.newImageRect( blocSheet, 196, params.size_x, params.size_y )
		            	ovni.name = 'ovni'
		            	ovni.x = params.size_x*j
		            	ovni.y = params.size_y*i
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
		            	map.depart_x=j
		            	map.depart_y=i
		  				map.entree=display.newImageRect( "images/start.png",  params.size_x, params.size_y )
		  				map.entree.x=params.size_x*j
		  				map.entree.y=params.size_y*i
		            end
		            if(level[i][j] == 9) then
		            	--print("arrivee ".. size_x*j..","..size_y*i)
		            	map.finish_x=j
		            	map.finish_y=i
						map.arrivee=display.newImageRect( "images/finish1.png",  params.size_x, params.size_y )
		  				map.arrivee.x=params.size_x*j
		  				map.arrivee.y=params.size_y*i
		            end
		  		
		        end
		    end

		    --blocs:toFront()

		    
		--end



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
				
			end
		end

	return map
end

return _M