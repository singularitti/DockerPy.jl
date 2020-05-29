module Volumes

using PyCall: PyObject

using DockerPy: Collection, docker, @pyinterface

export reload

mutable struct Volume
    o::PyObject
end
Volume() = Volume(docker.models.volumes.Volume())

reload(x::Volume) = PyObject(x).reload()
Base.rm(x::Volume; kwargs...) = PyObject(x).remove(kwargs...)

const VolumeCollection = Collection{Volume}

Volume(x::VolumeCollection; name = nothing, kwargs...) =
    Volume(PyObject(x).create(name = name, kwargs...))

Base.collect(x::VolumeCollection) = map(Volume, PyObject(x).list())
Base.get(x::VolumeCollection, volume_id) = Volume(PyObject(x).get(volume_id))
Base.empty!(x::VolumeCollection, filters = nothing) = PyObject(x).prune(filters = filters)

@pyinterface Volume

end # module Volumes
