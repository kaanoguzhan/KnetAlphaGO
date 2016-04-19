include("Coordinates.jl")
include("Players.jl")
include("SGFReaders.jl")
# # # # # # # # # # # # # #		Playing Moves			# # # # # # # # # # # # # #

# player = N -> remove any stone from coordinate(s)
# player = W -> Place white stone to coordinate(s)
# player = B -> Place black stone to coordinate(s)
function coordToBoard(board,coords,player)
	loopSize = size(coords)[1]

	plNum = getPlayerNumber(player)

	for i = 1 : loopSize
		if coords[i][1] != 0 && coords[i][2] != 0
			board[coords[i][1],coords[i][2]] = plNum
		end
	end
end

function play(board,coordinate,player)
	
	println(" * * * * * * * * * * * * * * * * * * * * * * * * * * *")
	x = coordinate[1][1]
	y = coordinate[1][2]
	
	plNum = getPlayerNumber(player)

	# Check if move is played on a neutral square
	if board[x,y] != 0
		return "Error: Move not possible !"
	end

	# Playing on a square that has all neutral around
	if	board[ x+1 <= 19 ? x+1 : x , y ] == 0 &&
		board[ x-1 >= 1  ? x-1 : x , y ] == 0 &&
		board[ x , y+1 <= 19 ? y+1 : y ] == 0 &&
		board[ x , y-1 >= 1  ? y-1 : y ] == 0
			println(player, " played on ", coorToLet(coordinate))
			coordToBoard(board,coordinate,player)
			return
	end

	# Playing on a square that has PROBLEM!
	println(player, " played on ", coorToLet(coordinate))
			
	nnn = getNonNeurtalNeigbours(board,coordinate[1])
	coordToBoard(board,coordinate,player)

	# Go through all Non Neurtal Neigbours
	for i=1:size(nnn)[1]
		println("checking NNN",nnn[i])
		curCoor = numToCoor(nnn[i][1],nnn[i][2])
		curPlyr = getCoorPl(board,curCoor)
		hasLiberty(board,curCoor,neurtalize=true)
	end
end

# knownFriends	-> Just for recursion
# neurtalize	-> If given coordinate has no liberty it and all of its friends become empty square
function hasLiberty(board,coordinate;knownFriends=CoorContainer(),neurtalize=false)
	nn = getNeurtalNeigbours(board,coordinate)
	if !isContEmpty(nn)
		println("\t",coordinate, " has ", size(nn)[1], " liberties")
		return true
	else
		#addCoordinate(knownFriends,coordinate)
		fn = getFriendNeighbours(board,coordinate)
		# remove known friends from fn
		if !isContEmpty(knownFriends)
			for i=1:size(knownFriends)[1]
				if knownFriends[i] in fn
					delCoordinate(fn,knownFriends[i])
				end
			end
		end
		# add new known friends when they are checked to knownFriends
		if !isContEmpty(fn)  
			for i=1:size(fn)[1]
				addCoordinate(knownFriends,fn[i])
				if hasLiberty(board,fn[i],knownFriends=knownFriends)
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
	coords = CoorContainer()

	# Got through all Non Neurtal Neigbours
	for i=1:size(nnn)[1]
		#println("checking NNN for friends",nnn[i])
		curCoor = numToCoor(nnn[i][1],nnn[i][2])
		curPlyr = getCoorPl(board,curCoor)
		if player == curPlyr
			#println("friend found ", curCoor)
			addCoordinate(coords,curCoor)
		end
	end
	return coords
end

function getNonNeurtalNeigbours(board,coordinate)
	coords = CoorContainer()

	x = getCoorX(coordinate)
	y = getCoorY(coordinate)
		
	#println("Looking non-neutral neighbours of ", x*10 + y)
	if	(x+1 <= 19) && (board[ x+1 , y ] != 0)
		#println("\t", (x+1)*10 + y , " is not neutral - Down")
		addCoordinate(coords,numToCoor((x+1)*10 + y))
	end
	if	(x-1 >= 1)  && (board[ x-1 , y ] != 0)
		#println("\t", (x-1)*10 + y , " is not neutral - Up")
		addCoordinate(coords,numToCoor((x-1)*10 + y))
	end
	if	(y+1 <= 19) && (board[ x , y+1 ] != 0)
		#println("\t", x*10 + y+1 , " is not neutral - Right")
		addCoordinate(coords,numToCoor(x*10 + y+1))
	end
	if	(y-1 >= 1)  && (board[ x , y-1 ] != 0)
		#println("\t", x*10 + y-1 , " is not neutral - Left")
		addCoordinate(coords,numToCoor(x*10 + y-1))
	end
	return coords
end

function getNeurtalNeigbours(board,coordinate)
	coords = CoorContainer()

	for i=1:size(coordinate)[1]
		x = getCoorX(coordinate)
		y = getCoorY(coordinate)
		
		#println("Looking neutral neighbours of ", (x*10) + y)
		if	board[ x+1 <= 19 ? x+1 : x , y ] == 0
			#println("\t",(x+1)*10 + y , " is neutral - Down")
			addCoordinate(coords,numToCoor((x+1)*10 + y))
		end
		if	board[ x-1 >= 1  ? x-1 : x , y ] == 0
			#println("\t",(x-1)*10 + y , " is neutral - Up")
			addCoordinate(coords,numToCoor((x-1)*10 + y))
		end
		if	board[ x , y+1 <= 19 ? y+1 : y ] == 0
			#println("\t",x*10 + y+1 , " is neutral - Right")
			addCoordinate(coords,numToCoor(x*10 + y+1))
		end
		if	board[ x , y-1 >= 1  ? y-1 : y ] == 0
			#println("\t",x*10 + y-1 , " is neutral - Left")
			addCoordinate(coords,numToCoor(x*10 + y-1))
		end
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


# Open file
fileN = "Documents/KnetAlphaGO/Dataset/2015-05-01-3.sgf"

# Generate 19x19 board
board = zeros(19,19)

hndCoords = getHandicapCoordinates(fileN)

whiteMoves = getWhiteMoves(fileN)
blackMoves = getBlackMoves(fileN)

coordToBoard(board,hndCoords,'W')
IFP = getIFP(board, 'W')

coordToBoard(board,hndCoords,'B')

include("Tests/testl.jl")

writedlm("Documents/KnetAlphaGO/board.txt", board)
#board2 = readdlm("Documents/KnetAlphaGO/test.txt")