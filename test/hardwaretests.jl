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
  local handle
  try
    handle = FT_Open(0)
    @test handle isa FT_HANDLE
    @test isopen(handle)
  catch ex
    rethrow(ex)
  finally
    if isopen(handle)
      close(handle)
    end
  end

  # FT_OpenEx tests...
  try
    handle = FT_OpenEx(description, FT_OPEN_BY_DESCRIPTION)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    close(handle)

    handle = FT_OpenEx(serialnumber, FT_OPEN_BY_SERIAL_NUMBER)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    close(handle)
  catch ex
    rethrow(ex)
  finally
    if isopen(handle)
      close(handle)
    end
  end

  # FT_Close tests...
  try
    handle = FT_Open(0)
    retval = FT_Close(handle)
    @assert retval == nothing
    @assert isopen(handle) == false
  catch ex
    rethrow(ex)
  finally
    if isopen(handle)
      close(handle)
    end
  end

end

