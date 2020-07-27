using Plots
using Statistics
using WAV

function test_fingerprint(input, output, n, filtersize, fanvalue, mindelta, maxdelta)
    ys, fs, _, _ = wavread(input)
    samples = vec(mean(ys, dims=2))[1:100000]
    spec = songspectrogram(samples, n, fs)
    freqs, times = findpeaks(spec, filtersize)
    pairs = Hanauta.paringpeaks(freqs, times, fanvalue, mindelta, maxdelta)
    heatmap(spec)
    for (f1, f2, dt, t1) in pairs
        plot!([t1, t1 + dt], [f1, f2], label="", linecolor=:blue)
    end
    scatter!(times, freqs, label="")
    savefig(output)
    return fingerprint(samples, n, fs, filtersize, fanvalue, mindelta, maxdelta)
end

@testset "fingerprint" begin
    n = 4096
    filtersize = 10
    fanvalue = 5
    mindelta = 1
    maxdelta = 100

    input1 = joinpath(@__DIR__, "data/original.wav")
    output1 = joinpath(@__DIR__, "output/result_original.png")

    input2 = joinpath(@__DIR__, "data/recorded.wav")
    output2 = joinpath(@__DIR__, "output/result_recorded.png")

    hash1 = test_fingerprint(input1, output1, n, filtersize, fanvalue, mindelta, maxdelta)
    hash2 = test_fingerprint(input2, output2, n, filtersize, fanvalue, mindelta, maxdelta)

    i = 0
    ts1 = Vector{Int64}()
    ts2 = Vector{Int64}()
    for h in keys(hash2)
        if haskey(hash1, h)
            push!(ts1, hash1[h])
            push!(ts2, hash2[h])
            i += 1
        end
    end
    println("Match: $i")
    if i > 0
        scatter(ts1, ts2)
        savefig(joinpath(@__DIR__, "output/scatter.png"))
    end
end
