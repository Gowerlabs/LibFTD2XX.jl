# LibFTD2XX.jl

module LibFTD2XX

export D2XXException
export D2XXDevice
export deviceidx, deviceflags, devicetype, deviceid, locationid, serialnumber, description, fthandle
export FT_HANDLE
export FTWordLength, BITS_8, BITS_7,
       FTStopBits, STOP_BITS_1, STOP_BITS_2,
       FTParity, PARITY_NONE, PARITY_ODD, PARITY_EVEN, PARITY_MARK, PARITY_SPACE,
       FTOpenBy, OPEN_BY_SERIAL_NUMBER, OPEN_BY_DESCRIPTION, OPEN_BY_LOCATION
export close, baudrate, datacharacteristics, status, driverversion, libversion, createdeviceinfolist

include("util.jl")
include("wrapper.jl")

using .Util
using .Wrapper
using Compat

@enum(
  FTOpenBy,
  OPEN_BY_SERIAL_NUMBER = FT_OPEN_BY_SERIAL_NUMBER,
  OPEN_BY_DESCRIPTION = FT_OPEN_BY_DESCRIPTION,
  OPEN_BY_LOCATION = FT_OPEN_BY_LOCATION)

@enum(
  FTWordLength,
  BITS_8 = FT_BITS_8,
  BITS_7 = FT_BITS_7)

@enum(
  FTStopBits,
  STOP_BITS_1 = FT_STOP_BITS_1,
  STOP_BITS_2 = FT_STOP_BITS_2)

@enum(
  FTParity,
  PARITY_NONE = FT_PARITY_NONE,
  PARITY_ODD  = FT_PARITY_ODD,
  PARITY_EVEN = FT_PARITY_EVEN,
  PARITY_MARK = FT_PARITY_MARK,
  PARITY_SPACE = FT_PARITY_SPACE)

struct D2XXException <: Exception
  str::String
end

struct D2XXDevice <: IO
  idx::Int
  flags::Int
  type::Int
  id::Int
  locid::Int
  serialnumber::String
  description::String
  fthandle::FT_HANDLE
end

"""
    D2XXDevice(deviceidx::Integer)

Construct a D2XXDevice without opening it.
"""
function D2XXDevice(deviceidx::Integer)
  idx, flags, typ, id, locid, serialnumber, description, fthandle = getdeviceinfodetail(deviceidx)
  D2XXDevice(idx, flags, typ, id, locid, serialnumber, description, fthandle)
end

"""
    deviceidx(d::D2XXDevice)

Get D2XXDevice index.
"""
deviceidx(d::D2XXDevice) = d.idx

"""
    deviceflags(d::D2XXDevice)

Get the D2XXDevice flags list.
"""
deviceflags(d::D2XXDevice) = d.flags

"""
    devicetype(d::D2XXDevice)

Get the D2XXDevice device type.
"""
devicetype(d::D2XXDevice) = d.type

  """
  deviceid(d::D2XXDevice)

Get the D2XXDevice device id.
"""
deviceid(d::D2XXDevice) = d.id

"""
    locationid(d::D2XXDevice)

Get the D2XXDevice location id. This is zero for windows devices.
"""
locationid(d::D2XXDevice) = d.locid

"""
    serialnumber(d::D2XXDevice)

Get the D2XXDevice device serial number.
"""
serialnumber(d::D2XXDevice) = d.serialnumber

"""
    description(d::D2XXDevice)

Get the D2XXDevice device description.
"""
description(d::D2XXDevice) = d.description

"""
    fthandle(d::D2XXDevice)

Get the D2XXDevice device D2XX handle of type ``::FT_HANDLE`.
"""
fthandle(d::D2XXDevice) = d.fthandle

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
  if ptr(handle) == C_NULL
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
  0 <= deviceidx < createdeviceinfolist() || throw(D2XXException("Device index $deviceidx not in range."))
  idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(deviceidx)
end

end