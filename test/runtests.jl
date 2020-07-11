using Hanauta

using Measures
using Plots
using Statistics
using WAV


wav_name = "wav/03 Roots Of Summer.wav"
println("loading wav...")
y, Fs, nbits, opt = wavread(wav_name)
signal = vec(mean(y, dims=2))
println("creating spectrogram...")
spc = spectrogram(signal)[:, end-2000:end-800]
peaks = find_peaks(spc)

hashes = generate_hashes(peaks)
print(hashes)
