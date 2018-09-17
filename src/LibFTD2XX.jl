# LibFTD2XX.jl

module LibFTD2XX

using Compat
using Compat.Libdl

export FT_HANDLE, createdeviceinfolist, getdeviceinfolist, listdevices, ftopen, 
       close, baudrate, datacharacteristics, status

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
  :FT_Open
  :FT_Close
  :FT_Read
  :FT_Write
  :FT_SetBaudRate
  :FT_SetDataCharacteristics
  :FT_GetModemStatus
  :FT_GetQueueStatus
  :FT_OpenEx
  :FT_Purge]

function __init__()
  lib[] = Libdl.dlopen(libFTD2XX)
  for n in cfuncn
    cfunc[n] = Libdl.dlsym(lib[], n)
  end
end

# Types
# 
struct FT_DEVICE_LIST_INFO_NODE
  flags::ULONG
  typ::ULONG
  id::ULONG
  locid::DWORD
  serialnumber::NTuple{16, Cchar}
  description::NTuple{64, Cchar}
  fthandle::Ptr{Cvoid}
end

mutable struct FT_HANDLE<:IO 
  p::Ptr{Cvoid} 
end

function FT_HANDLE()
  handle = FT_HANDLE(C_NULL)
  @compat finalizer(destroy!, handle)
  handle
end

function destroy!(handle::FT_HANDLE)
  if handle.p != C_NULL
    flush(handle)
    close(handle)
  end
  handle.p = C_NULL
end

function listdevices(arg1, arg2, flags)
  cfunc = Libdl.dlsym(lib[], "FT_ListDevices")
  flagsarg = DWORD(flags)
  status = ccall(cfunc, cdecl, FT_STATUS, (Ptr{Cvoid}, Ptr{Cvoid}, DWORD),
                                           arg1,       arg1,       flagsarg)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  arg1, arg2
end

function listdevices(flags)
  arg1 = Ref{DWORD}(0)
  arg2 = Ref{DWORD}(0)
  listdevices(arg1, arg2, flags)
end

function Base.String(input::NTuple{N, Cchar} where N)
  if any(input .== 0)
    endidx = findall(input .== 0)[1]-1
  elseif all(input .> 0)
    endidx = length(input)
  else
    throw(MethodError("No terminator or negative values!"))
  end
  String(UInt8.([char for char in input[1:endidx]]))
end

function createdeviceinfolist()
  numdevs = Ref{DWORD}(0)
  status = ccall(cfunc[:FT_CreateDeviceInfoList], cdecl, FT_STATUS, 
                 (Ref{DWORD},),
                  numdevs)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  numdevs[]
end

function getdeviceinfolist(numdevs)
  list =  @compat Vector{FT_DEVICE_LIST_INFO_NODE}(undef, numdevs)
  elnum = Ref{DWORD}(0)
  status = ccall(cfunc[:FT_GetDeviceInfoList], cdecl, FT_STATUS, 
                 (Ref{FT_DEVICE_LIST_INFO_NODE}, Ref{DWORD}),
                  list,                          elnum)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  list, elnum[]
end

function ftopen(devidx::Int)
  handle = FT_HANDLE()
  status = ccall(cfunc[:FT_Open], cdecl, FT_STATUS, (Int,    Ref{FT_HANDLE}),
                                                     devidx, handle)
  if FT_STATUS_ENUM(status) != FT_OK
    handle.p = C_NULL
    throw(FT_STATUS_ENUM(status))
  end
  handle
end

function Base.close(handle::FT_HANDLE)
  status = ccall(cfunc[:FT_Close], cdecl, FT_STATUS, (FT_HANDLE, ),
                                                       handle)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
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

function status(handle::FT_HANDLE)
  flags = Ref{DWORD}()
  status = ccall(cfunc[:FT_GetModemStatus], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{DWORD}),
                  handle,    flags)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  modemstatus = flags[] & 0xFF
  linestatus = (flags[] >> 8) & 0xFF
  mflaglist = Dict{String, Bool}()
  lflaglist = Dict{String, Bool}()
  mflaglist["CTS"]  = modemstatus & 0x10
  mflaglist["DSR"]  = modemstatus & 0x20
  mflaglist["RI"]   = modemstatus & 0x40
  mflaglist["DCD"]  = modemstatus & 0x80
  lflaglist["OE"]   = linestatus  & 0x02
  lflaglist["PE"]   = linestatus  & 0x04
  lflaglist["FE"]   = linestatus  & 0x08
  lflaglist["BI"]   = linestatus  & 0x10
  mflaglist, lflaglist
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
  @compat b = Vector{UInt8}(undef, bytesavailable(handle))
  readbytes!(handle, b)
  b
end

function Base.open(str::AbstractString, openby::FTOpenBy)
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
