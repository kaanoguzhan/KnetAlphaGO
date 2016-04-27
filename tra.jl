using Knet

println("Training start")

dtrn = minibatch(IFP_arF, Mov_arF, 25)
#dtst = minibatch(MNIST.xtst, MNIST.ytst, 25)