require("Profile")
using IProfile
@iprofile begin

    function f1(x::Int)
        z = 0
        for j = 1:x
            z += j^2
        end
        return z
    end
    
    function f1(x::Float64)
        return x+2
    end
    
    function f1{T}(x::T)
        return x+5
    end
    
    f2(x) = 2*x
    
end #@iprofile begin

f1(215)
for i = 1:100
    f1(3.5)
end
for i = 1:150
    f1(uint8(7))
end
for i = 1:125
    f2(11)
end

@iprofile report

