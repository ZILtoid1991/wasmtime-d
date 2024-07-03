# wasmtime-d
D language bindings for wasmtime

# Features

* Dynamic library loading (static loading coming later).
* Full binding to the C API.
* A class-based API with automatic memory management.
* Templates generating automatic binding to D functions.

# Brief user guide

## Loading the library

The DLL/SO file can be loaded with the following function call:

```d
loadWasmtime();
```

Optionally it can accept an argument of type of null-terminated string, that specifies the path to the dynamic library, and a boolean argument of which is true then it loads the minimalistic version of the library. It returns an error code if something haven't gone right.

## Loading a file

Files can be loaded as such:

```d
File file = File("pathtofile/file.wat", "r");
ulong size = file.size();
WasmByteVec wat = new WasmByteVec(cast(size_t)size);
file.rawRead(wat.backend.data[0..wat.backend.size]);
```

Textual files can be compiled into WASM with the following function:

```d
WasmByteVec wasm = new WasmByteVec();
WasmtimeError error = wat2wasm(cast(const(char)[])source, wasm);
```

## Running WASM scripts

First, you need to initialize the WASM engine, the Wasmtime storage, and a context:

```d
WasmEngine engine = new WasmEngine();
WasmtimeStore store = new WasmtimeStore(engine, null, null);
WasmtimeContext context = store.context();
```

You can create a module as from a compiled file with the following function:

```d
WasmtimeModule mod;
WasmtimeError error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
```

Use the following factory function template to create an automatic binding to a D function, which can be called as an import function from the WASM script:

```d
WasmtimeFunc dFunc = WasmtimeFunc.createFuncBinding!(myDFunc)(context);
WasmtimeExtern dFuncAsExtern;
dFuncAsExtern.kind = WasmExternkind.Func;
dFuncAsExtern.of.func = dFunc.backend;
```

Creating a Wasmtime instance follows as:

```d
WasmtimeInstance instance = new WasmtimeInstance(context, mod, imports);
```

Extracting an export function, then executing it is as easy as:

```d
WasmtimeExtern run = instance.exportGet("run");
WasmtimeFunc wasmentrypoint = new WasmtimeFunc(context, run.of.func);
//Number is the expected return arguments, after that the function can accept any number of arguments as long as the variadic function is built to deal with it.
auto funcResult = wasmentrypoint(0);
```

(Manual binding is still available if needed.)

# Roadmap

* Basic functionality works as of now.
* Handling of classes, interfaces, and structs as arguments are untested.
* Automatic function binding generation template factory works, untested for function arguments.

## Things need to be done

* Shared memory handling.
* Member function binding generation.
* Asynchronous functions.