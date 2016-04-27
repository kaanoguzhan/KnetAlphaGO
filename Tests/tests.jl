# Small game simulation
IFP = play(nothing,board,CoorContainer(coor=numToCoor("12")),'W',initIFP=true)
IFP = play(IFP,board,CoorContainer(coor=numToCoor("21")),'W')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("22")),'B')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("23")),'W')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("31")),'W')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("32")),'B')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("33")),'B')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("42")),'W')
IFP = play(IFP,board,CoorContainer(coor=numToCoor("43")),'W')


IFP = play(IFP,board,CoorContainer(coor=numToCoor("34")),'W')
