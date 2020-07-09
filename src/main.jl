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

function max_filter(n, spc)
    data_max = zero(spc)
    for j in 1:size(spc, 2) - n
        data_max[:, j] = maximum(view(spc, :, j:j + n), dims=2)
    end

    for i in 1:size(spc, 1) - n
        data_max[i, :] = maximum(view(data_max, i:i + n, :), dims=1)
    end
    data_max[1:end + 1 - n, 1:end + 1 - n]
end

function generate_hashes(peak_data)
    hash_dict = Dict{UInt32, Int32}()
    for i in 1:size(peak_data, 1)
        f1, t1 = peak_data[i, :]
        for j in i:size(peak_data, 1)
            f2, t2 = peak_data[j, :]
            (t1 + 2 < t2 && t2 < t1 + 64) || continue
            hash = UInt32(f1 << 20 + f2 << 10 + (t2 - t1))
            # print
            println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
            println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
            println(hash, ",", bitstring(hash))
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

    println("applying max filter...")
    data_plot = log.(spc)
    min_data, max_data = minimum(data_plot), maximum(data_plot)
    heatmap_data = @. (data_plot - min_data)/(max_data - min_data)
    n = 49
    heatmap_data_max = max_filter(n, heatmap_data)

    m = (n + 1) ÷ 2
    cropped_data = heatmap_data[m:end + 1 - m, m:end + 1 - m] 
    peak = (cropped_data .== heatmap_data_max) .* (cropped_data .> mean(cropped_data))
    peak_data = getindex.(findall(peak), [1 2])

    hashes = generate_hashes(peak_data)
    print(hashes)

    heatmap(cropped_data, margin=2mm)
    scatter!(peak_data[:, 2], peak_data[:, 1], label="", markercolor=:blue)
    savefig("results/plot_peaks.png")

    surface(cropped_data)
    savefig("results/surface.png")

    println("saving images...")
    save("results/image.png", colorview(Gray, 1 .- heatmap_data))
    save("results/image_max.png", colorview(Gray, 1 .- heatmap_data_max))
end

main("wav/03 Roots Of Summer.wav")

end # module