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

function part_1_unrolled(range)
    count = 0
    for i1 in 1:9
        for i2 in i1:9
            for i3 in i2:9
                for i4 in i3:9
                    for i5 in i4:9
                        for i6 in i5:9
                            if (i1 == i2 || i2 == i3 || i3 == i4 || i4 == i5 || i5 == i6)
                                val = 10^5*i1 + 10^4*i2 + 10^3*i3 + 10^2*i4 + 10*i5 + i6
                                #val = 10^5*i6 + 10^4*i5 + 10^3*i4 + 10^2*i3 + 10*i2 + i1
                                if val in range
                                    count += 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    count
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

function part_2_unrolled(range)
    count = 0
    for i1 in 1:9
        for i2 in i1:9
            for i3 in i2:9
                for i4 in i3:9
                    for i5 in i4:9
                        for i6 in i5:9
                            if (i1 == i2 || i2 == i3 || i3 == i4 || i4 == i5 || i5 == i6) &&
                                !(i1 == i2 == i3) &&
                                !(i2 == i3 == i4) &&
                                !(i3 == i4 == i5) &&
                                !(i4 == i5 == i6)
                                val = 10^5*i1 + 10^4*i2 + 10^3*i3 + 10^2*i4 + 10*i5 + i6
                                if val in range
                                    count += 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    count
end

@btime part_1(273025:767253)
@btime part_2(273025:767253)

@btime part_1_unrolled(273025:767253)
@btime part_2_unrolled(273025:767253)
