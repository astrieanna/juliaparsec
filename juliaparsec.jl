
# type Parser{T}
#     result::Union(Nothing,T)
#     remaininginput
# end

function sequence(fs::Array{Function,1})
    return (xs) -> begin
        acc = Array(Any,length(fs))
        i = 1
        for f = fs
            x = f(xs)
            if x != Nothing()
                result, rest = x
                xs = rest
                acc[i] = result
                i += 1
            else
                return Nothing()
            end
        end
        return (acc, xs)
    end
end

function branch(fs::Array{Function,1})
    return (xs) -> begin
      for f = fs
        x = f(xs)
        if x != Nothing()
          return x
        end
      end
      return Nothing()
   end
end


## usage example

abstract Token123
type Dog <: Token123 end
type Cat <: Token123 end

function parse_cat(xs)
  if beginswith(xs,"cat")
    return (Cat(),xs[4:])
  end
  return Nothing()
end

function parse_dog(xs)
  if beginswith(xs,"dog")
    return (Dog(),xs[4:])
  end
  return Nothing()
end

myparser = branch([parse_cat,parse_dog])
@show myparser("dog")
@show myparser("cat")
@show myparser("dogcat")
@show myparser("catdog")
@show myparser("god")

myseqparser = sequence([parse_cat,parse_dog])
@show myseqparser("dog")
@show myseqparser("cat")
@show myseqparser("dogcat")
@show myseqparser("catdog")
@show myseqparser("god")


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
