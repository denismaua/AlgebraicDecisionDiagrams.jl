# Implements Decision Diagram data structures, constructors, basic manipulation
export
    DecisionDiagram,
    Terminal,
    Node,
    index,
    value,
    pliteral,
    nliteral,
    indicator

nextid = 1

abstract type DecisionDiagram{T} end

"""
  Implements a generic decision diagram whose leaves are of given type T
"""
struct Terminal{T} <: DecisionDiagram{T}
    "Unique identifier."
    id::Int
    "Constant."
    value::T
    # "Constructs a terminal."
    # Terminal{T}(v) where T = new(typemax(Int),v)
    function Terminal{T}(v)  where T
        global nextid
        id = nextid
        nextid = (nextid + 1) % typemax(Int)
        new{T}(id,v)
    end
end
Terminal(v::T) where T = Terminal{T}(v)
"Multiplicative identity for terminals of type T"
@inline Base.one(α::DecisionDiagram{T}) where {T <: Number} = Terminal(one(T))
"Additive identity for terminals of type T"
@inline Base.zero(α::DecisionDiagram{T}) where {T <: Number} = Terminal(zero(T))
"Returns the sum of the respective functions."
# GETTERS
@inline value(α::Terminal) = α.value
@inline index(α::Terminal) = typemax(Int)
# OUTPUT
function Base.show(io::IO,α::Terminal)
    print(io,"(",value(α),") [", id(α), "]")
    nothing
end
struct Node{T} <: DecisionDiagram{T}
    "Unique identifier."
    id::Int
    "Root vertex variable index."
    index::Int
    "Low child vertex of BDD."
    low::DecisionDiagram{T}
    "High child vertex of BDD."
    high::DecisionDiagram{T}
    "Constructs a variable."
    function Node{T}(i::Integer, low::DecisionDiagram{T}, high::DecisionDiagram{T}) where T
        global nextid
        id = nextid
        nextid = (nextid + 1) % typemax(Int)
        new{T}(id,i,low,high)
    end
    Node{T}(id,index,low,high) where T = new(id,index,low,high)
end
# CONSTRUCTORS
Node(index,low::DecisionDiagram{T},high::DecisionDiagram{T}) where T = Node{T}(index,low,high)
Node(index,low::T,high::T) where T = Node{T}(index,Terminal(low),Terminal(high))
Node(index,low::T,high::DecisionDiagram{T}) where T = Node{T}(index,Terminal(low),high)
Node(index,low::DecisionDiagram{T},high::T) where T = Node{T}(index,low,Terminal(high))
"""
   Creates Diagram representing indicator function on given variable.
   If complement is true, then returns complement indicator.
"""
indicator(T::Type,index::Int,complement::Bool=false) = complement ? Node(index,Terminal(one(T)),Terminal(zero(T))) : Node(index,Terminal(zero(T)),Terminal(one(T))) # Numeric terminals
""""
    pliteral(index::Int)

Creates a positive literal (an indicator over Boolean constants) for variable index.
"""
pliteral(index::Int) = indicator(Bool,index) # Positive Literal
""""
    nliteral(index::Int)

Creates a negated literal (an indicator over Boolean constants) for variable index.
"""
nliteral(index::Int) = indicator(Bool,index,true) # Negative Literal
# GETTER functions
id(α::DecisionDiagram) = α.id
index(α::Node) = α.index
low(α::Node) = α.low
high(α::Node) = α.high
# OUTPUT
Base.show(io::IO,α::Node) = print(io,"\n@"), Base.show(io,α," ")
function Base.show(io::IO,α::Node,prefix::String)
    print(io,"╮ V", index(α), " [", id(α), "] \n",prefix, "├─⊂−⊃─")
    show(io,low(α),prefix * "│     ")
    print(io,"\n",prefix, "╰─⊂+⊃─")
    show(io,high(α),prefix * "      ")
    nothing
end
function Base.show(io::IO,α::Terminal,prefix::String)
    show(io,α)
    nothing
end

# ITERATORS
mutable struct IteratorDiagram{T}
    frontier::Vector{DecisionDiagram{T}}
    visited::Set{Int}
    count::Int
end
"""
    Depth-first search traversal.
"""
function Base.iterate(α::DecisionDiagram{T}, state = IteratorDiagram(DecisionDiagram{T}[α], Set{Int}(), 0)) where T
    if isempty(state.frontier)
        return nothing
    end
    node = pop!(state.frontier) #  change to popfirst! to perform BFS instead
    # get next unvisited state
    while id(node) in state.visited
        if isempty(state.frontier) return nothing end
        node = pop!(state.frontier)
    end
    # mark state as visited
    push!(state.visited, id(node))
    state.count += 1
    if isa(node, Node) # not a terminal
        if !(id(low(node)) in state.visited)
            push!(state.frontier,low(node))
        end
        if !(id(high(node)) in state.visited)
            push!(state.frontier,high(node))
        end
    end
    (node, state)
end
"We can't know the number of nodes in advance (to traversing the diagram)."
Base.IteratorSize(::DecisionDiagram{T}) where T = Base.SizeUnknown()
"""
    A decision diagram is composed of other decision diagrams.
"""
Base.eltype(α::Type{DecisionDiagram{T}}) where T = DecisionDiagram{T}
"Returns the number of nodes in the diagram."
Base.length(α::DecisionDiagram{T}) where T = length(collect(α))