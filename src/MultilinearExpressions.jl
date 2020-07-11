# Implements a Multilinear Expression data structure

export 
   Monomial,
   MultilinearExpression

# DATA TYPE DEFINITIONS
"""
    Monomial

Specifies a monomial as a coefficient of numeric type T and a sorted list of variable indices.
We assume the index 0 represents the constant (variable-free) monomial.
"""
struct Monomial #{T}
    #coef::T # coefficient
    vars::Tuple{Vararg{Int}} # list of variable indices
    # function Monomial{T}(coef::T,vars) where T <: Number    
    #     @assert Base.issorted(vars)
    #     new(coef,vars)
    # end
    function Monomial(vars) 
        @assert Base.issorted(vars)
        new(vars)
    end
end
"""
    MultilinearExpression

Implements a multilinear expression data type as a dictionary of monoids to coefficients.

### Examples
```julia
# Creates a constant expression
@show c = MultilinearExpression(7.4)
# Creates expressions with single term
@show e1 = MultilinearExpression(4.0,1)
@show e2 = MultilinearExpression(3.0,1,3)
````
"""
struct MultilinearExpression
    terms::Dict{Monomial,<:Number}
    MultilinearExpression(d::Dict{Monomial,<:Number}) = new(d)
end
# CONSTRUCTORS
"Creates an expression with a single constant c"
MultilinearExpression(c::Number) = MultilinearExpression(Dict(Monomial(tuple()) => c))
#Monomial(coef::T, vars::Tuple{Vararg{Int}}) where T <: Number = Monomial{T}(coef,vars)
"Creates an expression with a single term (given as a pair monomial => coefficient"
MultilinearExpression(t::Pair{Monomial,<:Number}) = MultilinearExpression(Dict(t))
# function MultilinearExpression(e::MultilinearExpression,t::Pair{Monomial,<:Number})
#     terms = copy(e.terms)
#     terms[t[1]] = t[2]        
#     MultilinearExpression(terms)
# end
"Creates an expression with given coefficient and variables (indices)."
MultilinearExpression(c::Number,v1::Int,v...) = MultilinearExpression(Dict(Monomial((v1,v...)) => c))
#monomial(coef,v1,v...) = MultilinearExpression( Monomial((v1,v...)) => coef )
#monomial(coef,v1,v...) = MultilinearExpression( (Monomial(coef,(v1,v...)),) )
#monomial(c::Number) = MultilinearExpression(Monomial(tuple()) => c)
"Returns the aditivity identity expression."
Base.zero(::Type{MultilinearExpression}) = MultilinearExpression(0) # falls back to most basic identity constant
Base.zero(e::MultilinearExpression) = MultilinearExpression(zero(first(e.terms)[2]))
"Returns the multiplicative identity expression."
Base.one(::Type{MultilinearExpression}) = MultilinearExpression(1) # falls back to most basic numeric identity constant
Base.one(e::MultilinearExpression) = MultilinearExpression(one(first(e.terms)[2]))
# # GETTERS
Base.getindex(e::MultilinearExpression,m::Monomial) = get(e.terms,m,zero(first(e.terms)[2]))
Base.setindex!(e::MultilinearExpression,c::Number,m::Monomial) = setindex!(e.terms,c,m)
@inline terms(e::MultilinearExpression) = e.terms
# coeffficient(m::Monomial) = m.coef
@inline variables(m::Monomial) = m.vars
# # HELPERS
# "Verify if monomials are ordered in an expression"
# issorted(e::MultilinearExpression) = length(e) < 2 || ((variables(e[1]) < variables(e[2])) && issorted(Base.tail(e)))
"Iterate over the pairs monomials => coeeficient in the expression."
Base.iterate(e::MultilinearExpression) = Base.iterate(terms(e))
Base.iterate(e::MultilinearExpression,state) = Base.iterate(terms(e),state)
"Returns the number of monomials in the expression."
Base.length(e::MultilinearExpression) = length(terms(e))
# # INPUT/OUTPUT
Base.show(io::IO, m::Monomial) = print(io, "χ", join(variables(m),"χ"))
function Base.show(io::IO, t::Pair{Monomial,<:Number})
    if length(variables(t[1])) == 0
        print(io, t[2])
    else
        print(io, t[2], t[1])
    end
    nothing
end 
#Base.show(io::IO, e::MultilinearExpression) = print(io, join(map(string,collect(terms(e)))," + "))
Base.show(io::IO, e::MultilinearExpression) = print(io, join(terms(e), " + "))
# # OPERATIONS
# """
#     Adds two expressions. Assumes the terms are ordered in each expression.
# """
function Base.:+(e1::MultilinearExpression,e2::MultilinearExpression)
    e = MultilinearExpression(copy(terms(e1)))
    for (m,c) in e2
        e[m] += c 
    end
    e
#     @assert issorted(e1) && issorted(e2)
#     i, j = 1, 1
#     e = Vector{Monomial}()
#     while i <= length(e1) && j <= length(e2)
#         c1, c2 = coeffficient(e1[i]), coeffficient(e2[j])
#         v1, v2 = variables(e1[i]), variables(e2[j])
#         if v1 == v2
#             if c1 + c2 != zero(c1)
#                 push!(e,Monomial(c1 + c2, v1))
#             end
#             i += 1
#             j += 1
#         elseif v1 < v2
#             if c1 != zero(c1)
#                 push!(e,e1[i])
#             end
#             i += 1
#         else
#             if c2 != zero(c2)
#                 push!(e,e2[j])
#             end
#             j += 1
#         end
#     end
#     for k = i:length(e1)
#         push!(e,e1[k])
#     end
#     for k = j:length(e2)
#         push!(e,e2[k])
#     end
#     Tuple(e)
end
## Base.:+(e::MultilinearExpression,m::Monomial) = Base.:+(e,(m,))
# # Base.:+(m::Monomial,e::MultilinearExpression) = Base.:+((m,),e)
Base.:+(c::Number,e::MultilinearExpression) = MultilinearExpression(c) + e
Base.:+(e::MultilinearExpression,c::Number) = c + e
# Base.:*(c::T,m::Monomial{T}) where T <: Number = Monomial(c*coeffficient(m),variables(m))
Base.:*(c::Number,m::Monomial) = MultilinearExpression(m => c)
Base.:*(m::Monomial,c::Number) = c * m
function Base.:*(m1::Monomial,m2::Monomial) 
    vars = union(variables(m1),variables(m2))
    @assert length(vars) == length(variables(m1)) + length(variables(m2)) "Multiplication of monomial with common variable is not multilinear"
    Monomial(Tuple(sort!(vars)))
end
function Base.:*(e1::MultilinearExpression,e2::MultilinearExpression)
    MultilinearExpression(Dict(
        m1 * m2 => c1 * c2
        for (m1,c1) in e1, (m2,c2) in e2
    ))
    # for (m1,c1) in e1
    #     for (m2,c2) in e2
    #         e[ m1 * m2 ] = c1 * c2
    #     end
    # end
    # e
    # @assert issorted(e1) && issorted(e2)
    # e = Dict{Tuple{Vararg{Int}},Monomial}()
    # Tuple( map(x -> x[2], sort!( collect(e), by = x -> x[1] ) ) )
end
Base.:*(c::Number,e::MultilinearExpression) = MultilinearExpression(c) * e
Base.:*(e::MultilinearExpression,c::Number) = c * e
## COMPARISONS
Base.:(==)(m1::Monomial,m2::Monomial) = variables(m1) == variables(m2)
function Base.:(==)(e1::MultilinearExpression,e2::MultilinearExpression)
    if length(e1) != length(e2) 
        return false 
    end
    for (m1,c1) in e1
        if e2[m1] != c1
            return false
        end
    end 
    true
end
Base.hash(m::Monomial, h::UInt) = hash(variables(m), h)
Base.hash(t::Pair{Monomial,<:Number}, h::UInt) = hash(t[1],hash(t[2],h))
Base.hash(e::MultilinearExpression, h::UInt) = foldl( (t1,t2) -> hash(t1,hash(t2,h)), e ; init=hash(0))
## PROMOTION AND CONVERSION
Base.convert(::Type{MultilinearExpression},c::Number) = MultilinearExpression(c)
Base.convert(::Type{MultilinearExpression},p::Pair{Monomial,Number}) = MultilinearExpression(p)
Base.promote_rule(::Type{MultilinearExpression}, ::Type{T}) where T <: Number = MultilinearExpression