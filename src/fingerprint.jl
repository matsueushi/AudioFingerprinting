function songspectrogram(samples, n, fs)
    spec = spectrogram(samples, n; fs = fs, window = DSP.Windows.hanning).power
    normspec = log10.(spec)
    return normspec
end

function fingerprint(samples, n, fs, filtersize, fanvalue, timerange, freqrange)
    spec = songspectrogram(samples, n, fs)
    peaks = findpeaks(spec, filtersize)
    hashdict = hashpeaks(peaks, fanvalue, timerange, freqrange)
    return hashdict
end

function fingerprint_song(ys, fs, n, filtersize, fanvalue, timerange, freqrange; path = nothing)
    hashdict = Dict{String, Int64}()
    for i in 1:size(ys, 2)
        samples = view(ys, :, i)
        if !isnothing(path)
            spec = songspectrogram(samples, n, fs)
            peaks = findpeaks(spec, filtersize)
            pairs = Hanauta.paringpeaks(peaks, fanvalue, timerange, freqrange)
            heatmap(spec)
            for (f1, f2, dt, t1) in pairs
                plot!([t1, t1 + dt], [f1, f2], label="", linecolor=:blue)
            end
            scatter!(peaks, label="")
            output = path * "_ch$i.png"
            savefig(output)
        end
        newdict = fingerprint(samples, n, fs, filtersize, fanvalue, timerange, freqrange)
        merge!(hashdict, newdict)
    end
    return hashdict
end
