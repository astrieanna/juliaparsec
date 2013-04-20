include("juliaparsec.jl")

## Calculator example
abstract CalcToken
type Plus <: CalcToken end
type Digit <: CalcToken
  value :: Int
end

function parse_plus(xs,pos)
  res = parse_char(xs,'+',pos)
  if(res == nothing) return nothing end
  p, pos2 = res
  return (Plus(),pos2)
end
function parse_digit(xs,pos)
    num = parse_num(xs,pos)
    if num == nothing return nothing end
    i,p2 = num
    return (Digit(i),p2)
end

parse_one_expr = sequence([parse_digit,zeroormore(sequence([parse_plus,parse_digit]))])
parse_one_expr_codegen = sequence2([parse_digit,zeroormore(sequence2([parse_plus,parse_digit]))])
function parse_one_expr_hand(str)
  arr = Array(Any,0)
  result = parse_digit(str,1)
  while result != nothing
    x,pos = result
    push!(arr,x)
    result = parse_plus(str,pos)
    if(result == nothing) return arr end
    x,pos = result
    push!(arr,x)
    result = parse_digit(str,pos)
  end
  return nothing 
end

function parse_one_expr_strpos(str)
  arr = Array(Any,0)
  pos = 1
  result = parse_num(str,pos)
  while result != nothing
    x,pos = result
    push!(arr,Digit(x))
    result = parse_char(str,'+',pos)
    if (result==nothing) return arr end
    x,pos = result
    push!(arr,Plus())
    result = parse_num(str,pos)
  end
  return nothing
end

function interpreter(line)
    result = parse_one_expr(line,1)
    if result == nothing
        return
    end
    expr, pos = result
    first = expr[1]
    rest = expr[2]
    sum = first.value
    for e = rest
      sum += e[2].value
    end
    return sum
end

function interpreter_codegen(line)
    result = parse_one_expr_codegen(line,1)
    if result == nothing
        return
    end
    expr, pos = result
    first = expr[1]
    rest = expr[2]
    sum = first.value
    for e = rest
      sum += e[2].value
    end
    return sum
end

function interpreter_hand(line)
    result = parse_one_expr_hand(line)
    if result == nothing
        return
    end
    sum = 0
    for ex = result
      if ex != Plus()
        sum += ex.value
      end
    end
    return sum
end

function interpreter_regex(line)
  fm = match(r"^(\d+)\+?",line).captures[1]
  arr = Array(CalcToken,1)
  arr[1] = Digit(int(fm))
  for m in eachmatch(r"\+(\d+)"i,line[length(fm)+1:])
        push!(arr,Plus())
        push!(arr,Digit(int(m.captures[1])))
  end
  sum = 0
  for ex=arr 
    if ex != Plus()
      sum += ex.value
    end
  end
  return sum
end

function interpreter_strpos(line)
    result = parse_one_expr_strpos(line)
    if result == nothing
        return
    end
    sum = 0
    for ex = result
      if ex != Plus()
        sum += ex.value
      end
    end
    return sum
end


numones =  500

@show interpreter("1+2")
@show interpreter("1+2+3+4")
@show interpreter("1+2+3+4+5+6+7+8+12345")
onestxt = join(ones(Int,numones),"+")
@show median([@elapsed interpreter(onestxt) for x = 1:10])

@show interpreter_codegen("1+2")
@show interpreter_codegen("1+2+3+4")
@show interpreter_codegen("1+2+3+4+5+6+7+8+12345")
@show median([@elapsed interpreter_codegen(onestxt) for x = 1:10])

@show interpreter_hand("1+2")
@show interpreter_hand("1+2+3+4")
@show interpreter_hand("1+2+3+4+5+6+7+8+12345")
@show median([@elapsed interpreter_hand(onestxt) for x = 1:10])

# this is as slow as all of them used to be (almost 8sec when numones = 50_000)
# @show interpreter_regex("1+2")
# @show interpreter_regex("1+2+3+4")
# @show interpreter_regex("1+2+3+4+5+6+7+8+12345")
# @show median([@elapsed interpreter_regex(onestxt) for x = 1:10])

@show interpreter_strpos("1+2")
@show interpreter_strpos("1+2+3+4")
@show interpreter_strpos("1+2+3+4+5+6+7+8+12345")
@show median([@elapsed interpreter_strpos(onestxt) for x = 1:10])
