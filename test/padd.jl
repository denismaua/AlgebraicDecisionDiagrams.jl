@testset "Parametrized Algebraic Decision Diagrams" begin
    ADD = AlgebraicDecisionDiagrams # Alias
    MLE = MultilinearExpression # Alias
    @show x1 = indicator(MLE,1) # equivalent to 
    #@show x1 = Node(1, MLE(0.0), MLE(1.0))
    @show x2 = indicator(MLE,2) # equivalent to
    #@show x2 = Node(2, MLE(0.0), MLE(1.0))
    @show x3 = x1 + x2
    @show d1 = Node(1, 1 + MLE(-1.0,1), MLE(1,1))
    @show m1 = x1 + d1
    @show d2 = Node(2, 1 + MLE(-1.0,2), MLE(1,2))
    @show m2 = x2 + d2
    @show m3 = d1 * d2
    @show convert(MLE,1)
    @show promote(MLE(1.0,2),2)
    println()
    @info "Example from the paper"
    # Dictionary of variables to indices (use negative to avoid collision with automatic variable creation)
    @show v =  Dict("a" => -1, "b" => -2)
    # Maps each expression to a fresh monomial
    let
        cache = Dict{MLE,MLE}()
        global new_monomial
        function new_monomial(e::MLE) 
            get!(cache,e,MLE(1.0,length(cache)+1))
        end
    end
    # Print out constraints
    dummy = MLE(1)
    function print_constraint(e1::MLE, e2::MLE) 
        println(e1, " = ", e2)
        dummy
    end
    @show ϕA = ADD.reduce(
        Node(0,
            Node(5,
                1+MLE(-1.0,v["a"]),
                MLE(1.0,v["a"])
            ),
            Node(1,
                Node(5,
                    1+MLE(-1.0,v["a"]),
                    MLE(1.0,v["a"])
                ),
                Node(6,
                    1+MLE(-1.0,v["a"]),
                    MLE(1.0,v["a"])
                ),
            )
        )
    )
    @show ϕ5 = Node(5, MLE(0.6), MLE(0.4))
    @show μ1 = marginalize(ϕA * ϕ5, 5)
    @show μ1p = apply(new_monomial,μ1)
    # equivalent to:
    # @show μ1p = ADD.reduce(
    #     Node(0,
    #         MLE(1.0,3]),
    #         Node(1,
    #             MLE(1.0,3),
    #             Node(6,
    #                 MLE(1.0,4),
    #                 MLE(1.0,5)
    #             )
    #         )
    #     )
    # )
    @show ϕ6 = Node(6, MLE(0.1), MLE(0.9))
    @show μ2 = marginalize(μ1p * ϕ6, 6)
    @show μ2p = apply(new_monomial,μ2)
    @show ϕ1 = Node(1, MLE(0.625), MLE(0.375))
    @show μ3 = marginalize(μ2p * ϕ1, 1)
    @show μ3p = apply(new_monomial,μ3)
    @show ϕB = ADD.reduce(
        Node(0,
            Node(7,
                1+MLE(-1.0,v["b"]),
                MLE(1.0,v["b"])
            ),
            Node(8,
                1+MLE(-1.0,v["b"]),
                MLE(1.0,v["b"])
            ),        
        )
    )
    @show ϕ8 = Node(8, MLE(0.8), MLE(0.2))
    @show μ4 = marginalize(μ3p * ϕB * ϕ8, 8)
    @show μ4p = apply(new_monomial,μ4)
    @show ϕ0 = Node(0, MLE(0.2), MLE(0.8))
    @show μ5 = marginalize(μ4p * ϕ0, 0)
    @show μ5p = apply(new_monomial,μ5)
    @show ϕ7 = Node(7, MLE(0.3), MLE(0.7))
    @show μ6 = marginalize(μ5p * ϕ7, 7) # = 0.7x12 + 0.3x11
    @test value(μ6) == MLE(0.7,12) + MLE(0.3,11)
    println()
    @info "Bilinear program"
    println("Maximize: $(value(μ6))")
    println("Subject to:")
    apply(print_constraint,μ1p,μ1)
    apply(print_constraint,μ2p,μ2)
    apply(print_constraint,μ3p,μ3)
    apply(print_constraint,μ4p,μ4)
    apply(print_constraint,μ5p,μ5);

end # testset