using OffsetArrays
using BenchmarkTools

function Base.push!(r::Ref, x)
    r[] = x
    r
end

input = [1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,3,1,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1102,1,22,1012,1101,309,0,1024,1102,1,29,1015,1101,0,30,1014,1101,0,221,1028,1102,24,1,1007,1102,32,1,1006,1102,1,31,1001,1101,0,20,1010,1101,34,0,1003,1102,899,1,1026,1101,304,0,1025,1101,0,1,1021,1101,892,0,1027,1101,0,0,1020,1101,0,484,1023,1101,25,0,1018,1101,0,21,1008,1102,491,1,1022,1102,212,1,1029,1102,1,23,1000,1101,0,26,1009,1102,36,1,1005,1101,27,0,1013,1101,35,0,1019,1101,38,0,1017,1101,0,39,1004,1102,37,1,1002,1102,33,1,1011,1102,28,1,1016,109,1,1208,5,35,63,1005,63,201,1001,64,1,64,1106,0,203,4,187,1002,64,2,64,109,36,2106,0,-9,4,209,1001,64,1,64,1105,1,221,1002,64,2,64,109,-30,2101,0,-4,63,1008,63,34,63,1005,63,247,4,227,1001,64,1,64,1105,1,247,1002,64,2,64,109,1,21108,40,40,8,1005,1016,265,4,253,1106,0,269,1001,64,1,64,1002,64,2,64,109,10,21101,41,0,-7,1008,1011,41,63,1005,63,295,4,275,1001,64,1,64,1105,1,295,1002,64,2,64,109,3,2105,1,3,4,301,1106,0,313,1001,64,1,64,1002,64,2,64,109,-18,2108,38,1,63,1005,63,329,1105,1,335,4,319,1001,64,1,64,1002,64,2,64,109,-11,2108,37,10,63,1005,63,357,4,341,1001,64,1,64,1106,0,357,1002,64,2,64,109,25,21107,42,41,-6,1005,1011,377,1001,64,1,64,1106,0,379,4,363,1002,64,2,64,109,-11,1207,3,25,63,1005,63,395,1105,1,401,4,385,1001,64,1,64,1002,64,2,64,109,-4,1202,0,1,63,1008,63,37,63,1005,63,423,4,407,1105,1,427,1001,64,1,64,1002,64,2,64,109,8,21102,43,1,6,1008,1016,43,63,1005,63,453,4,433,1001,64,1,64,1106,0,453,1002,64,2,64,109,-11,1208,6,36,63,1005,63,471,4,459,1105,1,475,1001,64,1,64,1002,64,2,64,109,21,2105,1,3,1001,64,1,64,1105,1,493,4,481,1002,64,2,64,109,-15,2107,22,3,63,1005,63,513,1001,64,1,64,1106,0,515,4,499,1002,64,2,64,109,-7,2107,35,7,63,1005,63,537,4,521,1001,64,1,64,1105,1,537,1002,64,2,64,109,23,1205,0,551,4,543,1105,1,555,1001,64,1,64,1002,64,2,64,109,-4,21101,44,0,-3,1008,1014,45,63,1005,63,579,1001,64,1,64,1105,1,581,4,561,1002,64,2,64,109,-15,2102,1,3,63,1008,63,33,63,1005,63,601,1106,0,607,4,587,1001,64,1,64,1002,64,2,64,109,23,1205,-5,623,1001,64,1,64,1106,0,625,4,613,1002,64,2,64,109,-7,21102,45,1,-8,1008,1010,43,63,1005,63,645,1105,1,651,4,631,1001,64,1,64,1002,64,2,64,109,-11,2102,1,1,63,1008,63,21,63,1005,63,677,4,657,1001,64,1,64,1106,0,677,1002,64,2,64,109,3,21107,46,47,4,1005,1014,695,4,683,1106,0,699,1001,64,1,64,1002,64,2,64,109,7,21108,47,48,-4,1005,1013,715,1106,0,721,4,705,1001,64,1,64,1002,64,2,64,109,-14,1201,0,0,63,1008,63,32,63,1005,63,741,1106,0,747,4,727,1001,64,1,64,1002,64,2,64,109,4,1201,2,0,63,1008,63,26,63,1005,63,769,4,753,1105,1,773,1001,64,1,64,1002,64,2,64,109,5,1207,-4,22,63,1005,63,795,4,779,1001,64,1,64,1106,0,795,1002,64,2,64,109,2,2101,0,-9,63,1008,63,34,63,1005,63,819,1001,64,1,64,1106,0,821,4,801,1002,64,2,64,109,-11,1202,1,1,63,1008,63,38,63,1005,63,841,1105,1,847,4,827,1001,64,1,64,1002,64,2,64,109,21,1206,-4,865,4,853,1001,64,1,64,1105,1,865,1002,64,2,64,109,3,1206,-6,877,1105,1,883,4,871,1001,64,1,64,1002,64,2,64,109,6,2106,0,-6,1001,64,1,64,1105,1,901,4,889,4,64,99,21101,0,27,1,21101,915,0,0,1106,0,922,21201,1,23692,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21102,942,1,0,1106,0,922,21202,1,1,-1,21201,-2,-3,1,21101,0,957,0,1106,0,922,22201,1,-1,-2,1106,0,968,22102,1,-2,-2,109,-3,2106,0,0]

struct ExtendedMemory{T}
    base::OffsetArray{T, 1, Array{T,1}}
    rest::Dict{T,T}
end
ExtendedMemory(base::AbstractArray{T}) where {T} = ExtendedMemory{T}(base, Dict{T,T}())

Base.getindex(mem::ExtendedMemory, idx) = (idx in eachindex(mem.base)) ?
    mem.base[idx] :
    get(mem.rest, idx, 0)

Base.setindex!(mem::ExtendedMemory, val, idx) = (idx in eachindex(mem.base)) ?
    setindex!(mem.base, val, idx) :
    setindex!(mem.rest, val, idx)

function run_instruction!(memory, iptr, relbase, inputs, output)
    opcode = memory[iptr]
    digs = digits(opcode; pad = 5)
    input_index = 1

    get_op(mode, address) = if mode == 0
        memory[memory[address]]
    elseif mode == 1
        memory[address]
    elseif mode == 2
        memory[relbase[] + memory[address]]
    end

    set_op(mode, address, value) = if mode == 0
        memory[memory[address]] = value
    elseif mode == 2
        memory[relbase[] + memory[address]] = value
    end

    if digs[1] == 1 # addition
        result = get_op(digs[3], iptr+1) + get_op(digs[4], iptr+2)
        set_op(digs[5], iptr + 3, result)
        return iptr + 4
    elseif digs[1] == 2 # multiply
        result = get_op(digs[3], iptr+1) * get_op(digs[4], iptr+2)
        set_op(digs[5], iptr + 3, result)
        return iptr + 4
    elseif digs[1] == 3 # input
        read = popfirst!(inputs)
        set_op(digs[3], iptr + 1, read)
        return iptr + 2
    elseif digs[1] == 4 # output
        push!(output, get_op(digs[3], iptr + 1))
        return iptr + 2
    elseif digs[1] == 5 # jump if true
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        return (op1 != 0) ? op2 : (iptr + 3)
    elseif digs[1] == 6 # jump if false
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        return (op1 == 0) ? op2 : (iptr + 3)
    elseif digs[1] == 7 # less than
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        set_op(digs[5], iptr+3, (op1 < op2))
        return iptr + 4
    elseif digs[1] == 8 # equals
        op1 = get_op(digs[3], iptr+1)
        op2 = get_op(digs[4], iptr+2)
        set_op(digs[5], iptr+3, (op1 == op2))
        return iptr + 4
    elseif digs[1] == 9
        if digs[2] == 9 # halt
            return -1
        elseif digs[2] == 0 # set relbase
            op1 = get_op(digs[3], iptr+1)
            relbase[] += op1
            return iptr + 2
        end
    end
    println("Unknown instruction $(digs)")
    return -1
end

function run_program!(program, inputs, outputs)
    iptr = 0
    relbase = Ref(0)
    while iptr >= 0
        iptr = run_instruction!(program, iptr, relbase, inputs, outputs)
    end
end

function run_boost(program, input)
    outs = Int[]
    mem = ExtendedMemory(OffsetArray(copy(program), -1))
    run_program!(mem, [input], outs)
    outs[1]
end

function run_boost_pad(program, input, pad)
    outs = Int[]
    mem = OffsetArray(vcat(program, zeros(Int, pad)), -1)
    run_program!(mem, [input], outs)
    outs[1]
end

@btime run_boost(input, 1) # part 1 - with proper "infinite" memory
@btime run_boost_pad(input, 1, 2000) # part 1 - with finite, padded memory

@btime run_boost(input, 2) # part 2 - with proper "infinite" memory
@btime run_boost_pad(input, 2, 2000) # part 2 - with finite, padded memory
