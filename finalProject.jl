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
function hasLiberty(board,coordinate;knownFriends=CoorContainer(),neurtalize=false,returnNum=false,echo=true)
	nn = getNeurtalNeigbours(board,coordinate)
	if !isContEmpty(nn)
		if returnNum
			return size(nn)[1]
		else
			if echo
				println("\t",coordinate, " has ", size(nn)[1], " liberties")
			end
			return true
		end
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
				if hasLiberty(board,fn[i],knownFriends=knownFriends;echo=echo)
					if returnNum
						return size(nn)[1]
					else
						return true
					end
				end
			end
		end
		if echo
			println("\t",coordinate, " has 0 liberties")
		end
		if neurtalize == true
			println("Stones to be neutralized: ", knownFriends)
			coordToBoard(board,knownFriends,'N')
		end
		return false
	end
end

function getFriendNeighbours(board,coordinate)
	if getCoorX(coordinate) == 0 || getCoorY(coordinate) == 0
		return CoorContainer()
	end
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
	IFP = zeros(19,19,26)	# Empty Input feature plane for return

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
	IFP[:,:,12][x,y] = 1.0

	for x=1:19, y=1:19
	libertyNum = hasLiberty(board,numToCoor("$x$y");echo=false,returnNum=true)
	# 13
		if libertyNum == 1
			IFP[:,:,13][x,y] = 1.0
		end

	# 14
		if libertyNum == 1
			IFP[:,:,14][x,y] = 1.0
		end

	# 15
		if libertyNum == 1
			IFP[:,:,15][x,y] = 1.0
		end

	# 16
		if libertyNum == 1
			IFP[:,:,16][x,y] = 1.0
		end

	# 17
		if libertyNum == 1
			IFP[:,:,17][x,y] = 1.0
		end

	# 18
		if libertyNum == 1
			IFP[:,:,18][x,y] = 1.0
		end

	# 19
		if libertyNum == 1
			IFP[:,:,19][x,y] = 1.0
		end

	# 20
		if libertyNum == 1
			IFP[:,:,20][x,y] = 1.0
		end

	# 21		Player Stones
	IFP[:,:,21] = map(x -> x == ply ? 1 : 0 ,board)

	# 22		Opponent Stones
	IFP[:,:,22] = map(x -> x == opp ? 1 : 0 ,board)

	# 23		Neutral/Empty Stones
	IFP[:,:,23] = map(x -> x == neu ? 1 : 0 ,board)

	# 24		Player Stones
	IFP[:,:,24] = map(x -> x == ply ? 1 : 0 ,board)

	# 25		Opponent Stones
	IFP[:,:,25] = map(x -> x == opp ? 1 : 0 ,board)

	# 26		Neutral/Empty Stones
	IFP[:,:,26] = map(x -> x == neu ? 1 : 0 ,board)

	end
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


# Empty array for holding each turns IFP and corresponding move
IFP_ar = []
Mov_ar = []


println("Starting game")
# Generate 19x19 board
board = zeros(19,19)	# Initialization of empty board

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
IFP_arF = Array{Float64}(19,19,26,size(IFP_ar)[1])
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
