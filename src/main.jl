module Hanauta

using FFTW
using Images
using Plots
using Statistics
using Measures
using WAV

function hann(n_window)
    ns = 0:n_window
    xs_hann = @. 0.5 * (1 - cos(2π * ns / n_window))
    xs_hann
end

function spectrogram(window_size, signal)
    overlap = window_size ÷ 2
    rs = 1:(window_size - overlap):Base.length(signal) - window_size
    data = Matrix{Float64}(undef, overlap + 1, Base.length(rs))
    hann_window = hann(window_size)
    for (i, idx) in enumerate(rs)
        rfft_result = rfft(hann_window .* view(signal, idx:idx + window_size))
        data[:, i] = abs.(rfft_result).^2
    end
    data
end

function max_filter(n, data)
    data_max = zero(data)
    for i in 1:size(data)[1]
        for j in 1:size(data)[2] - n
            data_max[i, j] = maximum(view(data, i:i, j:j + n))
        end
    end

    for i in 1:size(data)[1] - n
        for j in 1:size(data)[2] - n
            data_max[i, j] = maximum(view(data_max, i:i + n, j:j))
        end
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


function main()
    window_size = 1024
    println("loading wav...")
    y, Fs, nbits, opt = wavread("wav/01 Windowlicker.wav")
    signal = mean(y, dims=2)
    println("creating spectrogram...")
    data = spectrogram(window_size, signal)

    println("applying max filter...")
    data_plot = log.(data[:, end-2000:end-800])
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
    savefig("plot_peaks.png")

    surface(cropped_data)
    savefig("surface.png")

    # println("saving images...")
    # save("image.png", colorview(Gray, 1 .- heatmap_data))
    # save("image_max.png", colorview(Gray, 1 .- heatmap_data_max))
end

main()

end # module