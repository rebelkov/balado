-- player 
-- consiste a creer l'objet pour tracer le parcours
local _M = {}

local util = require("libs.utilities")

function _M.newParcours(params)

	local map = params.map
	local level = params.level
	local pointDepart=params.entree
	--adjust this number to effect the "smoothness" of the path; lower value yields a more precise path
	local pathPrecision = 20

	local newPoint;

	-- creation du point de tracage
	local pointTracage=display.newCircle( pointDepart.x, pointDepart.y, 10 )

	-- Mouvement du point
	-- le mouvement doit être suffisament long pour etre pris en compte (>20 px)
	function pointTracage:touch(event)

		if event.phase == 'began' then
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocused = true
			self:setFillColor( 0.8, 0.8, 0.9 )
			--ajoute les coordonnee du point de depart au parcours util ?
			self.parent:addPointToParcours(event)
			
			
		elseif self.isFocused then
			if event.phase == 'moved' then

				--create end point object for visualization
				if not ( newPoint ) then
					newPoint = display.newCircle( event.x, event.y, 10 )
					newPoint:setFillColor( 0.5, 0.5, 0.8 )
				end

				local nbPointParcours=self.parent:getNbPointParcours()

				-- si distance trop courte entre deux points alors pas de trace
				local previousPoint = self.parent:getLastPointParcours()

				--Debut du trace
				if ( nbPointParcours < 2 ) then
					--supprime ancien chemin
					if ( path ) then 
						display.remove( path ) 
					end
					path = display.newLine( previousPoint.x, previousPoint.y, event.x, event.y )
					path:setStrokeColor( 0.5, 0.5, 1 )
					path.strokeWidth = 4
					path:toFront()
				
				end
				-- si assez de distance ajout point et ajoute segment
				local dist = util.distanceEuclidienneBetween( previousPoint, event )
				if ( dist >= pathPrecision ) then
					self.parent:addPointToParcours(event)
					if (path and path.x and  nbPointParcours >=2 ) then 
							path:append( event.x, event.y ) 
					end
				end

				--move end point in unison with touch
				newPoint.x = event.x
				newPoint.y = event.y
			else

				self.parent:addPointToParcours(event)
				if ( path and path.x and self.parent:getNbPointParcours() > 2 ) then 
								path:append( event.x, event.y ) 
				end
	
				display.getCurrentStage():setFocus(self, nil)
				self.isFocused = false
				
			end
		end
		return true
	end
	pointTracage:addEventListener('touch')
end



return _M