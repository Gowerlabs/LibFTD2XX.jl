# These tests require an FT device which supports D2XX to be connected 
#
# By Reuben Hill 2019, Gowerlabs Ltd, reuben@gowerlabs.co.uk
#
# Copyright (c) Gowerlabs Ltd.

module TestLibFTD2XX

using Compat
using Compat.Test
using LibFTD2XX
import LibFTD2XX.Wrapper

@testset "high level" begin

  # libversion 
  ver = libversion()
  @test ver isa VersionNumber

  # createdeviceinfolist
  numdevs = LibFTD2XX.createdeviceinfolist()
  @test numdevs > 0

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
  @test_throws ArgumentError LibFTD2XX.getdeviceinfodetail(-1)

  # FT_HANDLE functions...
  @testset "FT_HANDLE" begin

    # open by description
    handle = open(descr, OPEN_BY_DESCRIPTION)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    @test_throws Wrapper.FT_DEVICE_NOT_FOUND open(descr, OPEN_BY_DESCRIPTION) # can't open twice
    close(handle)
    @test !isopen(handle)

    # open by serialnumber
    handle = open(serialn, OPEN_BY_SERIAL_NUMBER)
    @test handle isa FT_HANDLE
    @test isopen(handle)
    @test_throws Wrapper.FT_DEVICE_NOT_FOUND open(serialn, OPEN_BY_SERIAL_NUMBER) # can't open twice
    close(handle)
    @test !isopen(handle)

    
    # bytesavailable
    handle = open(descr, OPEN_BY_DESCRIPTION)
    nb = bytesavailable(handle)
    @test nb >= 0
    close(handle) # can't use on closed device
    @test_throws D2XXException bytesavailable(handle)

    # read
    handle = open(descr, OPEN_BY_DESCRIPTION)
    rxbuf = read(handle, nb)
    @test length(rxbuf) == nb
    @test_throws ArgumentError read(handle, -1)
    close(handle) # can't use on closed device
    @test_throws D2XXException read(handle, nb)

    # write
    handle = open(descr, OPEN_BY_DESCRIPTION)
    txbuf = ones(UInt8, 10)
    nwr = write(handle, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)
    @test_throws ErrorException write(handle, Int.(txbuf)) # No byte I/O...
    close(handle) # can't use on closed device
    @test_throws D2XXException read(handle, nb)

    # readavailable
    handle = open(descr, OPEN_BY_DESCRIPTION)
    rxbuf = readavailable(handle)
    @test rxbuf isa AbstractVector{UInt8}
    close(handle) # can't use on closed device
    @test_throws D2XXException readavailable(handle)

    # baudrate
    handle = open(descr, OPEN_BY_DESCRIPTION)
    retval = baudrate(handle, 2000000)
    @test retval == nothing
    txbuf = ones(UInt8, 10)
    nwr = write(handle, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)
    @test_throws ArgumentError baudrate(handle, 0)
    @test_throws ArgumentError baudrate(handle, -1)
    close(handle) # can't use on closed device
    @test_throws D2XXException baudrate(handle, 2000000)

    # flush and eof
    handle = open(descr, OPEN_BY_DESCRIPTION)
    retval = flush(handle)
    @test eof(handle)
    @test retval == nothing
    @test isopen(handle)
    close(handle) # can't use on closed device
    @test_throws D2XXException flush(handle)
    @test_throws D2XXException eof(handle)

    # driverversion
    handle = open(descr, OPEN_BY_DESCRIPTION)
    ver = driverversion(handle)
    @test ver isa VersionNumber
    close(handle) # can't use on closed device
    @test_throws D2XXException driverversion(handle)

    # datacharacteristics
    handle = open(descr, OPEN_BY_DESCRIPTION)
    retval = datacharacteristics(handle, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)
    @test retval == nothing
    close(handle) # can't use on closed device
    @test_throws D2XXException datacharacteristics(handle, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)

    # timeouts tests...
    handle = open(descr, OPEN_BY_DESCRIPTION)
    baudrate(handle, 9600)
    timeout_read, timeout_wr = 50, 10 # milliseconds
    timeouts(handle, timeout_read, timeout_wr)
    tread = @elapsed read(handle, 5000)
    buffer = zeros(UInt8, 5000);
    twr = @elapsed write(handle, buffer)
    @test tread*1000 < 2*timeout_read
    @test twr*1000 < 2*timeout_wr
    @test_throws ArgumentError timeouts(handle, timeout_read, -1)
    @test_throws ArgumentError timeouts(handle, -1, timeout_wr)
    close(handle) # can't use on closed device
    @test_throws D2XXException timeouts(handle, timeout_read, timeout_wr)

    # status
    handle = open(descr, OPEN_BY_DESCRIPTION)
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
    close(handle) # can't use on closed device
    @test_throws D2XXException status(handle)

    # close and isopen
    handle = open(descr, OPEN_BY_DESCRIPTION)
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
    @test_throws ArgumentError D2XXDevice(-1)
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
    @test_throws D2XXException open.(devices) # can't open twice
  
    # bytesavailable
    nbs = bytesavailable.(devices)
    @test all(nbs .>= 0)
    close.(devices) # can't use on closed device
    @test_throws D2XXException bytesavailable.(devices)

    device = devices[1] # choose device 1...
    nb = nbs[1]
    
    # read
    open(device)
    rxbuf = read(device, nb)
    @test length(rxbuf) == nb
    @test_throws ArgumentError read(device, -1)
    close(device) # can't use on closed device
    @test_throws D2XXException read(device, nb)


    # write
    open(device)
    txbuf = ones(UInt8, 10)
    nwr = write(device, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)
    @test_throws ErrorException write(device, Int.(txbuf)) # No byte I/O...
    close(device) # can't use on closed device
    @test_throws D2XXException write(device, txbuf)

    # readavailable
    open(device)
    rxbuf = readavailable(device)
    @test rxbuf isa AbstractVector{UInt8}
    close(device) # can't use on closed device
    @test_throws D2XXException readavailable(device)

    # baudrate
    open(device)
    retval = baudrate(device, 2000000)
    @test retval == nothing
    txbuf = ones(UInt8, 10)
    nwr = write(device, txbuf)
    @test nwr == length(txbuf)
    @test txbuf == ones(UInt8, 10)
    @test_throws ArgumentError baudrate(device, 0)
    @test_throws ArgumentError baudrate(device, -1)
    close(device) # can't use on closed device
    @test_throws D2XXException baudrate(device, 2000000)

    # flush and eof
    open(device)
    retval = flush(device)
    @test eof(device)
    @test retval == nothing
    @test isopen(device)
    close(device) # can't use on closed device
    @test_throws D2XXException flush(device)

    # driverversion
    open(device)
    ver = driverversion(device)
    @test ver isa VersionNumber
    close(device) # can't use on closed device
    @test_throws D2XXException driverversion(device)

    # datacharacteristics
    open(device)
    retval = datacharacteristics(device, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)
    @test retval == nothing
    close(device) # can't use on closed device
    @test_throws D2XXException datacharacteristics(device, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)

    # timeouts tests...
    open(device)
    baudrate(device, 9600)
    timeout_read, timeout_wr = 50, 10 # milliseconds
    timeouts(device, timeout_read, timeout_wr)
    tread = @elapsed read(device, 5000)
    buffer = zeros(UInt8, 5000);
    twr = @elapsed write(device, buffer)
    @test tread*1000 < 2*timeout_read
    @test twr*1000 < 2*timeout_wr
    @test_throws ArgumentError timeouts(device, timeout_read, -1)
    @test_throws ArgumentError timeouts(device, -1, timeout_wr)
    close(device) # can't use on closed device
    @test_throws D2XXException timeouts(device, timeout_read, timeout_wr)

    # status
    open(device)
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
    close(device) # can't use on closed device
    @test_throws D2XXException status(device)

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
