# These tests require an FT device which supports D2XX to be connected 

using LibFTD2XX
using Compat
using Compat.Test
using Test
import Sys.iswindows

@testset "util" begin
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o')))
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o','\0','x')))
end

@testset "wrapper" begin
  
  # FT_CreateDeviceInfoList tests...
  numdevs = FT_CreateDeviceInfoList()
  @test numdevs > 0
  @info "Number of devices is \$numdevs"

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
  idx, flags, type, id, locid, serialnumber, description, fthandle = FT_GetDeviceInfoDetail(0)

  @test idx == devinfolist[1].idx
  @test flags == devinfolist[1].flags
  @test type == devinfolist[1].type
  @test id == devinfolist[1].id
  @test locid == devinfolist[1].locid
  @test ntuple2string(serialnumber) == ntuple2string(devinfolist[1].serialnumber)
  @test ntuple2string(description) == ntuple2string(devinfolist[1].description)
  @test fthandle == devinfolist[1].fthandle

  # FT_GetDeviceInfoDetail tests...
  numdevs2 = Ref{UInt32}()
  FT_ListDevices(numdevs2, Ref{UInt32}(), FT_LIST_NUMBER_ONLY)
  @test numdevs2[] == numdevs

  devidx = Ref{UInt32}(0)
  buffer = pointer(Vector{Cchar}(undef, 64))
  FT_ListDevices(devidx, buffer, FT_LIST_BY_INDEX|FT_OPEN_BY_SERIAL_NUMBER)
  @test ntuple2string(description) == unsafe_string(buffer)

  # FT_Open tests...
  handle = FT_Open(0)
  @test handle isa FT_HANDLE
  @test isopen(handle)

  close(handle)
end

