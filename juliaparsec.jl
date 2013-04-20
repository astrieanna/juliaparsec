require("Profile")
using IProfile
@iprofile begin

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

## Calculator example
abstract CalcToken
type Plus <: CalcToken end
type Digit <: CalcToken
  value :: Int
end

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

## silly test example
abstract Token123
type Dog <: Token123 end
type Cat <: Token123 end

function parse_cat(xs,pos)
 r = parse_char(xs,'c',pos)
 if r == nothing return nothing end
 x,p2 = r

 r = parse_char(xs,'a',p2)
 if r == nothing return nothing end
 x,p2 = r

 r = parse_char(xs,'t',p2)
 if r == nothing
   return nothing
 end
 x,p2 = r
 return (Cat(),p2)
end
function parse_dog(xs,pos)
 r = parse_char(xs,'d',pos)
 if r == nothing return nothing end
 x,p2 = r

 r = parse_char(xs,'o',p2)
 if r == nothing return nothing end
 x,p2 = r

 r = parse_char(xs,'g',p2)
 if r == nothing
   return nothing
 end
 x,p2 = r
 return (Dog(),p2)
end

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
print("seq / seq2 JIT\n")
@time seq1parser(catstext,1)
@time seq2parser(catstext,1)
print("seq / seq2 test\n")
@time seq1parser(catstext,1)
@time seq2parser(catstext,1)

branch1parser = branch(cats)
branch2parser = branch2(cats)
print("branch / branch2 JIT\n")    
@time branch1parser(catstext,1)
@time branch2parser(catstext,1)    
print("branch / branch2 test\n")
@time branch1parser(catstext,1)
@time branch2parser(catstext,1)
    

end #@iprofile begin
