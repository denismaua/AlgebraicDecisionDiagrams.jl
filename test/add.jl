
@testset "Algebraic Decision Diagrams" begin
    @info "ADD"
    ADD = AlgebraicDecisionDiagrams
    @show x1 = indicator(Int,1) # equivalent to x1 = Node(1,Base.zero(Int),Base.one(Int))
    @show one(x1) - x1 
    @show ¬x1
    @show apply(x -> 1-x, x1)
    @show x1 + (¬x1)
    @show x1 * (¬x1)
    @show x2 = indicator(Int,2)
    @show x1 + x2
    @show x1 * x2
    @show apply(x -> x^2, x1 + x2)
    @show ⊕(x,y) = (x + y) % 2 # sum mod 2
    @show apply(⊕,x1,x2)
    @show x3 = indicator(Int,3)
    
    @info "Odd Parity Function"
    @show apply(⊕,x1,apply(⊕,x2,x3))
    @show apply(max, x1 * x2, x3)
    
    @info "Example from Fig. 1 in Bryant's paper"
    @show apply(max, (¬x1)*x2, x1*x3)

    @info "Example in Fig. 5 of Bryant's paper"
    A3 = Node(3,zero(Int),one(Int))
    @show A4 = ADD.reduce(Node(1,Node(2,zero(Int),A3),Node(2,A3,A3)))
    # for (i,α) in enumerate(x1*x2)
    #     println(i, "\n", α)
    # end
    println()

    @info "Directed Graph ADD"

    @info "Example in Fig 1. in Bahar et al. 1997's paper"
    x0 = indicator(Int,0)
    nx0 = indicator(Int,0,true)
    x1 = indicator(Int,2)
    nx1 = indicator(Int,2,true)
    y0 = indicator(Int,1)
    ny0 = indicator(Int,1,true)
    y1 = indicator(Int,3)
    ny1 = indicator(Int,3,true)
    @show graph = Terminal(2)*nx0*nx1*ny0*y1 + Terminal(2)*nx0*nx1*y0*ny1 + Terminal(2)*nx0*x1*ny0*y1 + Terminal(2)*nx0*x1*y0*ny1 + Terminal(4)*x0*nx1*y0*y1 + Terminal(4)*x0*x1*ny0*y1
    @info "Get scope"
    # collect nonterminal nodes
    nt = filter(n -> isa(n,Node), collect(graph))
    @show scope = mapreduce(index,union,nt) # 0,1,2,3
    @test length(intersect(scope,[0,1,2,3])) == 4
    println()

    @info "Matrix examples in page 9 of Bryant's paper"
    @show f = (¬x0)*(¬y0) + x0*y0
    @show g = Terminal(4)*nx0 + Terminal(2)*x0
    @show h = f + g
    println()
    @info "Restriction"
    @show restrict(h,0,false)
    @show h | (1 => true)
    @show (h | (index(x0) => true)) + (h | (index(x0) => false))
    @test value((h | (index(x0) => true)) + (h | (index(x0) => false))) == 7
    @show (h | (index(y0) => true)) + (h | (index(y0) => false))
    println()
    @info "marginalization"
    @show marginalize(h, index(x0))
    @show marginalize(h, index(y0))
    @show A4
    @show (A4 | (2 => true)) + (A4 | (2 => false))
    @show A5 = marginalize(A4, 2)
end # testset