# LibFTD2XX.jl

module LibFTD2XX

export close, baudrate, datacharacteristics, status, driverversion, libversion, createdeviceinfolist, getdeviceinfodetail

include("util.jl")
include("wrapper.jl")

using .Util
using .Wrapper
using Compat

function driverversion(handle::FT_HANDLE)
  version = FT_GetDriverVersion(handle)
  @assert (version >> 24) & 0xFF == 0x00 # 4th byte should be 0 according to docs
  patch = version & 0xFF
  minor = (version >> 8) & 0xFF
  major = (version >> 16) & 0xFF
  VersionNumber(major,minor,patch)
end

function libversion()
  version = FT_GetLibraryVersion()
  @assert (version >> 24) & 0xFF == 0x00 # 4th byte should be 0 according to docs
  patch = version & 0xFF
  minor = (version >> 8) & 0xFF
  major = (version >> 16) & 0xFF
  VersionNumber(major,minor,patch)
end

function status(handle::FT_HANDLE)
  flags = FT_GetModemStatus(handle)
  modemstatus = flags & 0xFF
  linestatus = (flags >> 8) & 0xFF
  mflaglist = Dict{String, Bool}()
  lflaglist = Dict{String, Bool}()
  mflaglist["CTS"]  = (modemstatus & 0x10) == 0x10
  mflaglist["DSR"]  = (modemstatus & 0x20) == 0x20
  mflaglist["RI"]   = (modemstatus & 0x40) == 0x40
  mflaglist["DCD"]  = (modemstatus & 0x80) == 0x89
  # Below is only non-zero for windows
  lflaglist["OE"]   = (linestatus  & 0x02) == 0x02
  lflaglist["PE"]   = (linestatus  & 0x04) == 0x04
  lflaglist["FE"]   = (linestatus  & 0x08) == 0x08
  lflaglist["BI"]   = (linestatus  & 0x10) == 0x10
  mflaglist, lflaglist
end

"""
    Base.close(handle::FT_HANDLE)

Closes an open FTD2XX device and marks its handle as closed.
"""
function Base.close(handle::FT_HANDLE)
  if isopen(handle)
    FT_Close(handle)
    handle.p = C_NULL
  end
  return
end

function Base.readbytes!(handle::FT_HANDLE, b::AbstractVector{UInt8}, nb=length(b))
  nbav = bytesavailable(handle)
  if nbav < nb
    nb = nbav
  end
  if length(b) < nb
    resize!(b, nb)
  end
  nbrx = FT_Read(handle, b, nb)
end

Base.write(handle::FT_HANDLE, buffer::Vector{UInt8}) = 
FT_Write(handle, buffer, length(buffer))

baudrate(handle::FT_HANDLE, baud) = FT_SetBaudRate(handle, baud)

datacharacteristics(handle::FT_HANDLE; 
                    wordlength::FTWordLength = BITS_8, 
                    stopbits::FTStopBits = STOP_BITS_1, 
                    parity::FTParity = PARITY_NONE) = 
FT_SetDataCharacteristics(handle, wordlength, stopbits, parity)

Compat.bytesavailable(handle::FT_HANDLE) = FT_GetQueueStatus(handle)

Base.eof(handle::FT_HANDLE) = (bytesavailable(handle) == 0)

function Base.readavailable(handle::FT_HANDLE)
  b = @compat Vector{UInt8}(undef, bytesavailable(handle))
  readbytes!(handle, b)
  b
end

"""
    open(str::AbstractString, openby::FTOpenBy)

Open an FTD2XX device.

# Arguments
 - `str::AbstractString` : Device identifier. Type depends on `openby`
 - `openby::FTOpenBy` : Indicator of device identifier `str` type.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> idx, flags, type, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0)
(0, 0x00000002, 0x00000007, 0x04036011, 0x00000000, "FT3AD2HCD", "USB <-> Serial Converter D", FT_HANDLE(Ptr{Nothing} @0x0000000000000000))

julia> handle = open(description, OPEN_BY_DESCRIPTION)
FT_HANDLE(Ptr{Nothing} @0x0000000000dfe740)

julia> isopen(handle)
true

julia> close(handle)

julia> handle = open(serialnumber, OPEN_BY_SERIAL_NUMBER)
FT_HANDLE(Ptr{Nothing} @0x0000000005448ea0)

julia> isopen(handle)
true

julia> close(handle)
```
"""
Base.open(str::AbstractString, openby::FTOpenBy) = FT_OpenEx(str, DWORD(openby))

function Base.flush(handle::FT_HANDLE)
  FT_StopInTask(handle)
  FT_Purge(handle, FT_PURGE_RX|FT_PURGE_RX)
  FT_RestartInTask(handle)
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

function createdeviceinfolist()
  numdevs = FT_CreateDeviceInfoList()
end

function getdeviceinfodetail(deviceidx)
  @assert 0 <= deviceidx < FT_CreateDeviceInfoList()
  idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(deviceidx)
end

end