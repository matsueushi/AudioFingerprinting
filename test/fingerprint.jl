# using Plots
using Statistics
using WAV

function test_fingerprint(input, output, n, filtersize, fanvalue, mindelta, maxdelta)
    ys, fs, _, _ = wavread(input)
    samples = vec(mean(ys, dims=2))
    spec = songspectrogram(samples, n, fs)
    freqs, times = findpeaks(spec, filtersize)
    # heatmap(spec)
    # scatter!(times, freqs, label="")
    # savefig(output)
    return fingerprint(samples, n, fs, filtersize, fanvalue, mindelta, maxdelta)
end

@testset "fingerprint" begin
    n = 4096
    filtersize = 10
    fanvalue = 5
    mindelta = 0
    maxdelta = 100

    input1 = joinpath(@__DIR__, "data/original.wav")
    output1 = joinpath(@__DIR__, "output/result_original.png")

    input2 = joinpath(@__DIR__, "data/recorded.wav")
    output2 = joinpath(@__DIR__, "output/result_recorded.png")

    hash1 = test_fingerprint(input1, output1, n, filtersize, fanvalue, mindelta, maxdelta)
    hash2 = test_fingerprint(input2, output2, n, filtersize, fanvalue, mindelta, maxdelta)

    for h in hash2
        if h in hash1
            println(h)
        end
    end
end
