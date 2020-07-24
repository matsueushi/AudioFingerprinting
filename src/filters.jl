function maximum_filter(matrix, filter_size)
    temp, result = zero(matrix), zero(matrix)
    n1, n2 = size(matrix)
    for i in 1:n1
        i_min = max(i - (filter_size - 1), 1)
        i_max = min(i + (filter_size - 1), n1)
        temp[i, :] = maximum(view(matrix, i_min:i_max, :), dims=1)
    end
    for j in 1:n2
        j_min = max(j - (filter_size - 1), 1)
        j_max = min(j + (filter_size - 1), n2)
        result[:, j] = maximum(view(temp, :, j_min:j_max), dims=2)
    end
    return result
end
