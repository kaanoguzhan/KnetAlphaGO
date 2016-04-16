function getHandicapNumber(file)
	hndLine = filter(x -> contains(x, "ST"),lines) # Filtering handicap Number line

	# Single number handicap
	if hndLine[1][3] == '[' && hndLine[1][5] == ']'
		return hndLine[1][4]
	end

	# Double number handicap
	if hndLine[1][3] == '[' && hndLine[1][5] == ']'
		return hndLine[1][4]
	end

	return "ERROR: Cannot read handicap"
end


function getHandicapCoordinates(lines)
	hnNumb = Int(getHandicapNumber(lines))-48
	
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
					println(ln[4:5])
					coords[cntr:cntr+1]=LetToNum(ln[4:5])
					cntr = cntr + 2
					end

				# Coordinate line that start with "["
				if ln[1] == '['
					println(ln[2:3])
					coords[cntr:cntr+1]=LetToNum(ln[2:3])
					#cntr = cntr + 2
				end				
			end
		end
	end
	print(hnNumb)
	print(coords)
end

function LetToNum(letCoor)
	numCoor = zeros(1,2)
	setindex!(numCoor, Int(letCoor[1])-96, 1)
	setindex!(numCoor, Int(letCoor[2])-96, 2)
end


# Read file line by line
file = open("KnetAlphaGO/Dataset/2015-05-01-1.sgf")
lines = readlines(file)

# Generate 19x19 board
board = zeros(19,19)


getHandicapCoordinates(lines)


writedlm("Documents/KnetAlphaGO/board.txt", board)
#board2 = readdlm("Documents/KnetAlphaGO/test.txt")