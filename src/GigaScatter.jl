module GigaScatter

    import Images, FileIO, ImageMagick, Colors, Distributions

    const Raster = Array{Float64, 3}
    const RasterMix = Tuple{Array{Float64, 3}, Matrix{Float64}, Matrix{Float64}}

    include("colors.jl")
    include("rasterize.jl")
    include("combine.jl")
    include("kernel.jl")
    include("export.jl")

    export #from colors.jl
        clusterPalette,
        expressionPalette,
        classColors,
        expressionColors,
        scaleMinMax,
        scaleNorm

    export #from rasterize.jl
        rasterize

    export #from kernel.jl
        rasterKernelCircle

    export #from combine.jl.jl
        mixableRaster,
        mixRasters,
        mixedRaster

    export #from export.jl
        solidBackground,
        savePNG,
        saveJPEG

end # module
