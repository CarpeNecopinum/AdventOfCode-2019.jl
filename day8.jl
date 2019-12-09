cd(@__DIR__)
input = read(open("day8_input.txt"), 15000) .- 48

in_matrix = reshape(input, (:,25,6))
least_zeros_slice = findmin(sum(in_matrix .== 0; dims = (2,3)))[2][1]
slice = view(in_matrix, least_zeros_slice, :,:)
one_count = count(==(1), slice)
two_count = count(==(2), slice)

one_count * two_count
