module Containers

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface
using DockerPy.Images: Image

export Container, exec_run, pause, reload, rename, restart, start, stats, stop

mutable struct Container
    o::PyObject
end
Container() = Container(docker.models.Container())

const ContainerCollection = Collection{Container}

Container(x::ContainerCollection, image::Image; kwargs...) =
    Container(PyObject(x).create(PyObject(image); kwargs...))

ExecResult(exit_code, output) = (exit_code = exit_code, output = output)
ExecResult(x) = ExecResult(x...)

function exec_run(
    container::Container,
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
    exec_result = ExecResult(PyObject(container).exec_run(
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
pause(container::Container) = PyObject(container).pause()
reload(container::Container) = PyObject(container).reload()
rename(container::Container, name::AbstractString) = PyObject(container).rename(name)
restart(container::Container; timeout = nothing) =
    PyObject(container).restart(timeout = timeout)
start(container::Container) = PyObject(container).start()
stats(container::Container; decode::Bool = false, stream::Bool = true) =
    PyObject(container).stats(decode = decode, stream = stream)
stop(container::Container, timeout = nothing) = PyObject(container).stop(timeout = timeout)
Base.kill(container::Container, signal = nothing) = PyObject(container).kill(signal)
Base.show(io::IO, x::Container) =
    print(io, "Container(name = \"$(x.name)\", short_id = \"$(x.short_id)\")")

Base.collect(x::ContainerCollection) = map(Container, PyObject(x).list())
Base.get(x::ContainerCollection, container_id) = Container(PyObject(x).get(container_id))
Base.empty!(x::ContainerCollection, filters = nothing) =
    PyObject(x).prune(filters = filters)

@pyinterface Container

end # module Containers
