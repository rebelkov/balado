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

local function getPathPoint(path)
	local listOfPoints = {}
	local prec_x
	local prec_y
	local createNode  = require ('libs.node')
	local nodetmp={}

	for k, node in ipairs(path) do
		node.x=math.floor(node.x*size_x)
		node.y=math.floor(node.y*size_y)
	
		if k > 1  then
					
			nodetmp=createNode(math.floor((node.x + prec_x)/2),math.floor((node.y +  prec_y)/2))
			table.insert(listOfPoints,nodetmp)
			
		end
		table.insert(listOfPoints,node)
		prec_x=node.x
		prec_y=node.y
	end

	for k, node in ipairs(listOfPoints) do
		 print(('step:%d, x: %d, y: %d'):format(k, node.x, node.y))

	end
end

function _M.calculParcours(map,parcours)

	grid.create(map)  -- We create the grid map
	grid.passable = function(value) return value ~= 1 end -- values ~= 5 are passable
	grid.diagonal = true  -- diagonal moves are disallowed (this is the default behavior)
	grid.distance = grid.calculateManhattanDistance  -- We will use manhattan heuristic


print("parcours ".."("..parcours.pos1_x..","..parcours.pos1_y..") to ("..parcours.pos2_x..","..parcours.pos2_y..")")
	local target = grid.getNode(parcours.pos2_x,parcours.pos2_y)
	runDijsktra(grid, target)

	--  Let us read the full path from node(9,9) => node(2,2)
	local start = grid.getNode(parcours.pos1_x,parcours.pos1_y)
	local p, cost = grid.findPath(start,target)
	
	--printInfo(grid, p, cost, 'path')

getPathPoint(p)

	_M.path = p
	_M.cost= cost

end

return _M