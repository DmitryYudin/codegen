from conans import ConanFile

class Pkg(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake"

    requires = (
        # direct
        "gtest/1.14.0",
        "fmt/10.2.1",
        "jsoncons/0.176.0",
        "nlohmann_json/3.11.3",
    )

    build_requires = (
    )

    default_options = {
    }

    def requirements(self):
        pass

    def build(self):
        cmake = CMake(self)
        cmake.verbose = False
        cmake.configure()
        cmake.build()
