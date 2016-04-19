# # # # # # # # # # # # # #			Coordinates.jl			# # # # # # # # # # # # # #

# Converting from input to Coordinate
function numToCoor(numCoor)
	Coor = zeros(1,2)

	# Coordinates are given as "00" - String
	if typeof(numCoor) == ASCIIString
		setindex!(Coor, Int(numCoor[1])-48, 1)
		setindex!(Coor, Int(numCoor[2])-48, 2)
		Coor = map(x -> Int(x) ,Coor) 
	end

	# Coordinates are given as 00 - Integer
	if typeof(numCoor) == Int64
		setindex!(Coor, Int((numCoor - (numCoor%10)) / 10), 1)
		setindex!(Coor, Int(numCoor%10), 2)
	end

	Coor = map(x -> Int(x) ,Coor) 
	return Coor
end

function numToCoor(numCoor1,numCoor2)
	Coor = zeros(1,2)

	# Coordinates are given as (0,0) - Integer
	if typeof(numCoor1) == Int64 && typeof(numCoor2) == Int64
		setindex!(Coor, numCoor1, 1)
		setindex!(Coor, numCoor2, 2)
	end

	Coor = map(x -> Int(x) ,Coor) 
	return Coor
end

function letToCoor(letCoor)
	Coor = zeros(1,2)
	setindex!(Coor, Int(letCoor[1])-96, 1)
	setindex!(Coor, Int(letCoor[2])-96, 2)
	Coor = map(x -> Int(x) ,Coor)
end



# Converting Coordinate to text or integer
function coorToLet(coordinate)
	coordinate[1][1],coordinate[1][2]
end

function coorToNum(coordinate)
	Int(coordinate[1][1]),Int(coordinate[1][2])
end



# Getters
function getCoorX(coordinate)
	return coordinate[1]
end

function getCoorY(coordinate)
	return coordinate[2]
end



# Empty Coordinate container
function CoorContainer(;coor=map(x -> Int(x),zeros(1,2)))
	Container = []

	if coor != nothing
		push!(Container,coor)
	end
end

# Adding coordinate to given container
function addCoordinate(container,coordinate)
	push!(container,coordinate)
end

# Empty coordinate for when a player decides a Pass turn
function passCoordinate()
	map(x -> Int(x),zeros(1,2))
end