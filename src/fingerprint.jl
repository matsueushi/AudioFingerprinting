function songspectrogram(samples, n, fs)
    spec = spectrogram(samples, n; fs = fs, window = DSP.Windows.hanning).power
    normspec = log10.(spec)
    return normspec
end

function fingerprint(samples, n, fs, filtersize, fanvalue, mindelta, maxdelta)
    spec = songspectrogram(samples, n, fs)
    peaks = findpeaks(spec, filtersize)
    hashdict = hashpeaks(peaks, fanvalue, mindelta, maxdelta)
    return hashdict
end