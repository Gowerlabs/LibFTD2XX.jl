module TestUtil

using Compat
using Compat.Test
using LibFTD2XX.Util

@testset "util" begin
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o')))
  @test "hello" == ntuple2string(Cchar.(('h','e','l','l','o','\0','x')))
end

end