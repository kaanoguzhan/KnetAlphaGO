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





# Read file line by line
file = open("2015-05-01-1.sgf")
lines = readlines(file)

# Generate 19x19 board
board = zeros(19,19)


getHandicapNumber(lines)

getHandicapCoordinates()
