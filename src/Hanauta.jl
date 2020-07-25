module Hanauta

using SHA
using DSP

include("peaks.jl")

export maxfilter, findpeaks, hashpeaks, songspectrogram

end # module
