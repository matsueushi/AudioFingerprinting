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
        zero_mask = spc .== 0
        nonzero_spc = view(spc, .!zero_mask)
        min_nonzero_spc = minimum(nonzero_spc)
        spc[.!zero_mask] = log10.(nonzero_spc)
        spc[zero_mask] .= log10(min_nonzero_spc)
    end

    return spc
end

function max_filter(spc, nbhd)
    data_max = zero(spc)
    nx, ny = size(spc) .- 2 .* nbhd
    for j in 1:ny
        data_max[:, j] = maximum(view(spc, :, j:j + 2 * nbhd), dims=2)
    end
    for i in 1:nx
        data_max[i, :] = maximum(view(data_max, i:i + 2 * nbhd, :), dims=1)
    end
    return data_max[1:nx, 1:ny]
end

function find_peaks(spc, nbhd)
    # println("applying max filter...")
    spc_max = max_filter(spc, nbhd)
    center_spc = spc[1 + nbhd:end - nbhd, 1 + nbhd:end - nbhd]

    mask = center_spc .!= minimum(center_spc)
    spc_mean = mean(view(center_spc, mask))
    peak_flag = (center_spc .== spc_max) .* (center_spc .> spc_mean)
    return getindex.(findall(peak_flag), [2 1])
end

function find_peak_pairs(peaks, fan_value, min_delta, max_delta)
    pairs = Vector{NTuple{4, Int64}}()
    n_peaks = size(peaks, 1)
    for i in 1:n_peaks
        t1, f1 = peaks[i, :]
        for j in 1:fan_value
            if i + j <= n_peaks
                t2, f2 = peaks[i + j, :]
                time_delta = t2 - t1
                (min_delta <= time_delta && time_delta <= max_delta) || continue
                push!(pairs, (t1, t2, f1, f2))
            end
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