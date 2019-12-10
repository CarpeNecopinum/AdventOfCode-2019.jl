cd(@__DIR__)
input = read(open("day8_input.txt"), 15000) .- 48

function part1(input)
    in_matrix = reshape(input, (25,6,:))
    least_zeros_slice = findmin(sum(in_matrix .== 0; dims = (1,2)))[2][3]
    slice = view(in_matrix, :,:,least_zeros_slice)
    one_count = count(==(1), slice)
    two_count = count(==(2), slice)

    one_count * two_count
end


function part21(input)
    in_matrix = reshape(input, (25,6,:))
    rowstring = Array{Char}(undef, size(in_matrix, 2))
    for row in axes(in_matrix, 1)
        for col in axes(in_matrix, 2)
            slice = findfirst(!=(2), view(in_matrix, row, col, :))
            rowstring[col] = (in_matrix[row, col, slice] == 1 ? '█' : ' ')
        end
        println(String(rowstring))
    end
end

function part2(input)
    in_matrix = reshape(input, (25,6,:))

    image = map(CartesianIndices(axes.(Ref(in_matrix), (1,2)))) do idx
        (row, col) = Tuple(idx)
        slice = findfirst(!=(2), view(in_matrix, row, col, :))
        in_matrix[row, col, slice] == 1 ? '█' : ' '
    end

    join(join.(eachcol(image)), "\n")
end

using BenchmarkTools
@btime part1(input)
@btime part2(input)
