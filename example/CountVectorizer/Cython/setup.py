from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy

extensions = [
    Extension("CythonVectorizer", sources=["CythonVectorizer.pyx"], language="c++",
    extra_compile_args=['-fopenmp'],
    extra_link_args=['-fopenmp'],
    include_dirs=[numpy.get_include()],)
]

setup(
    ext_modules = cythonize(extensions),
)