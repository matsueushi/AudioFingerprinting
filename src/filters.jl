function maximum_filter(matrix, filter_size)
    result = zero(matrix)
    n1, n2 = size(matrix)
    for i in 1:n1
        for j in 1:n2
            i_min = max(i - (filter_size - 1), 1)
            i_max = min(i + (filter_size - 1), n1)
            j_min = max(j - (filter_size - 1), 1)
            j_max = min(j + (filter_size - 1), n2)
            result[i, j] = maximum(view(matrix, i_min:i_max, j_min:j_max))
        end
    end
    return result
end
