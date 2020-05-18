module Images

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface

export Image

mutable struct Image
    o::PyObject
end
Image() = Image(docker.models.Image())

function build(
    x::Collection{Image};
    path::AbstractString,
    fileobj,
    tag::AbstractString,
    quiet::Bool,
    nocache::Bool,
    rm::Bool = false,
    timeout::Integer,
    custom_context::Bool,
    encoding::AbstractString,
    pull::Bool,
    forcerm::Bool,
    dockerfile::AbstractString,
    buildargs,
    container_limits,
    shmsize::Integer,
    labels,
    cache_from,
    target::AbstractString,
    network_mode::AbstractString,
    squash::Bool,
    extra_hosts,
    platform::AbstractString,
    isolation::AbstractString,
    use_config_proxy::Bool,
)
    result = PyObject(x).build(
        path = path,
        fileobj = fileobj,
        tag = tag,
        quiet = quiet,
        nocache = nocache,
        rm = rm,
        timeout = timeout,
        custom_context = custom_context,
        encoding = encoding,
        pull = pull,
        forcerm = forcerm,
        dockerfile = dockerfile,
        buildargs = buildargs,
        container_limits = container_limits,
        shmsize = shmsize,
        labels = labels,
        cache_from = cache_from,
        target = target,
        network_mode = network_mode,
        squash = squash,
        extra_hosts = extra_hosts,
        platform = platform,
        isolation = isolation,
        use_config_proxy = use_config_proxy,
    )
    return Image(result[1]), string(collect(result[2]))
end # function build
Base.collect(x::Collection{Image}) = map(Image, PyObject(x).list(all = true))
Base.get(x::Collection{Image}, name::AbstractString) = Image(PyObject(x).get(name))
Base.empty!(x::Collection{Image}, filters = nothing) = PyObject(x).prune(filters = filters)

@pyinterface Image

end # module Images
