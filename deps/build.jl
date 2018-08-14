# LibFTD2XX.jl

using BinDeps

Sys.WORD_SIZE != 64 && error("Build script configured only for x64")

@BinDeps.setup

function validate_libFTD2XX_version(name, handle)
    f = Libdl.dlsym_e(handle, "FT_GetLibraryVersion")
    f == C_NULL && return false
    v = Ref{Cuint}()
    s = ccall(f, Culong, (Ref{Cuint},), v)
    s == C_NULL && return false
    return v[] >= 0x00021228
end

libFTD2XX = library_dependency("libFTD2XX", aliases = ["ftd2xx64", "ftd2xx", "libftd2xx"], validate=validate_libFTD2XX_version)

libFTD2XX_win_x64_URI = URI("http://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip")
libFTD2XX_glx_x64_URI = URI("http://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx-x86_64-1.4.8.gz")
libFTD2XX_osx_x64_URI = URI("http://www.ftdichip.com/Drivers/D2XX/MacOSX/D2XX1.4.4.dmg")

provides(Binaries, libFTD2XX_win_x64_URI, libFTD2XX, unpacked_dir = ".",
         installed_libpath = joinpath(@__DIR__, "libFTD2XX", Sys.WORD_SIZE == 64 ? "amd64" : "i386"), os = :Windows)

@BinDeps.install Dict(:libFTD2XX => :libFTD2XX)

