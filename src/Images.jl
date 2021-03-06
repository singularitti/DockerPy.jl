module Images

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface

export Image, history, reload, save, tag, build, push, pull, search

mutable struct Image
    o::PyObject
end
Image() = Image(docker.models.Image())

history(x::Image) = PyObject(x).history()
reload(x::Image) = PyObject(x).reload()
save(x::Image; chunk_size = 2097152, named = false) =
    PyObject(x).save(chunk_size = chunk_size, named = named)
tag(x::Image, repository; tag = nothing, kwargs...) =
    PyObject(x).tag(repository, tag = tag, kwargs...)
Base.show(io::IO, x::Image) = print(
    io,
    "Image(tag = \"$(PyObject(x).tags[1])\", short_id = \"$(PyObject(x).short_id)\")",
)

const ImageCollection = Collection{Image}

function build(
    x::ImageCollection;
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
pull(x::ImageCollection, repository; tag = nothing, kwargs...) =
    Image.(PyObject(x).pull(repository, tag = tag, kwargs...))
push(x::ImageCollection, repository; tag = nothing, kwargs...) =
    PyObject(x).pull(repository, tag = tag, kwargs...)
search(x::ImageCollection, term::AbstractString) = PyObject(x).search(term)
Base.rm(x::ImageCollection, image; force::Bool = false, noprune::Bool = false) =
    PyObject(x).remove(image, force = force, noprune = noprune)
Base.collect(x::ImageCollection) = map(Image, PyObject(x).list(all = true))
Base.get(x::ImageCollection, name::AbstractString) = Image(PyObject(x).get(name))
Base.empty!(x::ImageCollection, filters = nothing) = PyObject(x).prune(filters = filters)

@pyinterface Image

end # module Images
