# # # # # # # # # # # # # #				Players.jl			# # # # # # # # # # # # # #

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

