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

function getCoorPl(board,coordinate)
	playerNumber = Int(board[coordinate.x,coordinate.y])
	if playerNumber == 1 
		return 'B'
	elseif playerNumber == 2
		return 'W'
	elseif playerNumber == 0
		return 'N'	
	end
end

function getCoorPlNum(board,coordinate)
	return Int(board[coordinate.x,coordinate.y])
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
	if container[1][1] == 0 && container[1][2] == 0
		container[1] = coordinate
	else
		push!(container,coordinate)
	end
end

function delCoordinate(container,coordinate)
	deleteat!(container, findfirst(container, coordinate))
end

function popCoordinate(container)
	return pop!(container)
end

function isContEmpty(container)
	if size(container)[1] == 0 
		return true
	end
	
	if container[1][1] == 0 && container[1][2] == 0
		return true
	else
		return false
	end
end

# Empty coordinate for when a player decides a Pass turn
function passCoordinate()
	map(x -> Int(x),zeros(1,2))
end


type Coordinate
	x::Int64
	y::Int64

	numToCoor::Function
	getCoorStr::Function
	getCoorInt::Function

	function Coordinate(coords)
		this = new()
		
		if typeof(coords) == ASCIIString	# coords are givena as String {"xy"}
			this.x = Int(coords[1])-48
			this.y = Int(coords[2])-48
		elseif typeof(coords) == Int64		# coords are givena as Int64 {xy}
			this.x = Int((coords - (coords%10)) / 10)
			this.y = Int(coords%10)
		else
			this.x = 0						# Initialize for default when coords
			this.y = 0						# type is unknown
			println("Unknown coordinate initialization")
		end


		this.numToCoor = function(string::ASCIIString)
			this.x = Int(string[1])-48
			this.y = Int(string[2])-48
		end

		this.getCoorStr = function()
			return  string(this.x) * string(this.y)
		end

		this.getCoorInt = function()
			return (this.x*10)+this.y
		end 

		return this
	end

	function Coordinate(coord1,coord2)
		x = ""
		if typeof(coord1) == ASCIIString
			x = coord1
		elseif typeof(coord1) == Int64
			x = string(coord1)
		end

		y = ""
		if typeof(coord2) == ASCIIString
			y = coord2
		elseif typeof(coord2) == Int64
			y = string(coord2)
		end

		return Coordinate(x*y)
	end
end

type CoorContainerN
	contt::Array{Coordinate,1}

	add::Function
	pop::Function
	remove::Function
	isEmpty::Function
	getSize::Function
	getCoordinate::Function

	function CoorContainerN()
		this = new()
		this.contt = [Coordinate(00)]

		this.add = function(coor)
			if this.contt[1].x == 0 && this.contt[1].y == 0
				this.contt[1] = coor
			else
				push!(this.contt,coor)
			end
		end

		this.pop = function()
			pop!(this.contt)
		end

		this.remove = function(Coordinate::coor)
			delCoordinate(this.contt,coor)
		end

		this.isEmpty = function()
			if this.contt[1].x == 0 && this.contt[1].y == 0
				return true
			else
				return false
			end
		end

		this.getSize = function()
			return size(this.contt)[1]
		end

		this.getCoordinate = function(i::Int64)
			return this.contt[i]
		end

		return this
	end
end 