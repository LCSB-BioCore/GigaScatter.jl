"""
    rasterKernelCircle(radius, raf::Array{Float64, 3})::Array{Float64, 3}

Expand single-pixel points in a raster (as obtained e.g. from `rasterize`) to small circles with the specified `radius`. Alpha and color is preserved.
"""

function rasterKernelCircle(radius, raf::Raster)::Raster
    # premultiply the radius
    rt = radius * radius
    # maximum required kernel offset
    r = Int64(ceil(radius))
    # resulting raster
    res = zeros(Float64, size(raf))

    for x = 1:size(raf, 2)
        for y = 1:size(raf, 3)
            sr = 0.0
            sg = 0.0
            sb = 0.0
            pia = 1.0 # alpha is blended by multiplying (1-alpha) values
            w = 0.0 # total weight

            # run through the environment of x,y by offsets
            for ox = (-r):r
                for oy = (-r):r
                    # check if the offset is in limits
                    tx = x + ox
                    ty = y + oy
                    if tx < 1 || tx > size(raf, 2) || ty < 1 || ty > size(raf, 3)
                        continue
                    end
                    # cut out the circle (TODO: antialias the border??)
                    if ox * ox + oy * oy > rt
                        continue
                    end

                    # blend it
                    sr += raf[1, tx, ty] * raf[4, tx, ty]
                    sg += raf[2, tx, ty] * raf[4, tx, ty]
                    sb += raf[3, tx, ty] * raf[4, tx, ty]
                    w += raf[4, tx, ty]
                    pia *= 1 - raf[4, tx, ty]
                end
            end
            # compute the weighted mean & convert the alpha back
            if w > 0
                res[1, x, y] = sr / w
                res[2, x, y] = sg / w
                res[3, x, y] = sb / w
                res[4, x, y] = 1 - pia
            end
        end
    end
    res
end
