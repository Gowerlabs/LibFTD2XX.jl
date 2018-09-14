# LibFTD2XX

Julia wrapper for FTD2XX driver. For reference see the [D2XX Programmer's Guide](http://www.ftdichip.com/Support/Documents/ProgramGuides/D2XX_Programmer's_Guide(FT_000071).pdf).

It has been tested on Julia 0.6.x and 0.7.

## Example Code

The below is a demonstration for a port which echos what it received.

```Julia
julia> using LibFTD2XX, Compat # Compat for codeunits 

julia> devs = createdeviceinfolist() # find out how many devices there are
4

julia> list, elnum = getdeviceinfolist(devs)
(FTD2XX.FT_DEVICE_LIST_INFO_NODE[FTD2XX.FT_DEVICE_LIST_INFO_NODE(0x00000002, 0x00000007, 0x04036011, 0x00000000, (70, 84, 50, 75, 72, 49, 72, 49, 65, 0, -128, 117, -2, 127, 0, 0), (85, 83, 66, 32, 60, 45, 62, 32, 83, 101, 114, 105, 97, 108, 32, 67, 111, 110, 118, 101, 114, 116, 101, 114, 32, 65, 0, 0, 0, 0, 0, 0, 97, -14, 31, 27, 84, 49, 0, 0, -112, 35, -37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -106, 86, 107, 115, -2, 127, 0, 0), FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000000000)), FTD2XX.FT_DEVICE_LIST_INFO_NODE(0x00000002, 0x00000007, 0x04036011, 0x00000000, (70, 84, 50, 75, 72, 49, 72, 49, 66, 0, 98, 7, 0, 0, 0, 0), (85, 83, 66, 32, 60, 45, 62, 32, 83, 101, 114, 105, 97, 108, 32, 67, 111, 110, 118, 101, 114, 116, 101, 114, 32, 66, 0, -128, 1, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0, 112, -68, 98, 7, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0), FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000000000)), FTD2XX.FT_DEVICE_LIST_INFO_NODE(0x00000002, 0x00000007, 0x04036011, 0x00000000, (70, 84, 50, 75, 72, 49, 72, 49, 67, 0, 98, 7, 0, 0, 0, 0), (85, 83, 66, 32, 60, 45, 62, 32, 83, 101, 114, 105, 97, 108, 32, 67, 111, 110, 118, 101, 114, 116, 101, 114, 32, 67, 0, -128, 1, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0, -40, -68, 98, 7, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0), FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000000000)), FTD2XX.FT_DEVICE_LIST_INFO_NODE(0x00000002, 0x00000007, 0x04036011, 0x00000000, (70, 84, 50, 75, 72, 49, 72, 49, 68, 0, 98, 7, 0, 0, 0, 0), (85, 83, 66, 32, 60, 45, 62, 32, 83, 101, 114, 105, 97, 108, 32, 67, 111, 110, 118, 101, 114, 116, 101, 114, 32, 68, 0, -128, 1, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0, 64, -67, 98, 7, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 32, 78, -37, 0, 0, 0, 0, 0), FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000000000))], 0x00000004)

julia> description = String(list[3].description)
"USB <-> Serial Converter C"

julia> handle = ftopen(0) # open device by index (from zero)
FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000d908b0)

julia> isopen(handle)
true

julia> close(handle)

julia> isopen(handle)
false

julia> handle = open(description, OPEN_BY_DESCRIPTION)
FTD2XX.FT_HANDLE(Ptr{Void} @0x0000000000db4e20)

julia> @compat write(handle, Vector{UInt8}(codeunits("Hello")))
5

julia> nb_available(handle)
5

julia> String(read(handle, 5))
"Hello"

julia> @compat write(handle, Vector{UInt8}(codeunits("world!")))
6

julia> String(readavailable(handle))
"world!"

julia> @compat write(handle, Vector{UInt8}(codeunits("I will be deleted.")))
18

julia> nb_available(handle)
18

julia> flush(handle)

julia> nb_available(handle)
0

julia> close(handle)

```