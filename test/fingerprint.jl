using Plots
using Statistics
using WAV

function test_fingerprint(input, output, n, filtersize, fanvalue, timerange)
    ys, fs, _, _ = wavread(input)
    samples = vec(mean(ys, dims=2))[100000:300000]
    spec = songspectrogram(samples, n, fs)
    peaks = findpeaks(spec, filtersize)
    pairs = Hanauta.paringpeaks(peaks, fanvalue, timerange)
    heatmap(spec)
    for (f1, f2, dt, t1) in pairs
        plot!([t1, t1 + dt], [f1, f2], label="", linecolor=:blue)
    end
    scatter!(peaks, label="")
    savefig(output)
    return fingerprint(samples, n, fs, filtersize, fanvalue, timerange)
end

@testset "fingerprint" begin
    n = 4096
    filtersize = 10
    fanvalue = 5
    timerange = 1 => 10

    input1 = joinpath(@__DIR__, "data/original.wav")
    output1 = joinpath(@__DIR__, "output/result_original.png")

    input2 = joinpath(@__DIR__, "data/recorded.wav")
    output2 = joinpath(@__DIR__, "output/result_recorded.png")

    hash1 = test_fingerprint(input1, output1, n, filtersize, fanvalue, timerange)
    hash2 = test_fingerprint(input2, output2, n, filtersize, fanvalue, timerange)

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
