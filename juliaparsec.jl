
type Parser{T}
    result::Union(Nothing,T)
    remaininginput
end

function sequence{T}(f::Function, seq::Array{T,1})
    
end

function branch{T}(f::Function, options::Array{Parser{T},1})

end

function parse{T}(p::Parser{T},t::Array{T,1})

end


## usage example

abstract Token
type Dog <: Token end
type Cat <: Token end

# function parse_dogcat() = branch([ sequence(['c','a','t']) do (_) -> Cat() end, sequence(['d','o','g']) do (_) -> Dog() end]) do (x) -> x end

# ## It seems like these two things are not equivalent. Does that seem odd to you?
# sequence(parse_dogcat, parse_dogcat)

# sequence(
#   branch([ sequence(['c','a','t']) do (_) -> Cat() end, sequence(['d','o','g']) do (_) -> Dog() end]),
#   branch([ sequence(['c','a','t']) do (_) -> Cat() end, sequence(['d','o','g']) do (_) -> Dog() end])) do (x) -> x end

# dogstring = "dog"
# catstring = "cat"
# catdogstring = "catdog"

# parse(parse_dogcat,dogstring) == Dog()
# parse(parse_dogcat,catstring) == Cat()
# parse(parse_dogcat,catdogstring) == ParsingFailure() 
