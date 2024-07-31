# Codegen example

There is an example of injecting types decribed by [json-schema](https://json-schema.org/) into `C++` and `typescript` program.

## Short way

Inspect artifacts in `test-regress/out-ref` directory.

## Long way

1. Install deps: `stage/install-all.sh`. This may require to restart `shell` due to `NVM`.
2. Install `conan`: `pip3 install -q --user conan==1.64.1`.
    If using `conan` for the first time, do not ignore `libstdc++` related warning. Fix it with:
```
    conan profile update settings.compiler.libcxx=libstdc++11 default
```
3. `cd test-cpp && ./build-simple.sh`
4. `cd test-ts && npm i && npm run test`
