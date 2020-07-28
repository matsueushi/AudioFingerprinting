@testset "peaks" begin
    @testset "simple" begin
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
            peaks = findpeaks(x, 2)
            @test peaks == [(2, 2), (4, 3), (5, 5)] 
        end
    end

    @testset "background" begin
        x = zeros(5, 6); x[2, 2] = 1.
        @test findpeaks(x, 2) == [(2, 2)]
    end

    @testset "hashpeaks" begin
        array = Bool[0 0 0 0 0 0 0;
                     0 0 1 1 0 0 0;
                     0 1 0 0 0 0 0;
                     0 1 0 1 0 1 0;
                     1 0 0 0 0 0 0]
        peaks = Hanauta.getmaskindex(array)
        @test peaks == [(1, 5), (2, 3), (2, 4), (3, 2), (4, 2), (4, 4), (6, 4)] 
        fanvalue = 2
        timerange = 0 => 1
        hashdict = hashpeaks(peaks, fanvalue, timerange)
        hashdict == Dict("db724d0a500003163dce50a08d4cb5199d837df32ff9bea778229f6f89e0ec49" => 2,
                         "9fc7745cc33e507d9ad28f16e9bd8d717b0de72ed078424da70292feb19248e4" => 1,
                         "3533f2977e2cb6bb57e7135baff39dbb15e418fa6e7841216ebb6979110a5da4" => 2,
                         "fe812d99d40bccea0f739ed5716d6f77af15b68fc73190b56bd11d579b7ed5d7" => 2,
                         "798fb293c5fce0ad4b6c4405d361322ada948757accfbfb43c79b094702c419f" => 1,
                         "8b0bbed14dafb6086bf675ee4fe2ab1e3a33a79bcc45f990918ba5cb24f12089" => 3,
                         "1c22c9113f4f50934e03ac63bf365ddebfb220f6af556f6dd31ee9c8be4eb619" => 3,
                         "c241ae9f10dd86f58a0c97363f4de1f08d10e3b0dae3cf139efd6027f2c75482" => 4)
    end
end
