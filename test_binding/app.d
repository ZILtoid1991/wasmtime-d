module app;

import wasmtime;
import wasmtime.loader;
import wasmtime.types;
import wasmtime.staticfuncs;
import wasmtime_nat.wrapper;
import wasmtime_nat.enums;
import std.stdio;
import std.conv : to;

int main(string[] args) {
    loadWasmtime();
    if (args.length <= 1) args ~= "";
    switch (args[1]) {
        case "hellod": return helloDMain();
        case "hellod2": return helloDMain2();
        case "gcd": return gcdMain(args[2..$]);
        case "gcd2": return gcdMain2(args[2..$]);
        case "linearMemory": return linearMemoryMain();
        case "linking": return linkingMain();
        case "environment": return environmentMain();
        case "classRef": return classRefMain(args[2..$]);
        default: return helloMain();
    }
}

//Begin of hello world example
extern(C)
wasm_trap_t* helloCallback(void* env, wasmtime_caller_t* caller, const WasmtimeVal* args, size_t nargs, 
        WasmtimeVal* res, size_t nres) nothrow {
    try {
        writeln("Calling back...");
        writeln("Hello World!");
    } catch (Exception e) {

    }
    return null;
}

int helloMain() {
    writeln("Initializing...");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File(".examples/hello.wat", "r");
    ulong size = file.size();
    WasmByteVec wat = new WasmByteVec(cast(size_t)size);
    file.rawRead(wat.backend.data[0..wat.backend.size]);
    file.close();

    WasmByteVec wasm = new WasmByteVec();
    WasmtimeError error = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    if (error) {
        writeln("Failed to parse WAT. Error message:");
        writeln(error);
        return 1;
    }

    writeln("Compiling module...");
    WasmtimeModule mod;
    error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }

    writeln("Creating callback...");
    wasm_functype_t* hello_ty = wasm_functype_new_0_0();
    WasmtimeFunc hello = new WasmtimeFunc(context, new WasmFunctype(hello_ty), &helloCallback, null, null);

    writeln("Instantiating module...");
    WasmTrap trap;
    WasmtimeInstance instance;
    WasmtimeExtern _import;
    _import.kind = WasmExternkind.Func;
    _import.of.func = hello.backend;
    instance = new WasmtimeInstance(context, mod, [_import]);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("Extracting export...");
    WasmtimeExtern run = instance.exportGet("run");
    assert(run.kind == WasmExternkind.Func);

    writeln("Calling export...");
    error = new WasmtimeFunc(context, run.of.func).call([], [], trap);
    if (error || trap) {
        writeln("Failed to compile module. Error message:");
        if (error) writeln(error);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("All finished!");
    return 0;
}
//end of hello world example
//begin of modified hello world example
void helloCallbackD() {
    writeln("Calling back...");
    writeln("Hello D!");
}
int helloDMain() {
    writeln("Initializing...");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File(".examples/hello.wat", "r");
    ulong size = file.size();
    WasmByteVec wat = new WasmByteVec(cast(size_t)size);
    file.rawRead(wat.backend.data[0..wat.backend.size]);
    file.close();

    WasmByteVec wasm = new WasmByteVec();
    WasmtimeError error = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    if (error) {
        writeln("Failed to parse WAT. Error message:");
        writeln(error);
        return 1;
    }

    writeln("Compiling module...");
    WasmtimeModule mod;
    error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }

    writeln("Creating callback...");
    WasmtimeFunc hello = WasmtimeFunc.createFuncBinding!(helloCallbackD)(context);

    writeln("Instantiating module...");
    WasmTrap trap;
    WasmtimeInstance instance;
    WasmtimeExtern _import;
    _import.kind = WasmExternkind.Func;
    _import.of.func = hello.backend;
    instance = new WasmtimeInstance(context, mod, [_import]);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("Extracting export...");
    WasmtimeExtern run = instance.exportGet("run");
    assert(run.kind == WasmExternkind.Func);

    writeln("Calling export...");
    WasmtimeFunc wasmentry = new WasmtimeFunc(context, run.of.func);
    auto funcResult = wasmentry(0);
    if (funcResult.error || funcResult.trap) {
        writeln("Failed to compile module. Error message:");
        if (funcResult.error) writeln(funcResult.error);
        if (funcResult.trap) {
            wasmtime_trap_code_t code;
            funcResult.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("All finished!");
    return 0;
}
int helloDMain2() {
    writeln("Initializing...");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File("examples/hellowasmtime.wasm", "r");
    ulong size = file.size();
    WasmByteVec wasm = new WasmByteVec(cast(size_t)size);
    file.rawRead(wasm.backend.data[0..wasm.backend.size]);
    file.close();

    // WasmByteVec wasm = new WasmByteVec();
    // WasmtimeError error = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    // if (error) {
        // writeln("Failed to parse WAT. Error message:");
        // writeln(error);
        // return 1;
    // }

    writeln("Compiling module...");
    WasmtimeModule mod;
    WasmtimeError error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }

    writeln("Creating callback...");
    WasmtimeFunc hello = WasmtimeFunc.createFuncBinding!(helloCallbackD)(context);

    writeln("Instantiating module...");
    WasmTrap trap;
    WasmtimeInstance instance;
    WasmtimeExtern _import;
    _import.kind = WasmExternkind.Func;
    _import.of.func = hello.backend;
    instance = new WasmtimeInstance(context, mod, [_import]);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("Extracting export...");
    WasmtimeExtern run = instance.exportGet("_start");
    assert(run.kind == WasmExternkind.Func);

    writeln("Calling export...");
    WasmtimeFunc wasmentry = new WasmtimeFunc(context, run.of.func);
    auto funcResult = wasmentry(0);
    if (funcResult.error || funcResult.trap) {
        writeln("Failed to compile module. Error message:");
        if (funcResult.error) writeln(funcResult.error);
        if (funcResult.trap) {
            wasmtime_trap_code_t code;
            funcResult.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("All finished!");
    return 0;
}
//end of modified hello world example
//begin of GCD example
int gcdMain(string[] args) {
    assert(args.length >= 2, "Not enough arguments.");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();
    
    File file = File(".examples/gcd.wat", "r");
    ulong size = file.size();
    WasmByteVec wat = new WasmByteVec(cast(size_t)size);
    file.rawRead(wat.backend.data[0..wat.backend.size]);

    WasmByteVec wasm = new WasmByteVec();
    WasmtimeError error = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    if (error) {
        writeln("Failed to parse WAT. Error message:");
        writeln(error);
        return 1;
    }

    WasmtimeModule mod;
    error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }
    
    WasmtimeInstance instance;
    instance = new WasmtimeInstance(context, mod, []);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    WasmtimeExtern run = instance.exportGet("gcd");
    assert(run.kind == WasmExternkind.Func);

    WasmtimeFunc gcdFunc = new WasmtimeFunc(context, run.of.func);
    int a = args[0].to!int;
    int b = args[1].to!int;
    WasmtimeResult gcdRes = gcdFunc(1, a, b);
    if (gcdRes.error || gcdRes.trap) {
        writeln("Failed to compile module. Error message:");
        if (gcdRes.error) writeln(gcdRes.error);
        if (gcdRes.trap) {
            wasmtime_trap_code_t code;
            gcdRes.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }
    assert(gcdRes.retVal.length);
    assert(gcdRes.retVal[0].kind == WasmtimeValkind.I32);
    writeln("Result: ", gcdRes.retVal[0].of.i32);
    return 0;
}
int gcdMain2(string[] args) {
    assert(args.length >= 2, "Not enough arguments.");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File("examples/gcd.wasm", "r");
    ulong size = file.size();
    WasmByteVec wasm = new WasmByteVec(cast(size_t)size);
    file.rawRead(wasm.backend.data[0..wasm.backend.size]);

    // WasmByteVec wasm = new WasmByteVec();
    WasmtimeError error;// = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    // if (error) {
        // writeln("Failed to parse WAT. Error message:");
        // writeln(error);
        // return 1;
    // }

    WasmtimeModule mod;
    error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }

    WasmtimeInstance instance;
    instance = new WasmtimeInstance(context, mod, []);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    WasmtimeExtern run = instance.exportGet("gcd");
    assert(run.kind == WasmExternkind.Func);

    WasmtimeFunc gcdFunc = new WasmtimeFunc(context, run.of.func);
    int a = args[0].to!int;
    int b = args[1].to!int;
    WasmtimeResult gcdRes = gcdFunc(1, a, b);
    if (gcdRes.error || gcdRes.trap) {
        writeln("Failed to compile module. Error message:");
        if (gcdRes.error) writeln(gcdRes.error);
        if (gcdRes.trap) {
            wasmtime_trap_code_t code;
            gcdRes.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }
    assert(gcdRes.retVal.length);
    assert(gcdRes.retVal[0].kind == WasmtimeValkind.I32);
    writeln("Result: ", gcdRes.retVal[0].of.i32);
    return 0;
}
int linearMemoryMain() {
    writeln("Initializing...");
    WasmEngine engine = new WasmEngine();
    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    WasmtimeContext context = store.context();

    File file = File(".examples/memory.wat", "r");
    ulong size = file.size();
    WasmByteVec wat = new WasmByteVec(cast(size_t)size);
    file.rawRead(wat.backend.data[0..wat.backend.size]);

    WasmByteVec wasm = new WasmByteVec();
    WasmtimeError error = wat2wasm(cast(const(char)[])wat.backend.data[0..wat.backend.size], wasm);
    if (error) {
        writeln("Failed to parse WAT. Error message:");
        writeln(error);
        return 1;
    }

    WasmtimeModule mod;
    error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }

    WasmtimeInstance instance;
    instance = new WasmtimeInstance(context, mod, []);
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    WasmtimeMemory memory;
    WasmtimeFunc sizeFunc, loadFunc, storeFunc;
    WasmtimeExtern item;

    item = instance.exportGet("memory");
    assert(!instance.lastError);
    memory = new WasmtimeMemory(context, item.of.memory);

    item = instance.exportGet("size");
    assert(!instance.lastError);
    sizeFunc = new WasmtimeFunc(context, item.of.func);

    item = instance.exportGet("load");
    assert(!instance.lastError);
    loadFunc = new WasmtimeFunc(context, item.of.func);

    item = instance.exportGet("store");
    assert(!instance.lastError);
    storeFunc = new WasmtimeFunc(context, item.of.func);

    writeln("Checking memory...");
    assert(memory.size() == 2);
    assert(memory.dataSize() == 0x20000);
    assert(memory.data()[0] == 0);
    assert(memory.data()[0x1000] == 1);
    assert(memory.data()[0x1003] == 4);

    assert(sizeFunc(1).get!int() == 2);
    assert(loadFunc(1, 0).get!int() == 0);
    assert(loadFunc(1, 0x1000).get!int() == 1);
    assert(loadFunc(1, 0x1003).get!int() == 4);
    assert(loadFunc(1, 0x1_ffff).get!int() == 0);
    assert(loadFunc(1, 0x2_0000).trap);

    writeln("Mutating memory...");
    memory.data()[0x1003] = 0x05;
    storeFunc(0, 0x1002, 6);
    assert(storeFunc(0, 0x2_0000, 0).trap);

    assert(memory.data()[0x1002] == 6);
    assert(memory.data()[0x1003] == 5);
    assert(loadFunc(1, 0x1002).get!int() == 6);
    assert(loadFunc(1, 0x1003).get!int() == 5);

    writeln("Growing memory...");
    ulong oldSize;
    if (memory.grow(1, &oldSize)) {
        writeln("Failed to grow memory: ", memory.lastError_D.toString);
    }
    assert(memory.size() == 3);
    assert(memory.dataSize() == 0x3_0000);

    assert(!(loadFunc(1, 0x2_0000).trap));
    assert(!(storeFunc(0, 0x2_0000, 0).trap));
    assert(loadFunc(1, 0x3_0000).trap);
    assert(storeFunc(0, 0x3_0000, 0).trap);

    assert(memory.grow(1, &oldSize));
    memory.lastError_D = null;
    assert(!memory.grow(0, &oldSize), memory.lastError_D.toString);

    writeln("Creating stand-alone memory...");
    WasmLimits limits = WasmLimits(5, 5);
    WasmMemorytype memoryType = new WasmMemorytype(limits);
    WasmtimeMemory memory2 = new WasmtimeMemory(context, memoryType);
    assert(!memory2.lastError_D, memory2.lastError_D.toString);
    assert(memory2.size() == 5);
    return 0;
}
int wasiMain() {
    return 0;
}
int linkingMain() {
    writeln("Initializing...");
    WasmtimeError error = null;
    WasmTrap trap = null;
    WasmEngine engine = new WasmEngine();
    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    WasmtimeContext context = store.context();

    File file1 = File(".examples/linking1.wat", "r");
    File file2 = File(".examples/linking2.wat", "r");
    ulong size1 = file1.size();
    ulong size2 = file2.size();
    WasmByteVec linkingFile1 = new WasmByteVec(cast(size_t)size1);
    WasmByteVec linkingFile2 = new WasmByteVec(cast(size_t)size2);
    file1.rawRead(linkingFile1.backend.data[0..linkingFile1.backend.size]);
    file2.rawRead(linkingFile2.backend.data[0..linkingFile2.backend.size]);
    
    writeln("Compiling...");
    WasmByteVec linkingBC1 = new WasmByteVec();
    WasmByteVec linkingBC2 = new WasmByteVec();
    error = wat2wasm(cast(const(char)[])linkingFile1.backend.data[0..linkingFile1.backend.size], linkingBC1);
    assert(!error, error.toString());
    error = wat2wasm(cast(const(char)[])linkingFile2.backend.data[0..linkingFile2.backend.size], linkingBC2);
    assert(!error, error.toString());
    writeln("Creating modules...");
    WasmtimeModule linkingMod1, linkingMod2;
    
    error = WasmtimeModule.create(engine, linkingBC1.backend.data[0..linkingBC1.backend.size], linkingMod1);
    assert(!error, error.toString());
    error = WasmtimeModule.create(engine, linkingBC2.backend.data[0..linkingBC2.backend.size], linkingMod2);
    assert(!error, error.toString());

    writeln("Setting up WASI...");
    WasiConfig wasiCfg = new WasiConfig();
    wasiCfg.inheritArgv();
    wasiCfg.inheritEnv();
    wasiCfg.inheritStdin();
    wasiCfg.inheritStdout();
    wasiCfg.inheritStderr();

    error = context.setWasi(wasiCfg);
    assert(!error, error.toString());

    writeln("Linking...");
    WasmtimeLinker linker = new WasmtimeLinker(engine);
    error = linker.defineWASI();
    assert(!error, error.toString());

    WasmtimeInstance linking2;
    error = linker.instantiate(context, linkingMod2, linking2, trap);
    assert(!error, error.toString());

    error = linker.defineInstance(context, "linking2", linking2);
    assert(!error, error.toString());

    WasmtimeInstance linking1;
    error = linker.instantiate(context, linkingMod1, linking1, trap);
    assert(!error, error.toString());

    error = linker.defineInstance(context, "linking1", linking1);
    assert(!error, error.toString());

    writeln("Executing main function...");
    WasmtimeFunc runFunc = new WasmtimeFunc(context, linking1.exportGet("run").of.func);
    WasmtimeResult result = runFunc(0);
    assert(!result.error, result.error.toString());
    assert(!result.trap, result.trap.toString());

    return 0;
}
int add(int a, int b) {
    return a + b;
}
int sub(int a, int b) {
    return a - b;
}
int mul(int a, int b) {
    return a * b;
}
int div(int a, int b) {
    return a / b;
}
void writeInt(int var) {
    writeln("The value from the WASM script is: ", var);
}
void writeDouble(double var) {
    writeln("The value from the WASM script is: ", var);
}
int environmentMain() {
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File("examples/environment.wasm", "r");
    ulong size = file.size();
    WasmByteVec wasm = new WasmByteVec(cast(size_t)size);
    file.rawRead(wasm.backend.data[0..wasm.backend.size]);

    WasmtimeModule mod;
    WasmtimeError error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }
    WasmtimeFunc[] funcs = [
        WasmtimeFunc.createFuncBinding!(add)(context), WasmtimeFunc.createFuncBinding!(sub)(context),
        WasmtimeFunc.createFuncBinding!(mul)(context), WasmtimeFunc.createFuncBinding!(div)(context),
        WasmtimeFunc.createFuncBinding!(writeInt)(context)
    ];
    WasmtimeExtern[string][string] imports;
    imports["math"]["add"] = funcs[0].toExtern();
    imports["math"]["sub"] = funcs[1].toExtern();
    imports["math"]["mul"] = funcs[2].toExtern();
    imports["math"]["div"] = funcs[3].toExtern();
    imports["display"]["writeInt"] = funcs[4].toExtern();
    WasmTrap trap;
    WasmtimeInstance instance = new WasmtimeInstance(context, mod, buildCorrectEnvironment(mod, imports));
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }
    WasmtimeExtern run = instance.exportGet("_start");
    assert(run.kind == WasmExternkind.Func);
    WasmtimeFunc wasmentry = new WasmtimeFunc(context, run.of.func);
    auto funcResult = wasmentry(0);
    if (funcResult.error || funcResult.trap) {
        writeln("Failed to compile module. Error message:");
        if (funcResult.error) writeln(funcResult.error);
        if (funcResult.trap) {
            wasmtime_trap_code_t code;
            funcResult.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("All finished!");

    return 0;
}
class TestClass {
    int var1;
    int var2;
    this (int var1, int var2) {
        this.var1 = var1;
        this.var2 = var2;
    }
    double foo() {
        return cast(double)var1 / cast(double)var2;
    }
    double bar(int a, int b) {
        var1 = a;
        var2 = b;
        return foo();
    }
}
TestClass tc;
TestClass getClassRef() { return tc; }
int classRefMain(string[] args) {
    assert(args.length >= 2, "Not enough arguments.");
    WasmEngine engine = new WasmEngine();
    assert(engine.backend != null);

    tc = new TestClass(to!int(args[0]), to!int(args[1]));

    WasmtimeStore store = new WasmtimeStore(engine, null, null);
    assert(store.backend != null);
    WasmtimeContext context = store.context();

    File file = File("examples/classref.wasm", "r");
    ulong size = file.size();
    WasmByteVec wasm = new WasmByteVec(cast(size_t)size);
    file.rawRead(wasm.backend.data[0..wasm.backend.size]);

    WasmtimeModule mod;
    WasmtimeError error = WasmtimeModule.create(engine, cast(ubyte[])wasm.backend.data[0..wasm.backend.size], mod);
    if (error) {
        writeln("Failed to compile module. Error message:");
        writeln(error);
        return 1;
    }
    WasmtimeFunc[] funcs = [
        WasmtimeFunc.createFuncBinding!(add)(context), WasmtimeFunc.createFuncBinding!(sub)(context),
        WasmtimeFunc.createFuncBinding!(mul)(context), WasmtimeFunc.createFuncBinding!(div)(context),
        WasmtimeFunc.createFuncBinding!(writeInt)(context), WasmtimeFunc.createFuncBinding!(writeDouble)(context),
        WasmtimeFunc.createMethodBinding!(TestClass.foo)(context), WasmtimeFunc.createMethodBinding!(TestClass.bar)
        (context), WasmtimeFunc.createFuncBinding!(getClassRef)(context)
    ];
    WasmtimeExtern[string][string] imports;
    imports["math"]["add"] = funcs[0].toExtern();
    imports["math"]["sub"] = funcs[1].toExtern();
    imports["math"]["mul"] = funcs[2].toExtern();
    imports["math"]["div"] = funcs[3].toExtern();
    imports["display"]["writeInt"] = funcs[4].toExtern();
    imports["display"]["writeDouble"] = funcs[5].toExtern();
    imports["classreftest"]["foo"] = funcs[6].toExtern();
    imports["classreftest"]["bar"] = funcs[7].toExtern();
    imports["classreftest"]["getClassRef"] = funcs[8].toExtern();
    WasmTrap trap;
    WasmtimeInstance instance = new WasmtimeInstance(context, mod, buildCorrectEnvironment(mod, imports));
    if (WasmtimeInstance.lastError || WasmtimeInstance.lastTrap) {
        writeln("Failed to instantiate. Error message:");
        if (WasmtimeInstance.lastError) writeln(new WasmtimeError(WasmtimeInstance.lastError).toString);
        if (WasmtimeInstance.lastTrap) {
            wasmtime_trap_code_t code;
            new WasmTrap(WasmtimeInstance.lastTrap).code(code);
            writeln("Code: ", code);
        }
        return 1;
    }
    WasmtimeExtern run = instance.exportGet("_start");
    assert(run.kind == WasmExternkind.Func);
    WasmtimeFunc wasmentry = new WasmtimeFunc(context, run.of.func);
    auto funcResult = wasmentry(0);
    if (funcResult.error || funcResult.trap) {
        writeln("Failed to compile module. Error message:");
        if (funcResult.error) writeln(funcResult.error);
        if (funcResult.trap) {
            wasmtime_trap_code_t code;
            funcResult.trap.code(code);
            writeln("Code: ", code);
        }
        return 1;
    }

    writeln("All finished!");

    return 0;
}
