using StaticArrays
using BenchmarkTools

function part_1(range)
    digs = zero(MVector{6,Int})
    function isvalid(i)    
        digits!(digs, i)
        found_repeating = false
        for j in 2:length(digs)
            (digs[j] <= digs[j-1]) || (return false)
            (digs[j] == digs[j-1]) && (found_repeating = true)
        end
        return found_repeating
    end
    count(isvalid, range)
end

function part_2(range)
    digs = zero(MVector{6,Int})
    function isvalid(i)    
        digits!(digs, i)
        found_repeating = false
        for j in 2:length(digs)
            (digs[j] <= digs[j-1]) || (return false)
            if (digs[j] == digs[j-1]) &&
               (j-2 < 1 || digs[j-2] != digs[j]) &&
               (j+1 > length(digs) || digs[j+1] != digs[j])
               found_repeating = true
           end
        end
        return found_repeating
    end
    count(isvalid, range)
end

@benchmark part_1(273025:767253)
@benchmark part_2(273025:767253)
