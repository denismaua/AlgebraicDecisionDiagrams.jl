@testset "Multilinear Expressions" begin

    @info "Multilinear Expressions"
    MLE = MultilinearExpression # Alias
    @show c = MLE(7.4) 
    @show isa(c,MLE)
    @show e1 = MLE(4.0,1)
    @show isa(e1,MLE)
    @show e2 = MLE(3.0,1,3)
    @show e3 = c + e1 + e2 
    @show isa(e3,MLE)
    @show e3[Monomial((1,3))]
    @show e3[Monomial((1,2))]
    @show e3[Monomial((1,2))] = 1.5
    @show length(e3)
    for (m,c) in e3
        println(m => c)
    end
    @show e4 = MLE(1.0,1) + MLE(1.5,1,2)
    @show isa(e4,MLE)
    @show e5 = e3 + e4
    @show e6 = e5 + 2.6
    @show e7 = -2.4 + e5
    @show e8 = e7 + zero(e7)
    @show e9 = e8 + 0.2 * one(e8)
    @show Monomial((1,)) * Monomial((3,))
    try
        @show e1 * e2
    catch
        println("Multiplication of expressions with common variables produces error")
    end
    @show e1 * MLE(0.5,2)
    @show MLE(2.0,4) * e7
    @show a = MLE(2.0,1,3) + MLE(2.0,3)
    @show b = MLE(3.0,2) + MLE(1.0,2,4) + MLE(1.0,4)
    @show c = a * b
    @show a == b
    @show a == MLE(2.0,1,3) + MLE(2.0,3)
    @show c == a * b
    @show isequal(c,a * b)
    @show MLE(0) == MLE(0)
    @show 1+MLE(-1.0,1) == 1+MLE(-1.0,1)
    @show hash(Monomial((1,3)))
    @show hash(a)
    @show hash(MLE(2.0,1,3) + MLE(2.0,3))
    @show hash(c)
    @show hash(a * b)
    println()

end # testset