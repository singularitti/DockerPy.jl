module Containers

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface
using DockerPy.Images: Image

export Container, exec_run, pause, reload, rename, restart, start, stats, stop

mutable struct Container
    o::PyObject
end
Container() = Container(docker.models.Container())
Container(
    image::Image;
    command = nothing,
    stdout = true,
    stderr = false,
    remove = false,
    kwargs...,
) = image.client.containers.run(image.id, command, stdout, stderr, remove, kwargs...)

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
    exec_result = PyObject(container).exec_run(
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
    )
    if stream || socket || detach
        @warn "`detach`, `stream` or `socket` is `true`! Unable to determine if there is an error!"
    else
        exit_code = first(exec_result)
        if !iszero(exit_code)
            @error "the exit code `$exit_code` is not zero! Something wrong happened!"
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

Base.collect(x::Collection{Container}) = map(Container, PyObject(x).list())
Base.get(x::Collection{Container}, container_id) = Container(PyObject(x).get(container_id))
Base.empty!(x::Collection{Container}, filters = nothing) =
    PyObject(x).prune(filters = filters)

@pyinterface Container

end # module Containers
