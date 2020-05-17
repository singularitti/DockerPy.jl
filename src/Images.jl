module Images

using PyCall: PyObject

using DockerPy: docker, @pyinterface

export Image

mutable struct Image
    o::PyObject
end
Image() = Image(docker.models.Image())

@pyinterface Image

end # module Images
