# AlgebraicDecisionDiagrams.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://denismaua.github.io/AlgebraicDecisionDiagrams.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://denismaua.github.io/AlgebraicDecisionDiagrams.jl/dev)
[![Build Status](https://github.com/denismaua/AlgebraicDecisionDiagrams.jl/workflows/CI/badge.svg)](https://github.com/denismaua/AlgebraicDecisionDiagrams.jl/actions)

This package implements Algebraic Decision Diagrams [[2]](#adds). It is focused on usability at the expense of optimization.

## Instalation

In a Julia shell, type:
```julia
import Pkg; Pkg.add("http://github.com/denismaua/AlgebraicDecisionDiagrams.jl")
```

## Usage

ADD are represented as parametric linked structures. The easiest way to create and manipulate ADDs is by using operations and constants. Omitting types is equivalent to assuming Boolean constant values (hence BDDs [[1]](#bdds)).

```julia
using AlgebraicDecisionDiagrams
# Use alias for convenience
ADD = AlgebraicDecisionDiagrams 

# Boolean Decision Diagrams

## This creates a positive literal on variable 1
l1 = pliteral(1)
@show ¬l1 # obtains the negation of that literal
@show apply(~,l1) # alternatively, one can apply negation (~) to the function
@show l1 ∧ (¬l1) # contradiction
@show l1 ∨ (¬l1) # tautology

## The BDD in Fig. 7 in Bryant's paper [1]
l2, l3 = pliteral(2), pliteral(3)
@show ¬(l1 ∧ l3) ∨ (l2 ∧ l3)

# Algebraic Decision Diagrams

## Example from Fig. 1 in Bryant's paper, using 0/1 constants [1]
x1, x2, x3 = indicator(Int,1), indicator(Int,2), indicator(Int,3)
@show apply((¬x1)*x2, x1*x3, max)

## Example in Fig. 5 of Bryant's paper, using 0/1 constants [1]
@show ADD.reduce( # return canonical form
    Node(1, # variable index (integer)
        Node(2, # variable index
            zero(Int), # low child -> additivite identity for Int (0)
            indicator(Int,3)
        ), # high child -> indicator node on variable 3
        Node(2,
            indicator(Int,3), # low
            indicator(Int,3)  # high
        )
    )
)

## Example in Fig 1. in Bahar et al. 1997's paper [2]
x0 = indicator(Int,0)
x1 = indicator(Int,2)
y0 = indicator(Int,1)
y1 = indicator(Int,3)
@show graph = Terminal(2)*(¬x0)*(¬x1)*(¬y0)*y1 + Terminal(2)*(¬x0)*(¬x1)*y0*(¬y1) + Terminal(2)*(¬x0)*x1*(¬y0)*y1 + Terminal(2)*(¬x0)*x1*y0*(¬y1) + Terminal(4)*x0*(¬x1)*y0*y1 + Terminal(4)*x0*x1*(¬y0)*y1

## Diagram Traversal
# To collect all nonterminal nodes of the previous diagram
nt = filter(n -> isa(n,Node), collect(graph)) # node are traversed in breath-first order
# now obtain its set of variable indices (without repetition)
@show mapreduce(index,union,nt) # should contain 0,1,2,3

## Matrix examples in page 9
@show f = (¬x0)*(¬y0) + x0*y0
@show g = Terminal(4)*(¬x0) + Terminal(2)*x0
@show h = f + g
@info "Restriction"
@show restrict(h,0,false)
@show h | (1 => true)
@show (h | (index(x0) => true)) + (h | (index(x0) => false))
@show (h | (index(y0) => true)) + (h | (index(y0) => false))

# Parametrized ADDs: ADDs with Multilinear Expressions (MLE) constants

MLE = MultilinearExpression # Alias

## Create some MLE examples
@show a = MLE(2.0,1,3) + MLE(2.0,3)
@show b = MLE(3.0,2) + MLE(1.0,2,4) + MLE(1.0,4)
@show c = a * b

## Now create PADDs
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
```
## License

(C) Denis Deratani Mauá. See LICENSE file.

## References

For more information on ADDs and BDDs see:

<a name="bdds">[1]</a>: Bryant, Randal E. Graph-based algorithms for boolean function manipulation. Computers, IEEE Transactions on 100, no. 8 (1986): 677-691.

<a name="adds">[2]</a>: Bahar, R. Iris, Erica A. Frohm, Charles M. Gaona, Gary D. Hachtel, Enrico Macii, Abelardo Pardo, and Fabio Somenzi. Algebraic decision diagrams and their applications. Formal methods in system design 10, no. 2-3 (1997): 171-206.
