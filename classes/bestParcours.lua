local _M = {}

-- Dependencies
local runDijsktra = require 'libs.dijkstra'
local grid = require 'libs.grid'


local W_LEN=20

local size_x= (display.contentWidth - 30) / W_LEN
local size_y=display.contentHeight / W_LEN
-- A custom function that print the actual state of the
-- distance map
local function printDistanceMap(grid)
	print()
	for y,row in ipairs(grid.nodes) do
		for x,cell in ipairs(row) do
			io.write(('%4s'):format(cell.distance))
		end
		io.write('\n')
	end
	print()
end

--function pour calculer la distance entre deux points
local function distanceBetween( point1, point2 )
	local xfactor = point2.x-point1.x ; local yfactor = point2.y-point1.y
	local distanceBetween = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))
	return distanceBetween
end
-- A custom function that print some debugging information
-- It sequentially prints a message, then the distance map, then the path
-- returned by grid.getPath (see grid.lua)
local function printInfo(grid, path, cost, msg)
	print(msg)
	printDistanceMap(grid)
	print(('path : %d steps - cost: %d'):format(#path, cost))
	 -- Print the path  
	for k, node in ipairs(path) do
	    print(('step:%d, x: %d, y: %d'):format(k, node.x*size_x, node.y*size_y))

	end
	print(('-'):rep(80))
end

--calcul coordonnee des point en focntion du path (case qui est fourni par W_LEN)
local function getPathPoint(path)
	local listOfPoints = {}
	local prec={}
	
	local createNode  = require ('libs.node')
	local nodetmp={}

	local totaldistance=0
	
	for k, node in ipairs(path) do
	
	print("node en case "..node.x.." "..node.y);
	
		node.x=math.floor(node.x*size_x)
		node.y=math.floor(node.y*size_y)
		
	--print("node en px "..node.x.." "..node.y);
	
		if k > 1  then

			local nbintermediaire=math.floor(distanceBetween(node,prec) / 30) +1	
			-- print("nb intermdire "..nbintermediaire)	
			totaldistance=totaldistance + math.floor(distanceBetween(node,prec))
			for p=2,nbintermediaire,1 do
				local intervalle_x=node.x - prec.x
				local intervalle_y=node.y - prec.y
				-- print("intervalle "..intervalle_x..","..intervalle_y)
				nodetmp=createNode(math.floor(prec.x + (intervalle_x * (p-1)/nbintermediaire)),math.floor(prec.y + (intervalle_y * (p-1)/nbintermediaire)))
				
				-- print (" prec to node  "..prec.x..","..prec.y.." to "..node.x..","..node.y)
				-- print (" + "..intervalle_x * (p-1)/nbintermediaire.. ","..intervalle_y * (p-1)/nbintermediaire)
				-- print(" coordonnee "..nodetmp.x..","..nodetmp.y)
				table.insert(listOfPoints,nodetmp)
			end
			
		end
		table.insert(listOfPoints,node)
		prec=createNode(node.x,node.y)
	end
	listOfPoints.distance=totaldistance
	return listOfPoints
end

function _M.calculParcours(map,parcours)


	grid.create(map)  -- We create the grid map
	grid.passable = function(value) return value ~= 5  end -- values ~= 5 are passable
	grid.diagonal = true  -- diagonal moves are disallowed (this is the default behavior)

	--grid.distance = grid.calculateManhattanDistance  -- We will use manhattan heuristic
--grid.distance = grid.calculateDiagonalDistance
grid.distance=grid.calculateEuclidienneDistance

print("parcours ".."("..parcours.pos1_x..","..parcours.pos1_y..") to ("..parcours.pos2_x..","..parcours.pos2_y..")")
	local target = grid.getNode(parcours.pos2_x,parcours.pos2_y)
	runDijsktra(grid, target)

	--  Let us read the full path from node(9,9) => node(2,2)
	local start = grid.getNode(parcours.pos1_x,parcours.pos1_y)
	local p, cost = grid.findPath(start,target)
	
	--printInfo(grid, p, cost, 'path')
	
	print('nb de point best '..#p)

  _M.listOfPoints=getPathPoint(p)

	_M.path = p
	_M.cost= cost

end

return _M