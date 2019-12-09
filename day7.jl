using OffsetArrays
using BenchmarkTools
using Combinatorics
using Base.Threads:  @spawn, wait

function Base.push!(r::Ref, x)
    r[] = x
    r
end

input = OffsetArray([3,8,1001,8,10,8,105,1,0,0,21,30,55,76,97,114,195,276,357,438,99999,3,9,102,3,9,9,4,9,99,3,9,1002,9,3,9,1001,9,5,9,1002,9,2,9,1001,9,2,9,102,2,9,9,4,9,99,3,9,1002,9,5,9,1001,9,2,9,102,5,9,9,1001,9,4,9,4,9,99,3,9,1001,9,4,9,102,5,9,9,101,4,9,9,1002,9,4,9,4,9,99,3,9,101,2,9,9,102,4,9,9,1001,9,5,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,99,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,99], -1)

function run_instruction!(memory::OffsetArray, iptr, inputs, output)
    opcode = memory[iptr]
    digs = digits(opcode; pad = 5)
    input_index = 1

    if digs[1] == 1 # addition
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        memory[memory[iptr+3]] = op1 + op2
        return iptr + 4
    elseif digs[1] == 2 # multiply
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        memory[memory[iptr+3]] = op1 * op2
        return iptr + 4
    elseif digs[1] == 3 # input
        read = popfirst!(inputs)
        memory[memory[iptr+1]] = read
        return iptr + 2
    elseif digs[1] == 4 # output
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        push!(output, op1)
        return iptr + 2
    elseif digs[1] == 5 # jump if true
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        return (op1 != 0) ? op2 : (iptr + 3)
    elseif digs[1] == 6 # jump if false
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        return (op1 == 0) ? op2 : (iptr + 3)
    elseif digs[1] == 7 # less than
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        memory[memory[iptr+3]] = (op1 < op2)
        return iptr + 4
    elseif digs[1] == 8 # equals
        op1 = (digs[3] == 0) ? memory[memory[iptr+1]] : memory[iptr+1]
        op2 = (digs[4] == 0) ? memory[memory[iptr+2]] : memory[iptr+2]
        memory[memory[iptr+3]] = (op1 == op2)
        return iptr + 4
    elseif digs[1] == 9 && digs[2] == 9 # halt
        return length(memory) + 1
    end
    println("Unknown instruction")
    return length(memory) + 1
end

function run_program!(program, inputs, outputs)
    iptr = 0
    while iptr in eachindex(program)
        iptr = run_instruction!(program, iptr, inputs, outputs)
    end
end

function test_amps(program, phase_settings)
    signal = 0
    for i in 1:5
        output = Ref(0)
        run_program!(copy(program), [phase_settings[i], signal], output)
        signal = output[]
    end
    signal
end

function find_boostiest(program)
    maximum(permutations(0:4)) do perm
        (test_amps(program, perm), perm)
    end
end


function test_loop_amps(program, phase_settings)
    channels = ntuple(i->Channel{Int}(1), 5)
    push!.(channels, phase_settings)

    @spawn push!(channels[1], 0)
    machines = ntuple(5) do i
        @spawn run_program!(copy(program), channels[i], channels[mod1(i+1,5)])
    end
    wait.(machines)

    popfirst!(channels[1])
end

function find_boostiest_loop(program)
    maximum(permutations(5:9)) do perm
        (test_loop_amps(program, perm), perm)
    end
end

@btime find_boostiest(input) # part 1
@btime find_boostiest_loop(input) # part 2
