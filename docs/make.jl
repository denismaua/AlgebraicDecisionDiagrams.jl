using AlgebraicDecisionDiagrams
using Documenter

makedocs(;
    modules=[AlgebraicDecisionDiagrams],
    authors="denismaua <denis.maua@gmail.com> and contributors",
    repo="https://github.com/denismaua/AlgebraicDecisionDiagrams.jl/blob/{commit}{path}#L{line}",
    sitename="AlgebraicDecisionDiagrams.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://denismaua.github.io/AlgebraicDecisionDiagrams.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/denismaua/AlgebraicDecisionDiagrams.jl",
)
