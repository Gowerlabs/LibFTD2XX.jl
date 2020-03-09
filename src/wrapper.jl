# LibFTD2XX.jl - C Library Wrapper
#
# By Reuben Hill 2019, Gowerlabs Ltd, reuben@gowerlabs.co.uk
#
# Copyright (c) Gowerlabs Ltd.
#
# This module contains wrappers for D2XX devices. See D2XX Programmer's Guide 
# (FT_000071) for more information. Function names match those in the library.
#
# Only recommended for advanced users. Note that there is minimal argument 
# checking in these wrapper methods. 

module Wrapper

# Type Aliases
export DWORD, ULONG, UCHAR

# Library Constants
export FT_OPEN_BY_SERIAL_NUMBER, FT_OPEN_BY_DESCRIPTION, FT_OPEN_BY_LOCATION
export FT_DEVICE
export FT_LIST_NUMBER_ONLY, FT_LIST_BY_INDEX, FT_LIST_ALL
export FT_BITS_8, FT_BITS_7
export FT_STOP_BITS_1, FT_STOP_BITS_2
export FT_PARITY_NONE, FT_PARITY_ODD, FT_PARITY_EVEN, FT_PARITY_MARK, FT_PARITY_SPACE
export FT_FLOW_NONE, FT_FLOW_RTS_CTS, FT_FLOW_DTR_DSR, FT_FLOW_XON_XOFF
export FT_EVENT_RXCHAR, FT_EVENT_MODEM_STATUS, FT_EVENT_LINE_STATUS
export FT_PURGE_RX, FT_PURGE_TX
export FT_MODE_RESET,
       FT_MODE_ASYNC_BITBANG,
       FT_MODE_MPSSE,
       FT_MODE_SYNC_BITBANG,
       FT_MODE_MCU_EMULATION,
       FT_MODE_FAST_OPTO,
       FT_MODE_CBUS_BITBANG,
       FT_MODE_SCS_FIFO
export FT_STATUS_ENUM,
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
       FT_DEVICE_LIST_NOT_READY

# Types
export FT_HANDLE

# Functions
export FT_CreateDeviceInfoList, 
       FT_GetDeviceInfoList,
       FT_GetDeviceInfoDetail,
       FT_ListDevices,
       FT_Open,
       FT_OpenEx,
       FT_Close,
       FT_Read,
       FT_Write,
       FT_SetBaudRate,
       FT_SetDataCharacteristics,
       FT_SetTimeouts,
       FT_SetFlowControl,
       FT_SetDtr,
       FT_ClrDtr,
       FT_SetRts,
       FT_ClrRts,
       FT_GetModemStatus,
       FT_GetQueueStatus,
       FT_GetDeviceInfo,
       FT_GetDriverVersion,
       FT_GetLibraryVersion,
       FT_GetStatus,
       FT_SetEventNotification,
       FT_SetChars,
       FT_SetBreakOn,
       FT_SetBreakOff,
       FT_Purge,
       FT_ResetDevice,
       FT_StopInTask,
       FT_RestartInTask,
       FT_GetLatencyTimer,
       FT_SetLatencyTimer,
       FT_SetBitMode,
       FT_GetBitMode,
       FT_SetUSBParameters

using Libdl
using libftd2xx_jll

# Type Aliases
# 
const DWORD     = UInt32
const ULONG     = UInt64
const USHORT    = UInt16
const UCHAR     = UInt8
const FT_STATUS = DWORD

# Library Constants
#

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

# FT_SetFlowControl Flow Control Flags
const FT_FLOW_NONE            = 0x0000
const FT_FLOW_RTS_CTS         = 0x0100
const FT_FLOW_DTR_DSR         = 0x0200
const FT_FLOW_XON_XOFF        = 0x0400

# FT_SetEventNotification Event Flags (not yet implemented)
const FT_EVENT_RXCHAR         = 1
const FT_EVENT_MODEM_STATUS   = 2
const FT_EVENT_LINE_STATUS    = 4
@enum(
  FT_EVENT_ENUM,
  FT_EVENT_RXCHAR,
  FT_EVENT_MODEM_STATUS,
  FT_EVENT_LINE_STATUS)

# FT_Purge Flags
const FT_PURGE_RX = 1
const FT_PURGE_TX = 2

# Mode Flags
const FT_MODE_RESET          = 0x00
const FT_MODE_ASYNC_BITBANG  = 0x01
const FT_MODE_MPSSE          = 0x02
const FT_MODE_SYNC_BITBANG   = 0x04
const FT_MODE_MCU_EMULATION  = 0x08
const FT_MODE_FAST_OPTO      = 0x10
const FT_MODE_CBUS_BITBANG   = 0x20
const FT_MODE_SCS_FIFO       = 0x40
@enum(
  FT_MODE_ENUM,
  FT_MODE_RESET,
  FT_MODE_ASYNC_BITBANG,
  FT_MODE_MPSSE,
  FT_MODE_SYNC_BITBANG,
  FT_MODE_MCU_EMULATION,
  FT_MODE_FAST_OPTO,
  FT_MODE_CBUS_BITBANG,
  FT_MODE_SCS_FIFO)

# FT_STATUS Return Values
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

# Types
# 

"""
    struct FT_DEVICE_LIST_INFO_NODE

Julia language representation of the `FT_DEVICE_LIST_INFO_NODE` structure which 
is passed to `FT_GetDeviceInfoList`.

Pre-allocated arrays of `Cchar` (in julia, represented as `NTuple{L, Cchar}`) 
are filled by `FT_GetDeviceInfoList` with null terminated strings. They can be 
converted to julia strings using [`ntuple2string`](@ref).
"""
struct FT_DEVICE_LIST_INFO_NODE
  flags::DWORD
  typ::DWORD
  id::DWORD
  locid::DWORD
  serialnumber::NTuple{16, Cchar}
  description::NTuple{64, Cchar}
  fthandle_ptr::Ptr{Cvoid}
end

"""
    mutable struct FT_HANDLE <: IO

Holds a handle to an FT D2XX device.
"""
mutable struct FT_HANDLE <: IO
  p::Ptr{Cvoid} 
end

"""
    FT_HANDLE()

Constructs a handle to an FT D2XX device that points to `C_NULL`. Initialsed 
with a finalizer that calls [`destroy!`](@ref).
"""
function FT_HANDLE()
  handle = FT_HANDLE(C_NULL)
  finalizer(destroy!, handle)
  handle
end

"""
    destroy!(handle::FT_HANDLE)

Destructor for the [`FT_HANDLE`](@ref) type.
"""
function destroy!(handle::FT_HANDLE)
  if _ptr(handle) != C_NULL
    FT_Close(handle)
  end
end

## Type Accessors
#

"""
    _ptr(handle::FT_HANDLE)

Get the raw pointer for an [`FT_HANDLE`](@ref).
"""
_ptr(handle::FT_HANDLE) = handle.p

"""
    _ptr(handle::FT_HANDLE, fthandle_ptr::Ptr{Cvoid})

Set the raw pointer for an [`FT_HANDLE`](@ref).
"""
_ptr(handle::FT_HANDLE, fthandle_ptr::Ptr{Cvoid}) = (handle.p = fthandle_ptr)

# Utility functions
#

# Internal use only
function check(status::FT_STATUS) 
  FT_STATUS_ENUM(status) == FT_OK ||  throw(FT_STATUS_ENUM(status))
end

# wrapper functions
#

"""
    FT_CreateDeviceInfoList()

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
  status = ccall((:FT_CreateDeviceInfoList, libftd2xx), cdecl, FT_STATUS, 
                 (Ref{DWORD},),
                 lpdwNumDevs)
  check(status)
  lpdwNumDevs[]
end


"""
    FT_GetDeviceInfoList(lpdwNumDevs)

# Arguments
 - `lpdwNumDevs`: The number of devices.

# Example
```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> devinfolist, numdevs = FT_GetDeviceInfoList(numdevs);

julia> numdevs
0x00000004

julia> using LibFTD2XX.Util # for ntuple2string

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
  pDest =  Vector{FT_DEVICE_LIST_INFO_NODE}(undef, lpdwNumDevs)
  status = ccall((:FT_GetDeviceInfoList, libftd2xx), cdecl, FT_STATUS, 
                 (Ref{FT_DEVICE_LIST_INFO_NODE}, Ref{DWORD}),
                  pDest,                         Ref{DWORD}(lpdwNumDevs))
  check(status)
  pDest, lpdwNumDevs
end


"""
    FT_GetDeviceInfoDetail(dwIndex)

# Arguments
 - `dwIndex`: Index of entry in the device info list.

# Example
```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0) # zero indexed
(0, 0x00000002, 0x00000007, 0x04036011, 0x00000000, "FT3AD2HCD", "USB <-> Serial Converter D", FT_HANDLE(Ptr{Nothing} @0x0000000000000000))
```
"""
function FT_GetDeviceInfoDetail(dwIndex)
  lpdwFlags, lpdwType  = Ref{DWORD}(), Ref{DWORD}()
  lpdwID,    lpdwLocId = Ref{DWORD}(), Ref{DWORD}()
  pcSerialNumber = pointer(Vector{Cchar}(undef, 16))
  pcDescription  = pointer(Vector{Cchar}(undef, 64))
  ftHandle = FT_HANDLE()
  
  status = ccall((:FT_GetDeviceInfoDetail, libftd2xx), cdecl, FT_STATUS, 
  (DWORD,   Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Ref{DWORD}, Cstring,        Cstring,       Ref{FT_HANDLE}),
   dwIndex, lpdwFlags,  lpdwType,   lpdwID,     lpdwLocId,  pcSerialNumber, pcDescription, ftHandle)
  
  check(status)
  dwIndex[], lpdwFlags[], lpdwType[], lpdwID[], lpdwLocId[], unsafe_string(pcSerialNumber), unsafe_string(pcDescription), ftHandle
end


"""
    FT_ListDevices(pvArg1, pvArg2, dwFlags)

**NOT FULLY FUNCTIONAL: NOT RECOMMENDED FOR USE**.

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
Ptr{Int8} @0x0000000004f2e530

julia> FT_ListDevices(devidx, buffer, FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER)
ERROR: FT_ListDevices wrapper does not yet flags other than FT_LIST_NUMBER_ONLY.
Stacktrace:
...

```
"""
function FT_ListDevices(pvArg1, pvArg2, dwFlags)
  dwFlags == FT_LIST_NUMBER_ONLY || throw(ErrorException("FT_ListDevices wrapper does not yet flags other than FT_LIST_NUMBER_ONLY."))
  flagsarg = DWORD(dwFlags)
  status = ccall((:FT_ListDevices, libftd2xx), cdecl, FT_STATUS, 
                 (Ptr{Cvoid}, Ptr{Cvoid}, DWORD),
                  pvArg1,     pvArg2,     dwFlags)
  check(status)
  return
end


"""
    FT_Open(iDevice)

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
  status = ccall((:FT_Open, libftd2xx), cdecl, FT_STATUS, (Int,     Ref{FT_HANDLE}),
                                                     iDevice, ftHandle)
  if FT_STATUS_ENUM(status) != FT_OK
    _ptr(ftHandle, C_NULL)
    throw(FT_STATUS_ENUM(status))
  end
  ftHandle
end


"""
    FT_OpenEx(pvArg1::AbstractString, dwFlags::Integer)

# Arguments
 - `pvArg1::AbstractString` : Either description or serial number depending on 
   `dwFlags`.
 - `dwFlags::Integer` : FT_OPEN_BY_DESCRIPTION or FT_OPEN_BY_SERIAL_NUMBER. 
   Note that FT_OPEN_BY_LOCATION is not currently supported.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0)
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
  status = ccall((:FT_OpenEx, libftd2xx), cdecl, FT_STATUS, 
                 (Cstring , DWORD,    Ref{FT_HANDLE}),
                  pvArg1,   flagsarg, handle)
  if FT_STATUS_ENUM(status) != FT_OK
    _ptr(handle, C_NULL)
    throw(FT_STATUS_ENUM(status))
  end
  handle
end


"""
    FT_Close(ftHandle::FT_HANDLE)

Closes an open device and sets the pointer to C_NULL.

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
  status = ccall((:FT_Close, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE, ),
                                                      ftHandle)
  check(status)
  _ptr(ftHandle, C_NULL)
  return
end


"""
    FT_Read(ftHandle::FT_HANDLE, lpBuffer::AbstractVector{UInt8}, dwBytesToRead::Integer)

Returns number of bytes read.

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
  status = ccall((:FT_Read, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD,         Ref{DWORD}),
                 ftHandle,   lpBuffer,   dwBytesToRead, lpdwBytesReturned)
  check(status)
  lpdwBytesReturned[]
end


"""
    FT_Write(ftHandle::FT_HANDLE, lpBuffer::Vector{UInt8}, dwBytesToWrite::Integer)

Returns number of bytes written.

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
  status = ccall((:FT_Write, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UInt8}, DWORD,          Ref{DWORD}),
                  ftHandle,  lpBuffer,   dwBytesToWrite, lpdwBytesWritten)
  check(status)
  lpdwBytesWritten[]
end


"""
    FT_SetBaudRate(ftHandle::FT_HANDLE, dwBaudRate::Integer)

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
  status = ccall((:FT_SetBaudRate, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD),
                  ftHandle,    dwBaudRate)
  check(status)
  return
end


"""
    FT_SetDataCharacteristics(ftHandle::FT_HANDLE, uWordLength, uStopBits, uParity)

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
  status = ccall((:FT_SetDataCharacteristics, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, UCHAR,       UCHAR,     UCHAR),
                  ftHandle,  uWordLength, uStopBits, uParity)
  check(status)
  return
end


"""
    FT_SetTimeouts(ftHandle::FT_HANDLE, dwReadTimeout, dwWriteTimeout)

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
  status = ccall((:FT_SetTimeouts, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD,         DWORD,),
                  ftHandle,  dwReadTimeout, dwWriteTimeout)
  check(status)
  return
end


"""
    FT_SetFlowControl(ftHandle::FT_HANDLE, usFlowControl, uXon, uXoff)

# Arguments
 - `ftHandle` : device handle
 - `usFlowControl` : 
 - `uXon` : 
 - `uXoff` : 

# Example

"""
function FT_SetFlowControl(ftHandle::FT_HANDLE, usFlowControl, uXon, uXoff)
  @assert any(usFlowControl.==[FT_FLOW_NONE,FT_FLOW_RTS_CTS,FT_FLOW_DTR_DSR,FT_FLOW_XON_XOFF])
  status = ccall((:FT_SetFlowControl, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, USHORT,        UCHAR, UCHAR,),
                  ftHandle,  usFlowControl, uXon,  uXoff)
  check(status)
  return
end


"""
    FT_SetDtr(ftHandle::FT_HANDLE)

# Example

"""
function FT_SetDtr(ftHandle::FT_HANDLE)
  status = ccall((:FT_SetDtr, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE,),
                  ftHandle,)
  check(status)
  return
end


"""
    FT_ClrDtr(ftHandle::FT_HANDLE)

# Example

"""
function FT_ClrDtr(ftHandle::FT_HANDLE)
  status = ccall((:FT_ClrDtr, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE,),
                  ftHandle,)
  check(status)
  return
end


"""
    FT_SetRts(ftHandle::FT_HANDLE)

# Example

"""
function FT_SetRts(ftHandle::FT_HANDLE)
  status = ccall((:FT_SetRts, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE,),
                  ftHandle,)
  check(status)
  return
end


"""
    FT_ClrRts(ftHandle::FT_HANDLE)

# Example

"""
function FT_ClrRts(ftHandle::FT_HANDLE)
  status = ccall((:FT_ClrRts, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE,),
                  ftHandle,)
  check(status)
  return
end


"""
    FT_GetModemStatus(ftHandle::FT_HANDLE)

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
  status = ccall((:FT_GetModemStatus, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{DWORD}),
                  ftHandle,  lpdwModemStatus)
  check(status)
  lpdwModemStatus[]
end


"""
    FT_GetQueueStatus(ftHandle::FT_HANDLE)

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
  status = ccall((:FT_GetQueueStatus, libftd2xx), cdecl, FT_STATUS, 
                  (FT_HANDLE, Ref{DWORD}),
                   ftHandle,  lpdwAmountInRxQueue)
  check(status)
  lpdwAmountInRxQueue[]
end


"""
    FT_GetDeviceInfo(ftHandle::FT_HANDLE)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> typ, id, serialnumber, description = FT_GetDeviceInfo(handle);

julia> FT_Close(handle)
```
"""
function FT_GetDeviceInfo(ftHandle::FT_HANDLE)
  pftType = Ref{FT_DEVICE}()
  lpdwID = Ref{DWORD}()
  pcSerialNumber = pointer(Vector{Cchar}(undef, 16))
  pcDescription  = pointer(Vector{Cchar}(undef, 64))
  pvDummy = C_NULL

  status = ccall((:FT_GetDeviceInfo, libftd2xx), cdecl, FT_STATUS, 
  (FT_HANDLE, Ref{FT_DEVICE}, Ref{DWORD}, Cstring,        Cstring,       Ptr{Cvoid}),
   ftHandle,  pftType,        lpdwID,     pcSerialNumber, pcDescription, pvDummy)
  
  check(status)
  pftType[], lpdwID[], unsafe_string(pcSerialNumber), unsafe_string(pcDescription)
end


if Sys.iswindows()

  """
      FT_GetDriverVersion(ftHandle::FT_HANDLE)

  # Example

  ```julia-repl
  julia> numdevs = FT_CreateDeviceInfoList()
  0x00000004

  julia> handle = FT_Open(0)
  FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

  julia> version = FT_GetDriverVersion(handle)
  0x00021212

  julia> patch = version & 0xFF
  0x00000012

  julia> minor = (version >> 8) & 0xFF
  0x00000012

  julia> major = (version >> 16) & 0xFF
  0x00000002

  julia> VersionNumber(major,minor,patch)
  v"2.18.18"

  julia> FT_Close(handle)
  ```
  """
  function FT_GetDriverVersion(ftHandle::FT_HANDLE)
    lpdwDriverVersion = Ref{DWORD}()
    status = ccall((:FT_GetDriverVersion, libftd2xx), cdecl, FT_STATUS, 
                  (FT_HANDLE, Ref{DWORD}),
                    ftHandle,  lpdwDriverVersion)
    check(status)
    lpdwDriverVersion[]
  end


  """
      FT_GetLibraryVersion()

  # Example

  ```julia-repl

  julia> version = FT_GetLibraryVersion()
  0x00021212

  julia> patch = version & 0xFF
  0x00000012

  julia> minor = (version >> 8) & 0xFF
  0x00000012

  julia> major = (version >> 16) & 0xFF
  0x00000002

  julia> VersionNumber(major,minor,patch)
  v"2.18.18"
  ```
  """
  function FT_GetLibraryVersion()
    lpdwDLLVersion = Ref{DWORD}()
    status = ccall((:FT_GetLibraryVersion, libftd2xx), cdecl, FT_STATUS, 
                  (Ref{DWORD},),
                    lpdwDLLVersion)
    check(status)
    version = lpdwDLLVersion[]
  end

end # Sys.iswindows()


"""
    FT_GetStatus(ftHandle::FT_HANDLE)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> nbrx, nbtx, eventstatus = FT_GetStatus(handle)
(0x00000000, 0x00000000, 0x00000000)

julia> FT_Close(handle)
```
"""
function FT_GetStatus(ftHandle::FT_HANDLE)
  lpdwAmountInRxQueue, lpdwAmountInTxQueue  = Ref{DWORD}(), Ref{DWORD}()
  lpdwEventStatus = Ref{DWORD}()
  status = ccall((:FT_GetStatus, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{DWORD},          Ref{DWORD},          Ref{DWORD}),
                  ftHandle,  lpdwAmountInRxQueue, lpdwAmountInTxQueue, lpdwEventStatus)
  check(status)
  lpdwAmountInRxQueue[], lpdwAmountInTxQueue[], lpdwEventStatus[]
end


"""
    FT_SetEventNotification(ftHandle::FT_HANDLE, dwEventMask, pvArg)

Sets conditions for event notification.

An application can use this function to setup conditions which allow a thread to block 
until one of the conditions is met. Typically, an application will create an event, 
call this function, then block on the event. When the conditions are met, the event is set,
and the application thread unblocked. `dwEventMask` is a bit-map that describes the events
the application is interested in. `pvArg` is interpreted as the handle of an event which 
has been created by the application. If one of the event conditions is met, the event is 
set. If `dwEventMask=FT_EVENT_RXCHAR`, the event will be set when a character has been 
received by the device. If `dwEventMask=FT_EVENT_MODEM_STATUS`, the event will be set when 
a change in the modem signals has been detected by the device.
If `dwEventMask=FT_EVENT_LINE_STATUS`, the event will be set when a change in the line 
status has been detected by the device.
"""
function FT_SetEventNotification(ftHandle::FT_HANDLE, dwEventMask, pvArg)
  @assert dwEventMask in FT_EVENT_ENUM
  status = ccall((:FT_SetEventNotification, libftd2xx), cdecl, FT_STATUS,
                 (FT_HANDLE, DWORD,       Ptr{Cvoid}),
                  ftHandle,  dwEventMask, pvArg)
  check(status)
  return
end


"""
    FT_SetChars(ftHandle::FT_HANDLE, uEventCh, uEventChEn, uErrorCh, uErrorChEn)

This function sets the special characters for the device.

This function allows for inserting specified characters in the data stream to represent 
events firing or errors occurring.
"""
function FT_SetChars(ftHandle::FT_HANDLE, uEventCh, uEventChEn, uErrorCh, uErrorChEn)
  status = ccall((:FT_SetChars, libftd2xx), cdecl, FT_STATUS,
                 (FT_HANDLE, UCHAR,    UCHAR,      UCHAR,    UCHAR,),
                  ftHandle,  uEventCh, uEventChEn, uErrorCh, uErrorChEn)
  check(status)
  return
end


"""
    FT_SetBreakOn(ftHandle::FT_HANDLE)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetBreakOn(handle) # break now on...

julia> FT_Close(handle)
```
"""
function FT_SetBreakOn(ftHandle::FT_HANDLE)
  status = ccall((:FT_SetBreakOn, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE,),
                                                           ftHandle)
  check(status)
  return
end


"""
    FT_SetBreakOff(ftHandle::FT_HANDLE)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetBreakOff(handle) # break now off...

julia> FT_Close(handle)
```
"""
function FT_SetBreakOff(ftHandle::FT_HANDLE)
  status = ccall((:FT_SetBreakOff, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE,),
                                                           ftHandle)
  check(status)
  return
end


"""
    FT_Purge(ftHandle::FT_HANDLE, dwMask)

# Arguments
 - `ftHandle::FT_HANDLE` : handle to open device
 - `dwMask` : must be `FT_PURGE_RX`, `FT_PURGE_TX` or 
   `FT_PURGE_TX | FT_PURGE_RX`.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_Purge(handle, FT_PURGE_RX|FT_PURGE_TX)

julia> nbrx, nbtx, eventstatus = FT_GetStatus(handle) # All queues empty!
(0x00000000, 0x00000000, 0x00000000)

julia> FT_Close(handle)
```
"""
function FT_Purge(ftHandle::FT_HANDLE, dwMask)
  @assert (dwMask == FT_PURGE_RX) || (dwMask == FT_PURGE_TX) || 
          (dwMask == FT_PURGE_RX|FT_PURGE_TX)
  status = ccall((:FT_SetBreakOff, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE, DWORD),
                                                           ftHandle,   dwMask)
  check(status)
  return
end


"""
    FT_ResetDevice(ftHandle::FT_HANDLE)

Send a reset command to the device.

# Example
"""
function FT_ResetDevice(ftHandle::FT_HANDLE)
  status = ccall((:FT_ResetDevice, libftd2xx), cdecl, FT_STATUS,
                 (FT_HANDLE,),
                  ftHandle)
  check(status)
  return
end


"""
    FT_StopInTask(ftHandle::FT_HANDLE)

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_StopInTask(handle) # The driver's IN task is now stopped.

julia> FT_RestartInTask(handle) # The driver's IN task is now restarted.

julia> FT_Close(handle)
```
"""
function FT_StopInTask(ftHandle::FT_HANDLE)
  status = ccall((:FT_StopInTask, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE,),
                                                           ftHandle)
  check(status)
  return
end


"""
    FT_RestartInTask(ftHandle::FT_HANDLE)

# Example

See `FT_StopInTask`.
"""
function FT_RestartInTask(ftHandle::FT_HANDLE)
  status = ccall((:FT_RestartInTask, libftd2xx), cdecl, FT_STATUS, (FT_HANDLE,),
                                                           ftHandle)
  check(status)
  return
end


"""
    FT_GetLatencyTimer(ftHandle::FT_HANDLE)

Get the current latency timer in milliseconds.

# Example

See `FT_GetLatencyTimer`.
"""
function FT_GetLatencyTimer(ftHandle::FT_HANDLE)
  pucTimer = Ref{UCHAR}()
  status = ccall((:FT_GetLatencyTimer, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UCHAR}),
                  ftHandle,  pucTimer)
  check(status)
  pucTimer[]
end


"""
    FT_SetLatencyTimer(ftHandle::FT_HANDLE, ucTimer)

Get the current latency timer value in milliseconds.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetLatencyTimer(handle, 0x0A)

julia> FT_GetLatencyTimer(handle)
0x0a

See `FT_GetLatencyTimer`.
"""
function FT_SetLatencyTimer(ftHandle::FT_HANDLE, ucTimer)
  status = ccall((:FT_SetLatencyTimer, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, UCHAR),
                  ftHandle,  ucTimer)
  check(status)
  return
end


"""
    FT_GetBitMode(ftHandle::FT_HANDLE)

Get the current bit mode.

# Example

See `FT_SetBitMode`.
"""
function FT_GetBitMode(ftHandle::FT_HANDLE)
  pucMode = Ref{UCHAR}()
  status = ccall((:FT_GetBitMode, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, Ref{UCHAR}),
                  ftHandle,  pucMode)
  check(status)
  pucMode[]
end


"""
    FT_SetBitMode(ftHandle::FT_HANDLE, ucMask, ucMode)

Enables different chip modes.

`ucMask` sets up which bits are inputs and outputs. A bit value of 0 sets the corresponding
pin to an input, a bit value of 1 sets the corresponding pin to an output. In the case of 
CBUS Bit Bang, the upper nibble of this value controls which pins are inputs and outputs, 
while the lower nibble controls which of the outputs are high and low.

`ucModeMode` sets the chip mode, and must be one of the following: 
0x0 = Reset 
0x1 = Asynchronous Bit Bang 
0x2 = MPSSE (FT2232, FT2232H, FT4232H and FT232H devices only) 
0x4 = Synchronous Bit Bang (FT232R, FT245R,FT2232, FT2232H, FT4232H and FT232H devices only) 
0x8 = MCU Host Bus Emulation Mode (FT2232, FT2232H, FT4232H and FT232H devices only) 
0x10 = FastOpto-Isolated Serial Mode (FT2232, FT2232H, FT4232H and FT232H devices only) 
0x20 = CBUS Bit Bang Mode (FT232Rand FT232H devices only) 
0x40 = Single Channel Synchronous 245 FIFO Mode (FT2232H and FT232H devices only) 

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetBitMode(handle, 0x0F, FT_MODE_ASYNC_BITBANG)

julia> FT_GetBitMode(handle)
0x01

See [`FT_GetBitMode`](@ref).
"""
function FT_SetBitMode(ftHandle::FT_HANDLE, ucMask, ucMode)
  @assert ucMode in FT_MODE_ENUM
  status = ccall((:FT_SetBitMode, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, UCHAR,  UCHAR),
                  ftHandle,  ucMask, ucMode)
  check(status)
  return
end


"""
    FT_SetUSBParameters(ftHandle::FT_HANDLE, dwInTransferSize, dwOutTransferSize)

Set the USB request transfer size.

This function can be used to change the transfer sizes from the default transfer size 
of 4096 bytes to better suit the application requirements. Transfer sizes must be set to a
multiple of 64 bytes between 64 bytes and 64k bytes. When FT_SetUSBParameters is called, 
the change comes into effect immediately and any data that was held in the driver at the 
time of the change is lost. Note that, at present, only dwInTransferSize is supported.

# Example

```julia-repl
julia> numdevs = FT_CreateDeviceInfoList()
0x00000004

julia> handle = FT_Open(0)
FT_HANDLE(Ptr{Nothing} @0x00000000051e56c0)

julia> FT_SetUSBParameters(handle, 16384, 8192)
"""
function FT_SetUSBParameters(ftHandle::FT_HANDLE, dwInTransferSize, dwOutTransferSize)
  @assert 64 <= dwInTransferSize <= 65536
  @assert 64 <= dwOutTransferSize <= 65536
  status = ccall((:FT_SetUSBParameters, libftd2xx), cdecl, FT_STATUS, 
                 (FT_HANDLE, DWORD,            DWORD),
                  ftHandle,  dwInTransferSize, dwOutTransferSize)
  check(status)
  return
end

end # module Wrapper
