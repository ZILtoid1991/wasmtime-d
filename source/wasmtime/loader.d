module wasmtime.loader;

import bindbc.loader;
import wasmtime.funcs;

enum WasmtimeSupport {
    noLibrary,
    badLibrary,
    v20_0,
    v20_0_min,
}

private {
    SharedLib lib;
    WasmtimeSupport loadedVersion;
}

void unloadWasmtime() {
    if (lib != invalidHandle) lib.unload;
}

WasmtimeSupport loadedWasmtimeVersion() {
    return loadedVersion;
}

WasmtimeSupport loadWasmtime(bool min = false) {
    version(Windows) {
        const(char)[][2] libNames = [
            "wasmtime.dll\0",
            "wasmtime-min.dll\0"
        ];
    } else {
        const(char)[][2] libNames = [
            "wasmtime.so\0",
            "wasmtime-min.so\0"
        ];
    }
    WasmtimeSupport result;
    foreach(name; libNames){
		result = loadWasmtime(name.ptr, min);
		if(result != WasmtimeSupport.noLibrary) return result;
	}
	return result;
}

WasmtimeSupport loadWasmtime(const(char)* libname, bool min = false) {
    lib = load(libname);
    if (lib == invalidHandle) return WasmtimeSupport.noLibrary;
    auto errcount = errorCount();
    loadFuncs(lib, min);
    if (errcount != errorCount) return WasmtimeSupport.badLibrary;
    if (min) return WasmtimeSupport.v20_0_min;
    return WasmtimeSupport.v20_0;
}