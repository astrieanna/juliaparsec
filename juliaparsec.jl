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

function zeroormore(f::Function)
    return (xs) -> begin
        acc = Array(Any,0)
        rest = xs
        x = f(xs)
        while(x != Nothing())            
            result, rest = x
            append!(acc, convert(Array{Any,1},[result]))
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

function parse_plus(xs)
    if beginswith(xs,"+")
        return (Plus(),xs[2:])
    end
    return Nothing()
end
    
function parse_digit(xs)
    m = match(r"\d+",xs)
    if m != Nothing()
        return (Digit(int(m.match)),xs[length(m.match)+1:])
    end
    return Nothing()
end

parse_one_expr = sequence([parse_digit,zeroormore(sequence([parse_plus,parse_digit]))])

function interpreter(line)
    result = parse_one_expr(line)
    if result == Nothing()
        return
    end
    expr,remainder = result
    first = expr[1]
    rest = expr[2]
    sum = first.value
    for e = rest
        if e != Plus()
            sum += e.value
        end
    end
    return sum
end

@show interpreter("1+2")
@show interpreter("1+2+3+4")
@show interpreter("1+2+3+4+5+6+7+8+12345")
@show interpreter(join(ones(Int,100000),"+"))

## silly test example
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

myzeroparser = zeroormore(parse_cat)
@show myzeroparser("dog")
@show myzeroparser("cat")
@show myzeroparser("catcatcat")
@show myzeroparser("dogcat")
@show myzeroparser("catdog")
@show myzeroparser("god")
