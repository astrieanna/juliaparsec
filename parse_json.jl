# Json = Object | Array
# Array = [ (Value (, Value) *)? ]
# Object = {(String : Value (, String : Value)*)?}
# Number = -?Digit+ # also, decimal point. also e|E.
# String = " _* " # no quote, except \" but not \\"
# Value = String | Number | Object | Array | true | false | null 

# parsewhitespace, parsekeyword, oneormore, zeroorone, parsechar

parsenumber = sequence([zeroorone('-'),oneormore(parsedigit)])
parsestring = sequence([parsechar('"'),parseuntil('"'),parsechar('"')])

parseobject = sequence(
  [ parsechar('{')
  , parsewhitespace
  , zeroorone(sequence([parsestring,parsewhitespace,parsechar(':'),parsewhitespace,parsevalue
                , zeroormore(sequence([parsewhitespace,parsechar(','),parsewhitespace
                               ,parsestring,parsewhitespace,parsechar(':'),parsewhitespace,parsevalue]))]))
  , parsewhitespace
  , parsechar('}')])

parsearray = sequence(
  [ parsechar('[')
  , parsewhitespace
  , zeroorone(sequence(parsevalue,zeroormore(parsewhitespace,parsechar(','),parsewhitespace,parsevalue)))
  , parsewhitespace
  , parsechar(']')])

parsevalue = branch([parsenumber,parsestring,parseobject,parsearray,parsekeyword("true"),parsekeyword("false"),parsekeyword("null")])
parsejson = eatnothings(sequence(parsewhitespace,branch(parsearray,parseobject),parsewhitespace))
