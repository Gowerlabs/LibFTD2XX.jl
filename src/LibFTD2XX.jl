# LibFTD2XX.jl

module LibFTD2XX

# Get library
const depsfile = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("LibFTD2XX not properly installed. Please run Pkg.build(\"LibFTD2XX\") then restart Julia.")
end

end
