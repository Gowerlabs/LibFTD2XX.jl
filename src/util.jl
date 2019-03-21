# LibFTD2XX.jl - Utility Module
#
# By Reuben Hill 2019, Gowerlabs Ltd, reuben@gowerlabs.co.uk
#
# Copyright (c) Gowerlabs Ltd.

module Util

export ntuple2string

using Compat

"""
    ntuple2string(input::NTuple{N, Cchar} where N)

Convert an NTuple of Cchars (optionally null terminated) to a julia string.

# Example

```jldoctest
julia> ntuple2string(Cchar.(('h','e','l','l','o')))
"hello"

julia> ntuple2string(Cchar.(('h','e','l','l','o', '\0', 'x'))) # null terminated
"hello"
```

"""
function ntuple2string(input::NTuple{N, Cchar} where N)
  if any(input .== 0)
    @compat endidx = findall(input .== 0)[1]-1
  elseif all(input .> 0)
    endidx = length(input)
  else
    throw(MethodError("No terminator or negative values!"))
  end
  String(UInt8.([char for char in input[1:endidx]]))
end

end # module Util