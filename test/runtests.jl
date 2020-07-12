using Hanauta

using Images
using Measures
using Plots
using Statistics
using WAV

wav_name = "wav/03 Roots Of Summer.wav"

println("loading wav...")
y, _, _, _ = wavread(wav_name)
signal = vec(mean(y, dims=2))

println("creating spectrogram...")
spc = spectrogram(signal)[:, end-2000:end-800]
m = 24
max_spc = max_filter(spc, m)
peaks = find_peaks(spc)

pairs = find_peak_pairs(peaks, 2, 64)

center_spc = spc[1 + m:end - m, 1 + m:end - m]
heatmap(center_spc, margin=2mm)
scatter!(peaks[:, 1], peaks[:, 2], label="", markercolor=:blue)
savefig("results/plot_peaks.png")

println("saving images...")
save("results/image.png", colorview(Gray, 1 .- spc))
save("results/image_max.png", colorview(Gray, 1 .- max_spc))

pairs_for_print = pairs[1:50]
println(pairs_for_print)
for (t1, t2, f1, f2) in pairs_for_print
    println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
    println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
end

hashes = pairs_to_hashes(pairs_for_print)
println(hashes)
