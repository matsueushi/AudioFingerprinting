function songspectrogram(samples, n, fs)
    spec = spectrogram(samples, n; fs = fs, window = DSP.Windows.hanning).power
    normspec = log10.(spec)
    return normspec
end

function fingerprint(samples, n, fs, filtersize, fanvalue, mindelta, maxdelta)
    spec = songspectrogram(samples, n, fs)
    freqs, times = findpeaks(spec, filtersize)
    hashdict = hashpeaks(freqs, times, fanvalue, mindelta, maxdelta)
    return hashdict
end