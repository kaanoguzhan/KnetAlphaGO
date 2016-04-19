# # # # # # # # # # # # # #			Coordinates.jl			# # # # # # # # # # # # # #

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

function letToCoor(letCoor)
	Coor = zeros(1,2)
	setindex!(Coor, Int(letCoor[1])-96, 1)
	setindex!(Coor, Int(letCoor[2])-96, 2)
	Coor = map(x -> Int(x) ,Coor)
end

function CoorContainer(;coor=map(x -> Int(x),zeros(1,2)))
	Container = []

	if coor != nothing
		push!(Container,coor)
	end
end

function addCoordinate(container,coordinate)
	push!(container,coordinate)
end

# Empty coordinate for when a player decides a Pass turn
function passCoordinate()
	map(x -> Int(x),zeros(1,2))
end