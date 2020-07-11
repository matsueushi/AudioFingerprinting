module Hanauta

using FFTW
using Images
using Statistics


export spectrogram, generate_hashes, find_peaks, find_peak_pairs, pairs_to_hashes

function hann(window_size)
    ns = 0:window_size
    xs_hann = @. 0.5 * (1 - cos(2π * ns / window_size))
    xs_hann
end

function spectrogram(signal; window_size=1024)
    overlap = window_size ÷ 2
    rs = 1:(window_size - overlap):Base.length(signal) - window_size
    spc = zeros(overlap + 1, Base.length(rs))
    hann_window = hann(window_size)
    for (i, idx) in enumerate(rs)
        rfft_result = rfft(hann_window .* view(signal, idx:idx + window_size))
        spc[:, i] = abs.(rfft_result).^2
    end
    spc
end

function max_filter(spc, m)
    data_max = zero(spc)
    nx = size(spc, 1) - 2 * m
    ny = size(spc, 2) - 2 * m
    for j in 1:ny
        data_max[:, j] = maximum(view(spc, :, j:j + 2 * m), dims=2)
    end
    for i in 1:nx
        data_max[i, :] = maximum(view(data_max, i:i + 2 * m, :), dims=1)
    end
    data_max[1:nx, 1:ny]
end

function find_peaks(spc, m=24)
    # println("applying max filter...")
    log_spc = log.(spc)
    min_data, max_data = extrema(log_spc)
    norm_log_spc = @. (log_spc - min_data)/(max_data - min_data)

    norm_log_spc_max = max_filter(norm_log_spc, m)
    center_spc = norm_log_spc[1 + m:end - m, 1 + m:end - m]

    peak_flag = (center_spc .== norm_log_spc_max) .* (center_spc .> mean(center_spc))
    peaks = getindex.(findall(peak_flag), [2 1])

    # heatmap(center_spc, margin=2mm)
    # scatter!(peaks[:, 1], peaks[:, 2], label="", markercolor=:blue)
    # savefig("results/plot_peaks.png")

    # println("saving images...")
    # save("results/image.png", colorview(Gray, 1 .- norm_log_spc))
    # save("results/image_max.png", colorview(Gray, 1 .- norm_log_spc_max))
    peaks
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
    pairs
end

function pairs_to_hashes(pairs)
    hash_dict = Dict{UInt32, UInt32}()
    for (t1, t2, f1, f2) in pairs
        hash = UInt32(f1 << 20 + f2 << 10 + (t2 - t1))
        hash_dict[hash] = t1
    end
    hash_dict
end

function generate_hashes(peaks, start=2, stop=64)
    pairs = find_peak_pairs(peaks, start, stop)
    hash_dict = pairs_to_hashes(pairs)
    hash_dict
end

end # module