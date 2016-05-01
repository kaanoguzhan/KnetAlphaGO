

println("Training start",typeof(Mov_arF))


#println("typM",typeof(IFP_arF),"typI",typeof(Mov_arF))
#include(Pkg.dir("Knet/examples/mnist.jl"))
#println("Mxtr",typeof(MNIST.xtrn),"Mytr",typeof(MNIST.ytrn))
#dtrn = minibatch(IFP_arF, Mov_arF, 50)
#dtst = minibatch(MNIST.xtst, MNIST.ytst, 20)

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


#=
# Policiy network descriped on the paper
@knet function polnet(x1)
    x2	= cbfp(x1; out=128, f=:relu, cwindow=5, pwindow=1, padding=2, stride=1)	# Layer 1
    x3	= cbfp(x2; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)	# Layer 2
    x4	= cbfp(x3; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x5	= cbfp(x4; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x6	= cbfp(x5; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x7	= cbfp(x6; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x8	= cbfp(x7; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x9	= cbfp(x8; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x10	= cbfp(x9; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x11	= cbfp(x10; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x12	= cbfp(x11; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)# Layer 11
    x13 = cbfp(x12; out=1, f=:relu, cwindow=1, pwindow=1, stride=1)				# Layer 12
    x14 = wbf(x13; out=256, f=:tanh)											# Layer 13
    return wbf(x14; out=361, f=:soft)
end
=#

#=
# Value network descriped on the paper
@knet function valnet(x1)
    x2	= cbfp(x1; out=128, f=:relu, cwindow=5, pwindow=1, padding=2, stride=1)	# Layer 1
    x3	= cbfp(x2; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)	# Layer 2
    x4	= cbfp(x3; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x5	= cbfp(x4; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x6	= cbfp(x5; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x7	= cbfp(x6; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x8	= cbfp(x7; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x9	= cbfp(x8; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x10	= cbfp(x9; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x11	= cbfp(x10; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x12	= cbfp(x11; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)
    x13	= cbfp(x12; out=128, f=:relu, cwindow=3, pwindow=1, padding=1, stride=1)# Layer 12
    x14 = cbfp(x13; out=1, f=:relu, cwindow=1, pwindow=1, stride=1)				# Layer 13
    x15 = wbf(x14; out=256, f=:tanh)											# Layer 14
    return wbf(x15; out=361, f=:soft)
end
=#



@knet function polnet(x1)
    x2 = cbfp(x1; out=40, f=:relu, cwindow=5, pwindow=2) 
    x3 = cbfp(x2; out=40, f=:relu, cwindow=3, pwindow=1) 
    return wbf(x3; out=361, f=:soft) 
end



# Compileing model
model = compile(:polnet)
setp(model, lr=0.1)

nepoch=100
result=zeros(nepoch)
accdiff=0

# Running models
println("Running Model batch=50")
dtrn = minibatch(IFP_arF, Mov_arF, 50)
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

println("Running Model batch=25")
dtrn = minibatch(IFP_arF, Mov_arF, 25)
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