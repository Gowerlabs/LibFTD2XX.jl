# LibFTD2XX.jl

module LibFTD2XX

# Enums
export FTOpenBy, OPEN_BY_SERIAL_NUMBER, OPEN_BY_DESCRIPTION
export FTWordLength, BITS_8, BITS_7
export FTStopBits, STOP_BITS_1, STOP_BITS_2
export FTParity, PARITY_NONE, PARITY_ODD, PARITY_EVEN, PARITY_MARK, PARITY_SPACE

# Types and Constructors
export FT_HANDLE # Exported by .Wrapper
export D2XXException
export D2XXDevice, D2XXDevices

# Port communication functions
export baudrate, datacharacteristics, status, driverversion

# Library Functions
export libversion

# D2XXDevice Accessor Functions
export deviceidx, deviceflags, devicetype, deviceid, locationid, serialnumber, 
       description, fthandle


include("util.jl")
include("wrapper.jl")


using .Util
using .Wrapper
using Compat


"""
    @enum(
      FTOpenBy,
      OPEN_BY_SERIAL_NUMBER = FT_OPEN_BY_SERIAL_NUMBER,
      OPEN_BY_DESCRIPTION = FT_OPEN_BY_DESCRIPTION)

For use with [`open`](@ref).
"""
@enum(
  FTOpenBy,
  OPEN_BY_SERIAL_NUMBER = FT_OPEN_BY_SERIAL_NUMBER,
  OPEN_BY_DESCRIPTION = FT_OPEN_BY_DESCRIPTION)


"""
    @enum(
      FTWordLength,
      BITS_8 = FT_BITS_8,
      BITS_7 = FT_BITS_7)

For use with [`datacharacteristics`](@ref).
"""
@enum(
  FTWordLength,
  BITS_8 = FT_BITS_8,
  BITS_7 = FT_BITS_7)


"""
    @enum(
      FTStopBits,
      STOP_BITS_1 = FT_STOP_BITS_1,
      STOP_BITS_2 = FT_STOP_BITS_2)

For use with [`datacharacteristics`](@ref).
"""
@enum(
  FTStopBits,
  STOP_BITS_1 = FT_STOP_BITS_1,
  STOP_BITS_2 = FT_STOP_BITS_2)

"""
    @enum(
      FTParity,
      PARITY_NONE = FT_PARITY_NONE,
      PARITY_ODD  = FT_PARITY_ODD,
      PARITY_EVEN = FT_PARITY_EVEN,
      PARITY_MARK = FT_PARITY_MARK,
      PARITY_SPACE = FT_PARITY_SPACE)

For use with [`datacharacteristics`](@ref).
"""
@enum(
  FTParity,
  PARITY_NONE = FT_PARITY_NONE,
  PARITY_ODD  = FT_PARITY_ODD,
  PARITY_EVEN = FT_PARITY_EVEN,
  PARITY_MARK = FT_PARITY_MARK,
  PARITY_SPACE = FT_PARITY_SPACE)


"""
    D2XXException <: Exception

LibFTD2XX High-Level Library Error Type.
"""
struct D2XXException <: Exception
  str::String
end


"""
    mutable struct D2XXDevice <: IO

Device identifier for a D2XX device.

See also: [`D2XXDevices`](@ref), [`deviceidx`](@ref), [`deviceflags`](@ref), 
[`devicetype`](@ref), [`deviceid`](@ref), [`locationid`](@ref), 
[`serialnumber`](@ref), [`description`](@ref), [`fthandle`](@ref).
"""
mutable struct D2XXDevice <: IO
  idx::Int
  flags::Int
  typ::Int
  id::Int
  locid::Int
  serialnumber::String
  description::String
  fthandle::FT_HANDLE
end


# D2XXDevice Constructors
#
"""
    D2XXDevice(deviceidx::Integer)

Construct a `D2XXDevice` without opening it. D2XX hardware must pre present to 
work.
"""
function D2XXDevice(deviceidx::Integer)
  idx, flags, typ, id, locid, serialnumber, description, fthandle = getdeviceinfodetail(deviceidx)
  D2XXDevice(idx, flags, typ, id, locid, serialnumber, description, fthandle)
end


"""
    D2XXDevices()

Returns an array of available D2XX devices of type `D2XXDevice`.

Their state is not modified - if they are already open/closed they remain 
open/closed.

See also: [`D2XXDevice`](@ref), [`open`](@ref)
"""
function D2XXDevices()
  numdevs = createdeviceinfolist()
  devices = D2XXDevice[]
  for i = 0:(numdevs-1)
    push!(devices, D2XXDevice(i))
  end
  devices
end


# Port communication functions
#
"""
    isopen(d::D2XXDevice) -> Bool

See also: [`D2XXDevice`](@ref)
"""
Base.isopen(d::D2XXDevice) = isopen(fthandle(d))

"""
    isopen(handle::FT_HANDLE) -> Bool

See also: [`FT_HANDLE`](@ref)
"""
function Base.isopen(handle::FT_HANDLE)
  open = true
  if ptr(handle) == C_NULL
    open = false
  else
    try
      FT_GetModemStatus(handle)
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


"""
    Base.open(d::D2XXDevice)

Open a [`D2XXDevice`](@ref) for reading and writing using [`FT_OpenEx`](@ref).
Cannot be used to open the same device twice.

See also: [`isopen`](@ref), [`close`](@ref)
"""
function Base.open(d::D2XXDevice)
  isopen(d) && throw(D2XXException("Device already open."))
  d.fthandle = FT_Open(deviceidx(d))
  return
end

"""
    open(str::AbstractString, openby::FTOpenBy) -> FT_HANDLE

Create an open [`FT_HANDLE`](@ref) for reading and writing using 
[`FT_OpenEx`](@ref). Cannot be used to open the same device twice.

# Arguments
 - `str::AbstractString` : Device identifier. Type depends on `openby`
 - `openby::FTOpenBy` : Indicator of device identifier `str` type.

See also: [`isopen`](@ref), [`close`](@ref)
"""
function Base.open(str::AbstractString, openby::FTOpenBy)
  try
    FT_OpenEx(str, DWORD(openby))
  catch ex
    if (ex == FT_DEVICE_NOT_OPENED) || (ex == FT_DEVICE_NOT_FOUND)
      throw(D2XXException("Device already open."))
    else
      rethrow(ex)
    end
  end
end


"""
    close(d::D2XXDevice)

Close a [`D2XXDevice`](@ref) using [`FT_Close`](@ref). Does not perform a 
[`flush`](@ref) first.
"""
Base.close(d::D2XXDevice) = close(fthandle(d))

"""
    close(handle::FT_HANDLE)

Close an [`FT_HANDLE`](@ref) using [`FT_Close`](@ref). Does not perform a 
[`flush`](@ref) first.
"""
function Base.close(handle::FT_HANDLE)
  if isopen(handle)
    FT_Close(handle)
  end
  return
end

"""
    bytesavailable(d::D2XXDevice)

See also: [`D2XXDevice`](@ref), [`isopen`](@ref), [`open`](@ref), 
[`readavailable`](@ref), [`read`](@ref)
"""
Compat.bytesavailable(d::D2XXDevice) = bytesavailable(fthandle(d))

"""
    bytesavailable(handle::FT_HANDLE)

See also: [`FT_HANDLE`](@ref), [`isopen`](@ref), [`open`](@ref), 
[`readavailable`](@ref), [`read`](@ref)
"""
function Compat.bytesavailable(handle::FT_HANDLE)
  isopen(handle) || throw(D2XXException("Device must be open to check bytes available."))
  FT_GetQueueStatus(handle)
end

"""
    eof(d::D2XXDevice) -> Bool

Indicates if any bytes are available to be read from an open 
[`D2XXDevice`](@ref). Non-blocking.

See also: [`isopen`](@ref), [`open`](@ref), 
[`readavailable`](@ref), [`read`](@ref)
"""
Base.eof(d::D2XXDevice) = eof(fthandle(d))

"""
    eof(d::D2XXDevice) -> Bool

Indicates if any bytes are available to be read from an open 
[`FT_HANDLE`](@ref). Non-blocking.

See also: [`isopen`](@ref), [`open`](@ref), 
[`readavailable`](@ref), [`read`](@ref)
"""
Base.eof(handle::FT_HANDLE) = (bytesavailable(handle) == 0)


"""
    readbytes!(d::D2XXDevice, b::AbstractVector{UInt8}, nb=length(b))

See also: [`D2XXDevice`](@ref).
"""
Base.readbytes!(d::D2XXDevice, b::AbstractVector{UInt8}, nb=length(b)) =
readbytes!(fthandle(d), b, nb)

"""
    readbytes!(handle::FT_HANDLE, b::AbstractVector{UInt8}, nb=length(b))

See also: [`FT_HANDLE`](@ref)
"""
function Base.readbytes!(handle::FT_HANDLE, b::AbstractVector{UInt8}, nb=length(b))
  isopen(handle) || throw(D2XXException("Device must be open to read."))
  nbav = bytesavailable(handle)
  if nbav < nb
    nb = nbav
  end
  if length(b) < nb
    resize!(b, nb)
  end
  nbrx = FT_Read(handle, b, nb)
end


"""
    readavailable(d::D2XXDevice)

Read all available data from an open [`D2XXDevice`](@ref). Does not block if 
nothing is available.
"""
Base.readavailable(d::D2XXDevice) = readavailable(fthandle(d))

"""
    readavailable(handle::FT_HANDLE)

Read all available data from an open [`FT_HANDLE`](@ref). Does not block if 
nothing is available.

See also: [`readbytes`](@ref) [`isopen`](@ref), [`open`](@ref)
"""
function Base.readavailable(handle::FT_HANDLE)
  b = @compat Vector{UInt8}(undef, bytesavailable(handle))
  readbytes!(handle, b)
  b
end


"""
    write(d::D2XXDevice, buffer::Vector{UInt8})

Write `buffer` to an open [`D2XXDevice`](@ref) using [`FT_Write`](@ref).
"""
Base.write(d::D2XXDevice, buffer::Vector{UInt8}) = write(fthandle(d), buffer)

"""
    write(handle::FT_HANDLE, buffer::Vector{UInt8})

Write `buffer` to an open [`FT_HANDLE`](@ref) using [`FT_Write`](@ref).

See also: [`isopen`](@ref), [`open`](@ref)
"""
function Base.write(handle::FT_HANDLE, buffer::Vector{UInt8})
  isopen(handle) || throw(D2XXException("Device must be open to write."))
  FT_Write(handle, buffer, length(buffer))
end


"""
    baudrate(d::D2XXDevice, baud)

Set the baudrate of an open [`D2XXDevice`](@ref) using [`FT_SetBaudRate`](@ref).
"""
baudrate(d::D2XXDevice, baud) = baudrate(fthandle(d), baud)

"""
    baudrate(handle::FT_HANDLE, baud)

Set the baudrate of an open [`FT_HANDLE`](@ref) to `baud` using 
[`FT_SetBaudRate`](@ref).

See also: [`isopen`](@ref), [`open`](@ref)
"""
function baudrate(handle::FT_HANDLE, baud)
  isopen(handle) || throw(D2XXException("Device must be open to set baudrate."))
  FT_SetBaudRate(handle, baud)
end


"""
    datacharacteristics(d::D2XXDevice; 
                        wordlength::FTWordLength = BITS_8, 
                        stopbits::FTStopBits = STOP_BITS_1, 
                        parity::FTParity = PARITY_NONE)

Set the transmission and reception data characteristics for an open 
[`D2XXDevice`](@ref) using [`FT_SetDataCharacteristics`](@ref).

# Arguments
 - `wordlength::FTWordLength` : Either BITS_7 or BITS_8
 - `stopbits::FTStopBits` : Either STOP_BITS_1 or STOP_BITS_2
 - `parity::FTParity` : PARITY_NONE, PARITY_ODD, PARITY_EVEN, PARITY_MARK, or 
   PARITY_SPACE
"""
datacharacteristics(d::D2XXDevice; 
                    wordlength::FTWordLength = BITS_8, 
                    stopbits::FTStopBits = STOP_BITS_1, 
                    parity::FTParity = PARITY_NONE) = 
datacharacteristics(fthandle(d), 
                    wordlength=wordlength, 
                    stopbits=stopbits, 
                    parity=parity)

"""
    datacharacteristics(handle::FT_HANDLE;
                        wordlength::FTWordLength = BITS_8, 
                        stopbits::FTStopBits = STOP_BITS_1, 
                        parity::FTParity = PARITY_NONE)

Set the transmission and reception data characteristics for an open 
[`FT_HANDLE`](@ref) using [`FT_SetDataCharacteristics`](@ref).

See also: [`isopen`](@ref), [`open`](@ref)
"""
function datacharacteristics(handle::FT_HANDLE; 
                             wordlength::FTWordLength = BITS_8, 
                             stopbits::FTStopBits = STOP_BITS_1, 
                             parity::FTParity = PARITY_NONE)
isopen(handle) || throw(D2XXException("Device must be open to set data characteristics."))
FT_SetDataCharacteristics(handle, DWORD(wordlength), DWORD(stopbits), DWORD(parity))
end


"""
    status(d::D2XXDevice) ->
      mflaglist::Dict{String, Bool}, lflaglist::Dict{String, Bool}

Return `Bool` dictionaries of flags for  the modem status (`mflaglist`) and 
line status (`lflaglist`) for an open [`D2XXDevice`](@ref) using 
[`FT_GetModemStatus`](@ref).
"""
status(d::D2XXDevice) = status(fthandle(d))

"""
    status(d::D2XXDevice) ->
      mflaglist::Dict{String, Bool}, lflaglist::Dict{String, Bool}

Return `Bool` dictionaries of flags for  the modem status (`mflaglist`) and 
line status (`lflaglist`) for an open [`FT_HANDLE`](@ref) using 
[`FT_GetModemStatus`](@ref).

See also: [`isopen`](@ref), [`open`](@ref)
"""
function status(handle::FT_HANDLE)
  isopen(handle) || throw(D2XXException("Device must be open to check status."))
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
    driverversion(d::D2XXDevice)

Get the driver version for an open [`D2XXDevice`](@ref) using 
[`FT_GetDriverVersion`](@ref)
"""
driverversion(d::D2XXDevice) = driverversion(fthandle(d))

"""
    driverversion(handle::FT_HANDLE)

Get the driver version for an open [`FT_HANDLE`](@ref) using 
[`FT_GetDriverVersion`](@ref)

See also: [`isopen`](@ref), [`open`](@ref)
"""
function driverversion(handle::FT_HANDLE)
  isopen(handle) || throw(D2XXException("Device must be open to check driver version"))
  version = FT_GetDriverVersion(handle)
  @assert (version >> 24) & 0xFF == 0x00 # 4th byte should be 0 according to docs
  patch = version & 0xFF
  minor = (version >> 8) & 0xFF
  major = (version >> 16) & 0xFF
  VersionNumber(major,minor,patch)
end


"""
    flush(d::D2XXDevice)

Clear the transmit and receive buffers for an open [`D2XXDevice`](@ref).
"""
Base.flush(d::D2XXDevice) = flush(fthandle(d))

"""
    flush(handle::FT_HANDLE)

Clear the transmit and receive buffers for an open [`FT_HANDLE`](@ref).

See also: [`isopen`](@ref), [`open`](@ref), [`bytesavailable`](@ref)
"""
function Base.flush(handle::FT_HANDLE)
  isopen(handle) || throw(D2XXException("Device must be open to flush."))
  FT_StopInTask(handle)
  FT_Purge(handle, FT_PURGE_RX|FT_PURGE_RX)
  FT_RestartInTask(handle)
end


# Other Functions
#
function createdeviceinfolist()
  numdevs = FT_CreateDeviceInfoList()
end


function getdeviceinfodetail(deviceidx)
  0 <= deviceidx < createdeviceinfolist() || throw(D2XXException("Device index $deviceidx not in range."))
  idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(deviceidx)
end


# Library Functions
#
"""
    libversion()

Get a version number from a call to [`FT_GetLibraryVersion`](@ref).
"""
function libversion()
  version = FT_GetLibraryVersion()
  @assert (version >> 24) & 0xFF == 0x00 # 4th byte should be 0 according to docs
  patch = version & 0xFF
  minor = (version >> 8) & 0xFF
  major = (version >> 16) & 0xFF
  VersionNumber(major,minor,patch)
end


# D2XXDevice Accessor Functions
#
"""
    deviceidx(d::D2XXDevice)

Get D2XXDevice index.

See also: [`D2XXDevice`](@ref)
"""
deviceidx(d::D2XXDevice) = d.idx


"""
    deviceflags(d::D2XXDevice)

Get the D2XXDevice flags list.

See also: [`D2XXDevice`](@ref)
"""
deviceflags(d::D2XXDevice) = d.flags


"""
    devicetype(d::D2XXDevice)

Get the D2XXDevice device type.

See also: [`D2XXDevice`](@ref)
"""
devicetype(d::D2XXDevice) = d.typ


"""
  deviceid(d::D2XXDevice)

Get the D2XXDevice device id.

See also: [`D2XXDevice`](@ref)
"""
deviceid(d::D2XXDevice) = d.id


"""
    locationid(d::D2XXDevice)

Get the D2XXDevice location id. This is zero for windows devices.

See also: [`D2XXDevice`](@ref)
"""
locationid(d::D2XXDevice) = d.locid


"""
    serialnumber(d::D2XXDevice)

Get the D2XXDevice device serial number.

See also: [`D2XXDevice`](@ref)
"""
serialnumber(d::D2XXDevice) = d.serialnumber


"""
    description(d::D2XXDevice)

Get the D2XXDevice device description.

See also: [`D2XXDevice`](@ref)
"""
description(d::D2XXDevice) = d.description


"""
    fthandle(d::D2XXDevice)

Get the D2XXDevice device D2XX handle of type ::FT_HANDLE`.

See also: [`D2XXDevice`](@ref)
"""
fthandle(d::D2XXDevice) = d.fthandle

end # module LibFTD2XX