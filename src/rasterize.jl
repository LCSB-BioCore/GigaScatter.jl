"""
    rasterize(
        res::Tuple{Int64, Int64},
        points::Matrix{Float64},
        colors::Matrix{Float64};
        xlim = (minimum(points[:,1]), maximum(points[:,1])),
        ylim = (minimum(points[:,2]), maximum(points[:,2]))
        )::Array{Float64, 3}

Rasterize the `points` represented as coordinates in 2-row matrix colored by
RGBA float colors in the corresponding 4-row matrix into a raster of size
`res`. `xlim` and `ylim` are the point-coordinates of raster edges.

The raster is returned as a 3D RGBA array with coordinates as in
`[colorChannel, x, y]`.
"""
function rasterize(
    res::Tuple{Int64,Int64},
    points::Matrix{Float64},
    colors::Matrix{Float64};
    xlim = (minimum(points[1, :]), maximum(points[1, :])),
    ylim = (minimum(points[2, :]), maximum(points[2, :])),
)::Raster

    # Color blending is computed on integers because floats are just slower.
    # `precision` is where the value of float 1.0 is mapped.
    # Note that because there's multiplication in the process, the value of
    # precision should not exceed the square root of maximum integer precision,
    # in this case around 2^31. 100k as used here is MORE THAN ENOUGH for any
    # thinkable use in this universe.
    precision = Int64(100000)
    # Most notably, having precision > 256 dodges the ugly low-alpha color
    # artifacts that are pretty common with many graphics libraries.

    # integer raster
    ra = zeros(Int64, 4, res[1], res[2])

    # minima
    mins = [xlim[1], ylim[1]]
    # actual raster point sizes
    iszs = [res[1] / (xlim[2] - xlim[1]), res[2] / (ylim[2] - ylim[1])]

    if size(points,1) != 2 || size(colors) != (4, size(points,2))
        throw(ArgumentError("wrong input matrix sizes"))
    end

    @inbounds for i = 1:size(points, 2)
        # convert the input coordinates to raster indexes
        posx =  trunc(Int64, (points[1, i] - mins[1]) * iszs[1]) + 1
        posy =  trunc(Int64, (points[2, i] - mins[2]) * iszs[2]) + 1

        # skip if it's off limits
        if posx < 1 || posx > res[1] || posy < 1 || posy > res[2]
            continue
        end

        # get the src color
        srcr = trunc(Int64, precision * colors[1, i])
        srcg = trunc(Int64, precision * colors[2, i])
        srcb = trunc(Int64, precision * colors[3, i])
        srca = trunc(Int64, precision * colors[4, i])

        # premultiply alpha
        srcr = (srcr * srca) ÷ precision
        srcg = (srcg * srca) ÷ precision
        srcb = (srcb * srca) ÷ precision

        # get the dst color
        dstr = ra[1, posx, posy]
        dstg = ra[3, posx, posy]
        dstb = ra[3, posx, posy]
        dsta = ra[4, posx, posy]

        # aaaand it blends!
        ra[1, posx, posy] = srcr + dstr - ((srca * dstr) ÷ precision)
        ra[2, posx, posy] = srcg + dstg - ((srca * dstg) ÷ precision)
        ra[3, posx, posy] = srcb + dstb - ((srca * dstb) ÷ precision)
        ra[4, posx, posy] = srca + dsta - ((srca * dsta) ÷ precision)
    end

    #unmultiply alpha and convert back to floats in range 0..1
    raf = zeros(Float64, 4, res[1], res[2])

    for i = 1:res[1]
        for j = 1:res[2]
            # get the alpha element
            raa = ra[4, i, j]
            if raa == 0 #transparent black
                continue
            end
            # remove alpha (which is still in precision-scale, so this
            # effectively removes precision multiplication from r,g,b channels
            raf[1, i, j] = ra[1, i, j] / raa
            raf[2, i, j] = ra[2, i, j] / raa
            raf[3, i, j] = ra[3, i, j] / raa
            # and scale alpha back down to 0..1
            raf[4, i, j] = ra[4, i, j] / precision
        end
    end

    raf
end
