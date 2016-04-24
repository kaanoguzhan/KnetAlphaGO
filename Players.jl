# # # # # # # # # # # # # #				Players.jl			# # # # # # # # # # # # # #

function getPlayerNumber(player)
	if player == 'B' 
		return 1
	elseif player == 'W'
		return 2
	elseif player == 'N'
		return 0
	end
end

function getOpponentNumber(player)
	if player == 'B' 
		return 2
	elseif player == 'W'
		return 1
	end
end

function getOpponent(player)
	if player == 'B' 
		return 'W'
	elseif player == 'W'
		return 'B'
	end
end

function getNeutralNumber()
	return 0
end

