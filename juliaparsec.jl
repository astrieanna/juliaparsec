function sequence(fs::Array{Function,1})
    function (xs)
        acc = Array(Any,length(fs))
        i = 1
        for f = fs
            x = f(xs)
            if x != nothing
                result, rest = x
                xs = rest
                acc[i] = result
                i += 1
            else
                return nothing
            end
        end
        return (acc, xs)
    end
end

function branch(fs::Array{Function,1})
    function (xs)
        for f = fs
            x = f(xs)
            if x != nothing
                return x
            end
        end
        return nothing
    end
end

function zeroormore(f::Function)
    function (xs)
        acc = Array(Any,0)
        rest = xs
        x = f(xs)
        while(x != nothing)            
            result, rest = x
            push!(acc,result)
            x = f(rest)
        end
        return (acc, rest)
     end
end

## Usage examples

## Calculator example
abstract CalcToken
type Plus <: CalcToken end
type Digit <: CalcToken
  value :: Int
end

parse_plus(xs) = beginswith(xs,"+") ? (Plus(),xs[2:]) : nothing
    
function parse_digit(xs)
    m = match(r"\d+",xs)
    if m != nothing
        return (Digit(int(m.match)),xs[length(m.match)+1:])
    end
    return nothing
end

parse_one_expr = sequence([parse_digit,zeroormore(sequence([parse_plus,parse_digit]))])

function interpreter(line)
    result = parse_one_expr(line)
    if result == nothing
        return
    end
    expr, remainder = result
    first = expr[1]
    rest = expr[2]
    sum = first.value
    for e = rest
      sum += e[2].value
    end
    return sum
end

@show interpreter("1+2")
@show interpreter("1+2+3+4")
@show interpreter("1+2+3+4+5+6+7+8+12345")
@time @show interpreter(join(ones(Int,5000),"+"))

## silly test example
abstract Token123
type Dog <: Token123 end
type Cat <: Token123 end

parse_cat(xs) = beginswith(xs,"cat") ? (Cat(),xs[4:]) : nothing
parse_dog(xs) = beginswith(xs,"dog") ? (Dog(),xs[4:]) : nothing

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

myzeroparser = zeroormore(parse_cat)
@show myzeroparser("dog")
@show myzeroparser("cat")
@show myzeroparser("catcatcat")
@show myzeroparser("dogcat")
@show myzeroparser("catdog")
@show myzeroparser("god")
