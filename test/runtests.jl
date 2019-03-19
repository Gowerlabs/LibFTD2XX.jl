# LibFTD2XX.jl

using LibFTD2XX
using Compat
using Compat.Test

include("util.jl")

numdevs = createdeviceinfolist()
if numdevs > 0
  include("hardware/wrapper.jl")
  include("hardware/LibFTD2XX.jl")
else
  include("nohardware/wrapper.jl")
  include("nohardware/LibFTD2XX.jl")
end