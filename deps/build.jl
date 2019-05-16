# LibFTD2XX.jl
#
# Library installation script based on BinaryProvider LibFoo.jl example

using Libdl
using BinaryProvider

verbose = true

prefix = joinpath(@__DIR__, "usr")

if Sys.islinux()
    libnames = ["libftd2xx", "libftd2xx.1.4.4", "libftd2xx.so.1.4.8"]
    products = Product[LibraryProduct(joinpath(prefix, "release", "build"), libnames, :libftd2xx)]
end

if Sys.iswindows()
    libnames = ["ftd2xx64", "ftd2xx"]
    products = Product[LibraryProduct(joinpath(prefix, Sys.WORD_SIZE == 64 ? "amd64" : "i386"), libnames, :libftd2xx)]
end

if Sys.isapple()
    libnames = ["ftd2xx64", "ftd2xx", "libftd2xx", "libftd2xx.1.4.4", "libftd2xx.so.1.4.8"]
    products = Product[LibraryProduct(joinpath(prefix, "release", "build"), libnames, :libftd2xx)]
end



bin_prefix = "https://www.ftdichip.com/Drivers"
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/D2XX/Linux/libftd2xx-arm-v8-1.4.8.gz", "815d880c5ec40904f062373e52de07b2acaa428e54fece98b31e6573f5d261a0"),
    Linux(:armv7l, :glibc)  => ("$bin_prefix/D2XX/Linux/libftd2xx-arm-v7-hf-1.4.8.gz", "815d880c5ec40904f062373e52de07b2acaa428e54fece98b31e6573f5d261a0"),
    Linux(:i686, :glibc)    => ("$bin_prefix/D2XX/Linux/libftd2xx-i386-1.4.8.gz", "815d880c5ec40904f062373e52de07b2acaa428e54fece98b31e6573f5d261a0"),
    Linux(:x86_64, :glibc)  => ("$bin_prefix/D2XX/Linux/libftd2xx-x86_64-1.4.8.gz", "815d880c5ec40904f062373e52de07b2acaa428e54fece98b31e6573f5d261a0"),

    MacOS(:x86_64)          => ("$bin_prefix/D2XX/MacOSX/D2XX1.4.4.dmg", "815d880c5ec40904f062373e52de07b2acaa428e54fece98b31e6573f5d261a0"),

    Windows(:x86_64)        => ("$bin_prefix/CDM/CDM%20v2.12.28%20WHQL%20Certified.zip", "82db36f089d391f194c8ad6494b0bf44c508b176f9d3302777c041dad1ef7fe6")
)

# First, check to see if we're all satisfied
if any(!satisfied(p; verbose=verbose) for p in products)
    try
        # Download and install binaries
        url, tarball_hash = choose_download(download_info)
        if Sys.islinux()
            install(url, tarball_hash, prefix=Prefix(prefix), force=true, verbose=verbose)
        elseif Sys.iswindows()
            # Explitly download, unzip and install on windows since .zip instead of tarball
            tarball_path = joinpath(Prefix(prefix), "downloads", basename(url))
            download_verify(url, tarball_hash, tarball_path, force=true, verbose=verbose)
            # unzip
            exe7z = joinpath(Sys.BINDIR, "7z.exe")
            isfile(exe7z) || error("7z.exe not in $(Sys.BINDIR)")
            run(`$exe7z x $tarball_path -o$prefix`)
        else
            throw(ArgumentError("Unsupported platform"))
        end
    catch e
        if typeof(e) <: ArgumentError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end