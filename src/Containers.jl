module Containers

using PyCall: PyObject

using DockerPy: docker, @pyinterface

export Container

mutable struct Container
    o::PyObject
end
Container() = Container(docker.models.Container())

exec_run(
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
) = PyObject(container).exec_run(
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

Base.kill(container::Container, signal = nothing) = PyObject(container).kill(signal)

@pyinterface Container

end # module Containers
