from setuptools import setup, Extension
from Cython.Build import cythonize
import sys

# Extension modülleri tanımla
extensions = [
    Extension("network", ["network.pyx"]),
    Extension("memory", ["memory.pyx"]),
    Extension("services", ["services.pyx"]),
    Extension("system_tweaks", ["system_tweaks.pyx"]),
    Extension("ui", ["ui.pyx"]),
]

setup(
    name='GamingOptimizer',
    ext_modules=cythonize(
        extensions,
        compiler_directives={
            'language_level': "3",
            'embedsignature': True
        }
    )
)