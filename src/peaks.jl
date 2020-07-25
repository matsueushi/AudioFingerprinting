function maxfilter(matrix, filtersize)
    temp, result = zero(matrix), zero(matrix)
    n1, n2 = size(matrix)
    for i in 1:n1
        imin = max(i - (filtersize - 1), 1)
        imax = min(i + (filtersize - 1), n1)
        temp[i, :] = maximum(view(matrix, imin:imax, :), dims=1)
    end
    for j in 1:n2
        jmin = max(j - (filtersize - 1), 1)
        jmax = min(j + (filtersize - 1), n2)
        result[:, j] = maximum(view(temp, :, jmin:jmax), dims=2)
    end
    return result
end

function findpeaks(matrix, filtersize)
    maxmatrix = maxfilter(matrix, filtersize)
    mask = maxmatrix .== matrix
    maskindex = getindex.(findall(mask), [1 2])
    return maskindex[:, 1], maskindex[:, 2]
end
