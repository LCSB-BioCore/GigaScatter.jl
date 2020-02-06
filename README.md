
# GigaScatter.jl

Fast rasterization of huge amounts of tiny transparent points.

## How-To

First, get some data -- you will need point coordinates and their colors (in RGBA).

```julia
points = randn(2,100000)
colors = rand(4,100000)
```

After that, create a raster (of size 500x500):

```julia
using GigaScatter

raster = rasterize((500,500), points, colors)
```

The raster is now basically 4-layer matrix with channels; you can write it to PNG and see what it looks like:

```julia
savePNG("norm.png", raster)
```

