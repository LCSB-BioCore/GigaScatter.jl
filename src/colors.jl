
"""
    clusterPalette(n; alpha=1.0, h=0.0, hl=360.0, s::Array{Float64,1}=[0.7, 1.0], v=[1.0, 0.7])

Create an array of categorical colors suitable for plotting colored clusters.

# Arguments
- `n` number of colors
- `alpha` transparency
- `h`, `hs` starting hue and hue range
- `s`,`v` arrays of saturations and color values in the palette
   (the numbers will be used in a cyclic manner)
"""
function clusterPalette(n; alpha=1.0, h=0.0, hl=360.0, s=[0.7, 1.0], v=[1.0, 0.7])
    [Colors.convert(Colors.RGBA,
        Colors.HSVA(
            h + hl*(i-1)/n,
            s[1+i%length(s)],
            v[1+i%length(v)],
            alpha)) for i in 1:n]
end

"""
    linearPaletteBlend(c, r)

Internal function for picking the color blends from palette arrays
"""
function linearPaletteBlend(c, r)
    k = size(c, 1)
    kr = (k-1)*r
    i = Int64(trunc(kr))
    
    if i<0
        return c[1,:]
    end

    if i>=(k-1)
        return c[k,:]
    end

    a = kr-i
    return (1-a)*c[i+1,:] + a*c[i+2,:]
end

# data taken from a modified RbYlBu from EmbedSOM, which was originally taken
# from ColorBrewer and slightly modified
palRdYlBu = 
    Matrix{Float64}(
    [33    38  149;
     53   101  180;
    100   157  209;
    145   195  226;
    184   217  200;
    255   255  168;
    254   224  144;
    253   174   97;
    244   109   67;
    215    48   39;
    165     0   38])

"""
    expressionPalette(n; alpha=1.0, palette=palRdYlBu)

Create a palette of `n` colors with alpha `alpha` that is useful for displaying
expressions; by default a variation of the widely used RdYlBu palette is used.
Any supplied `palette` with colors ranging from 0 to `maxValue` can be expanded.
"""
function expressionPalette(n::Int64;
                           alpha::Float64=1.0,
                           palette::Matrix{Float64}=palRdYlBu,
                           maxValue::Float64=255.0)
    [Colors.RGBA(x[1], x[2], x[3], alpha)
     for x in
       [linearPaletteBlend(palette, (i-1)/(n-1))
        for i in 1:n] / maxValue
    ]
end

"""
    classColors(classes::Array{Int64, 1}, palette)::Matrix{Float64}

Take integer class IDs from `classes` and the corresponding colors in
`Palette`, and produce a corresponding color matrix usable in `rasterize`.

Optionally, `classCount` specifies the number of classes; by default taken as a
maximum of `classes` if `classCount` zero.
"""
function classColors(classes::Array{Int64, 1}, palette)::Matrix{Float64}
    hcat([[palette[i].r,palette[i].g,palette[i].b,palette[i].alpha]
          for i in classes
         ]...)
end


"""
    expressionColors(expressions::Array{Float64, 1}, palette)::Matrix{Float64}

Convert array of floating point `expressions` in range [0..1] to an array of
colors usable in `rasterize`, using the `palette` as a color lookup.
"""
function expressionColors(expressions::Array{Float64, 1}, palette)::Matrix{Float64}
    nColors = length(palette)
    hcat([[palette[c].r,palette[c].g,palette[c].b,palette[c].alpha]
          for c in Array{Int64,1}(1 .+ trunc.((nColors-1)*expressions))
         ]...)
end

"""
    scaleMinMax(expressions::Array{Float64, 1})::Array{Float64, 1}

Linearly scale `expressions` into the interval [0..1], usable in
`expressionColors`.
"""
function scaleMinMax(expressions::Array{Float64, 1})::Array{Float64, 1} #TODO quantiles?
    expressions .-= minimum(expressions)
    m = maximum(expressions)
    if m > 0
        expressions ./= m
    end
    expressions
end
"""
    scaleNorm(expressions::Array{Float64, 1})::Array{Float64, 1}

Scale `expressions` to quantile in their empirical normal distribution, i.e. to [0..1], usable in
`expressionColors`.
"""
function scaleNorm(expressions::Array{Float64, 1})::Array{Float64, 1}
    len = length(expressions)
    if len==0
        return []
    end

    # compute the empirical distribution
    mu = sum(expressions)/len
    var = sum((expressions.-mu).^2)/len

    if var==0
        var=1 #save the day
    end

    dist=Distributions.Normal(mu, sqrt(var))

    Distributions.cdf.(dist, expressions)
end
