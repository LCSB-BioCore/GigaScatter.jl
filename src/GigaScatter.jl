module GigaScatter

import Images, FileIO, ImageMagick, Colors, Distributions

const Raster = Array{Float64,3}
const RasterMix = Tuple{Array{Float64,3},Matrix{Float64},Matrix{Float64}}

include("colors.jl")
include("rasterize.jl")
include("combine.jl")
include("kernel.jl")
include("export.jl")

# colors.jl
export clusterPalette,
    expressionPalette, classColors, expressionColors, scaleMinMax, scaleNorm

# rasterize.jl
export rasterize

# kernel.jl
export rasterKernelCircle

# combine.jl
export mixableRaster, mixRasters, mixedRaster

# export.jl
export solidBackground, savePNG, saveJPEG

end # module
