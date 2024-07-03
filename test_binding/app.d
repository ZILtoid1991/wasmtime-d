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
        case "gcd": return gcdMain(args[2..$]);
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