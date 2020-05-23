module Containers

using PyCall: PyObject, pybytes

using DockerPy: Collection, docker, @pyinterface
using DockerPy.Images: Image

export Container,
    DockerPath,
    attach,
    attach_socket,
    exec_run,
    pause,
    unpause,
    reload,
    rename,
    restart,
    start,
    stats,
    stop,
    get_archive,
    put_archive

mutable struct Container
    o::PyObject
end
Container() = Container(docker.models.Container())

const ContainerCollection = Collection{Container}

Container(x::ContainerCollection, image::Image; kwargs...) =
    Container(PyObject(x).create(PyObject(image); kwargs...))

ExecResult(exit_code, output) = (exit_code = exit_code, output = output)
ExecResult(x) = ExecResult(x...)

struct DockerPath
    container::Container
    path::AbstractString
end

"""
    attach(container::Container; stdout = true, stderr = true, stream = false, logs = false, demux = false)

Attach to this container.

# Arguments
- `stdout::Bool`: include stdout.
- `stderr::Bool`: include stderr.
- `stream::Bool`: return container output progressively as an iterator of strings, rather than a single string.
- `logs::Bool`: include the container’s previous output.
"""
attach(x::Container; kwargs...) = PyObject(x).attach(kwargs...)
"""
    attach_socket(container::Container, params = nothing, ws = false)

Like `attach`, but returns the underlying socket-like object for the HTTP request.
"""
attach_socket(x::Container; kwargs...) = PyObject(x).attach_socket(kwargs...)
function exec_run(
    x::Container,
    cmd;
    stdout = true,
    stderr = true,
    stdin = false,
    tty = false,
    privileged = false,
    user = "",
    detach = false,
    stream = false,
    socket = false,
    environment = nothing,
    workdir = nothing,
    demux = false,
)
    exec_result = ExecResult(PyObject(x).exec_run(
        cmd,
        stdout,
        stderr,
        stdin,
        tty,
        privileged,
        user,
        detach,
        stream,
        socket,
        environment,
        workdir,
        demux,
    ))
    if stream || socket || detach
        @warn "`detach`, `stream` or `socket` is `true`! Unable to determine if there is an error!"
    else
        if !iszero(exec_result.exit_code)
            @error "the exit code is not zero! Something wrong happened!"
        end
    end
    return exec_result
end # function exec_run
pause(x::Container) = PyObject(x).pause()
unpause(x::Container) = PyObject(x).unpause()
reload(x::Container) = PyObject(x).reload()
rename(x::Container, name::AbstractString) = PyObject(x).rename(name)
restart(x::Container; timeout = nothing) = PyObject(x).restart(timeout = timeout)
start(x::Container) = PyObject(x).start()
stats(x::Container; decode::Bool = false, stream::Bool = true) =
    PyObject(x).stats(decode = decode, stream = stream)
stop(x::Container, timeout = nothing) = PyObject(x).stop(timeout = timeout)
get_archive(x::Container, path, chunk_size = 2097152) =
    PyObject(x).get_archive(path, chunk_size = chunk_size)
put_archive(x::Container, path, data) = PyObject(x).put_archive(path, data)
function Base.cp(src::DockerPath, dst::AbstractString)
    container, path = src.container, src.path
    bits, _ = container.get_archive(path)
    open(dst, "w") do io
        for chunk in bits
            write(io, chunk)
        end
    end
end # function Base.cp
function Base.cp(src::AbstractString, dst::DockerPath)
    put_archive(dst.container, dst.path, pybytes(read(src)))
end # function Base.cp
Base.kill(x::Container, signal = nothing) = PyObject(x).kill(signal)
Base.rm(x::Container; kwargs...) = PyObject(x).remove(kwargs...)
Base.show(io::IO, x::Container) =
    print(io, "Container(name = \"$(x.name)\", short_id = \"$(x.short_id)\")")

Base.collect(x::ContainerCollection) = map(Container, PyObject(x).list())
Base.get(x::ContainerCollection, container_id) = Container(PyObject(x).get(container_id))
Base.empty!(x::ContainerCollection, filters = nothing) =
    PyObject(x).prune(filters = filters)

@pyinterface Container

end # module Containers
