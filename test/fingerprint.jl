using Plots
using WAV


function plot_fingerprint(input, n, filtersize, fanvalue, timerange, freqrange)
    ys, fs, _, _ = wavread(input)
    # ysview = view(ys, 100000:300000, :)
    ysview = ys
    path, _ = splitext(input)
    return fingerprint_song(ysview, fs, n, filtersize, fanvalue, timerange, freqrange; path = path)
end

@testset "fingerprint" begin
    n = 4096
    filtersize = 10
    fanvalue = 50
    timerange = 0 => 20
    freqrange = -200 => 200

    input1 = joinpath(@__DIR__, "data/original.wav")
    input2 = joinpath(@__DIR__, "data/recorded.wav")

    hash1 = plot_fingerprint(input1, n, filtersize, fanvalue, timerange, freqrange)
    hash2 = plot_fingerprint(input2, n, filtersize, fanvalue, timerange, freqrange)

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
        scatter(ts1, ts2, aspect_ratio=1., label="")
        savefig(joinpath(@__DIR__, "output/scatter.png"))
    end
end
