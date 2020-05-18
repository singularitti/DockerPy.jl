module Client

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface
using DockerPy.Images: Image
using DockerPy.Containers: Container

export DockerClient, from_env, images, containers, events, datausage, info, login, ping, version

mutable struct DockerClient
    o::PyObject
end
DockerClient(;
    base_url = nothing,
    version = "1.35",
    timeout = 60,
    tls = false,
    user_agent = "docker-sdk-python/$version",
    credstore_env = nothing,
) = DockerClient(docker.client.DockerClient(
    base_url = base_url,
    version = version,
    timeout = timeout,
    tls = tls,
    user_agent = user_agent,
    credstore_env = credstore_env,
))

images(x::DockerClient) = Collection{Image}(PyObject(x).images)
containers(x::DockerClient) = Collection{Container}(PyObject(x).containers)
events(x::DockerClient) = PyObject(x).events()
datausage(x::DockerClient) = Dict{String,Any}(PyObject(x).df())
info(x::DockerClient) = Dict{String,Any}(PyObject(x).info())
login(
    x::DockerClient,
    username;
    password = nothing,
    email = nothing,
    registry = nothing,
    reauth = false,
    dockercfg_path = nothing,
) = PyObject(x).login(
    username,
    password = password,
    email = email,
    registry = registry,
    dockercfg_path = dockercfg_path,
)
ping(x::DockerClient) = PyObject(x).ping()
version(x::DockerClient) = Dict{String,Any}(PyObject(x).version())

from_env(;
    version = v"1.35",
    timeout,
    ssl_version,
    assert_hostname,
    environment = ENV,
    credstore_env,
) = DockerClient(docker.from_env())

@pyinterface DockerClient

end # module Client
