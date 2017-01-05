--utilitaires

local _M={}


--function pour calculer la distance entre deux points
function _M.distanceEuclidienneBetween( point1, point2 )
	
	local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
	local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
	return distanceBetween
end



return _M