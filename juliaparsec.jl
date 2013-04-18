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

function sequence2(fs::Array{Function,1})
    f = quote function(xs) end end
    push!(f.args[2].args[2].args, :(result = Array(Any,length($fs))))
    append!(f.args[2].args[2].args, { quote
        x = $(fs[i])(xs)
        if x == nothing
            return nothing
        end
        result[$i], xs = x
    end for i=1:length(fs)})
    push!(f.args[2].args[2].args, :(return (result, xs)))
    return eval(f)
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

function branch2(fs::Array{Function,1})
  f = quote function(xs) end end
  append!(f.args[2].args[2].args, {
    quote
      r = $f(xs)
      if r != nothing
        return r
      end
    end for f=fs }
  )
  push!(f.args[2].args[2].args, :(return nothing))
  eval(f)
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
parse_one_expr_codegen = sequence2([parse_digit,zeroormore(sequence2([parse_plus,parse_digit]))])

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

function interpreter_codegen(line)
    result = parse_one_expr_codegen(line)
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

numones = 5000

@show interpreter("1+2")
@show interpreter("1+2+3+4")
@show interpreter("1+2+3+4+5+6+7+8+12345")
onestxt = join(ones(Int,numones),"+")
@time @show interpreter(onestxt)

@show interpreter_codegen("1+2")
@show interpreter_codegen("1+2+3+4")
@show interpreter_codegen("1+2+3+4+5+6+7+8+12345")
@time @show interpreter_codegen(onestxt)

## silly test example
abstract Token123
type Dog <: Token123 end
type Cat <: Token123 end

parse_cat(xs) = beginswith(xs,"cat") ? (Cat(),xs[4:]) : nothing
parse_dog(xs) = beginswith(xs,"dog") ? (Dog(),xs[4:]) : nothing

if(false)
myparser = branch([parse_cat,parse_dog])
@show myparser("dog")
@show myparser("cat")
@show myparser("dogcat")
@show myparser("catdog")
@show myparser("god")

myparser2 = branch2([parse_cat,parse_dog])
@show myparser2("dog")
@show myparser2("cat")
@show myparser2("dogcat")
@show myparser2("catdog")
@show myparser2("god")

myseqparser = sequence([parse_cat,parse_dog])
@show myseqparser("dog")
@show myseqparser("cat")
@show myseqparser("dogcat")
@show myseqparser("catdog")
@show myseqparser("god")

myseqparser2 = sequence2([parse_cat,parse_dog])
@show myseqparser2("dog")
@show myseqparser2("cat")
@show myseqparser2("dogcat")
@show myseqparser2("catdog")
@show myseqparser2("god")

myzeroparser = zeroormore(parse_cat)
@show myzeroparser("dog")
@show myzeroparser("cat")
@show myzeroparser("catcatcat")
@show myzeroparser("dogcat")
@show myzeroparser("catdog")
@show myzeroparser("god")
end

numseq = 100
cats = fill!(Array(Function,numseq),parse_cat)
catstext = "cat"^numseq    
seq1parser = sequence(cats)
seq2parser = sequence2(cats)
print("seq / seq2 test\n")
@time seq1parser(catstext)
@time seq2parser(catstext)

branch1parser = branch(cats)
branch2parser = branch2(cats)
print("branch / branch2 test\n")
@time branch1parser(catstext)
@time branch2parser(catstext)
    
