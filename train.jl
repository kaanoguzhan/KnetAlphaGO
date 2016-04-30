

println("Training start",typeof(Mov_arF))


println("typM",typeof(IFP_arF),"typI",typeof(Mov_arF))
#include(Pkg.dir("Knet/examples/mnist.jl"))
println("Mxtr",typeof(MNIST.xtrn),"Mytr",typeof(MNIST.ytrn))
dtrn = minibatch(IFP_arF, Mov_arF, 25)
#dtst = minibatch(MNIST.xtst, MNIST.ytst, 25)

function train(f, data, loss)
	for (x,y) in data
		forw(f, x)
		back(f, y, loss)
		update!(f)
	end
end
function test(f, data, loss)
	sumloss = numloss = 0
	for (x,ygold) in data
		ypred = forw(f, x)
		sumloss += loss(ypred, ygold)
		numloss += 1
	end
sumloss / numloss
end



@knet function mdfun(x1)
    x2 = cbfp(x1; out=20, f=:relu, cwindow=5, pwindow=2)
    return wbf(x2; out=361, f=:soft)
end



# Compileing model
model = compile(:mdfun)
setp(model, lr=0.1)

nepoch=100
result=zeros(nepoch)
accdiff=0

# Running model
println("Running Model")
for epoch=1:nepoch
	train(model, dtrn, softloss)
	result[epoch]=test(model, dtrn, zeroone)
	@printf("epoch:%d softloss:%g accuracy:%g accuracydiff:%g\n", epoch,
		test(model, dtrn, softloss),
		1-result[epoch],
		accdiff-result[epoch])
	accdiff=result[epoch]
	if result[epoch] == 0
		break
	end
end



println("Train complete")