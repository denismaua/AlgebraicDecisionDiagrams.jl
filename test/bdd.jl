@testset "Boolean Decision Diagrams" begin
    l1 = pliteral(1)
    @show l1
    @show ¬l1
    @show apply(~,l1)
    @show nliteral(1)
    @show l1 ∧ (¬l1)
    @test value(l1 ∧ (¬l1)) == false
    @show l1 ∨ (¬l1)
    @test value(l1 ∨ (¬l1)) == true
    @info "Fig. 7 in Bryant's paper"
    l2, l3 = pliteral(2), pliteral(3)
    @show ¬(l1 ∧ l3) ∨ (l2 ∧ l3)
    println()
end # testset