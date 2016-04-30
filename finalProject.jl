using Knet
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

function play(IFP,board,coordinate,player;initIFP=false)
	if initIFP
		IFP = zeros(19,19,48)	# Initialization of empty Input feature plane
	end

	println(" * * * * * * * * * * * * * * * * * * * * * * * * * * *")
	x = coordinate[1][1]
	y = coordinate[1][2]
	if x == 0 && y == 0
		println("Pass move")
		return IFP
	end

	plNum = getPlayerNumber(player)

	# Playing on a square that has all neutral around
	if	board[ x+1 <= 19 ? x+1 : x , y ] == 0 &&
		board[ x-1 >= 1  ? x-1 : x , y ] == 0 &&
		board[ x , y+1 <= 19 ? y+1 : y ] == 0 &&
		board[ x , y-1 >= 1  ? y-1 : y ] == 0
			println(player, " played on ", coorToLet(coordinate))
			coordToBoard(board,coordinate,player)
			writedlm(boardPath, board)
			return updateIFP(IFP,board,coordinate,player)
	end

	# Playing on a square that has PROBLEM!
	println(player, " played on ", coorToLet(coordinate))
			
	nnn = getNonNeurtalNeigbours(board,coordinate[1])
	coordToBoard(board,coordinate,player)

	# Go through all Non Neurtal Neigbours
	for i=1:size(nnn)[1]
		println("checking NNN",nnn[i])
		curCoor = numToCoor(nnn[i][1],nnn[i][2])
		#curPlyr = getCoorPl(board,curCoor)
		hasLiberty(board,curCoor,neurtalize=true)
	end

	writedlm(boardPath, board)
	return updateIFP(IFP,board,coordinate,player)
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
	if	(x+1 <= 19) && (1 <= y <= 19)  && (board[ x+1 , y ] != 0)
		#println("\t", (x+1)*10 + y , " is not neutral - Down")
		addCoordinate(coords,numToCoor(x+1 , y))
	end
	if	(x-1 >= 1)  && (1 <= y <= 19)  && (board[ x-1 , y ] != 0)
		#println("\t", (x-1)*10 + y , " is not neutral - Up")
		addCoordinate(coords,numToCoor(x-1 , y))
	end
	if	(y+1 <= 19) && (1 <= x <= 19)  && (board[ x , y+1 ] != 0)
		#println("\t", x*10 + y+1 , " is not neutral - Right")
		addCoordinate(coords,numToCoor(x , y+1))
	end
	if	(y-1 >= 1)  && (1 <= x <= 19)  && (board[ x , y-1 ] != 0)
		#println("\t", x*10 + y-1 , " is not neutral - Left")
		addCoordinate(coords,numToCoor(x , y-1))
	end
	return coords
end

function getNeurtalNeigbours(board,coordinate)
	coords = CoorContainer()

	for i=1:size(coordinate)[1]
		x = getCoorX(coordinate)
		y = getCoorY(coordinate)
		
		#println("Looking neutral neighbours of ", (x*10) + y)
		if	(x+1 <= 19) && (1 <= y <= 19) && (board[ x+1 , y ] == 0)
			#println("\t",(x+1)*10 + y , " is neutral - Down")
			addCoordinate(coords,numToCoor((x+1)*10 + y))
		end
		if	(x-1 >= 1)  && (1 <= y <= 19) && (board[ x-1 , y ] == 0)
			#println("\t",(x-1)*10 + y , " is neutral - Up")
			addCoordinate(coords,numToCoor((x-1)*10 + y))
		end
		if	(y+1 <= 19) && (1 <= x <= 19) && (board[ x , y+1 ] == 0)
			#println("\t",x*10 + y+1 , " is neutral - Right")
			addCoordinate(coords,numToCoor(x*10 + y+1))
		end
		if	(y-1 >= 1)  && (1 <= x <= 19) && (board[ x , y-1 ] == 0)
			#println("\t",x*10 + y-1 , " is neutral - Left")
			addCoordinate(coords,numToCoor(x*10 + y-1))
		end
	end

	return coords
end


# # # # # # # # # # # # # #		Input feature plane			# # # # # # # # # # # # # #


function updateIFP(IFPold, board, coordinate, player)
	IFP = zeros(19,19,12)	# Empty Input feature plane for return

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

	# 5		Turns Since - 1
	IFP[:,:,5] = IFPold[:,:,6]
	
	# 6		Turns Since - 2
	IFP[:,:,6] = IFPold[:,:,7]
	
	# 7		Turns Since - 3
	IFP[:,:,7] = IFPold[:,:,8]
	
	# 8		Turns Since - 4
	IFP[:,:,8] = IFPold[:,:,9]
	
	# 9		Turns Since - 5
	IFP[:,:,9] = IFPold[:,:,10]
	
	# 10	Turns Since - 6
	IFP[:,:,10] = IFPold[:,:,11]
	
	# 11	Turns Since - 7
	IFP[:,:,11] = IFPold[:,:,12]
	
	# 12	Turns Since - 8
	x = coordinate[1][1]
	y = coordinate[1][2]	
	IFP[:,:,12][x,y] = 2.0

	return IFP
end

function getStartingPlayer(fileName)
	file = open(fileName)
	lines = readlines(file)
	close(file)

	hnCoor = filter(x -> contains(x, ";"),lines)[2][2] # Filtering ;
end

# Open file
fileN = "Dataset/2015-05-01-3.sgf"
boardPath = "/mnt/kufs/scratch/koguzhan/board.txt"
#include("Tests/tests.jl")



println("Starting game")
# Generate 19x19 board
board = zeros(19,19)	# Initialization of empty board

# Empty array for holding each turns IFP and corresponding move
IFP_ar = []
Mov_ar = []

# Placing handicaps to board
hndCoords = getHandicapCoordinates(fileN)
coordToBoard(board,hndCoords,'B')

# Reading White & Black moves
whiteMoves = getWhiteMoves(fileN)
blackMoves = getBlackMoves(fileN)
WTotalTurn = size(whiteMoves)[1]
BTotalTurn = size(blackMoves)[1]

# Playing turn by turn
WCurrTurn = 2
BCurrTurn = 1
# First turn of White
IFP = play(nothing,board,CoorContainer(coor=whiteMoves[1]),'W',initIFP=true)
push!(IFP_ar, IFP)
push!(Mov_ar, whiteMoves[1])
# Rest of the turns
while WTotalTurn > WCurrTurn || BTotalTurn > BCurrTurn
	# White always plays first
	# Black move
	if BTotalTurn > BCurrTurn
		println("BM",blackMoves[BCurrTurn])
		IFP = play(IFP,board,CoorContainer(coor=blackMoves[BCurrTurn]),'B')
		push!(IFP_ar, IFP)
		push!(Mov_ar, blackMoves[BCurrTurn])
	end
	BCurrTurn = BCurrTurn + 1

	# White move
	if WTotalTurn > WCurrTurn
		println("WM",whiteMoves[WCurrTurn])
		IFP = play(IFP,board,CoorContainer(coor=whiteMoves[WCurrTurn]),'W')
		push!(IFP_ar, IFP)
		push!(Mov_ar, whiteMoves[WCurrTurn])
	end
	WCurrTurn = WCurrTurn + 1
end


# Reshape any-array data to fixed size array data
IFP_arF = Array{Float64}(19,19,12,size(IFP_ar)[1])
Mov_arF = Array{Int64}(19,19,size(Mov_ar)[1])
for i=1:size(IFP_ar)[1]
	IFP_arF[:,:,:,i] = IFP_ar[i]
end
Mov_arF = map(x-> x = 0 ,Mov_arF)
for i=1:size(Mov_ar)[1]
	if Mov_ar[i][1] != 0 && Mov_ar[i][2] != 0
		Mov_arF[Mov_ar[i][1],Mov_ar[i][2],i] = 1
	end
end
IFP_arF = map(x->Float32(x) ,IFP_arF)	# Convert to Float32
Mov_arF = map(x->Float32(x) ,Mov_arF)

Mov_arF = reshape(Mov_arF, 361,size(Mov_ar)[1])
println("Done")

include("train.jl")

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  #
