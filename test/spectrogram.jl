using Plots
using Statistics
using WAV

function plot_spectrogram(input, output, n, filtersize)
    ys, fs, _, _ = wavread(input)
    samples = vec(mean(ys, dims=2))
    spec = songspectrogram(samples, n, fs)
    freqs, times = findpeaks(spec, filtersize)
    heatmap(spec)
    scatter!(times, freqs, label="")
    savefig(output)
end

