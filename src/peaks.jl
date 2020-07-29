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
    return collect(zip(times, freqs))
end

function findpeaks(matrix, filtersize)
    maxmatrix = maxfilter(matrix, filtersize)
    maxmask = maxmatrix .== matrix
    meanmask = matrix .> mean(matrix)
    return getmaskindex(maxmask .* meanmask)
end

function paringpeaks(peaks, fanvalue, timerange, freqrange)
    data = Vector{NTuple{4, Int64}}()
    ntimes = Base.length(peaks)
    # println(peaks)
    mintdelta, maxtdelta = timerange
    minfdelta, maxfdelta = freqrange
    for (i1, (t1, f1)) in pairs(IndexLinear(), peaks)
        for i in 1:fanvalue
            i2 = i1 + i
            i2 > ntimes && break
            t2, f2 = peaks[i2]
            dt = t2 - t1
            df = f2 - f1
            (mintdelta <= dt && dt <= maxtdelta) || break
            (minfdelta <= df && df <= maxfdelta) || continue
            push!(data, (f1, f2, dt, t1))
        end
    end
    return data
end

function hashpeaks(peaks, fanvalue, timerange, freqrange)
    hashdict = Dict{String, Int64}()
    pairs = paringpeaks(peaks, fanvalue, timerange, freqrange)
    for (f1, f2, dt, t1) in pairs
        info = "$f1|$f2|$dt"
        hash = bytes2hex(sha256(info))
        hashdict[hash] = t1
        # println("($t1, $f1) - ($t2, $f2), $info [$hash] -> $t1")
    end
    return hashdict
end
