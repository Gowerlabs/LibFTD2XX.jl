# These tests require an FT device which supports D2XX to be connected 

module TestLibFTD2XX

using LibFTD2XX
using Test

@testset "high level" begin

  # createdeviceinfolist
  numdevs = createdeviceinfolist()
  @test numdevs > 0
  @info "high level: Number of devices is $numdevs"

  # LibFTD2XX.getdeviceinfodetail
  @test_throws D2XXException LibFTD2XX.getdeviceinfodetail(numdevs)
  for deviceidx = 0:(numdevs-1)
    idx, flags, typ, id, locid, serialnumber, description, fthandle = LibFTD2XX.getdeviceinfodetail(deviceidx)
    @test idx == deviceidx
    if Sys.iswindows() # should not have a locid on windows
      @test locid == 0
    end
    @test serialnumber isa String
    @test description isa String
    @test fthandle isa FT_HANDLE
  end
  idx, flags, typ, id, locid, serialnumber, description, fthandle = LibFTD2XX.getdeviceinfodetail(0)
  @info "high level: testing device $description"

  # open by description
  handle = open(description, OPEN_BY_DESCRIPTION)
  @test handle isa FT_HANDLE
  @test isopen(handle)
  close(handle)
  @test !isopen(handle)

  # open by serialnumber
  handle = open(serialnumber, OPEN_BY_SERIAL_NUMBER)
  @test handle isa FT_HANDLE
  @test isopen(handle)
  close(handle)
  @test !isopen(handle)

  handle = open(description, OPEN_BY_DESCRIPTION)
 
  # bytesavailable
  nb = bytesavailable(handle)
  @test nb >= 0

  # read
  rxbuf = read(handle, nb)
  @test length(rxbuf) == nb

  # write
  txbuf = ones(UInt8, 10)
  nwr = write(handle, txbuf)
  @test nwr == length(txbuf)
  @test txbuf == ones(UInt8, 10)

  # readavailable
  rxbuf = readavailable(handle)
  @test rxbuf isa AbstractVector{UInt8}

  # baudrate
  retval = baudrate(handle, 9600)
  @test retval == nothing
  txbuf = ones(UInt8, 10)
  nwr = write(handle, txbuf)
  @test nwr == length(txbuf)
  @test txbuf == ones(UInt8, 10)

  # driverversion 
  ver = driverversion(handle)
  @test ver isa VersionNumber

  # close 
  retval = close(handle)
  @test retval == nothing
  @test !isopen(handle)
  @test LibFTD2XX.Wrapper.ptr(handle) == C_NULL
  retval = close(handle) # check can close more than once without issue...
  @test !isopen(handle)

  # libversion 
  ver = libversion()
  @test ver isa VersionNumber
end

end # module TestLibFTD2XX
