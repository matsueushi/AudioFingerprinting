using Hanauta

using Images
using Measures
using Plots
using Statistics
using Test
using WAV


@testset "test1" begin
    wav_name = "wav/03 Roots Of Summer.wav"

    println("loading wav...")
    y, _, _, _ = wavread(wav_name)
    nbhd = 24
    println("initializing...")
    spc1 = generate_spectrogram(y)[:, end-500:end-120]
    signal_info1 = PeakInfo(spc1, nbhd)
    println("complete.")

    # center_spc = spc[1 + nbhd:end - nbhd, 1 + nbhd:end - nbhd]
    # heatmap(center_spc, margin=2mm)
    # scatter!(peaks[:, 1], peaks[:, 2], label="", markercolor=:blue)
    # savefig("results/plot_peaks.png")

    # println("saving images...")
    # min_data, max_data = extrema(spc)
    # save("results/image.png", colorview(Gray, @. 1 - (spc - min_data)/(max_data - min_data)))
    # max_spc = max_filter(spc, nbhd)
    # save("results/image_max.png", colorview(Gray, @. 1 - (max_spc - min_data)/(max_data - min_data)))

    # pairs_for_print = pairs
    # for (t1, t2, f1, f2) in pairs_for_print
    #     println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
    #     println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
    # end

    wav_name2 = "wav/roots.wav"

    println("loading wav...")
    y2, _, _, _ = wavread(wav_name)
    signal2 = vec(mean(y2, dims=2))

    println("creating spectrogram...")
    spc2 = generate_spectrogram(signal2)
    signal_info2 = PeakInfo(spc2, nbhd)

    println("hash matching")
    ret = []
    for h in signal_info2.hash_dict
        if haskey(signal_info1.hash_dict, h)
            push!(ret, signal_info1.hash_dict[h], signal_info2.hashe_dict[h])
        end
    end
    println(ret)
end