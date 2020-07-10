module Hanauta

using FFTW
using Images
using Plots
using Statistics
using Measures
using WAV

function hann(window_size)
    ns = 0:window_size
    xs_hann = @. 0.5 * (1 - cos(2π * ns / window_size))
    xs_hann
end

function spectrogram(signal; window_size = 1024)
    overlap = window_size ÷ 2
    rs = 1:(window_size - overlap):Base.length(signal) - window_size
    spc = Matrix{Float64}(undef, overlap + 1, Base.length(rs))
    hann_window = hann(window_size)
    for (i, idx) in enumerate(rs)
        rfft_result = rfft(hann_window .* view(signal, idx:idx + window_size))
        spc[:, i] = abs.(rfft_result).^2
    end
    spc
end

function max_filter(spc, n)
    data_max = zero(spc)
    for j in 1:size(spc, 2) - n
        data_max[:, j] = maximum(view(spc, :, j:j + n), dims=2)
    end

    for i in 1:size(spc, 1) - n
        data_max[i, :] = maximum(view(data_max, i:i + n, :), dims=1)
    end
    data_max[1:end + 1 - n, 1:end + 1 - n]
end

function find_peaks(spc, n=49)
    # println("applying max filter...")
    log_spc = log.(spc)
    min_data, max_data = minimum(log_spc), maximum(log_spc)
    norm_log_spc = @. (log_spc - min_data)/(max_data - min_data)
    norm_log_spc_max = max_filter(norm_log_spc, n)

    m = (n + 1) ÷ 2
    center_spc = norm_log_spc[m:end + 1 - m, m:end + 1 - m]

    peak_flag = @. (center_spc == norm_log_spc_max) * (center_spc > mean(center_spc))
    peaks = getindex.(findall(peak_flag), [2 1])

    # heatmap(center_spc, margin=2mm)
    # scatter!(peaks[:, 1], peaks[:, 2], label="", markercolor=:blue)
    # savefig("results/plot_peaks.png")

    # surface(center_spc)
    # savefig("results/surface.png")

    # println("saving images...")
    # save("results/image.png", colorview(Gray, 1 .- norm_log_spc))
    # save("results/image_max.png", colorview(Gray, 1 .- norm_log_spc_max))

    peaks
end

function generate_hashes(peaks, start=2, stop=64)
    hash_dict = Dict{UInt32, UInt32}()
    n_peaks = size(peaks, 1)
    for i in 1:n_peaks
        t1, f1 = peaks[i, :]
        for j in i:n_peaks
            t2, f2 = peaks[j, :]
            (t1 + start < t2 && t2 < t1 + stop) || continue
            hash = UInt32(f1 << 20 + f2 << 10 + (t2 - t1))
            # print
            # println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
            # println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
            # println(hash, ",", bitstring(hash))
            hash_dict[hash] = t1
        end
    end
    hash_dict
end


function main(wav_name)
    println("loading wav...")
    y, Fs, nbits, opt = wavread(wav_name)
    signal = vec(mean(y, dims=2))
    println("creating spectrogram...")
    spc = spectrogram(signal)[:, end-2000:end-800]
    peaks = find_peaks(spc)

    hashes = generate_hashes(peaks)
    # print(hashes)
end

main("wav/03 Roots Of Summer.wav")

end # module