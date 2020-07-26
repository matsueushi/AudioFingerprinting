module Hanauta

using SHA
using Statistics
using DSP

include("peaks.jl")
include("spectrogram.jl")

export maxfilter, findpeaks, hashpeaks, songspectrogram

end # module
