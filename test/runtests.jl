using Test

using Hanauta

@testset "peaks" begin
    x = [0.94 0.54 0.67 0.48 0.10;
         0.77 0.98 0.54 0.63 0.32;
         0.83 0.54 0.57 0.96 0.50;
         0.56 0.40 0.79 0.69 0.43;
         0.47 0.61 0.10 0.18 0.88]
         
    @testset "maxfilter" begin
        @test maxfilter(x, 2) == [0.98 0.98 0.98 0.67 0.63;
                                  0.98 0.98 0.98 0.96 0.96;
                                  0.98 0.98 0.98 0.96 0.96;
                                  0.83 0.83 0.96 0.96 0.96;
                                  0.61 0.79 0.79 0.88 0.88]
        @test maxfilter(x, 3) == [0.98 0.98 0.98 0.98 0.96;
                                  0.98 0.98 0.98 0.98 0.96;
                                  0.98 0.98 0.98 0.98 0.96;
                                  0.98 0.98 0.98 0.98 0.96;
                                  0.83 0.96 0.96 0.96 0.96]
    end

    @testset "findpeaks" begin
        @test findpeaks(x, 2) == ([2, 3, 5], [2, 4, 5])
    end

    @testset "pairingpeaks" begin
        peaks = Bool[0 0 0 0 0 0 0;
                     0 1 1 0 0 0 0;
                     0 0 0 0 0 1 0;
                     0 0 0 1 0 1 0;
                     1 0 0 0 0 0 0]
    end
end