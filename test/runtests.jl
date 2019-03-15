# LibFTD2XX.jl

using LibFTD2XX
using Compat
using Compat.Test

numdevs = FT_CreateDeviceInfoList()
if numdevs > 0
  include("hardwaretests.jl")
end