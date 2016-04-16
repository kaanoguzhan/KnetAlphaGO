function getHandicapNumber(file)
	handicap = filter(x -> contains(x, "ST"),lines) #Get Handicap line

	# Single number handicap
	if handicap[1][3] == '[' && handicap[1][5] == ']'
		return handicap[1][4]
	end

	# Double number handicap
	if handicap[1][3] == '[' && handicap[1][5] == ']'
		return handicap[1][4]
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

	if hnNumb == 1
		hnCoor = filter(x -> contains(x, "AB"),lines)[1] # Filtering handicap coordinates line
		coords[1:2]=LetToNum(hnCoor[4:5])
		return coords
	end 
	

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
