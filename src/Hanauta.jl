module Hanauta

using FFTW
using Statistics


export spectrogram, max_filter, find_peaks, find_peak_pairs, pairs_to_hashes

hann(window_size) = @. 0.5 * (1 - cos(2π * (0:window_size) / window_size))

function spectrogram(signal; window_size=1024, logscale=true)
    overlap = window_size ÷ 2
    rs = 1:(window_size - overlap):Base.length(signal) - window_size
    spc = zeros(overlap + 1, Base.length(rs))
    hann_window = hann(window_size)
    for (i, idx) in enumerate(rs)
        rfft_result = rfft(hann_window .* view(signal, idx:idx + window_size))
        spc[:, i] = abs.(rfft_result).^2
    end

    if logscale
        non_zero = spc .!= 0
        spc[non_zero] = log10.(spc[non_zero])
    end

    return spc
end

function max_filter(spc, m)
    data_max = zero(spc)
    nx, ny = size(spc) .- 2 .* m
    for j in 1:ny
        data_max[:, j] = maximum(view(spc, :, j:j + 2 * m), dims=2)
    end
    for i in 1:nx
        data_max[i, :] = maximum(view(data_max, i:i + 2 * m, :), dims=1)
    end
    return data_max[1:nx, 1:ny]
end

function find_peaks(spc, m)
    # println("applying max filter...")
    spc_max = max_filter(spc, m)
    center_spc = spc[1 + m:end - m, 1 + m:end - m]

    peak_flag = (center_spc .== spc_max) .* (center_spc .> mean(center_spc))
    return getindex.(findall(peak_flag), [2 1])
end

function find_peak_pairs(peaks, start, stop)
    pairs = Vector{NTuple{4, Int64}}()
    n_peaks = size(peaks, 1)
    for i in 1:n_peaks
        t1, f1 = peaks[i, :]
        for j in i:n_peaks
            t2, f2 = peaks[j, :]
            (t1 + start < t2 && t2 < t1 + stop) || continue
            push!(pairs, (t1, t2, f1, f2))
        end
    end
    return pairs
end

function pairs_to_hashes(pairs)
    hash_dict = Dict{UInt32, UInt32}()
    for (t1, t2, f1, f2) in pairs
        hash = UInt32(f1 << 20 + f2 << 10 + (t2 - t1))
        hash_dict[hash] = t1
    end
    return hash_dict
end

end # module