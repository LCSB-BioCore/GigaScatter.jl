"""
    solidBackground(
        raster::Array{Float64,3},
        color::Array{Float64,1}=[1.0,1.0,1.0]
        )::Array{Float64,3}

Take a 4-channel `raster` with alpha channel and convert it to 3-channel one by
adding a background `color`. Useful for saving non-transparent PNGs and JPEGs.
"""
function solidBackground(
    raster::Raster,
    color::Array{Float64,1}=[1.0,1.0,1.0]
    )::Raster
    r=copy(raster)
    r[1,:,:]=r[1,:,:].*r[4,:,:] + color[1].*(1 .-r[4,:,:])
    r[2,:,:]=r[2,:,:].*r[4,:,:] + color[2].*(1 .-r[4,:,:])
    r[3,:,:]=r[3,:,:].*r[4,:,:] + color[3].*(1 .-r[4,:,:])
    r[1:3, :, :]
end

"""
    savePNG(filename::String, raster::Array{Float64,3})

Save the `raster` to a PNG `filename`. Transparency is choosen automatically
based on the number of raster channels.
"""
function savePNG(filename::String, raster::Raster)
    format = Images.RGBA
    if size(raster,1)==3
        format = Images.RGB
    elseif size(raster,1)==4
        format = Images.RGBA
    else
        throw(DomainError(
            size(raster,1),
            "unsupported number of channels in raster"))
    end

    Images.save(
        FileIO.File(FileIO.format"PNG", filename),
        Images.colorview(format, raster)
    )
end

"""
    saveJPEG(filename::String, raster::Array{Float64,3})

Save the `raster` to a JPEG `filename`. Only supports 3-channel rasters (see `solidBackground`).
"""
function saveJPEG(filename::String, raster::Raster)
    format = Images.RGB
    if size(raster,1)==3
        format = Images.RGB
    else
        throw(DomainError(
            size(raster,1),
            "unsupported number of channels in raster"))
    end

    Images.save(
        FileIO.File(FileIO.format"JPEG", filename),
        Images.colorview(format, raster)
    )
end
