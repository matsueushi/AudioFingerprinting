using Hanauta

using Images
using Measures
using Plots
using Statistics
using Test
using WAV


function plot_peaks(file_name, spc, signal_info, nbhd)
    center_spc = spc[1 + nbhd:end - nbhd, 1 + nbhd:end - nbhd]
    heatmap(center_spc, margin=2mm)
    scatter!(signal_info.peaks[:, 1], signal_info.peaks[:, 2], label="", markercolor=:blue)
    savefig(file_name)
end

function plot_max_filter(file_name1, file_name2, spc, nbhd)
    min_data, max_data = extrema(spc)
    save(file_name1, colorview(Gray, @. 1 - (spc - min_data)/(max_data - min_data)))
    max_spc = max_filter(spc, nbhd)
    save(file_name2, colorview(Gray, @. 1 - (max_spc - min_data)/(max_data - min_data)))
end


@testset "original vs recorded" begin
    original_name = "wav/original.wav"
    recorded_name = "wav/recorded.wav"
    nbhd = 20
    window = 4096

    y1, _, _, _ = wavread(original_name)
    spc1 = generate_spectrogram(y1, window)
    signal_info1 = PeakInfo(spc1, nbhd)
    plot_peaks("results/peak_original.png", spc1, signal_info1, nbhd)

    y2, _, _, _ = wavread(recorded_name)
    spc2 = generate_spectrogram(y2, window)
    signal_info2 = PeakInfo(spc2, nbhd)
    plot_peaks("results/peak_recorded.png", spc2, signal_info2, nbhd)
end


@testset "hash matching" begin
    original_name = "wav/original.wav"
    recorded_name = "wav/recorded.wav"
    nbhd = 20
    window = 4096

    y1, _, _, _ = wavread(original_name)
    spc1 = generate_spectrogram(y1, window)
    signal_info1 = PeakInfo(spc1, nbhd)

    y2, _, _, _ = wavread(recorded_name)
    spc2 = generate_spectrogram(y2, window)
    signal_info2 = PeakInfo(spc2, nbhd)
 
    # plot_max_filter("results/image.png", "results/image_max.png", spc1, nbhd)

    # pairs_for_print = pairs
    # for (t1, t2, f1, f2) in pairs_for_print
    #     println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
    #     println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
    # end

    println("hash matching...")
    ret = []
    for h in signal_info2.hash_dict
        if haskey(signal_info1.hash_dict, h)
            push!(ret, signal_info1.hash_dict[h], signal_info2.hashe_dict[h])
        end
    end
    println(ret)
end