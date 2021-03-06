# # # # # # # # # # # # # #				Handicap.jl			# # # # # # # # # # # # # #
# Used for reading the followings from given sgf file
# Handicap
# Komi


# # # # # # # # # # # # # #		Reading handicap			# # # # # # # # # # # # # #
function getHandicapNumber(lines)
	hndLine = filter(x -> contains(x, "HA"),lines) # Filtering handicap Number line

	# No Handicap
	if hndLine==[]
		return 0
	end

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


# # # # # # # # # # # # # #			Reading Komi			# # # # # # # # # # # # # #

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


# # # # # # # # # # # # # #			Reading Player Moves	# # # # # # # # # # # # # #

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
