module Images

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface

export Image

mutable struct Image
    o::PyObject
end
Image() = Image(docker.models.Image())

Base.collect(x::Collection{Image}) = map(Image, PyObject(x).list(all = true))
Base.get(x::Collection{Image}, name::AbstractString) = Image(PyObject(x).get(name))
Base.empty!(x::Collection{Image}, filters = nothing) = PyObject(x).prune(filters = filters)

@pyinterface Image

end # module Images
