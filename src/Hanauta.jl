module Hanauta

using DSP
using SHA
using Statistics
using Plots

include("peaks.jl")
include("fingerprint.jl")

export maxfilter, findpeaks, hashpeaks, fingerprint, fingerprint_song

end # module
