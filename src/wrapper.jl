# LibFTD2XX.jl

export FTWordLength, BITS_8, BITS_7,
       FTStopBits, STOP_BITS_1, STOP_BITS_2,
       FTParity, PARITY_NONE, PARITY_ODD, PARITY_EVEN, PARITY_MARK, PARITY_SPACE,
       FTOpenBy, OPEN_BY_SERIAL_NUMBER, OPEN_BY_DESCRIPTION, OPEN_BY_LOCATION

# Constants
# 
const DWORD     = Cuint
const ULONG     = Culong
const UCHAR     = Cuchar
const FT_STATUS = ULONG

# FT_OpenEx Flags
const FT_OPEN_BY_SERIAL_NUMBER  = 1
const FT_OPEN_BY_DESCRIPTION    = 2
const FT_OPEN_BY_LOCATION       = 4
const FT_OPEN_MASK  = (FT_OPEN_BY_SERIAL_NUMBER | 
                       FT_OPEN_BY_DESCRIPTION | 
                       FT_OPEN_BY_LOCATION)

# FT_ListDevices Flags (used in conjunction with FT_OpenEx Flags)
const FT_LIST_NUMBER_ONLY     = 0x80000000
const FT_LIST_BY_INDEX        = 0x40000000
const FT_LIST_ALL             = 0x20000000

# Baud Rates
const FT_BAUD_300             = 300
const FT_BAUD_600             = 600
const FT_BAUD_1200            = 1200
const FT_BAUD_2400            = 2400
const FT_BAUD_4800            = 4800
const FT_BAUD_9600            = 9600
const FT_BAUD_14400           = 14400
const FT_BAUD_19200           = 19200
const FT_BAUD_38400           = 38400
const FT_BAUD_57600           = 57600
const FT_BAUD_115200          = 115200
const FT_BAUD_230400          = 230400
const FT_BAUD_460800          = 460800
const FT_BAUD_921600          = 921600

# Word Lengths
const FT_BITS_8               = 8
const FT_BITS_7               = 7

# Stop Bits
const FT_STOP_BITS_1          = 0
const FT_STOP_BITS_2          = 2

# Parity
const  FT_PARITY_NONE         = 0
const  FT_PARITY_ODD          = 1
const  FT_PARITY_EVEN         = 2
const  FT_PARITY_MARK         = 3
const  FT_PARITY_SPACE        = 4

# Flow Control
const FT_FLOW_NONE            = 0x0000
const FT_FLOW_RTS_CTS         = 0x0100
const FT_FLOW_DTR_DSR         = 0x0200
const FT_FLOW_XON_XOFF        = 0x0400

# Events
const FT_EVENT_RXCHAR         = 1
const FT_EVENT_MODEM_STATUS   = 2
const FT_EVENT_LINE_STATUS    = 4

# Timeouts
const  FT_DEFAULT_RX_TIMEOUT  = 300
const  FT_DEFAULT_TX_TIMEOUT  = 300

const FT_PURGE_RX = 1
const FT_PURGE_TX = 2

# Library
# 
@enum(
  FTOpenBy,
  OPEN_BY_SERIAL_NUMBER = FT_OPEN_BY_SERIAL_NUMBER,
  OPEN_BY_DESCRIPTION = FT_OPEN_BY_DESCRIPTION,
  OPEN_BY_LOCATION = FT_OPEN_BY_LOCATION)

@enum(
  FT_STATUS_ENUM,
  FT_OK,
  FT_INVALID_HANDLE,
  FT_DEVICE_NOT_FOUND,
  FT_DEVICE_NOT_OPENED,
  FT_IO_ERROR,
  FT_INSUFFICIENT_RESOURCES,
  FT_INVALID_PARAMETER,
  FT_INVALID_BAUD_RATE,
  FT_DEVICE_NOT_OPENED_FOR_ERASE,
  FT_DEVICE_NOT_OPENED_FOR_WRITE,
  FT_FAILED_TO_WRITE_DEVICE,
  FT_EEPROM_READ_FAILED,
  FT_EEPROM_WRITE_FAILED,
  FT_EEPROM_ERASE_FAILED,
  FT_EEPROM_NOT_PRESENT,
  FT_EEPROM_NOT_PROGRAMMED,
  FT_INVALID_ARGS,
  FT_NOT_SUPPORTED,
  FT_OTHER_ERROR,
  FT_DEVICE_LIST_NOT_READY)

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

# wrapper functions
#



# """
# Wrapper for `FT_ListDevices`. See D2XX Programmer's Guide (FT_000071) for more
# information.
# Call with `pvArg1 = Ref{DWORD}()` and/or `pvArg2 = Ref{DWORD}()` for cases 
# where `pvArg1` and/or `pvArg2` return or are given DWORD information.
# NOT RECOMMENDED FOR USE.
# """
# function FT_ListDevices(pvArg1, pvArg2, dwFlags)
#   cfunc = Libdl.dlsym(lib[], "FT_ListDevices")
#   flagsarg = DWORD(dwFlags)
#   status = ccall(cfunc, cdecl, FT_STATUS, (Ptr{Cvoid}, Ptr{Cvoid}, DWORD),
#                                            pvArg1,     pvArg2,     dwFlags)
#   FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
#   pvArg1, pvArg2
# end

function FT_CreateDeviceInfoList()
  numdevs = Ref{DWORD}(0)
  status = ccall(cfunc[:FT_CreateDeviceInfoList], cdecl, FT_STATUS, 
                 (Ref{DWORD},),
                  numdevs)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  numdevs[]
end

"""
Wrapper for `FT_GetDeviceInfoDetail`. See D2XX Programmer's Guide (FT_000071) 
for more information.
"""
function FT_GetDeviceInfoDetail(dwIndex)
  lpdwFlags, lpdwType  = Ref{DWORD}(), Ref{DWORD}()
  lpdwID,    lpdwLocId = Ref{DWORD}(), Ref{DWORD}()
  pcSerialNumber = pointer(Vector{Cchar}(undef, 16))
  pcDescription  = pointer(Vector{Cchar}(undef, 64))
  ftHandle = FT_HANDLE()
  
  status = ccall(cfunc[:FT_GetDeviceInfoDetail], cdecl, FT_STATUS, 
  (DWORD,   Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Cstring,        Cstring,       Ref{FT_HANDLE}),
   dwIndex, lpdwFlags,  lpdwType,   lpdwID,     lpdwLocId,  pcSerialNumber, pcDescription, ftHandle)
  
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  dwIndex[], lpdwFlags[], lpdwType[], lpdwID[], lpdwLocId[], unsafe_string(pcSerialNumber), unsafe_string(pcDescription), ftHandle
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
  b = @compat Vector{UInt8}(undef, bytesavailable(handle))
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
