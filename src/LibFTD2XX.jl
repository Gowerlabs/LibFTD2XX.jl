# LibFTD2XX.jl

module LibFTD2XX

using Compat
using Compat.Libdl

export FT_HANDLE, FT_CreateDeviceInfoList, FT_GetDeviceInfoList, FT_GetDeviceInfoDetail, FT_ListDevices, FT_Open, FT_OpenEx, FT_Close, FT_Read, FT_Write, FT_SetBaudRate, FT_SetDataCharacteristics, FT_SetTimeouts, FT_GetModemStatus, FT_GetQueueStatus, FT_GetDeviceInfo, FT_GetDriverVersion, FT_GetLibraryVersion,
       close, baudrate, datacharacteristics, status, ntuple2string

include("wrapper.jl")

# Library
# 
const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
  include(depsfile)
else
  error("LibFTD2XX not properly installed. Please run Pkg.build(\"LibFTD2XX\") then restart Julia.")
end

const lib = Ref{Ptr{Cvoid}}(0)
const cfunc = Dict{Symbol, Ptr{Cvoid}}()

const cfuncn = [
  :FT_CreateDeviceInfoList
  :FT_GetDeviceInfoList
  :FT_GetDeviceInfoDetail
  :FT_ListDevices
  :FT_Open
  :FT_OpenEx
  :FT_Close
  :FT_Read
  :FT_Write
  :FT_SetBaudRate
  :FT_SetDataCharacteristics
  :FT_SetTimeouts
  :FT_GetModemStatus
  :FT_GetQueueStatus
  :FT_GetDeviceInfo
  :FT_GetDriverVersion
  :FT_GetLibraryVersion
  :FT_Purge]

function __init__()
  lib[] = Libdl.dlopen(libFTD2XX)
  for n in cfuncn
    cfunc[n] = Libdl.dlsym(lib[], n)
  end
end

"""
    ntuple2string(input::NTuple{N, Cchar} where N)

Convert an NTuple of Cchars (optionally null terminated) to a julia string.

# Example

```jldoctest
julia> ntuple2string(Cchar.(('h','e','l','l','o')))
"hello"

julia> ntuple2string(Cchar.(('h','e','l','l','o', '\0', 'x'))) # null terminated
"hello"
```

"""
function ntuple2string(input::NTuple{N, Cchar} where N)
  if any(input .== 0)
    endidx = findall(input .== 0)[1]-1
  elseif all(input .> 0)
    endidx = length(input)
  else
    throw(MethodError("No terminator or negative values!"))
  end
  String(UInt8.([char for char in input[1:endidx]]))
end

function Base.isopen(handle::FT_HANDLE)
  open = true
  if handle.p == C_NULL
    open = false
  else
    try
      status(handle)
    catch ex
      if ex == FT_INVALID_HANDLE
        open = false
      else
        rethrow(ex)
      end
    end
  end
  open
end

end
