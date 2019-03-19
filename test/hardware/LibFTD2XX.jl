# These tests require an FT device which supports D2XX to be connected 

module TestLibFTD2XX

using LibFTD2XX
using Test

@testset "high level" begin

  # libversion 
  ver = libversion()
  @test ver isa VersionNumber

  # createdeviceinfolist
  numdevs = createdeviceinfolist()
  @test numdevs > 0
  @info "high level: Number of devices is $numdevs"

  # LibFTD2XX.getdeviceinfodetail
  @test_throws D2XXException LibFTD2XX.getdeviceinfodetail(numdevs)
  for deviceidx = 0:(numdevs-1)
    idx, flgs, typ, devid, locid, serialn, descr, fthand = LibFTD2XX.getdeviceinfodetail(deviceidx)
    @test idx == deviceidx
    if Sys.iswindows() # should not have a locid on windows
      @test locid == 0
    end
    @test serialn isa String
    @test descr isa String
    @test fthand isa FT_HANDLE
  end
  idx, flgs, typ, devid, locid, serialn, descr, fthand = LibFTD2XX.getdeviceinfodetail(0)
  @info "high level: testing device $description"

  # FT_HANDLE functions...
  @testset "FT_HANDLE" begin

    # open by description
    handle = open(descr, OPEN_BY_DESCRIPTION)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    close(handle)
    @test !isopen(handle)

    # open by serialnumber
    handle = open(serialn, OPEN_BY_SERIAL_NUMBER)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    close(handle)
    @test !isopen(handle)

    handle = open(descr, OPEN_BY_DESCRIPTION)
  
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
    @test_throws D2XXException driverversion(FT_HANDLE())

    # close 
    retval = close(handle)
    @test retval == nothing
    @test !isopen(handle)
    @test LibFTD2XX.Wrapper.ptr(handle) == C_NULL
    retval = close(handle) # check can close more than once without issue...
    @test !isopen(handle)
  end

  # D2XXDevice
  @testset "D2XXDevice" begin
    # by index...
    @test_throws D2XXException D2XXDevice(-1)
    for i = 0:(numdevs-1)
      idx, flgs, typ, devid, locid, serialn, descr, fthand = LibFTD2XX.getdeviceinfodetail(i)
      dev = D2XXDevice(i)
      @test deviceidx(dev) == idx == i
      @test deviceflags(dev) == flgs
      @test devicetype(dev) == typ
      @test deviceid(dev) == devid
      if Sys.iswindows()
        @test locationid(dev) == locid == 0
      else
        @test locationid(dev) == locid
      end
      @test serialnumber(dev) == serialn
      @test description(dev) == descr
      @test LibFTD2XX.Wrapper.ptr(fthandle(dev)) == LibFTD2XX.Wrapper.ptr(fthand)
      @test !isopen(fthandle(dev))
    end
  end

end

end # module TestLibFTD2XX
