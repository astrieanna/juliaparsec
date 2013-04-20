#require("Profile")
#using IProfile
#@iprofile begin

function sequence(fs::Array{Function,1})
    function (xs,pos)
        acc = Array(Any,length(fs))
        i = 1
        for f = fs
            x = f(xs,pos)
            if x != nothing
                result, pos = x
                acc[i] = result
                i += 1
            else
                return nothing
            end
        end
        return (acc, pos)
    end
end

function sequence2(fs::Array{Function,1})
    f = quote function(xs,pos) end end
    push!(f.args[2].args[2].args, :(result = Array(Any,length($fs))))
    append!(f.args[2].args[2].args, { quote
        x = $(fs[i])(xs,pos)
        if x == nothing
            return nothing
        end
        result[$i], pos = x
    end for i=1:length(fs)})
    push!(f.args[2].args[2].args, :(return (result, pos)))
    return eval(f)
end

function branch(fs::Array{Function,1})
    function (xs,pos)
        for f = fs
            x = f(xs,pos)
            if x != nothing
                return x
            end
        end
        return nothing
    end
end

function branch2(fs::Array{Function,1})
  f = quote function(xs,pos) end end
  append!(f.args[2].args[2].args, {
    quote
      r = $f(xs,pos)
      if r != nothing
        return r
      end
    end for f=fs }
  )
  push!(f.args[2].args[2].args, :(return nothing))
  eval(f)
end

function zeroormore(f::Function)
    function (xs,pos)
        acc = Array(Any,0)
        x = f(xs,pos)
        while(x != nothing)            
            result, pos = x
            push!(acc,result)
            x = f(xs,pos)
        end
        return (acc, pos)
     end
end

## Usage examples


function parse_char(xs,c,p)
  if p > length(xs) return nothing end
  xs[p] == c ? (c,p+1) : nothing
end
function parse_num(xs,p)
  digits = ['0','1','2','3','4','5','6','7','8','9']
  numstr = ""
  while p <= length(xs) && contains(digits,xs[p])
    numstr = "$numstr$(xs[p])"
    p += 1
  end
  return numstr == "" ? nothing : (parseint(numstr),p)
end


