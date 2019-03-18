# These tests require an FT device which supports D2XX to be connected 

using LibFTD2XX
using Compat
using Compat.Test
using Test

@testset "util" begin
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o')))
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o','\0','x')))
end

@testset "wrapper" begin
  
  # FT_CreateDeviceInfoList tests...
  numdevs = FT_CreateDeviceInfoList()
  @test numdevs > 0
  @info "Number of devices is $numdevs"

  # FT_GetDeviceInfoList tests...
  devinfolist, numdevs2 = FT_GetDeviceInfoList(numdevs)
  @test numdevs2 == numdevs
  @test length(devinfolist) == numdevs
  
  description = ntuple2string(devinfolist[1].description)
  @info "testing device $description"

  if Sys.iswindows() # should not have a locid on windows
    @test devinfolist[1].locid == 0
  end

  # FT_GetDeviceInfoDetail tests...
  idx, flags, typ, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0)

  @test idx == 0
  @test flags == devinfolist[1].flags
  @test typ == devinfolist[1].typ
  @test id == devinfolist[1].id
  @test locid == devinfolist[1].locid
  @test serialnumber == ntuple2string(devinfolist[1].serialnumber)
  @test description == ntuple2string(devinfolist[1].description)
  @test LibFTD2XX.ptr(fthandle) == devinfolist[1].fthandle_ptr

  # FT_GetDeviceInfoDetail tests...
  numdevs2 = Ref{UInt32}()
  retval = FT_ListDevices(numdevs2, Ref{UInt32}(), FT_LIST_NUMBER_ONLY)
  @test retval == nothing
  @test numdevs2[] == numdevs

  # devidx = Ref{UInt32}(0)
  # buffer = pointer(Vector{Cchar}(undef, 64))
  # FT_ListDevices(devidx, buffer, FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER)
  # @test ntuple2string(description) == unsafe_string(buffer)

  # FT_Open tests...
  handle = FT_Open(0)
  @test handle isa FT_HANDLE
  @test LibFTD2XX.ptr(handle) != C_NULL
  FT_Close(handle)

  # FT_OpenEx tests...
  # by description
  handle = FT_OpenEx(description, FT_OPEN_BY_DESCRIPTION)
  @test handle isa FT_HANDLE
  @test LibFTD2XX.ptr(handle) != C_NULL
  FT_Close(handle)
  # by serialnumber
  handle = FT_OpenEx(serialnumber, FT_OPEN_BY_SERIAL_NUMBER)
  @test handle isa FT_HANDLE
  @test LibFTD2XX.ptr(handle) != C_NULL
  FT_Close(handle)

  # FT_Close tests...
  handle = FT_Open(0)
  retval = FT_Close(handle)
  @test retval == nothing
  @test_throws FT_STATUS_ENUM FT_Close(handle) # can't close twice...

  # FT_Read tests...
  handle = FT_Open(0)
  buffer = zeros(UInt8, 5)
  nread = FT_Read(handle, buffer, 0) # read 0 bytes
  @test nread == 0
  @test buffer == zeros(UInt8, 5)
  @test_throws AssertionError FT_Read(handle, buffer, 6) # read 5 bytes
  @test_throws AssertionError FT_Read(handle, buffer, -1) # read -1 bytes
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_Read(handle, buffer, 0)

  # FT_Write tests...
  handle = FT_Open(0)
  buffer = ones(UInt8, 5)
  nwr = FT_Write(handle, buffer, 0) # write 0 bytes
  @test nwr == 0
  @test buffer == ones(UInt8, 5)
  nwr = FT_Write(handle, buffer, 2) # write 2 bytes
  @test nwr == 2
  @test buffer == ones(UInt8, 5)
  @test_throws AssertionError FT_Write(handle, buffer, 6) # write 6 bytes
  @test_throws AssertionError FT_Write(handle, buffer, -1) # write -1 bytes
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_Write(handle, buffer, 0)

  # FT_SetDataCharacteristics tests...
  handle = FT_Open(0)
  retval = FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE)
  @test retval == nothing
  # other combinations...
  FT_SetDataCharacteristics(handle, FT_BITS_7, FT_STOP_BITS_1, FT_PARITY_NONE)
  FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE)
  FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_EVEN)
  FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_ODD)
  FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_MARK)
  FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_SPACE)
  # Bad values
  @test_throws AssertionError FT_SetDataCharacteristics(handle, ~(FT_BITS_8 | FT_BITS_7), FT_STOP_BITS_1, FT_PARITY_NONE)
  @test_throws AssertionError FT_SetDataCharacteristics(handle, FT_BITS_8, ~(FT_STOP_BITS_1 | FT_STOP_BITS_2), FT_PARITY_NONE)
  @test_throws AssertionError FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, ~(FT_PARITY_NONE | FT_PARITY_EVEN))
  # closed handle
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_SetDataCharacteristics(handle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE)

  # FT_SetTimeouts tests...
  handle = FT_Open(0)
  FT_SetBaudRate(handle, 9600)
  timeout_read, timeout_wr = 50, 10 # milliseconds
  FT_SetTimeouts(handle, timeout_read, timeout_wr)
  buffer = zeros(UInt8, 5000);
  tread = @elapsed nread = FT_Read(handle, buffer, 5000)
  twr = @elapsed nwr = FT_Write(handle, buffer, 5000)
  @test tread*1000 < 2*timeout_read
  @test twr*1000 < 2*timeout_wr
  @test_throws InexactError FT_SetTimeouts(handle, timeout_read, -1)
  @test_throws InexactError FT_SetTimeouts(handle, -1, timeout_wr)
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_SetTimeouts(handle, timeout_read, timeout_wr)

  # FT_GetModemStatus tests
  handle = FT_Open(0)
  flags = FT_GetModemStatus(handle)
  @test flags isa LibFTD2XX.DWORD
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_GetModemStatus(handle)

  # FT_GetQueueStatus tests
  handle = FT_Open(0)
  nbrx = FT_GetQueueStatus(handle)
  @test nbrx isa LibFTD2XX.DWORD
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_GetQueueStatus(handle)

  # FT_GetDeviceInfo tests
  id_buf = id
  serialnumber_buf = serialnumber
  description_buf = description
  handle = FT_Open(0)
  type, id, serialnumber, description = FT_GetDeviceInfo(handle)
  @test type isa FT_DEVICE
  @test serialnumber == serialnumber_buf
  @test description == description_buf
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_GetDeviceInfo(handle)

  # FT_GetDriverVersion tests
  handle = FT_Open(0)
  version = FT_GetDriverVersion(handle)
  @test version isa LibFTD2XX.DWORD
  @test version > 0
  FT_Close(handle)
  @test_throws FT_STATUS_ENUM FT_GetDriverVersion(handle)

end

