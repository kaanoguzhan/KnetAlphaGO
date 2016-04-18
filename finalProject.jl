# # # # # # # # # # # # # #		Coordinates				# # # # # # # # # # # # # #

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

function passCoordinate()
	# Create empty coordiane for no move turns
	map(x -> Int(x),zeros(1,2))
end

# # # # # # # # # # # # # #		Reading Handicap		# # # # # # # # # # # # # #

function getHandicapNumber(lines)
	hndLine = filter(x -> contains(x, "HA"),lines) # Filtering handicap Number line

	# Single number handicap
	if hndLine[1][3] == '[' && hndLine[1][5] == ']'
		#println("Total Handicap number: ",Int(hndLine[1][4])-48)
		return Int(hndLine[1][4])-48 
	end

	# Double number handicap
	if hndLine[1][3] == '[' && hndLine[1][6] == ']'
		#println("Total Handicap number: ",(Int(hndLine[1][4])-48) * 10 + (Int(hndLine[1][5])-48))
		return Int((Int(hndLine[1][4])-48) * 10 + (Int(hndLine[1][5])-48))
	end

	return "ERROR: Cannot read handicap"
end


function getHandicapCoordinates(fileName)
	file = open(fileName)
	lines = readlines(file)
	hnNumb = getHandicapNumber(lines)
	close(file)

	# Exit if there is no handicap
	if hnNumb == 0
		return 0
	end

	CoorCont = CoorContainer()

	# No loop if only 1 handicap
	if hnNumb == 1
		hnCoor = filter(x -> contains(x, "AB"),lines)[1] # Filtering handicap coordinates line
		CoorCont[1:2]=letToCoor(hnCoor[4:5])
		return CoorCont
	end 
	
	# Loop for 1+ handicaps
	line = 1
	cntr = 1
	for ln in lines
		if line < 19		# Skip first 18 lines
			line = line +1	
		else				# Start reading
			if !contains(ln, ";") && contains(ln, "[") 
				# Coordinate line that start with "AB"
				if ln[1] == 'A'
					#println("Handicap at: ",ln[4:5])
					coordinate = letToCoor(ln[4:5])
					addCoordinate(CoorCont,coordinate)
					cntr = cntr + 2
				end

				# Coordinate line that start with "["
				if ln[1] == '['
					#println("Handicap at: ",ln[2:3])
					coordinate = letToCoor(ln[2:3])
					addCoordinate(CoorCont,coordinate)
					cntr = cntr + 2
				end				
			end
		end
	end
	#println("Handicap Coordinates\n",CoorCont)
	return CoorCont
end

# # # # # # # # # # # # # #		Board position Numbers	# # # # # # # # # # # # # #

function getPlayerNumber(player)
	if player == 'B' 
		return 1
	elseif player == 'W'
		return 2
	end
end

function getOpponentNumber(player)
	if player == 'B' 
		return 2
	elseif player == 'W'
		return 1
	end
end

function getNeutralNumber()
	return 0
end

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
			coordToBoard(board,coordinate,player)
	end

	# Playing on a square that has PROBLEM!
		getNonNeurtalNeigbours(board,coordinate)

end

function getNonNeurtalNeigbours(board,coordinate)
	coords = CoorContainer()
	x = coordinate[1][1]
	y = coordinate[1][2]
	
	println("Looking non-neutral neighbours of ", x*10 + y)
	if	board[ x+1 <= 19 ? x+1 : x , y ] != 0
		println((x+1)*10 + y , " is not neutral - Down")
		addCoordinate(coords,numToCoor((x+1)*10 + y))
	end
	if	board[ x-1 >= 1  ? x-1 : x , y ] != 0
		println((x-1)*10 + y , " is not neutral - Up")
		addCoordinate(coords,numToCoor((x-1)*10 + y))
	end
	if	board[ x , y+1 <= 19 ? y+1 : y ] != 0
		println(x*10 + y+1 , " is not neutral - Right")
		addCoordinate(coords,numToCoor(x*10 + y+1))
	end
	if	board[ x , y-1 >= 1  ? y-1 : y ] != 0
		println(x*10 + y-1 , " is not neutral - Left")
		addCoordinate(coords,numToCoor(x*10 + y-1))
	end

	return coords
end

function getNeurtalNeigbours(board,coordinate)
	coords = CoorContainer()
	x = coordinate[1][1]
	y = coordinate[1][2]
	
	println("Looking neutral neighbours of ", x*10 + y)
	if	board[ x+1 <= 19 ? x+1 : x , y ] == 0
		println((x+1)*10 + y , " is neutral - Down")
		addCoordinate(coords,numToCoor((x+1)*10 + y))
	end
	if	board[ x-1 >= 1  ? x-1 : x , y ] == 0
		println((x-1)*10 + y , " is neutral - Up")
		addCoordinate(coords,numToCoor((x-1)*10 + y))
	end
	if	board[ x , y+1 <= 19 ? y+1 : y ] == 0
		println(x*10 + y+1 , " is neutral - Right")
		addCoordinate(coords,numToCoor(x*10 + y+1))
	end
	if	board[ x , y-1 >= 1  ? y-1 : y ] == 0
		println(x*10 + y-1 , " is neutral - Left")
		addCoordinate(coords,numToCoor(x*10 + y-1))
	end

	return coords
end

# # # # # # # # # # # # # #		Reading Player Moves	# # # # # # # # # # # # # #

function getMoveCoordinatesLine(fileName)
	file = open(fileName)
	lines = readlines(file)
	close(file)

	tmpLine = filter(x -> contains(x, "W["),lines)		# Isolating coordinates line
	cooLine = filter(x -> contains(x, "B["),tmpLine)[1]	# Isolating coordinates line
end

function getWhiteMoves(fileName)
	cooLine = getMoveCoordinatesLine(fileName)

	CoorCont = CoorContainer()
	for i=1:361  # 361 = 19*19
		if contains(cooLine, "W[")
			indx = search(cooLine, "W[")[2] + 1
			
			if cooLine[indx] != ']'	# White player made a move
				curCoor = letToCoor(cooLine[indx:indx+1])	# Find next move coordinate
				#println("White Move " , i , ":\t" , cooLine[indx:indx+1], " " ,curCoor)
				addCoordinate(CoorCont,curCoor)						# Add current move
			else					# White player Passed
				#println("Black Pass ", i)
				addCoordinate(CoorCont,passCoordinate())				# Add pass coordinate
			end

			# Go to next move
			cooLine = cooLine[indx+2:end]
		end
	end
	#println(CoorCont)
	return CoorCont
end

function getBlackMoves(fileName)
	cooLine = getMoveCoordinatesLine(fileName)

	CoorCont = CoorContainer()
	for i=1:361  # 361 = 19*19
		if contains(cooLine, "B[")
			indx = search(cooLine, "B[")[2] + 1
			
			if cooLine[indx] != ']'	# Black player made a move
				curCoor = letToCoor(cooLine[indx:indx+1])	# Find next move coordinate
				#println("Black Move " , i , ":\t" , cooLine[indx:indx+1], " " ,curCoor)

				addCoordinate(CoorCont,curCoor)						# Add current move
			else					# Black player Passed
				#println("Black Pass ", i)
				addCoordinate(CoorCont,passCoordinate())				# Add pass coordinate
			end

			# Go to next move
			cooLine = cooLine[indx+2:end]
		end
	end
	#println(CoorCont)
	return CoorCont
end

# # # # # # # # # # # # # #		Reading Komi			# # # # # # # # # # # # # #

function getKomi(fileName)
	file = open(fileName)
	lines = readlines(file)
	close(file)
	
	hndLine = filter(x -> contains(x, "KM"),lines) # Filtering komi line

	# Reading komi in "[x.xx]" format
	if hndLine[1][3] == '[' && hndLine[1][8] == ']'
		c = hndLine[1][4:7]
		komi = map(x-> (v = tryparse(Float64,x); isnull(v) ? 0.0 : get(v)),[c])
		komi = komi[1]
		#println("Komi is: ",komi)
		return komi
	end

	return "ERROR: Cannot read Komi"
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

play(board,CoorContainer(coor=numToCoor("12")),'W')
coordToBoard(board,CoorContainer(coor=numToCoor("22")),'B')
play(board,CoorContainer(coor=numToCoor("32")),'W')
play(board,CoorContainer(coor=numToCoor("21")),'W')
play(board,CoorContainer(coor=numToCoor("23")),'W')

writedlm("Documents/KnetAlphaGO/board.txt", board)
#board2 = readdlm("Documents/KnetAlphaGO/test.txt")