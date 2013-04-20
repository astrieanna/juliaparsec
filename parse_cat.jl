include("juliaparsec.jl")

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

#end #@iprofile begin    

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
   
