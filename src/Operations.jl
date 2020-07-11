# Implements standard manipulation operation with Decision Diagrams

export
    ¬,
    ∧,
    ∨,
    apply,
    reduce,
    restrict,
    marginalize

# OPERATIONS
"Returns the complement of the function."
@inline (¬)(α::Node) = Node(index(α), ¬low(α), ¬high(α))
@inline (¬)(α::Terminal{Bool}) = value(α) ? Terminal(false) : Terminal(true)
@inline (¬)(α::Terminal{T}) where T = Terminal(one(T) - value(α))
"Returns the conjunction of the Boolean functions."
@inline (∧)(α::DecisionDiagram{Bool}, β::DecisionDiagram{Bool}) = apply(&, α, β)
"Returns the disjunction of the Boolean functions."
@inline (∨)(α::DecisionDiagram{Bool}, β::DecisionDiagram{Bool}) = apply(|, α, β)
@inline Base.:+(α::DecisionDiagram{T}, β::DecisionDiagram{T}) where T = apply(+, α, β)
"Returns the subtraction of the respective functions."
@inline Base.:-(α::DecisionDiagram{T}, β::DecisionDiagram{T}) where T = apply(-, α, β)
"Returns the product of the respective functions."
@inline Base.:*(α::DecisionDiagram{T}, β::DecisionDiagram{T}) where T = apply(*, α, β)
@inline Base.:*(c::Number,α::Terminal) = Terminal(c * value(α))
@inline Base.:*(c::Number,α::DecisionDiagram) = Node(index(α),c * low(α),c * high(α))
"Returns a Diagram canonical representation of α OP β, where OP is some binary operator."
@inline apply(OP::Function,α::DecisionDiagram{T}, β::DecisionDiagram{T}) where T = apply(OP, α, β, Dict{Tuple{Int, Int}, DecisionDiagram{T}}(), Dict{T,DecisionDiagram{T}}(),Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}())
"""
    apply(OP,α,β,opcache,vcache)

Recursively computes α OP β and cache results.

# Parameters
- `OP`: operation to apply to leaves
- `α`,`β`: decision diagrams
- `opcache`: cache of applied operations
- `vcache`: cache of terminal values
"""
function apply(OP::Function, α::DecisionDiagram{T}, β::DecisionDiagram{T}, opcache::Dict{Tuple{Int, Int}, DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}, ncache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}) where T
    key = (id(α), id(β))
    if haskey(opcache, key) return opcache[key] end
    #TODO: check identity and anihilator cases 
    local γ::DecisionDiagram{T}
    if isa(α,Terminal) && isa(β,Terminal)
        constant = OP(value(α),value(β))
        γ = get!(vcache, constant, Terminal(constant))
        # if haskey(vcache, constant) # avoid duplicate terminals
        #     γ = vcache[constant]
        # else
        #     γ = Terminal(constant)
        #     vcache[constant] = γ
        # end
    else # decompose on least variable (terminals are associated with upper variables)
        if index(α) < index(β) # decompose on variable index(α)
            l = apply(OP, low(α), β, opcache, vcache, ncache)
            h = apply(OP, high(α), β, opcache, vcache, ncache)
        elseif index(α) > index(β) # decompose on variable index(β)
            l = apply(OP, α, low(β), opcache, vcache, ncache)
            h = apply(OP, α, high(β), opcache, vcache, ncache)
        else # both DDs are rooted at the same variable
            l = apply(OP, low(α), low(β), opcache, vcache, ncache)
            h = apply(OP, high(α), high(β), opcache, vcache, ncache)
        end
        if id(l) == id(h) # redundant node
            γ = l
            #γ = index(α) <= index(β) ? l : h
        elseif haskey(ncache,(min(index(α),index(β)),id(l),id(h))) # duplicate or already visited node
            γ = ncache[min(index(α),index(β)),id(l),id(h)]
        else
            γ = ncache[min(index(α),index(β)),id(l),id(h)] = Node(min(index(α),index(β)), l, h)
        end
    end
    opcache[key] = γ
end
"""
    apply(f::Function, α::DecisionDiagram)

Returns the application of function f to α.
"""
function apply(f::Function,α::DecisionDiagram{T}) where T
    apply(f,α,Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}(),Dict{T,DecisionDiagram{T}}())
end
function apply(f::Function,α::Terminal{T}, cache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}) where T 
    v = f(value(α))
    get!(vcache,v,Terminal(v))
end
function apply(f::Function,α::DecisionDiagram{T}, cache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}) where T
    left, right = apply(f,low(α),cache,vcache), apply(f,high(α),cache,vcache)
    if id(left) == id(right) # redundant node
        return left
    end
    # if there is a node with the same variable and children, return it
    # otherwise, create it
    get!(cache, (index(α),id(left),id(right)), Node{T}(id(α),index(α),left,right))
end

"""
    reduce(α::DecisionDiagram)

Returns the canonical form of the decision diagram α. 
A diagram is canonical iff:
- no two terminals are assigned to the same value
- no two nodes have are labeled by the same variable and have the same two reduced children low and high with identical ids

"""
function reduce(α::DecisionDiagram{T}) where T
    reduce(α,Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}(),Dict{T,DecisionDiagram{T}}())
end
"""
reduce(α::DecisionDiagram{T}, cache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}) 

Returns the canonical form of decision diagram α using node and value caches.
A diagram is canonical iff:
    - no two terminals are assigned to the same value
    - no two nodes have are labeled by the same variable and have the same two reduced children low and high with identical ids

# Arguments
- `α`: decision diagram to reduce.  
- `cache`: cache of inner nodes (identified by ids of variable, low and high children).
- `vcache::Dict{T,DecisionDiagram{T}}`: cache of terminal nodes identified by the associated value.
"""
reduce(α::Terminal{T}, cache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}) where T = get!(vcache,value(α),α)
function reduce(α::DecisionDiagram{T}, cache::Dict{Tuple{Int,Int,Int},DecisionDiagram{T}}, vcache::Dict{T,DecisionDiagram{T}}) where T
    left, right = reduce(low(α),cache,vcache), reduce(high(α),cache,vcache)
    if id(left) == id(right) # redundant node
        return left
    end
    # if there is a node with the same variable and children, return it
    # otherwise, create it
    get!(cache, (index(α),id(left),id(right)), Node{T}(id(α),index(α),left,right))
    # elseif haskey(cache,(index(α),id(left),id(right))) # duplicate or already visited node
    #     return cache[index(α),id(left),id(right)]
    # end
    # cache[index(α),id(left),id(right)] = Node{T}(id(α),index(α),left,right)
end

"""
    restrict(α::DecisionDiagram, var::Int, value::Bool=true)

Returns the canonical form of the function α constrained at variable var=value.

# Example
```julia
x, y = variable(1), variable(2)
f = (one(x)-x)*(one(y)-1) + x*y
g = Terminal(4)*(one(x)-x) + Terminal(2)*x
h = f + g
r1 = restrict(h,1,false)
r2 = h | (2 => true) # shorthand for restrict(h,2,true)
r3 = h | (y => true) # same as above
```
"""
function restrict(α::DecisionDiagram, var::Int, value::Bool=true) 
    if isa(α,Terminal) return α end
    if index(α) != var
        l = restrict(low(α),var,value)
        h = restrict(high(α),var,value)
        return Node(index(α), l, h)
    end
    if value return restrict(high(α),var,value) end
    restrict(low(α),var,value)
end
@inline Base.:|(α::DecisionDiagram,a::Pair{Int,Bool}) = restrict(α,a[1],a[2])

"Marginalize a variable var from function α."
@inline marginalize(α::Terminal, var::Int) = α + α
#marginalize(α::Node{T}, var::Int) = reduce(marginalize_step(α, var))
marginalize(α::DecisionDiagram, var::Int) = restrict(α,var,true) + restrict(α,var,false)
# function marginalize(α::DecisionDiagram, var::Int)
#   # produces non-canonical form (perhaps more efficient?)
#   if index(α) == var return low(α) + high(α) end
#   Node(index(α), marginalize(low(α), var), marginalize(high(α), var))
# end