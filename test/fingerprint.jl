using Plots
using Measures
using WAV


function plot_fingerprint(input, n, filtersize, fanvalue, timerange, freqrange)
    ys, fs, _, _ = wavread(input)
    # ysview = view(ys, 100000:300000, :)
    ysview = ys
    path, _ = splitext(input)
    return fingerprint_song(ysview, fs, n, filtersize, fanvalue, timerange, freqrange)#"; path = path)
end

function hashmatching(hash1, hash2)
    i = 0
    ts1 = Vector{Int64}()
    ts2 = Vector{Int64}()
    for h in keys(hash2)
        if haskey(hash1, h)
            t1, t2 = hash1[h], hash2[h]
            push!(ts1, t1)
            push!(ts2, t2)
            i += 1
        end
    end
    println("Match: $i")
    if i > 0
        scatter(ts1, ts2, label="", margin=5mm)
        savefig(joinpath(@__DIR__, "output/scatter.png"))
        tsdiff = ts1 .- ts2
        histogram(tsdiff, label="", bins=50, margin=5mm)
        savefig(joinpath(@__DIR__, "output/hist.png"))
    end
end

@testset "fingerprint" begin
    n = 4096
    filtersize = 10
    fanvalue = 50
    timerange = 0 => 20
    freqrange = -200 => 200

    input1 = joinpath(@__DIR__, "data/04 Buddy Holly.wav")
    input2 = joinpath(@__DIR__, "data/noise_added.wav")

    hash1 = plot_fingerprint(input1, n, filtersize, fanvalue, timerange, freqrange)
    hash2 = plot_fingerprint(input2, n, filtersize, fanvalue, timerange, freqrange)

    hashmatching(hash1, hash2)
end
