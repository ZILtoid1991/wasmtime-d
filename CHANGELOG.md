# v0.2.0-beta

* Fixed a bug with `WasmtimeFunc.createFuncBinding`, which caused D functions with arguments to fail.
* Added `WasmtimeFunc.createMethodBinding` for binding class methods (untested due to `externref` invocating is either undocumented or nonexistent in the D WASM ABI).
* Added `buildCorrectEnvironment`, shich builds the appropriate environment from the supplied imports (see examples on use).
* Added testcases/examples written in D, use `ldc2 -mtriple=wasm32-unknown-unknown-wasm -betterC -L-allow-undefined <filename>` to compile them.

# v0.1.0

Made two more versions working, this required some tweaking of the currently available functions.

# v0.1.0-alpha

Initial release.
