# LibFTD2XX.jl

export FTWordLength, BITS_8, BITS_7,
       FTStopBits, STOP_BITS_1, STOP_BITS_2,
       FTParity, PARITY_NONE, PARITY_ODD, PARITY_EVEN, PARITY_MARK, PARITY_SPACE,
       FTOpenBy, OPEN_BY_SERIAL_NUMBER, OPEN_BY_DESCRIPTION, OPEN_BY_LOCATION,
       FT_OPEN_BY_SERIAL_NUMBER, FT_OPEN_BY_DESCRIPTION, FT_OPEN_BY_LOCATION, FT_LIST_NUMBER_ONLY, FT_LIST_BY_INDEX,
       FT_STATUS_ENUM

export FT_DEVICE

export FT_BITS_8, FT_BITS_7, 
FT_STOP_BITS_1, FT_STOP_BITS_2, 
FT_PARITY_NONE, FT_PARITY_ODD, FT_PARITY_EVEN, FT_PARITY_MARK, FT_PARITY_SPACE

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

# FT_GetDeviceInfo FT_DEVICE Type Enum
@enum(
  FT_DEVICE,
  FT_DEVICE_232BM    = DWORD(0),
  FT_DEVICE_232AM    = DWORD(1),
  FT_DEVICE_100AX    = DWORD(2),
  FT_DEVICE_UNKNOWN  = DWORD(3),
  FT_DEVICE_2232C    = DWORD(4),
  FT_DEVICE_232R     = DWORD(5),
  FT_DEVICE_2232H    = DWORD(6),
  FT_DEVICE_4232H    = DWORD(7),
  FT_DEVICE_232H     = DWORD(8),
  FT_DEVICE_X_SERIES = DWORD(9)
)

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
  fthandle_ptr::Ptr{Cvoid}
end

mutable struct FT_HANDLE<:IO 
  p::Ptr{Cvoid} 
end

function FT_HANDLE()
  handle = FT_HANDLE(C_NULL)
  @compat finalizer(destroy!, handle)
  handle
end

ptr(handle::FT_HANDLE) = handle.p

function destroy!(handle::FT_HANDLE)
  if handle.p != C_NULL
    flush(handle)
    close(handle)
  end
  handle.p = C_NULL
end

# wrapper functions
#

"""
    FT_CreateDeviceInfoList()

Wrapper for D2XX library function `FT_CreateDeviceInfoList`. 

See D2XX Programmer's Guide (FT_000071) for more information.

# Example
```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> "Number of devices is \$numdevs"
"Number of devices is 4"
```
"""
function FT_CreateDeviceInfoList()
  lpdwNumDevs = Ref{DWORD}(0)
  status = ccall(cfunc[:FT_CreateDeviceInfoList], cdecl, FT_STATUS, 
                 (Ref{DWORD},),
                 lpdwNumDevs)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  lpdwNumDevs[]
end

"""
    FT_GetDeviceInfoList(lpdwNumDevs)

Wrapper for D2XX library function `FT_GetDeviceInfoList`. 

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `lpdwNumDevs`: The number of devices.

# Example
```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> devinfolist, numdevs = FT_GetDeviceInfoList(numdevs);

julia> numdevs
0x00000004

julia> ntuple2string(devinfolist[1].description)
"USB <-> Serial Converter D"

julia> devinfolist[1].fthandle_ptr
Ptr{Nothing} @0x0000000000000000

julia> devinfolist[1].locid
0x00000000

julia> devinfolist[1].typ
0x00000007

julia> devinfolist[1].flags
0x00000002

julia> devinfolist[1].id
0x04036011

julia> ntuple2string(devinfolist[1].serialnumber)
"FT3AD2HCD"

```
"""
function FT_GetDeviceInfoList(lpdwNumDevs)
  pDest =  @compat Vector{FT_DEVICE_LIST_INFO_NODE}(undef, lpdwNumDevs)
  status = ccall(cfunc[:FT_GetDeviceInfoList], cdecl, FT_STATUS, 
                 (Ref{FT_DEVICE_LIST_INFO_NODE}, Ref{DWORD}),
                  pDest,                         Ref{DWORD}(lpdwNumDevs))
  pDest, lpdwNumDevs
end

"""
    FT_GetDeviceInfoDetail(dwIndex)

Wrapper for D2XX library function `FT_GetDeviceInfoDetail`. 

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `dwIndex`: Index of entry in the device info list.

# Example
```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> idx, flags, type, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0) # zero indexed
(0, 0x00000002, 0x00000007, 0x04036011, 0x00000000, "FT3AD2HCD", "USB <-> Serial Converter D", FT_HANDLE(Ptr{Nothing} @0x0000000000000000))
```
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


"""
    FT_ListDevices(pvArg1, pvArg2, dwFlags)

**NOT FULLY FUNCTIONAL: NOT RECOMMENDED FOR USE**.

Wrapper for D2XX library function `FT_ListDevices`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `pvArg1`: Depends on dwFlags.
 - `pvArg2`: Depends on dwFlags.
- `dwFlags`: Flag which determines format of returned information.

E.g. call with `pvArg1 = Ref{UInt32}()` and/or `pvArg2 = Ref{UInt32}()` for 
cases where `pvArg1` and/or `pvArg2` return or are given DWORD information.

# Examples

1. Get number of devices...
```julia-repl

julia> numdevs = Ref{UInt32}();

julia> FT_ListDevices(numdevs, Ref{UInt32}(), FT_LIST_NUMBER_ONLY)

julia> numdevs[]
0x00000004
```

2. Get serial number of first device... *NOT CURRENTLY WORKING*
```julia-repl

julia> devidx = Ref{UInt32}(0)
Base.RefValue{UInt32}(0x00000000)

julia> buffer = pointer(Vector{Cchar}(undef, 64))
Ptr{Int8} @0x00000000065a8690

julia> FT_ListDevices(devidx, buffer, FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER)
ERROR: FT_DEVICE_NOT_FOUND::FT_STATUS_ENUM = 2
Stacktrace:
...

```
"""
function FT_ListDevices(pvArg1, pvArg2, dwFlags)
  flagsarg = DWORD(dwFlags)
  status = ccall(cfunc[:FT_ListDevices], cdecl, FT_STATUS, 
                 (Ptr{Cvoid}, Ptr{Cvoid}, DWORD),
                  pvArg1,     pvArg2,     dwFlags)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end


"""
    FT_Open(iDevice)

Wrapper for D2XX library function `FT_Open`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `iDevice`: Zero-base index of device to open

# Example

```julia-repl

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000000c4970)

```
"""
function FT_Open(iDevice)
  ftHandle = FT_HANDLE()
  status = ccall(cfunc[:FT_Open], cdecl, FT_STATUS, (Int,     Ref{FT_HANDLE}),
                                                     iDevice, ftHandle)
  if FT_STATUS_ENUM(status) != FT_OK
    ftHandle.p = C_NULL
    throw(FT_STATUS_ENUM(status))
  end
  ftHandle
end

"""
    FT_OpenEx(pvArg1::AbstractString, dwFlags::Integer)

Wrapper for D2XX library function `FT_OpenEx`.

See D2XX Programmer's Guide (FT_000071) for more information. Note that 
FT_OPEN_BY_LOCATION is not currently supported.

# Arguments
 - `pvArg1::AbstractString` : Either description or serial number depending on 
   `dwFlags`.
 - `dwFlags::Integer` : FT_OPEN_BY_DESCRIPTION or FT_OPEN_BY_SERIAL_NUMBER.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> idx, flags, type, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0)
(0, 0x00000002, 0x00000007, 0x04036011, 0x00000000, "FT3AD2HCD", "USB <-> Serial Converter D", FT_HANDLE(Ptr{Nothing} @0x0000000000000000))

julia> handle = FT_OpenEx(description, FT_OPEN_BY_DESCRIPTION)
FT_HANDLE(Ptr{Nothing} @0x0000000000dfe740)

julia> isopen(handle)
true

julia> close(handle)

julia> handle = FT_OpenEx(serialnumber, FT_OPEN_BY_SERIAL_NUMBER)
FT_HANDLE(Ptr{Nothing} @0x0000000005448ea0)

julia> isopen(handle)
true

julia> close(handle)
```
"""
function FT_OpenEx(pvArg1::AbstractString, dwFlags::Integer)
  @assert (dwFlags == FT_OPEN_BY_DESCRIPTION) | (dwFlags == FT_OPEN_BY_SERIAL_NUMBER)
  flagsarg = DWORD(dwFlags)
  handle = FT_HANDLE()
  status = ccall(cfunc[:FT_OpenEx], cdecl, FT_STATUS, 
                 (Cstring , DWORD,    Ref{FT_HANDLE}),
                  pvArg1,   flagsarg, handle)
  if FT_STATUS_ENUM(status) != FT_OK
    handle.p = C_NULL
    throw(FT_STATUS_ENUM(status))
  end
  handle
end


"""
    FT_Close(ftHandle::FT_HANDLE)

Wrapper for D2XX library function `FT_Close`. Closes an open device.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x000000000010a870)

julia> FT_Close(handle)
```
"""
function FT_Close(ftHandle::FT_HANDLE)
  status = ccall(cfunc[:FT_Close], cdecl, FT_STATUS, (FT_HANDLE, ),
                                                      ftHandle)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

"""
    FT_Read(ftHandle::FT_HANDLE, lpBuffer::AbstractVector{UInt8}, dwBytesToRead::Integer)

Wrapper for D2XX library function `FT_Read`. Returns number of bytes read.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> buffer = zeros(UInt8, 2)
2-element Array{UInt8,1}:
 0x00
 0x00

julia> nread = FT_Read(handle, buffer, 0) # read 0 bytes. Returns number read...
0x00000000

julia> buffer # should be unmodified...
2-element Array{UInt8,1}:
 0x00
 0x00

julia> FT_Close(handle)
```
"""
function FT_Read(ftHandle::FT_HANDLE, lpBuffer::AbstractVector{UInt8}, dwBytesToRead::Integer)
  @assert 0 <= dwBytesToRead <= length(lpBuffer)
  lpdwBytesReturned = Ref{DWORD}()
  status = ccall(cfunc[:FT_Read], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD,         Ref{DWORD}),
                 ftHandle,   lpBuffer,   dwBytesToRead, lpdwBytesReturned)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  lpdwBytesReturned[]
end

"""
    FT_Write(ftHandle::FT_HANDLE, lpBuffer::Vector{UInt8}, dwBytesToWrite::Integer)

Wrapper for D2XX library function `FT_Write`. Returns number of bytes written.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> buffer = ones(UInt8, 2)
2-element Array{UInt8,1}:
 0x01
 0x01

julia> nwr = FT_Write(handle, buffer, 0) # Write 0 bytes...
0x00000000

julia> buffer # should be unmodified...
2-element Array{UInt8,1}:
 0x01
 0x01

julia> nwr = FT_Write(handle, buffer, 2) # Write 2 bytes...
0x00000002

julia> buffer # should be unmodified...
2-element Array{UInt8,1}:
 0x01
 0x01

julia> FT_Close(handle)
```
"""
function FT_Write(ftHandle::FT_HANDLE, lpBuffer::AbstractVector{UInt8}, dwBytesToWrite::Integer)
  @assert 0 <= dwBytesToWrite <= length(lpBuffer)
  lpdwBytesWritten = Ref{DWORD}()
  status = ccall(cfunc[:FT_Write], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD,          Ref{DWORD}),
                  ftHandle,  lpBuffer,   dwBytesToWrite, lpdwBytesWritten)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  lpdwBytesWritten[]
end

"""
    FT_SetBaudRate(ftHandle::FT_HANDLE, dwBaudRate::Integer)

Wrapper for D2XX library function `FT_SetBaudRate`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetBaudRate(handle, 115200) # Set baud rate to 115200

julia> FT_Close(handle)
```
"""
function FT_SetBaudRate(ftHandle::FT_HANDLE, dwBaudRate::Integer)
  @assert 0 < dwBaudRate <= typemax(DWORD)
  status = ccall(cfunc[:FT_SetBaudRate], cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD),
                  ftHandle,    dwBaudRate)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

"""
    FT_SetDataCharacteristics(ftHandle::FT_HANDLE, uWordLength, uStopBits, uParity)

Wrapper for D2XX library function `FT_SetDataCharacteristics`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `ftHandle` : device handle
 - `uWordLength` : Bits per word - either FT_BITS_8 or FT_BITS_7
 - `uStopBits` : Stop bits - either FT_STOP_BITS_1 or FT_STOP_BITS_2
 - `uParity` : Parity - either FT_PARITY_EVEN, FT_PARITY_ODD, FT_PARITY_MARK, 
   FT_PARITY_SPACE, or FT_PARITY_NONE.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE) 

julia> FT_Close(handle)
```
"""
function FT_SetDataCharacteristics(ftHandle::FT_HANDLE, uWordLength, uStopBits, uParity)
  @assert (uWordLength == FT_BITS_8) || (uWordLength == FT_BITS_7)
  @assert (uStopBits == FT_STOP_BITS_1) || (uStopBits == FT_STOP_BITS_2)
  @assert (uParity == FT_PARITY_EVEN) || (uParity == FT_PARITY_ODD) || 
          (uParity == FT_PARITY_MARK) || (uParity == FT_PARITY_SPACE) || 
          (uParity == FT_PARITY_NONE)
  status = ccall(cfunc[:FT_SetDataCharacteristics], cdecl, FT_STATUS, 
                 (FT_HANDLE, UCHAR,       UCHAR,     UCHAR),
                  ftHandle,  uWordLength, uStopBits, uParity)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

"""
    FT_SetTimeouts(ftHandle::FT_HANDLE, dwReadTimeout, dwWriteTimeout)

Wrapper for D2XX library function `FT_SetTimeouts`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Arguments
 - `ftHandle` : device handle
 - `dwReadTimeout` : Read timeout (milliseconds)
 - `dwWriteTimeout` : Write timeout (milliseconds)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetBaudRate(handle, 9600)

julia> FT_SetTimeouts(handle, 50, 10) # 50ms read timeout, 10 ms write timeout

julia> buffer = zeros(UInt8, 5000);

julia> @time nwr = FT_Write(handle, buffer, 5000) # writes nothing if timesout
  0.014323 seconds (4 allocations: 160 bytes)
0x00000000

julia> @time nread = FT_Read(handle, buffer, 5000)
  0.049545 seconds (4 allocations: 160 bytes)
0x00000000

julia> FT_Close(handle)
```
"""
function FT_SetTimeouts(ftHandle::FT_HANDLE, dwReadTimeout, dwWriteTimeout)
  status = ccall(cfunc[:FT_SetTimeouts], cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD,         DWORD,),
                  ftHandle,  dwReadTimeout, dwWriteTimeout)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  return
end

"""
    FT_GetModemStatus(ftHandle::FT_HANDLE)

Wrapper for D2XX library function `FT_GetModemStatus`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> flags = FT_GetModemStatus(handle)
0x00006400

julia> FT_Close(handle)
```
"""
function FT_GetModemStatus(ftHandle::FT_HANDLE)
  lpdwModemStatus = Ref{DWORD}()
  status = ccall(cfunc[:FT_GetModemStatus], cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{DWORD}),
                  ftHandle,  lpdwModemStatus)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  lpdwModemStatus[]
end

"""
    FT_GetQueueStatus(ftHandle::FT_HANDLE)

Wrapper for D2XX library function `FT_GetQueueStatus`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> nbrx = FT_GetQueueStatus(handle) # get number of items in recieve queue
0x00000000

julia> FT_Close(handle)
```
"""
function FT_GetQueueStatus(ftHandle::FT_HANDLE)
  lpdwAmountInRxQueue = Ref{DWORD}()
  status = ccall(cfunc[:FT_GetQueueStatus], cdecl, FT_STATUS, 
                  (FT_HANDLE, Ref{DWORD}),
                   ftHandle,  lpdwAmountInRxQueue)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  lpdwAmountInRxQueue[]
end

"""
    FT_GetDeviceInfo(ftHandle::FT_HANDLE)

Wrapper for D2XX library function `FT_GetDeviceInfo`.

See D2XX Programmer's Guide (FT_000071) for more information.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> type, id, serialnumber, description = FT_GetDeviceInfo(handle);

julia> FT_Close(handle)
```
"""
function FT_GetDeviceInfo(ftHandle::FT_HANDLE)
  pftType = Ref{FT_DEVICE}()
  lpdwID = Ref{DWORD}()
  pcSerialNumber = pointer(Vector{Cchar}(undef, 16))
  pcDescription  = pointer(Vector{Cchar}(undef, 64))
  pvDummy = C_NULL

  status = ccall(cfunc[:FT_GetDeviceInfo], cdecl, FT_STATUS, 
  (FT_HANDLE, Ref{FT_DEVICE}, Ref{DWORD}, Cstring,        Cstring,       Ptr{Cvoid}),
   ftHandle,  pftType,        lpdwID,     pcSerialNumber, pcDescription, pvDummy)
  
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  pftType[], lpdwID[], unsafe_string(pcSerialNumber), unsafe_string(pcDescription)
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
