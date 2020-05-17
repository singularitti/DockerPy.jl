module Client

using PyCall: PyObject

using DockerPy: docker, @pyinterface
using DockerPy.Images: Image
using DockerPy.Containers: Container

export DockerClient, from_env, images, containers

mutable struct DockerClient
    o::PyObject
end
DockerClient() = DockerClient(docker.client.DockerClient())

images(client::DockerClient) = map(Image, PyObject(client).images.list())
containers(client::DockerClient) = map(Container, PyObject(client).containers.list())

from_env() = DockerClient(docker.from_env())

@pyinterface DockerClient

end # module Client
