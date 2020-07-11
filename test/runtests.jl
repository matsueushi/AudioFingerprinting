using Hanauta

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
peaks = find_peaks(spc)

pairs = find_peak_pairs(peaks, 2, 64)

pairs_for_print = pairs[1:50]
println(pairs_for_print)
for (t1, t2, f1, f2) in pairs_for_print
    println("Hash:time = [", f1, ":", f2, ":", t2 - t1, "]:", t1)
    println(bitstring(f1)[end-9:end], ",", bitstring(f2)[end-9:end], ",", bitstring(t2 - t1)[end-9:end])
end

hashes = pairs_to_hashes(pairs_for_print)
println(hashes)
