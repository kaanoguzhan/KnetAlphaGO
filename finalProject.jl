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

function LetToNum(letCoor)
	numCoor = zeros(1,2)
	setindex!(numCoor, Int(letCoor[1])-96, 1)
	setindex!(numCoor, Int(letCoor[2])-96, 2)
end

function getHandicapCoordinates(file)
	lines = readlines(file)
	hnNumb = getHandicapNumber(lines)
	
	# Exit if there is no handicap
	if hnNumb == 0
		return 0
	end

	coords = zeros(2,hnNumb)

	# No loop if only 1 handicap
	if hnNumb == 1
		hnCoor = filter(x -> contains(x, "AB"),lines)[1] # Filtering handicap coordinates line
		coords[1:2]=LetToNum(hnCoor[4:5])
		return coords
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
					coords[cntr:cntr+1]=LetToNum(ln[4:5])
					cntr = cntr + 2
					end

				# Coordinate line that start with "["
				if ln[1] == '['
					#println("Handicap at: ",ln[2:3])
					coords[cntr:cntr+1]=LetToNum(ln[2:3])
					cntr = cntr + 2
				end				
			end
		end
	end
	coords = map(x -> Int(x),coords)
	#println("Handicap Coordinates\n",coords)
	return coords
end

function coordToBoard(board,coords)
	cooSize = size(coords)[2]
	
	for i = 0 : cooSize - 1
		board[coords[i*2 + 1],coords[i*2 + 2]] = 1
	end
end


# Open file
file = open("Documents/KnetAlphaGO/Dataset/2015-05-01-3.sgf")

# Generate 19x19 board
board = zeros(19,19)



hndCoords = getHandicapCoordinates(file)

coordToBoard(board,hndCoords)



writedlm("Documents/KnetAlphaGO/board.txt", board)
#board2 = readdlm("Documents/KnetAlphaGO/test.txt")