# LibFTD2XX

Julia wrapper for FTD2XX driver. For reference see the [D2XX Programmer's Guide (FT_000071)](http://www.ftdichip.com/Support/Documents/ProgramGuides/D2XX_Programmer's_Guide(FT_000071).pdf).

Contains methods and functions for interacting with D2XX devices. Most 
cross-platform functions are supported.

Direct access to functions detailed in the [D2XX Programmer's Guide (FT_000071)](http://www.ftdichip.com/Support/Documents/ProgramGuides/D2XX_Programmer's_Guide(FT_000071).pdf)
are available in in the submodule `Wrapper`.


Supports Julia v0.7 and above.

## Example Code

The below is a demonstration for a port running at 2MBaud which echos what it receives.

```Julia
julia> using LibFTD2XX


julia> devices = D2XXDevices() # create an array of available devices
4-element Array{D2XXDevice,1}:
 D2XXDevice(0, 2, 7, 67330065, 0, "FT3V1RFFA", "USB <-> Serial Converter A", Base.RefValue{FT_HANDLE}(FT_HANDLE(Ptr{Nothing} @0x0000000000000000)))
 D2XXDevice(1, 2, 7, 67330065, 0, "FT3V1RFFB", "USB <-> Serial Converter B", Base.RefValue{FT_HANDLE}(FT_HANDLE(Ptr{Nothing} @0x0000000000000000)))
 D2XXDevice(2, 2, 7, 67330065, 0, "FT3V1RFFC", "USB <-> Serial Converter C", Base.RefValue{FT_HANDLE}(FT_HANDLE(Ptr{Nothing} @0x0000000000000000)))
 D2XXDevice(3, 2, 7, 67330065, 0, "FT3V1RFFD", "USB <-> Serial Converter D", Base.RefValue{FT_HANDLE}(FT_HANDLE(Ptr{Nothing} @0x0000000000000000)))

julia> isopen.(devices) # devices are not opened when they are listed
4-element BitArray{1}:
 false
 false
 false
 false

julia> device = devices[1]
D2XXDevice(0, 2, 7, 67330065, 0, "FT3V1RFFA", "USB <-> Serial Converter A", Base.RefValue{FT_HANDLE}(FT_HANDLE(Ptr{Nothing} @0x0000000000000000)))

julia> open(device)

julia> isopen(device)
true

julia> datacharacteristics(device, wordlength = BITS_8, stopbits = STOP_BITS_1, parity = PARITY_NONE)

julia> baudrate(device,2000000)

julia> write(device, Vector{UInt8}(codeunits("Hello")))
0x00000005

julia> bytesavailable(device)
0x00000005

julia> String(read(device, 5)) # read 5 bytes
"Hello"

julia> write(device, Vector{UInt8}(codeunits("World")))
0x00000005

julia> String(readavailable(device)) # read all available bytes
"World"

julia> write(device, Vector{UInt8}(codeunits("I will be deleted.")))
0x00000012

julia> bytesavailable(device)
0x00000012

julia> flush(device)

julia> bytesavailable(device)
0x00000000

julia> close(device)

julia> isopen(device)
false

```

## Linux support

It is likely that the kernel will automatically load VCP drivers when running on linux, which will prevent the D2XX drivers from accessing the device. Follow the guidance in the FTDI Linux driver [README](https://www.ftdichip.com/Drivers/D2XX/Linux/ReadMe-linux.txt) to unload the `ftdio_sio` and `usbserial` kernel modules before use. These can optionally be blacklisted if appropriate.

The D2XX drivers use raw USB access through `libusb` which may not be available to non-root users. A udev file is required to enable access to a specified group. A script to create the appropriate file and user group is available, e.g., [here](https://stackoverflow.com/questions/13419691/accessing-a-usb-device-with-libusb-1-0-as-a-non-root-user).
