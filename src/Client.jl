module Client

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface
using DockerPy.Images: Image
using DockerPy.Containers: Container

export DockerClient, from_env, images, containers

mutable struct DockerClient
    o::PyObject
end
DockerClient() = DockerClient(docker.client.DockerClient())

images(client::DockerClient) = Collection{Image}(PyObject(client).images)
containers(client::DockerClient) = Collection{Container}(PyObject(client).containers)

from_env() = DockerClient(docker.from_env())

@pyinterface DockerClient

end # module Client
