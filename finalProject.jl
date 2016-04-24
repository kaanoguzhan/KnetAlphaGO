include("Coordinates.jl")
include("Players.jl")
include("SGFReaders.jl")
# # # # # # # # # # # # # #		Playing Moves			# # # # # # # # # # # # # #

# player = N -> remove any stone from coordinate(s)
# player = W -> Place white stone to coordinate(s)
# player = B -> Place black stone to coordinate(s)
function coordToBoard(board,coords,player)
	println("at least")
	if typeof(coords) == Coordinate
		board[coords.x,coords.y] = getPlayerNumber(player)
	elseif typeof(coords) == CoorContainerN
		for i = 1 : coords.getsize()
			println(coords)
			if coords.x != 0 && coords.y != 0
			println("hii")
				board[coords[i].x,coords[i].y] = getPlayerNumber(player)
			end
		end
	end
end

function play(board,coordinate,player)
	
	println(" * * * * * * * * * * * * * * * * * * * * * * * * * * *")
	x = coordinate.x
	y = coordinate.y

	# Check if move is played on a neutral square
	if board[x,y] != 0
		return "Error: Move not possible !"
	end

	# Playing on a square that has all neutral around
	if	board[ x+1 <= 19 ? x+1 : x , y ] == 0 &&
		board[ x-1 >= 1  ? x-1 : x , y ] == 0 &&
		board[ x , y+1 <= 19 ? y+1 : y ] == 0 &&
		board[ x , y-1 >= 1  ? y-1 : y ] == 0
			println(player, " played on ", coordinate.getCoorStr())
			coordToBoard(board,coordinate,player)
			return
	end

	# Playing on a square that has PROBLEM!
	println(player, " played on ", coordinate.getCoorStr())
			
	nnn = getNonNeurtalNeigbours(board,coordinate)
	coordToBoard(board,coordinate,player)

	# Go through all Non Neurtal Neigbours
	for i=1:nnn.getSize()
		curCoor = nnn.getCoordinate(i)
		println("checking NNN ",curCoor.getCoorStr())
		curPlyr = getCoorPl(board,curCoor)
		hasLiberty(board,curCoor,neurtalize=true)
	end
end

# knownFriends	-> Just for recursion
# neurtalize	-> If given coordinate has no liberty it and all of its friends become empty square
function hasLiberty(board,coordinate;knownFriends=CoorContainerN(),neurtalize=false)
	nn = getNeurtalNeigbours(board,coordinate)
	if !nn.isEmpty()
		println("\t",coordinate.getCoorStr(), " has ", nn.getSize(), " liberties")
		return true
	else
		#addCoordinate(knownFriends,coordinate)
		fn = getFriendNeighbours(board,coordinate)
		# remove known friends from fn
		#println("a")
		if !knownFriends.isEmpty()
		#println("b")
			for i=1:knownFriends.getSize()
				if fn.contains(knownFriends.getCoordinate(i))
					println("2")
					fn.remove(knownFriends.getCoordinate(i))
				end
			end
		end
println("yepu")
		# add new known friends when they are checked to knownFriends
		if !fn.isEmpty() 
			for i=1:fn.getSize()
				knownFriends.add(fn.getCoordinate(i))
				if hasLiberty(board,fn.getCoordinate(i),knownFriends=knownFriends)
					println("yep")
					return true
				end
			end
		end
		println("\t",coordinate, " has 0 liberties")
		if neurtalize == true 
			println("Stones to be neutralized: ", knownFriends)
			coordToBoard(board,knownFriends,'N')
		end
		return false
	end
end

function getFriendNeighbours(board,coordinate)
	nnn = getNonNeurtalNeigbours(board,coordinate)
	player = getCoorPl(board,coordinate)
	coords = CoorContainerN()

	# Got through all Non Neurtal Neigbours
	for i=1:nnn.getSize()
		#println("checking NNN for friends",nnn[i])
		curCoor = nnn.getCoordinate(i)
		curPlyr = getCoorPl(board,curCoor)
		if player == curPlyr
			#println("friend found ", curCoor)
			coords.add(curCoor)
		end
	end
	return coords
end

function getNonNeurtalNeigbours(board,coordinate)
	coords = CoorContainerN()

	x = coordinate.x
	y = coordinate.y
		
	#println("Looking non-neutral neighbours of ", x*10 + y)
	if	(x+1 <= 19) && (board[ x+1 , y ] != 0)
		#println("\t", (x+1)*10 + y , " is not neutral - Down")
		coords.add(Coordinate((x+1)*10 + y))
	end
	if	(x-1 >= 1)  && (board[ x-1 , y ] != 0)
		#println("\t", (x-1)*10 + y , " is not neutral - Up")
		coords.add(Coordinate((x-1)*10 + y))
	end
	if	(y+1 <= 19) && (board[ x , y+1 ] != 0)
		#println("\t", x*10 + y+1 , " is not neutral - Right")
		coords.add(Coordinate(x*10 + y+1))
	end
	if	(y-1 >= 1)  && (board[ x , y-1 ] != 0)
		#println("\t", x*10 + y-1 , " is not neutral - Left")
		coords.add(Coordinate(x*10 + y-1))
	end
	return coords
end

function getNeurtalNeigbours(board,coordinate)
	coords = CoorContainerN()

	x = coordinate.x
	y = coordinate.y
		
	println("Looking neutral neighbours of ", (x*10) + y)
	if	(x+1 <= 19) && (board[ x+1 , y ] == 0)
		#println("\t",(x+1)*10 + y , " is neutral - Down")
		coords.add(Coordinate((x+1)*10 + y))
	end
	if	(x-1 >= 1)  && (board[ x-1 , y ] == 0)
		#println("\t",(x-1)*10 + y , " is neutral - Up")
		coords.add(Coordinate((x-1)*10 + y))
	end
	if	(y+1 <= 19) && (board[ x , y+1 ] == 0)
		#println("\t",x*10 + y+1 , " is neutral - Right")
		coords.add(Coordinate(x*10 + y+1))
	end
	if	(y-1 >= 1)  && (board[ x , y-1 ] == 0)
		#println("\t",x*10 + y-1 , " is neutral - Left")
		coords.add(Coordinate(x*10 + y-1))
	end

	return coords
end


# # # # # # # # # # # # # #		Input feature plane			# # # # # # # # # # # # # #

function getIFP(board, player)
	IFP = zeros(19,19,48)	# Initialize empty Input feature plane

	ply = getPlayerNumber(player)
	opp = getOpponentNumber(player)
	neu = getNeutralNumber()

	# 1		Player Stones
	IFP[:,:,1] = map(x -> x == ply ? 1 : 0 ,board)

	# 2		Opponent Stones
	IFP[:,:,2] = map(x -> x == opp ? 1 : 0 ,board)

	# 3		Neutral/Empty Stones
	IFP[:,:,3] = map(x -> x == neu ? 1 : 0 ,board)

	# 4		Ones
	IFP[:,:,4] = map(x -> 1,board)

	# 5		Turns Since

	return IFP
end

function getStartingPlayer(fileName)
	file = open(fileName)
	lines = readlines(file)
	close(file)

	hnCoor = filter(x -> contains(x, ";"),lines)[2][2] # Filtering ;

end

# Open file
fileN = "Documents/KnetAlphaGO/Dataset/2015-05-01-3.sgf"

# Generate 19x19 board
board = zeros(19,19)

hndCoords	= getHandicapCoordinates(fileN)
whiteMoves	= getWhiteMoves(fileN)
blackMoves	= getBlackMoves(fileN)
strtnPlayer = getStartingPlayer(fileN)

IFP = getIFP(board, 'W')


include("Tests/testl.jl")

writedlm("Documents/KnetAlphaGO/board.txt", board)
#board2 = readdlm("Documents/KnetAlphaGO/test.txt")