
type Parser{T}

end

function sequence(f::Function, seq::Array{T,1})

end

function branch(f::Function, options::Array{Parser{T},1})

end

function parse(p::Parser{T},t::Array{T,1})

end


## usage example

abstract Tokens
type Dog <: Token end
type Cat <: Token end

function parse_dogcat

parse_dogcat = branch([ sequence(['c','a','t']) do (_) -> Cat() end, sequence(['d','o','g']) do (_) -> Dog() end]) do (x) -> x end

dogstring = "dog"
catstring = "cat"
catdogstring = "catdog"

parse(parse_dogcat,dogstring) == Dog()
parse(parse_dogcat,catstring) == Cat()
parse(parse_dogcat,catdogstring) == ParsingFailure() 
