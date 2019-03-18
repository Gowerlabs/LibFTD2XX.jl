# LibFTD2XX.jl

module LibFTD2XX

using Compat
using Compat.Libdl

export close, baudrate, datacharacteristics, status

include("util.jl")
include("wrapper.jl")

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
  FT_Close(handle)
  handle.p = C_NULL
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
  nbrx = Ref{DWORD}()
  status = ccall(cfunc[:FT_Read], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD, Ref{DWORD}),
                  handle,    b,          nb,    nbrx)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  nbrx[]
end

function Base.write(handle::FT_HANDLE, buffer::Vector{UInt8})
  nb = DWORD(length(buffer))
  nbtx = Ref{DWORD}()
  status = ccall(cfunc[:FT_Write], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD, Ref{DWORD}),
                  handle,    buffer,     nb,    nbtx)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  nbtx[]
end

function baudrate(handle::FT_HANDLE, baud)
  status = ccall(cfunc[:FT_SetBaudRate], cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD),
                  handle,    baud)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

function datacharacteristics(handle::FT_HANDLE; wordlength::FTWordLength = BITS_8, stopbits::FTStopBits = STOP_BITS_1, parity::FTParity = PARITY_NONE)
  status = ccall(cfunc[:FT_SetDataCharacteristics], cdecl, FT_STATUS, 
                 (FT_HANDLE, UCHAR,      UCHAR,    UCHAR),
                  handle,    wordlength, stopbits, parity)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

function Compat.bytesavailable(handle::FT_HANDLE)
  nbrx = Ref{DWORD}()
  status = ccall(cfunc[:FT_GetQueueStatus], cdecl, FT_STATUS, 
                  (FT_HANDLE, Ref{DWORD}),
                  handle,    nbrx)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  nbrx[]
end

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
function open(str::AbstractString, openby::FTOpenBy)
  flagsarg = DWORD(openby)
  handle = FT_HANDLE()
  status = ccall(cfunc[:FT_OpenEx], cdecl, FT_STATUS, 
                 (Cstring, DWORD,    Ref{FT_HANDLE}),
                  str,     flagsarg, handle)
  if FT_STATUS_ENUM(status) != FT_OK
    handle.p = C_NULL
    throw(FT_STATUS_ENUM(status))
  end
  handle
end

function Base.flush(handle::FT_HANDLE)
  flagsarg = DWORD(FT_PURGE_RX | FT_PURGE_TX)
  status = ccall(cfunc[:FT_Purge], cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD),
                  handle,    flagsarg)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
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
