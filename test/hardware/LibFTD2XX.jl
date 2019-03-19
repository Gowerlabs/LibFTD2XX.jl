# These tests require an FT device which supports D2XX to be connected 

module TestLibFTD2XX

using LibFTD2XX
using Test

@testset "high level" begin

  # libversion 
  ver = libversion()
  @test ver isa VersionNumber

  # createdeviceinfolist
  numdevs = LibFTD2XX.createdeviceinfolist()
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
  @info "high level: testing device $descr"

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

    # flush and eof
    retval = flush(handle)
    @test eof(handle)
    @test retval == nothing
    @test isopen(handle)

    # driverversion 
    ver = driverversion(handle)
    @test ver isa VersionNumber
    @test_throws D2XXException driverversion(FT_HANDLE())

    # datacharacteristics
    retval = datacharacteristics(handle, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)
    @test retval == nothing

    # status
    mflaglist, lflaglist = status(handle)
    @test mflaglist isa Dict{String, Bool}
    @test lflaglist isa Dict{String, Bool}
    @test haskey(mflaglist, "CTS")
    @test haskey(mflaglist, "DSR")
    @test haskey(mflaglist, "RI")
    @test haskey(mflaglist, "DCD")
    @test haskey(lflaglist, "OE")
    @test haskey(lflaglist, "PE")
    @test haskey(lflaglist, "FE")
    @test haskey(lflaglist, "BI")

    # close and isopen
    retval = close(handle)
    @test retval == nothing
    @test !isopen(handle)
    @test LibFTD2XX.Wrapper.ptr(handle) == C_NULL
    retval = close(handle) # check can close more than once without issue...
    @test !isopen(handle)
  end

  # D2XXDevice
  @testset "D2XXDevice" begin

    # Constructor
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

    # D2XXDevices
    devices = D2XXDevices()
    @test length(devices) == numdevs
    @test all(deviceidx(devices[d]) == deviceidx(D2XXDevice(d-1)) for d = 1:numdevs)

    # isopen
    @test all(.!isopen.(devices))

    # open
    retval = open.(devices)
    @test all(retval .== nothing)
    @test all(isopen.(devices))
  
    # bytesavailable
    nbs = bytesavailable.(devices)
    @test all(nbs .>= 0)

    device = devices[1] # choose device 1...
    nb = nbs[1]

    # read
    rxbuf = read(device, nb)
    @test length(rxbuf) == nb

    # write
    txbuf = ones(UInt8, 10)
    nwr = write(device, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)

    # readavailable
    rxbuf = readavailable(device)
    @test rxbuf isa AbstractVector{UInt8}

    # baudrate
    retval = baudrate(device, 9600)
    @test retval == nothing
    txbuf = ones(UInt8, 10)
    nwr = write(device, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)

    # flush and eof
    retval = flush(device)
    @test eof(device)
    @test retval == nothing
    @test isopen(device)

    # driverversion 
    ver = driverversion(device)
    @test ver isa VersionNumber
    @test_throws D2XXException driverversion(FT_HANDLE())

    # datacharacteristics
    retval = datacharacteristics(device, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)
    @test retval == nothing

    # status
    mflaglist, lflaglist = status(device)
    @test mflaglist isa Dict{String, Bool}
    @test lflaglist isa Dict{String, Bool}
    @test haskey(mflaglist, "CTS")
    @test haskey(mflaglist, "DSR")
    @test haskey(mflaglist, "RI")
    @test haskey(mflaglist, "DCD")
    @test haskey(lflaglist, "OE")
    @test haskey(lflaglist, "PE")
    @test haskey(lflaglist, "FE")
    @test haskey(lflaglist, "BI")

    # close and isopen (all devices)
    retval = close.(devices)
    @test all(retval .== nothing)
    @test all(.!isopen.(devices))
    @test all(LibFTD2XX.Wrapper.ptr.(fthandle.(devices)) .== C_NULL)
    close.(devices) # check can close more than once without issue...
    @test all(.!isopen.(devices))

  end

end

end # module TestLibFTD2XX
