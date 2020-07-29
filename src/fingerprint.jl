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