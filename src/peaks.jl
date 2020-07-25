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

function getmaskindex(mask)
    maskindex = getindex.(findall(mask), [1 2])
    freqs = maskindex[:, 1]
    times = maskindex[:, 2]
    return freqs, times
end

function findpeaks(matrix, filtersize)
    maxmatrix = maxfilter(matrix, filtersize)
    mask = maxmatrix .== matrix
    return getmaskindex(mask)
end

function hashpeaks(freqs, times, fanvalue, mindelta, maxdelta)
    hashdict = Dict{String, Int64}()
    ntimes = Base.length(times)
    # println(times)
    # println(freqs)
    for (i1, t1) in pairs(IndexLinear(), times)
        f1 = freqs[i1]
        for i in 1:fanvalue
            i2 = i1 + i
            i2 > ntimes && break
            t2 = times[i2]
            dt = t2 - t1
            (mindelta <= dt && dt <= maxdelta) || continue
            f2 = freqs[i2]
            info = "$f1|$f2|$dt"
            hash = bytes2hex(sha256(info))
            # println("($t1, $f1) - ($t2, $f2), $info [$hash] -> $t1")
            hashdict[hash] = t1
        end
    end
    return hashdict
end
