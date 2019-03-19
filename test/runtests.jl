# LibFTD2XX.jl

using LibFTD2XX
using Compat
using Compat.Test

include("util.jl")

numdevs = createdeviceinfolist()
if numdevs > 0
  include("hardware/alltests.jl")
else
  include("nohardware/alltests.jl")
end