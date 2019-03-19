# These tests require an FT device which supports D2XX to be connected 

module TestLibFTD2XX

using LibFTD2XX
import LibFTD2XX.Wrapper
using Test

@testset "high level" begin

  # createdeviceinfolist
  numdevs = createdeviceinfolist()
  @test numdevs == 0
  @info "high level: Number of devices is $numdevs"

  # getdeviceinfodetail
  
  @test_throws AssertionError getdeviceinfodetail(0)

  # open by description
  @test_throws Wrapper.FT_DEVICE_NOT_FOUND open("", OPEN_BY_DESCRIPTION)
  
  # open by serialnumber
  @test_throws Wrapper.FT_DEVICE_NOT_FOUND open("", OPEN_BY_SERIAL_NUMBER)
  
  handle = FT_HANDLE() # create invalid handle...
 
  # bytesavailable
  @test_throws Wrapper.FT_INVALID_HANDLE bytesavailable(handle)

  # read
  @test_throws Wrapper.FT_INVALID_HANDLE read(handle, 0)
  @test_throws ErrorException read(handle, -1)

  # write
  txbuf = ones(UInt8, 10)
  @test_throws Wrapper.FT_INVALID_HANDLE write(handle, txbuf)
  @test txbuf == ones(UInt8, 10)

  # readavailable
  @test_throws Wrapper.FT_INVALID_HANDLE readavailable(handle)

  # baudrate
  @test_throws Wrapper.FT_INVALID_HANDLE baudrate(handle, 9600)

  # driverversion 
  @test_throws Wrapper.FT_INVALID_HANDLE driverversion(handle)

  # isopen
  @test !isopen(handle)

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
