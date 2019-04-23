# LibFTD2XX.jl

using Libdl
using BinDeps

download_dir = joinpath(@__DIR__, "downloads")

@BinDeps.setup

function validate_libFTD2XX_version(name, handle)
    f = Libdl.dlsym_e(handle, "FT_GetLibraryVersion")
    f == C_NULL && return false
    v = Ref{Cuint}()
    s = ccall(f, Culong, (Ref{Cuint},), v)
    s == C_NULL && return false
    if Sys.iswindows()
        return v[] >= 0x00021228
    else
        return true         # OS X library returns version 0x0000000
    end
end

libFTD2XX = library_dependency("libFTD2XX", 
    aliases = ["ftd2xx64", "ftd2xx", "libftd2xx", "libftd2xx.1.4.4", "libftd2xx.so.1.4.8"], 
    validate=validate_libFTD2XX_version)

# Windows 
#
libFTD2XX_win_x64_URI = URI("http://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip")

provides(Binaries, libFTD2XX_win_x64_URI, libFTD2XX, unpacked_dir = ".",
         installed_libpath = joinpath(@__DIR__, "libFTD2XX", Sys.WORD_SIZE == 64 ? "amd64" : "i386"), os = :Windows)

         
# MacOS
#
# Whilst binaries are provided, they are in a .dmg file which must be mounted, files extracted
# and unmounted. Hence this is performed as a build process calling a simple external script.         
libFTD2XX_osx_x64_URI = URI("http://www.ftdichip.com/Drivers/D2XX/MacOSX/D2XX1.4.4.dmg")
libFTD2XX_osx_dir = joinpath(@__DIR__, "usr", "lib")

provides(BuildProcess,
    (@build_steps begin
        CreateDirectory(libFTD2XX_osx_dir)
        CreateDirectory(download_dir)
        FileDownloader(string(libFTD2XX_osx_x64_URI), joinpath(download_dir, "D2XX1.4.4.dmg"))
        @build_steps begin
            FileRule(joinpath(libFTD2XX_osx_dir, "libftd2xx.1.4.4.dylib"), @build_steps begin
                `./build_osx.sh`
            end)
        end
    end), libFTD2XX, installed_libpath = joinpath(@__DIR__, "usr", "lib"), os = :Darwin)

# Linux
#
libFTD2XX_glx_armv7hf_URI = URI("https://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx-arm-v7-hf-1.4.8.gz")
libFTD2XX_glx_armv8hf_URI = URI("https://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx-arm-v8-1.4.8.gz")
libFTD2XX_glx_x86_URI = URI("https://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx-i386-1.4.8.gz")
libFTD2XX_glx_x64_URI = URI("https://www.ftdichip.com/Drivers/D2XX/Linux/libftd2xx-x86_64-1.4.8.gz")
libFTD2XX_glx_dir = joinpath(@__DIR__, "usr", "lib")

if Sys.islinux()

    if (Sys.ARCH == :arm || Sys.ARCH == :aarch64) && (occursin("arm-linux-gnueabihf", Sys.MACHINE) || occursin("aarch64", Sys.MACHINE))
        libFTD2XX_glx_URI = (Sys.WORD_SIZE == 32) ? libFTD2XX_glx_armv7hf_URI : libFTD2XX_glx_armv8hf_URI
    else
        libFTD2XX_glx_URI = (Sys.WORD_SIZE == 32) ? libFTD2XX_glx_x86_URI : libFTD2XX_glx_x64_URI
    end

    provides(BuildProcess,
    (@build_steps begin
        CreateDirectory(libFTD2XX_glx_dir)
        CreateDirectory(download_dir)
        FileDownloader(string(libFTD2XX_glx_URI), joinpath(download_dir, "libftd2xx.gz"))
        FileRule(joinpath(libFTD2XX_glx_dir, "libftd2xx.so.1.4.8"), @build_steps begin
            `./build_glx.sh`
        end)
    end), libFTD2XX, installed_libpath = joinpath(@__DIR__, "usr", "lib"), os = :Linux)

    # BinDeps doesn't do something sensible with .gz, so the following approach fails
    # provides(Binaries, libFTD2XX_glx_armv7hf_URI, libFTD2XX, #unpacked_dir = ".",
    #          installed_libpath = joinpath(@__DIR__, "release", "build"), os = :Linux)
end


@BinDeps.install Dict(:libFTD2XX => :libFTD2XX)

