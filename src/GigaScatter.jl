module GigaScatter

    import Images, FileIO, ImageMagick, Colors, Distributions

    include("colors.jl")
    include("rasterize.jl")
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

    export #from export.jl
        solidBackground,
        savePNG,
        saveJPEG

end # module
