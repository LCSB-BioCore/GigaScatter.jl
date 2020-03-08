"""
    mixableRaster(raster::Raster)::RasterMix

Convert a raster into a form that is suitable for combining with other rasters.
"""
function mixableRaster(raster::Raster)::RasterMix
    colors=copy(raster[1:3,:,:])
    colors[1,:,:] .*= raster[4,:,:]
    colors[2,:,:] .*= raster[4,:,:]
    colors[3,:,:] .*= raster[4,:,:]
    return (colors, 1 .- raster[4,:,:], raster[4,:,:])
end

"""
    mixRasters(
        (c1,ia1,w1)::RasterMix,
        (c2,ia2,w2)::RasterMix)::RasterMix

Combine 2 rasters into mixable form.
"""
function mixRasters(
    (c1,ia1,w1)::RasterMix,
    (c2,ia2,w2)::RasterMix)::RasterMix
    return (c1 .+ c2, ia1 .* ia2, w1 .+ w2)
end

"""
    mixedRaster((r,ia,w)::RasterMix)::Raster

Convert several (possibly many) mixed rasters back into normal raster.
"""
function mixedRaster((r,ia,ws)::RasterMix)::Raster
    w=copy(reshape(ws, (1,size(ws)...)))
    w[w .== 0] .= 1
    cat(dims=1,
        r[1:1,:,:]./w,
        r[2:2,:,:]./w,
        r[3:3,:,:]./w,
        1 .- reshape(ia,(1,size(ia)...)))
end
