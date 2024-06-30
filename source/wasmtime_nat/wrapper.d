module wasmtime_nat.wrapper;
///Note to self on dtors: in some cases, they might cause issues, other times they'll be fine.
import wasmtime.types;
import wasmtime.funcs;
import wasmtime.staticfuncs;
import core.vararg;
public import wasmtime.types : wasm_byte_t, wasm_valkind_t;
public import wasmtime_nat.enums;
import std.typetuple;
import std.traits;
import std.utf;

class WasmVecTempl(string T, string S) {
    mixin(`alias BackendT = wasm_`~S~`_vec_t;`);
    BackendT backend;
    mixin(`alias BackendST = wasm_`~S~`_t;`);
    this(BackendT backend) @nogc nothrow {
        this.backend = backend;
    }
    /* this(BackendST[] arr) @nogc nothrow {
        mixin(`wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr);`);
    } */
    this() @nogc nothrow {
        mixin(`wasm_`~S~`_vec_new_empty(&backend);`);
    }
    this(size_t size) @nogc nothrow {
        mixin(`wasm_`~S~`_vec_new_uninitialized(&backend, size);`);
    }
    ~this() @nogc nothrow {
        mixin(`wasm_`~S~`_vec_delete(&backend);`);
    }
    /* mixin(
        `this(wasm_`~S~`_vec_t backend) @nogc nothrow @safe { this.backend = backend; }`~
        `this() @nogc nothrow { wasm_`~S~`_vec_new_empty(&backend); }`~
        `this(size_t size) @nogc nothrow { wasm_`~S~`_vec_new_uninitialized(&backend, size); }`~
        `~this() @nogc nothrow { wasm_`~S~`_vec_delete(&backend); }`
    ); */
    static if (T.length) {
        mixin(`alias OutT = `~T~`;`);
        OutT opIndex(size_t index) nothrow { 
            return new OutT(backend.data[index]); 
        }
        OutT opIndexAssign(OutT value, size_t index) nothrow { 
            backend.data[index] = value.backend;
            value.isInternalRef = true;
            return value;
        }
        mixin(
            `this(wasm_`~S~`_t*[] arr) @nogc nothrow { wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr); }`
        );
        /* mixin(
            T~` opIndex(size_t index) nothrow const { return new `~T~`(backend.data[index]); }`~T~
            ` opIndexAssign(`~T~` value, size_t index) nothrow { 
            backend.data[index] = value.backend;
            value.isInternalRef = true;
            return value;}`
        ); */
    } else {
        ref BackendST opIndex(size_t index) @nogc nothrow { 
            return backend.data[index]; 
        }
        this(BackendST[] arr) @nogc nothrow {
            mixin(`wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr);`);
        }
        //mixin(`this(wasm_`~S~`_t[] arr) @nogc nothrow { wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr); }`);
        /* mixin(`ref wasm_`~S~`_t opIndex(size_t index) @nogc nothrow { return backend.data[index]; }`); */
    }
}
package enum WasmStdDtor(string T) = `~this() @nogc nothrow { if (!isInternalRef) wasm_`~T~`_delete(backend); }`;
/**
 * Wrapper around `wasm_byte_vec_t`. Used to pass data in and out various functions.
 */
alias WasmByteVec = WasmVecTempl!("", "byte");
alias WasmName = WasmByteVec;
/** 
 * Wrapper around `wasm_config_t`. Global engine configuration. 
 * 
 * This structure represents global configuration used when constructing a `wasm_engine_t`. Functions used to modify
 * the object can be found as members of this class, for convenience sake.
 */
class WasmConfig {
    wasm_config_t* backend;
    this() @nogc nothrow {
        backend = wasm_config_new();
    }
    ~this() @nogc nothrow {
        wasm_config_delete(backend);
    }
    void debugInfoSet(bool b) @nogc nothrow {
        wasmtime_config_debug_info_set(backend, b);
    }
    void consumeFuelSet(bool b) @nogc nothrow {
        wasmtime_config_consume_fuel_set(backend, b);
    }
    void epochInterruptionSet(bool b) @nogc nothrow {
        wasmtime_config_epoch_interruption_set(backend, b);
    }
    void maxWasmStackSet(bool b) @nogc nothrow {
        wasmtime_config_max_wasm_stack_set(backend, b);
    }
    void wasmThreadsSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_threads_set(backend, b);
    }
    void wasmTailCallSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_tail_call_set(backend, b);
    }
    void wasmReferenceTypesSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_reference_types_set(backend, b);
    }
    void wasmFunctionReferencesSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_function_references_set(backend, b);
    }
    void wasmGCSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_gc_set(backend, b);
    }
    void wasmSIMDSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_simd_set(backend, b);
    }
    void wasmRelaxedSIMDSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_set(backend, b);
    }
    void wasmRelaxedSIMDdeterministicSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_deterministic_set(backend, b);
    }
    void wasmBulkMemorySet(bool b) @nogc nothrow {
        wasmtime_config_wasm_bulk_memory_set(backend, b);
    }
    void wasmMultiValueSet(bool b) @nogc nothrow {
        wasmtime_config_wasm_multi_value_set(backend, b);
    }
    void wasmMultiMemorySet(bool b) @nogc nothrow {
        wasmtime_config_wasm_multi_memory_set(backend, b);
    }
    void wasmMemory64Set(bool b) @nogc nothrow {
        wasmtime_config_wasm_memory64_set(backend, b);
    }
    void strategySet(wasmtime_strategy_t strategy) @nogc nothrow {
        wasmtime_config_strategy_set(backend, strategy);
    }
    void parallelCompilationSet(bool b) @nogc nothrow {
        wasmtime_config_parallel_compilation_set(backend, b);
    }
    void craneliftDebugVerifierSet(bool b) @nogc nothrow {
        wasmtime_config_cranelift_debug_verifier_set(backend, b);
    }
    void craneliftNANCanonicalizationSet(bool b) @nogc nothrow {
        wasmtime_config_cranelift_nan_canonicalization_set(backend, b);
    }
    void craneliftOptLevelSet(wasmtime_opt_level_t optLevel) @nogc nothrow {
        wasmtime_config_cranelift_opt_level_set(backend, optLevel);
    }
    void profilerSet(wasmtime_profiling_strategy_t profiling) @nogc nothrow {
        wasmtime_config_profiler_set(backend, profiling);
    }
    void staticMemoryForcedSet(bool b) @nogc nothrow {
        wasmtime_config_static_memory_forced_set(backend, b);
    }
    void staticMemoryMaximumSizeSet(uint64_t maxMem) @nogc nothrow {
        wasmtime_config_static_memory_maximum_size_set(backend, maxMem);
    }
    void staticMemoryGuardSizeSet(uint64_t stMem) @nogc nothrow {
        wasmtime_config_static_memory_guard_size_set(backend, stMem);
    }
    void dynamicMemoryGuardSizeSet(uint64_t dynMem) @nogc nothrow {
        wasmtime_config_dynamic_memory_guard_size_set(backend, dynMem);
    }
    void dynamicMemoryReservedFforGrowthSet(uint64_t memSize) @nogc nothrow {
        wasmtime_config_dynamic_memory_reserved_for_growth_set(backend, memSize);
    }
    void nativeUnwindInfoSet(bool b) @nogc nothrow {
        wasmtime_config_native_unwind_info_set(backend, b);
    }
    void cacheConfigLoad(const(char)* config) @nogc nothrow {
        wasmtime_config_cache_config_load(backend, config);
    }
    void targetSet(const(char)* config) @nogc nothrow {
        wasmtime_config_target_set(backend, config);
    }
    void craneliftFlagEnable(const(char)* config) @nogc nothrow {
        wasmtime_config_cranelift_flag_enable(backend, config);
    }
    void craneliftFlagSet(const(char)* key, const(char)* value) @nogc nothrow {
        wasmtime_config_cranelift_flag_set(backend, key, value);
    }
    void macosUseMachPortsSet(bool b) @nogc nothrow {
        wasmtime_config_macos_use_mach_ports_set(backend, b);
    }
    void hostMemoryCreatorSet(wasmtime_memory_creator_t* memCreator) @nogc nothrow {
        wasmtime_config_host_memory_creator_set(backend, memCreator);
    }
    void memoryInitCOWSet(bool b) @nogc nothrow {
        wasmtime_config_memory_init_cow_set(backend, b);
    }
    void asyncSupportSet(bool b) @nogc nothrow {
        wasmtime_config_async_support_set(backend, b);
    }
    void asyncStackSizeSet(uint64_t size) @nogc nothrow {
        wasmtime_config_async_stack_size_set(backend, size);
    }
}
/** 
 * Wrapper around `wasm_engine_t`. Compilation environment and configuration.
 * An engine is typically global in a program and contains all the configuration necessary for compiling wasm code.
 * An engine is safe to share between threads. Multiple stores can be created within the same engine with each store
 * living on a separate thread. Typically you'll create one engine for the lifetime of your program.
 */
class WasmEngine {
    wasm_engine_t* backend;
    this() @nogc nothrow {
        backend = wasm_engine_new();
    }
    this(WasmConfig cfg) @nogc nothrow {
        backend = wasm_engine_new_with_config(cfg.backend);
    }
    ~this() @nogc nothrow {
        wasm_engine_delete(backend);
    }
    void incrementEpoch() @nogc nothrow {
        wasmtime_engine_increment_epoch(backend);
    }
}
/** 
 * Wrapper around `wasm_store_t`. A collection of instances and wasm global items. It corresponds to the concept of an 
 * embedding store.
 */
class WasmStore {
    static WasmStore defStore;
    wasm_store_t* backend;
    static void createDefWasmStore(WasmEngine engine) nothrow {
        defStore = new WasmStore(engine);
    }
    this(WasmEngine engine) @nogc nothrow {
        backend = wasm_store_new(engine.backend);
    }
    ~this() @nogc nothrow {
        wasm_store_delete(backend);
    }
}
/** 
 * Wrapper around `wasm_valtype_t`. An object representing the type of a value.
 */
class WasmValtype {
    wasm_valtype_t* backend;
    bool isInternalRef;
    package this(wasm_valtype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    package this(const(wasm_valtype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_valtype_t*)backend;
        isInternalRef = true;
    }
    this(wasm_valkind_t kind) @nogc nothrow {
        backend = wasm_valtype_new(kind);
    }
    this(WasmValtype other) @nogc nothrow {
        backend = wasm_valtype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_valtype_delete(backend);
    }
    wasm_valkind_t kind() @nogc nothrow {
        return wasm_valtype_kind(backend);
    }
}
/** 
 * A list of wasm_valtype_t values.
 */
alias WasmValtypeVec = WasmVecTempl!("WasmValtype", "valtype");
class WasmFunctype {
    wasm_functype_t* backend;
    bool isInternalRef;
    this(wasm_functype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_functype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_functype_t*)backend;
        isInternalRef = true;
    }
    this(WasmValtypeVec params, WasmValtypeVec results) @nogc nothrow {
        backend = wasm_functype_new(&params.backend, &results.backend);
    }
    this(WasmFunctype other) @nogc nothrow {
        backend = wasm_functype_copy(other.backend);
    }
    this(WasmExterntype other) @nogc nothrow {
        backend = wasm_externtype_as_functype(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_functype_delete(backend);
    }
    WasmValtypeVec params() nothrow {
        return new WasmValtypeVec(*cast(wasm_valtype_vec_t*)wasm_functype_params(backend));
    }
    WasmValtypeVec results() nothrow {
        return new WasmValtypeVec(*cast(wasm_valtype_vec_t*)wasm_functype_results(backend));
    }
}
alias WasmFunctypeVec = WasmVecTempl!("WasmFunctype", "functype");
class WasmGlobaltype {
    wasm_globaltype_t* backend;
    bool isInternalRef;
    this(wasm_globaltype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_globaltype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_globaltype_t*)backend;
        isInternalRef = true;
    }
    this(WasmValtype type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type.backend, mutability);
    }
    this(wasm_valtype_t* type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type, mutability);
    }
    this(WasmGlobaltype other) @nogc nothrow {
        backend = wasm_globaltype_copy(other.backend);
    }
    this(WasmExterntype other) @nogc nothrow {
        backend = wasm_externtype_as_globaltype(other.backend);
    }
    ~this() {
        if (!isInternalRef) wasm_globaltype_delete(backend);
    }
    WasmValtype content() nothrow {
        return new WasmValtype(cast(wasm_valtype_t*)wasm_globaltype_content(backend));
    }
    wasm_mutability_t mutability() @nogc nothrow {
        return wasm_globaltype_mutability(backend);
    }
}
alias WasmGlobaltypeVec = WasmVecTempl!("WasmGlobaltype", "globaltype");
alias WasmLimits = wasm_limits_t;
class WasmTabletype {
    wasm_tabletype_t* backend;
    bool isInternalRef;
    this(wasm_tabletype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_tabletype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_tabletype_t*)backend;
        isInternalRef = true;
    }
    this(WasmValtype type, const WasmLimits limits) @nogc nothrow {
        backend = wasm_tabletype_new(type.backend, &limits);
    }
    this(WasmTabletype other) @nogc nothrow {
        backend = wasm_tabletype_copy(other.backend);
    }
    this(WasmExterntype other) @nogc nothrow {
        backend = wasm_externtype_as_tabletype(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_tabletype_delete(backend);
    }
    WasmValtype element() nothrow {
        return new WasmValtype(wasm_tabletype_element(backend));
    }
    const(WasmLimits) limits() @nogc nothrow {
        return *wasm_tabletype_limits(backend);
    }
}
alias WasmTabletypeVec = WasmVecTempl!("WasmTabletype", "tabletype");
class WasmMemorytype {
    wasm_memorytype_t* backend;
    bool isInternalRef;
    this(wasm_memorytype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_memorytype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_memorytype_t*)backend;
        isInternalRef = true;
    }
    this(const WasmLimits limits) @nogc nothrow {
        backend = wasm_memorytype_new(&limits);
    } 
    this(WasmMemorytype other) @nogc nothrow {
        backend = wasm_memorytype_copy(other.backend);
    }
    this(WasmExterntype other) @nogc nothrow {
        backend = wasm_externtype_as_memorytype(other.backend);
    }
    this(ulong min, bool maxPresent, ulong max, bool is64) @nogc nothrow {
        backend = wasmtime_memorytype_new(min, maxPresent, max, is64);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_memorytype_delete(backend);
    }
    WasmLimits limits() @nogc nothrow {
        return *wasm_memorytype_limits(backend);
    }
    ulong min() @nogc nothrow {
        return wasmtime_memorytype_minimum(backend);
    }
    bool max(ref ulong result) @nogc nothrow {
        return wasmtime_memorytype_maximum(backend, &result);
    }
    bool is64() @nogc nothrow {
        return wasmtime_memorytype_is64(backend);
    }
    bool isShared() @nogc nothrow {
        return wasmtime_memorytype_isshared(backend);
    }
}
alias WasmMemorytypeVec = WasmVecTempl!("WasmMemorytype", "memorytype");
class WasmExterntype {
    wasm_externtype_t* backend;
    bool isInternalRef;
    this(wasm_externtype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_externtype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_externtype_t*)backend;
        isInternalRef = true;
    }
    this(WasmFunctype other) @nogc nothrow {
        backend = wasm_functype_as_externtype(other.backend);
    }
    this(WasmGlobaltype other) @nogc nothrow {
        backend = wasm_globaltype_as_externtype(other.backend);
    }
    this(WasmTabletype other) @nogc nothrow {
        backend = wasm_tabletype_as_externtype(other.backend);
    }
    this(WasmMemorytype other) @nogc nothrow {
        backend = wasm_memorytype_as_externtype(other.backend);
    }
    this(WasmExterntype other) @nogc nothrow {
        backend = wasm_externtype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_externtype_delete(backend);
    }
    WasmExternkind kind() @nogc nothrow {
        return cast(WasmExternkind)wasm_externtype_kind(backend);
    }
}
alias WasmExterntypeVec = WasmVecTempl!("WasmExterntype", "externtype");
class WasmImporttype {
    wasm_importtype_t* backend;
    bool isInternalRef;
    this(wasm_importtype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_importtype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_importtype_t*)backend;
        isInternalRef = true;
    }
    this(WasmName mod, WasmName name, WasmExterntype kind) @nogc nothrow {
        backend = wasm_importtype_new(&mod.backend, &name.backend, kind.backend);
    }
    this(WasmImporttype other) @nogc nothrow {
        backend = wasm_importtype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_importtype_delete(backend);
    }
    WasmName mod() nothrow {
        return new WasmName(*cast(wasm_byte_vec_t*)wasm_importtype_module(backend));
    }
    WasmName name() nothrow {
        return new WasmName(*cast(wasm_byte_vec_t*)wasm_importtype_name(backend));
    }
    WasmExterntype type() nothrow {
        return new WasmExterntype(wasm_importtype_type(backend));
    }
}
alias WasmImporttypeVec = WasmVecTempl!("WasmImporttype", "importtype");
class WasmExporttype {
    wasm_exporttype_t* backend;
    bool isInternalRef;
    this(wasm_exporttype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_exporttype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_exporttype_t*)backend;
        isInternalRef = true;
    }
    this(WasmName name, WasmExterntype kind) @nogc nothrow {
        backend = wasm_exporttype_new(&name.backend, kind.backend);
    }
    this(WasmExporttype other) @nogc nothrow {
        backend = wasm_exporttype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_exporttype_delete(backend);
    }
    WasmExterntype type() nothrow {
        return new WasmExterntype(wasm_exporttype_type(backend));
    }
}
alias WasmExporttypeVec = WasmVecTempl!("WasmExporttype", "exporttype");
alias WasmVal = wasm_val_t;
alias WasmValVec = WasmVecTempl!("", "val");
class WasmRef {
    wasm_ref_t* backend;
    bool isInternalRef;
    this(wasm_ref_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_copy(other.backend);
    }
    this(WasmTrap other) @nogc nothrow {
        backend = wasm_trap_as_ref(other.backend);
    }
    this(WasmForeign other) @nogc nothrow {
        backend = wasm_foreign_as_ref(other.backend);
    }
    this(WasmModule other) @nogc nothrow {
        backend = wasm_module_as_ref(other.backend);
    }
    this(WasmFunction other) @nogc nothrow {
        backend = wasm_func_as_ref(other.backend);
    }
    this(WasmGlobal other) @nogc nothrow {
        backend = wasm_global_as_ref(other.backend);
    }
    this(WasmTable other) @nogc nothrow {
        backend = wasm_table_as_ref(other.backend);
    }
    this(WasmMemory other) @nogc nothrow {
        backend = wasm_memory_as_ref(other.backend);
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_as_ref(other.backend);
    }
    this(WasmInstance other) @nogc nothrow {
        backend = wasm_instance_as_ref(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_ref_delete(backend);
    }
    bool same(WasmRef other) @nogc nothrow const {
        return wasm_ref_same(other.backend, backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_ref_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_ref_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_ref_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
class WasmFrame {
    wasm_frame_t* backend;
    bool isInternalRef;
    this(wasm_frame_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_frame_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_frame_t*)backend;
        isInternalRef = true;
    }
    this(WasmFrame other) @nogc nothrow {
        backend = wasm_frame_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_frame_delete(backend);
    }

    WasmInstance instance() nothrow {
        return new WasmInstance(wasm_frame_instance(backend));
    }
    uint32_t funcIndex() @nogc nothrow const {
        return wasm_frame_func_index(backend);
    }
    size_t funcOffset() @nogc nothrow const {
        return wasm_frame_func_offset(backend);
    }
    size_t moduleOffset() @nogc nothrow const {
        return wasm_frame_module_offset(backend);
    }
    string funcName() nothrow {
        auto result = wasmtime_frame_func_name(backend);
        return cast(string)result.data[0..result.size];
    }
    string moduleName() nothrow {
        auto result = wasmtime_frame_module_name(backend);
        return cast(string)result.data[0..result.size];
    }
}
alias WasmFrameVec = WasmVecTempl!("WasmFrame", "frame");
alias WasmMessage = WasmName;
class WasmTrap {
    wasm_trap_t* backend;
    bool isInternalRef;
    this(wasm_trap_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_trap_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_trap_t*)backend;
        isInternalRef = true;
    }
    this(WasmTrap other) @nogc nothrow {
        backend = wasm_trap_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_trap_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_trap(other.backend);
    }
    this(WasmStore store, WasmMessage msg) @nogc nothrow {
        backend = wasm_trap_new(store.backend, &msg.backend);
    }
    this(const(char)* msg, size_t msgLen) @nogc nothrow {
        backend = wasmtime_trap_new(msg, msgLen);
    }
    this(string msg) @nogc nothrow {
        backend = wasmtime_trap_new(msg.ptr, msg.length);
    }
    bool same(WasmTrap other) @nogc nothrow const {
        return wasm_trap_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_trap_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_trap_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_trap_set_host_info_with_finalizer(backend, info, finalizer);
    }
    bool code(ref wasmtime_trap_code_t code) { 
        return wasmtime_trap_code(backend, &code);
    }
}
class WasmForeign {
    wasm_foreign_t* backend;
    bool isInternalRef;
    this(wasm_foreign_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_foreign_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_foreign_t*)backend;
        isInternalRef = true;
    }
    this(WasmForeign other) @nogc nothrow {
        backend = wasm_foreign_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_foreign_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_foreign(other.backend);
    }
    this(WasmStore store) @nogc nothrow {
        backend = wasm_foreign_new(store.backend);
    }
    bool same(WasmForeign other) @nogc nothrow const {
        return wasm_foreign_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_foreign_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_foreign_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_foreign_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
class WasmModule {
    wasm_module_t* backend;
    bool isInternalRef;
    this(wasm_module_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_module_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_module_t*)backend;
        isInternalRef = true;
    }
    this(WasmModule other) @nogc nothrow {
        backend = wasm_module_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_module_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_module(other.backend);
    }
    this(WasmStore store, WasmSharedModule origin) @nogc nothrow {
        backend = wasm_module_obtain(store.backend, origin.backend);
    }
    this(WasmStore st, WasmByteVec binary) @nogc nothrow {
        backend = wasm_module_new(st.backend, &binary.backend);
    }
    private this() @nogc nothrow @safe { }
    bool same(WasmModule other) @nogc nothrow const {
        return wasm_module_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_module_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_module_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_module_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmSharedModule share() nothrow {
        return new WasmSharedModule(wasm_module_share(backend));
    }
    bool validate(WasmStore st, WasmByteVec binary) @nogc nothrow {
        return wasm_module_validate(st.backend, &binary.backend);
    }
    WasmImporttypeVec imports() nothrow {
        WasmImporttypeVec result = new WasmImporttypeVec();
        wasm_module_imports(backend, &result.backend);
        return result;
    }
    WasmExporttypeVec exports() nothrow {
        WasmExporttypeVec result = new WasmExporttypeVec();
        wasm_module_exports(backend, &result.backend);
        return result;
    }
    WasmByteVec serialize() nothrow {
        WasmByteVec result = new WasmByteVec();
        wasm_module_serialize(backend, &result.backend);
        return result;
    }
    static WasmModule deserialize(WasmStore st, WasmByteVec binary) nothrow {
        WasmModule result = new WasmModule();
        result.backend = wasm_module_deserialize(st.backend, &binary.backend);
        return result;
    }
}
class WasmSharedModule {
    wasm_shared_module_t* backend;
    bool isInternalRef;
    this(wasm_shared_module_t* backend) @nogc nothrow {
        this.backend = backend;
        //isInternalRef = true;
    }
    this(const(wasm_shared_module_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_shared_module_t*)backend;
        //isInternalRef = true;
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_shared_module_delete(backend);
    }
}
alias WasmFuncCallback = wasm_func_callback_t;
class WasmFunction {
    wasm_func_t* backend;
    WasmFuncCallback refcount;
    bool isInternalRef;
    this(wasm_func_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_func_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_func_t*)backend;
        isInternalRef = true;
    }
    this(WasmFunction other) @nogc nothrow {
        backend = wasm_func_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_func_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_func(other.backend);
    }
    this(WasmStore st, WasmFunctype type, wasm_func_callback_t callback) @nogc nothrow {
        this.backend = wasm_func_new(st.backend, type.backend, callback);
        refcount = callback;
    }
    this(WasmStore st, WasmFunctype type, wasm_func_callback_with_env_t callback, void* env, 
            wasmFinalizerFuncT finalizer) @nogc nothrow {
        this.backend = wasm_func_new_with_env(st.backend, type.backend, callback, env, finalizer);
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_as_func(other.backend);
    }
    bool same(WasmFunction other) @nogc nothrow const {
        return wasm_func_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_func_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_func_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_func_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmFunctype type() nothrow {
        return new WasmFunctype(wasm_func_type(backend));
    }
    size_t paramArity() @nogc nothrow {
        return wasm_func_param_arity(backend);
    }
    size_t resultArity() @nogc nothrow {
        return wasm_func_result_arity(backend);
    }
    WasmTrap _call(WasmValVec args, WasmValVec res) nothrow {
        wasm_trap_t* result = wasm_func_call(backend, &args.backend, &res.backend);
        if (result is null) return null;
        return new WasmTrap(result);
    }
    WasmResult opCall(...) nothrow {
        WasmResult result = WasmResult(new WasmValVec, null);
        WasmVal[] vals;
        vals.reserve = _arguments.length;
        for (int i ; i < _arguments.length ; i++) {
            WasmVal val;
            if (_arguments[i] == typeid(int)) {
                val.of.i32 = va_arg!int(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(short)) {
                val.of.i32 = va_arg!short(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(byte)) {
                val.of.i32 = va_arg!byte(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(uint)) {
                val.of.i32 = va_arg!uint(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(ushort)) {
                val.of.i32 = va_arg!ushort(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(ubyte)) {
                val.of.i32 = va_arg!ubyte(_argptr);
                val.kind = WasmValkind.I32;
            } else if (_arguments[i] == typeid(long)) {
                val.of.i64 = va_arg!long(_argptr);
                val.kind = WasmValkind.I64;
            } else if (_arguments[i] == typeid(ulong)) {
                val.of.i64 = va_arg!ulong(_argptr);
                val.kind = WasmValkind.I64;
            } else if (_arguments[i] == typeid(float)) {
                val.of.f32 = va_arg!float(_argptr);
                val.kind = WasmValkind.F32;
            } else if (_arguments[i] == typeid(double)) {
                val.of.f64 = va_arg!double(_argptr);
                val.kind = WasmValkind.F64;
            } /* else if (_arguments[i].) {
                if (_arguments[i].tsize == ulong.sizeof) {
                    val.of.i64 = va_arg!ulong(_argptr);
                    val.kind = WasmValkind.I64;
                } else if (_arguments[i].tsize == uint.sizeof) {
                    val.of.i32 = va_arg!uint(_argptr);
                    val.kind = WasmValkind.I32;
                } else {
                    assert(0, "UDA 'WasmCfgStructPkg' must only be attached to structs with 4 or 8 bytes in size!");    
                }
            } */ else {
                assert(0, "Function argument not yet supported!");
            }
            vals ~= val;
        }
        WasmValVec argsToFunc = new WasmValVec(vals);
        result.trap = _call(argsToFunc, result.returnVal);
        return result;
    }
}
///Special to this implementation, used when returning from WASM functions.
struct WasmResult {
    WasmValVec      returnVal;///Contains the return value vector itself.
    WasmTrap        trap;///Contains any trap that has been encountered during the execution of the function, null otherwise.
}
///UDA, structs marked with it will be packed into a WASM val as a single integer. Struct must be of size 4 or 8.
///Note that client languages might not be compatible with it, but otherwise can be useful when speed is important.
struct WasmCfgStructPkg {}
///UDA, structs marked with it will be packed field-by-field.
struct WasmCfgStructByField {}
immutable string excErrorMsg = "Another exception thrown while handling exception";
immutable string typeErrorMsg = "Type mismatch with D host function";
T wasmGetFromVal(T)(WasmVal v) {
    static if (is(T == int) || is(T == uint) || is(T == short) || is(T == ushort) || is(T == byte) || is(T == ubyte) || 
            is(T == char) || is(T == wchar) || is(T == dchar)) {
        if (v.kind == WasmValkind.I32) return cast(T)v.of.i32;
    } else static if (is(T == long) || is(T == ulong)) {
        if (v.kind == WasmValkind.I64) return cast(T)v.of.i64;
    } else static if (is(T == float)) {
        if (v.kind == WasmValkind.F32) return cast(T)v.of.f32;
    } else static if (is(T == double)) {
        if (v.kind == WasmValkind.F64)  return cast(T)v.of.f64;
    } else static if (hasUDA!(T, "WasmCfgStructPkg")) {
        static if (t.sizeof == 4) {
            if (v.kind == WasmValkind.I32) return *cast(T*)(cast(void*)&v.of.i32);
        } else static if (t.sizeof == 8) {
            if (v.kind == WasmValkind.I64) return *cast(T*)(cast(void*)&v.of.i64);
        } else static assert(0, "Struct must be of exactly the size of 4 or 8 bytes!");
    } else static if (is(T == void*)) {
        //TODO: handle external references
        //if (v.kind == WasmValkind.ExternRef) return cast(T)v.of._ref;
    }
    throw new Exception("Type mismatch!");
}
WasmVal wasmToVal(T)(T val) {
    static if (is(T == int) || is(T == uint) || is(T == short) || is(T == ushort) || is(T == byte) || is(T == ubyte) || 
            is(T == char) || is(T == wchar) || is(T == dchar)) {
        return WasmVal(WasmValkind.I32, i32 : val);
    } else static if (is(T == long) || is(T == ulong)) {
        return WasmVal(WasmValkind.I64, i64 : val);
    } else static if (is(T == float)) {
        return WasmVal(WasmValkind.F32, f32 : val);
    } else static if (is(T == double)) {
        return WasmVal(WasmValkind.F64, f64 : val);
    } else static if (hasUDA!(T, "WasmCfgStructPkg")) {
        static if (t.sizeof == 4) {
            return WasmVal(WasmValkind.I32, i32 : *cast(int*)(cast(void*)&val));
        } else static if (t.sizeof == 8) {
            return WasmVal(WasmValkind.I64, i64 : *cast(long*)(cast(void*)&val));
        } else static assert(0, "Struct must be of exactly the size of 4 or 8 bytes!");
    } else static if (is(T == void*)) {
        //TODO: handle external references
        //if (v.kind == WasmValkind.ExternRef) return cast(T)v.of._ref;
    }
    throw new Exception("Type mismatch!");
}
/** 
 * Function template to interface to D code. Automatically handles exceptions and converst their messages to WasmTraps.
 * Template params:
 *   T = The function to be interfaced to WASM.
 * Params:
 *   args = The incoming arguments.
 *   results = The outgoing results.
 * Returns: A WasmTrap if an exception during executing the D code have occured, null otherwise.
 */
extern(C) nothrow
wasm_trap_t* wasmFuncGen(Func)(const(wasm_val_vec_t)* args, wasm_val_vec_t* results) {
    import core.stdc.string : memcpy;
        
    import std.traits:Parameters, ReturnType;
    import std.meta:staticMap;
    staticMap!(Unqual,Parameters!Func) params;

    try {
        size_t i;
        foreach (ref key; params) {
            if (i <= args.size) throw new Exception("Argument number mismatch!");
            key = wasmGetFromVal!(typeof(key))(args.data[i]);
            i++;
        }
    } catch (Exception e) {
        //WasmMessage msg = new WasmMessage(cast(ubyte[])typeErrorMsg.dup);
        WasmTrap wt = new WasmTrap(typeErrorMsg.idup);
        wt.isInternalRef = true;
        return wt.backend;
    }

    try {
        static if (is(ReturnType!Func == void)) {
            Func(params);
        } else static if (hasUDA!(ReturnType!Func, "WasmCfgStructByField")) {
            ReturnType!Func retVal = Func(params);
            if (results.size != (ReturnType!Func).tupleof.length) throw new Exception("Return value number mismatch!");
            size_t i;
            static foreach (key ; (ReturnType!Func).tupleof) {
                results.data[i] = wasmToVal(__traits(child, retVal, key));
                i++;
            }
        } else {
            WasmVal v = wasmToVal(Func(params));
            if (res.length != 1) throw new Exception("Return value number mismatch!");
            results.data[0] = v;
        }
    } catch(Exception e) {
        string msg;
        try {
            msg = e.toString();
        } catch(Exception e2) {
            msg = excErrorMsg.idup;
        }
        WasmTrap wt = new WasmTrap(msg);
        wt.isInternalRef = true;
        return wt.backend;
    }
    //wasm_val_vec_new_uninitialized(results, res.length);
    return null;
}
//Todo: get info on how one should pass class references and the likes to WASM to be used from there
/* extern(C) nothrow
wasm_trap_t* wasmMemberFuncGen(O, F)(const(wasm_val_vec_t)* args, wasm_val_vec_t* results) {
    try {

    } catch(Exception e) {
        WasmMessage msg;
        try {
            msg = new WasmMessage(cast(ubyte[])e.toString().dup);
        } catch(Exception e2) {
            msg = new WasmMessage(cast(ubyte[])excErrorMsg.dup);
        }
        WasmTrap wt = new WasmTrap(WasmStore.defStore, &msg.backend);
        wt.isInternalRef = true;
        return wt.backend;
    }
    return null;
} */
class WasmGlobal {
    wasm_global_t* backend;
    bool isInternalRef;
    this(wasm_global_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_global_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_global_t*)backend;
        isInternalRef = true;
    }
    this(WasmGlobal other) @nogc nothrow {
        backend = wasm_global_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_global_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_global(other.backend);
    }
    this(WasmStore st, WasmGlobaltype type, WasmVal val) @nogc nothrow {
        backend = wasm_global_new(st.backend, type.backend, &val);
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_as_global(other.backend);
    }
    bool same(WasmGlobal other) @nogc nothrow const {
        return wasm_global_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_global_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_global_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_global_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmGlobaltype type() nothrow {
        return new WasmGlobaltype(wasm_global_type(backend));
    }
    void set(WasmVal v) @nogc nothrow {
        wasm_global_set(backend, &v);
    }
    void set(T)(T value) @nogc nothrow  {
        WasmVal v;
        static if(is(T == int) || is(T == uint)) {
            v.of.i32 = value;
            v.kind = WasmValkind.I32;
        } else static if(is(T == long) || is(T == ulong)) {
            v.of.i64 = value;
            v.kind = WasmValkind.I64;
        } else static if(is(T == float)) {
            v.of.f32 = value;
            v.kind = WasmValkind.F32;
        } else static if(is(T == double)) {
            v.of.f64 = value;
            v.kind = WasmValkind.F64;
        }
        wasm_global_set(backend, &v);
        
    }
    WasmVal get() @nogc nothrow {
        WasmVal v;
        wasm_global_get(backend, &v);
        return v;
    }
}
class WasmTable {
    wasm_table_t* backend;
    bool isInternalRef;
    this(wasm_table_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_table_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_table_t*)backend;
        isInternalRef = true;
    }
    this(WasmTable other) @nogc nothrow {
        backend = wasm_table_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_table_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_table(other.backend);
    }
    this(WasmStore st, WasmTabletype type, WasmRef init) {
        backend = wasm_table_new(st.backend, type.backend, init.backend);
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_as_table(other.backend);
    }
    bool same(WasmTable other) @nogc nothrow const {
        return wasm_table_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_table_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_table_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_table_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmTabletype type() nothrow {
        return new WasmTabletype(wasm_table_type(backend));
    }
    WasmRef opIndex(wasm_table_size_t index) nothrow {
        WasmRef result = new WasmRef(wasm_table_get(backend, index));
        result.isInternalRef = false;
        return result;
    }
    WasmRef opIndexAssign(WasmRef value, wasm_table_size_t index) @nogc nothrow {
        wasm_table_set(backend, index, value.backend);
        return value;
    }
    wasm_table_size_t length() @nogc nothrow {
        return wasm_table_size(backend);
    }
    void grow(wasm_table_size_t delta, WasmRef init) @nogc nothrow {
        wasm_table_grow(backend, delta, init.backend);
    }
}
class WasmMemory {
    wasm_memory_t* backend;
    bool isInternalRef;
    this(wasm_memory_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_memory_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_memory_t*)backend;
        isInternalRef = true;
    }
    this(WasmMemory other) @nogc nothrow {
        backend = wasm_memory_copy(other.backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_memory(other.backend);
    }
    this(WasmStore st, WasmMemorytype type) @nogc nothrow {
        backend = wasm_memory_new(st.backend, type.backend);
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_as_memory(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_memory_delete(backend);
    }
    bool same(WasmMemory other) @nogc nothrow const {
        return wasm_memory_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_memory_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_memory_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_memory_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmMemorytype type() nothrow {
        return new WasmMemorytype(wasm_memory_type(backend));
    }
    char* data() @nogc nothrow {
        return wasm_memory_data(backend);
    }
    size_t dataLength() @nogc nothrow {
        return wasm_memory_data_size(backend);
    }
    char[] dataArray() @nogc nothrow {
        return wasm_memory_data(backend)[0..wasm_memory_data_size(backend)];
    }
    void grow(wasm_memory_pages_t delta) @nogc nothrow {
        wasm_memory_grow(backend, delta);
    }
}
class WasmExtern {
    wasm_extern_t* backend;
    bool isInternalRef;
    this(wasm_extern_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_extern_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_extern_t*)backend;
        isInternalRef = true;
    }
    this(WasmExtern other) @nogc nothrow {
        backend = wasm_extern_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_extern_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_extern(other.backend);
    }
    this(WasmFunction other) @nogc nothrow {
        backend = wasm_func_as_extern(other.backend);
    }
    this(WasmGlobal other) @nogc nothrow {
        backend = wasm_global_as_extern(other.backend);
    }
    this(WasmTable other) @nogc nothrow {
        backend = wasm_table_as_extern(other.backend);
    }
    this(WasmMemory other) @nogc nothrow {
        backend = wasm_memory_as_extern(other.backend);
    }
    WasmExternkind kind() @nogc nothrow {
        return cast(WasmExternkind)wasm_extern_kind(backend);
    }
    WasmExterntype type() nothrow {
        return new WasmExterntype(wasm_extern_type(backend));
    }
    bool same(WasmExtern other) @nogc nothrow const {
        return wasm_extern_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_extern_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_extern_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_extern_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
alias WasmExternVec = WasmVecTempl!("WasmExtern", "extern");
class WasmInstance {
    wasm_instance_t* backend;
    bool isInternalRef;
    this(wasm_instance_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    this(const(wasm_instance_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_instance_t*)backend;
        isInternalRef = true;
    }
    this(WasmInstance other) @nogc nothrow {
        backend = wasm_instance_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_instance_delete(backend);
    }
    this(WasmRef other) @nogc nothrow {
        backend = wasm_ref_as_instance(other.backend);
    }
    bool same(WasmInstance other) @nogc nothrow const {
        return wasm_instance_same(backend, other.backend);
    }
    void* getHostInfo() @nogc nothrow const {
        return wasm_instance_get_host_info(backend);
    }
    void setHostInfo(void* info) @nogc nothrow {
        wasm_instance_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasm_instance_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
class WasiConfig {
    wasi_config_t* backend;
    bool isInternalRef;
    this() @nogc nothrow {
        backend = wasi_config_new();
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasi_config_delete(backend);
    }
    void setArgv(int argc, const(char*)* argv) {
        wasi_config_set_argv(backend, argc, argv);
    }
    void inheritArgv() {
        wasi_config_inherit_argv(backend);
    }
    void setEnv(int envc, const(char*)* names, const(char*)* values) {
        wasi_config_set_env(backend, envc, names, values);
    }
    void inheritEnv() {
        wasi_config_inherit_env(backend);
    }
    void setStdinFile(const(char)* path) {
        wasi_config_set_stdin_file(backend, path);
    }
    void setStdinBytes(WasmByteVec binary) {
        wasi_config_set_stdin_bytes(backend, &binary.backend);
    }
    void inheritStdin() {
        wasi_config_inherit_stdin(backend);
    }
    void setStdoutFile(const(char)* path) {
        wasi_config_set_stdout_file(backend, path);
    }
    void inheritStdout() {
        wasi_config_inherit_stdout(backend);
    }
    void setStderrFile(const(char)* path) {
        wasi_config_set_stderr_file(backend, path);
    }
    void inheritStderr() {
        wasi_config_inherit_stderr(backend);
    }
    void preopenDir(const(char)* path, const(char)* guestPath) {
        wasi_config_preopen_dir(backend, path, guestPath);
    }
}
class WasmtimeError {
    wasmtime_error_t* backend;
    bool isInternalRef;
    this(wasmtime_error_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    this(const(char)* msg) @nogc nothrow {
        backend = wasmtime_error_new(msg);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasmtime_error_delete(backend);
    }
    WasmMessage message() nothrow {
        wasm_name_t msg;
        wasmtime_error_message(backend, &msg);
        return new WasmMessage(msg);
    }
    bool exitStatus(int* status) @nogc nothrow {
        return wasmtime_error_exit_status(backend, status);
    }
    WasmFrameVec trace() nothrow {
        wasm_frame_vec_t result;
        wasmtime_error_wasm_trace(backend, &result);
        return new WasmFrameVec(result);
    }
    override string toString() nothrow {
        auto msg = message();
        return cast(string)msg.backend.data[0..msg.backend.size];
    }
}
class WasmtimeModule {
    wasmtime_module_t* backend;
    static WasmtimeError create(WasmEngine engine, ubyte[] wasm, ref WasmtimeModule mod) nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_new(engine.backend, wasm.ptr, wasm.length, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) mod = new WasmtimeModule(creation);
        return null;
    }
    static WasmtimeError deserialize(WasmEngine engine, ubyte[] wasm, ref WasmtimeModule mod) nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_deserialize(engine.backend, wasm.ptr, wasm.length, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) mod = new WasmtimeModule(creation);
        return null;
    }
    static WasmtimeError deserializeFromFile(WasmEngine engine, const(char)* path, ref WasmtimeModule mod) nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_deserialize_file(engine.backend, path, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) mod = new WasmtimeModule(creation);
        return null;
    }
    static WasmtimeError validate(WasmEngine engine, ubyte[] wasm) nothrow {
        wasmtime_error_t* error = wasmtime_module_validate(engine.backend, wasm.ptr, wasm.length);
        if (error) return new WasmtimeError(error);
        return null;
    }
    package this(wasmtime_module_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    this(WasmtimeModule other) @nogc nothrow {
        backend = wasmtime_module_clone(other.backend);
    }
    ~this() @nogc nothrow {
        wasmtime_module_delete(backend);
    }
    WasmImporttypeVec imports() nothrow {
        WasmImporttypeVec result = new WasmImporttypeVec();
        wasmtime_module_imports(backend, &result.backend);
        return result;
    }
    WasmExporttypeVec exports() nothrow {
        WasmExporttypeVec result = new WasmExporttypeVec();
        wasmtime_module_exports(backend, &result.backend);
        return result;
    }
    WasmtimeError serialize(ref WasmByteVec _out) nothrow {
        wasmtime_error_t* error = wasmtime_module_serialize(backend, &_out.backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    void*[2] imageRange() @nogc nothrow {
        void*[2] result;
        wasmtime_module_image_range(backend, &result[0], &result[1]);
        return result;
    }
}
class WasmtimeSharedmemory {
    wasmtime_sharedmemory_t* backend;
    static WasmtimeError create(WasmEngine engine, WasmMemorytype ty, ref WasmtimeSharedmemory _out) nothrow {
        wasmtime_sharedmemory_t* creation;
        wasmtime_error_t* error = wasmtime_sharedmemory_new(engine.backend, ty.backend, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) _out = new WasmtimeSharedmemory(creation);
        return null;
    }
    package this(wasmtime_sharedmemory_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    this(WasmtimeSharedmemory other) @nogc nothrow {
        backend = wasmtime_sharedmemory_clone(other.backend);
    }
    ~this() @nogc nothrow {
        wasmtime_sharedmemory_delete(backend);
    }
    WasmMemorytype type() nothrow {
        return new WasmMemorytype(wasmtime_sharedmemory_type(backend));
    }
    ubyte[] data() @nogc nothrow {
        return wasmtime_sharedmemory_data(backend)[0..wasmtime_sharedmemory_data_size(backend)];
    }
    size_t size() @nogc nothrow {
        return wasmtime_sharedmemory_size(backend);
    }
    WasmtimeError grow(size_t delta, size_t* prevSize) nothrow {
        wasmtime_error_t* error = wasmtime_sharedmemory_grow(backend, delta, prevSize);
        if (error) return new WasmtimeError(error);
        return null;
    }
}
class WasmtimeStore {
    wasmtime_store_t* backend;
    this(WasmEngine engine, void* data, wasmFinalizerFuncT finalizer) @nogc nothrow {
        backend = wasmtime_store_new(engine.backend, data, finalizer);
    }
    ~this() @nogc nothrow {
        wasmtime_store_delete(backend);
    }
    WasmtimeContext context() nothrow {
        return new WasmtimeContext(wasmtime_store_context(backend));
    }
    void limiter(int64_t memorySize, int64_t tableElements, int64_t instances, int64_t tables, int64_t memories) 
            @nogc nothrow {
        wasmtime_store_limiter(backend, memorySize, tableElements, instances, tables, memories);
    }
    void epochDeadlineCallback(wasmSEDCFuncT func, void *data, wasmFinalizerFuncT finalizer) @nogc nothrow {
        wasmtime_store_epoch_deadline_callback(backend, func, data, finalizer);
    }
}
class WasmtimeContext {
    wasmtime_context_t* backend;
    this(wasmtime_context_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    ~this() @nogc nothrow {
        wasmtime_context_gc(backend);
    }
    void* getData() @nogc nothrow {
        return wasmtime_context_get_data(backend);
    }
    void setData(void* data) @nogc nothrow {
        wasmtime_context_set_data(backend, data);
    }
    WasmtimeError setWasi(WasiConfig cfg) nothrow {
        wasmtime_error_t* error = wasmtime_context_set_wasi(backend, cfg.backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError setFuel(uint64_t fuel) nothrow {
        wasmtime_error_t* error = wasmtime_context_set_fuel(backend, fuel);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError getFuel(uint64_t* fuel) nothrow {
        wasmtime_error_t* error = wasmtime_context_get_fuel(backend, fuel);
        if (error) return new WasmtimeError(error);
        return null;
    }
    void setEpochDeadline(uint64_t ticsBeyondCurrent) {
        wasmtime_context_set_epoch_deadline(backend, ticsBeyondCurrent);
    }
}
alias WasmtimeExtern = wasmtime_extern_t;
WasmExterntype externType(WasmtimeExtern ext, WasmtimeContext context) nothrow {
    return new WasmExterntype(wasmtime_extern_type(context.backend, &ext));
}
WasmExterntype externType(WasmtimeExtern* ext, WasmtimeContext context) nothrow {
    return new WasmExterntype(wasmtime_extern_type(context.backend, ext));
}
/* class WasmtimeExtern {
    wasmtime_extern_t* backend;
    ~this() @nogc nothrow {
        wasmtime_extern_delete(backend);
    }
    WasmExterntype type(WasmtimeContext context) nothrow {
        return new WasmExterntype(wasmtime_extern_type(context.backend, backend));
    }
} */
class WasmtimeAnyref {
    wasmtime_anyref_t* backend;
    WasmtimeContext context;    ///Currently it's there due to the functions, might need to be changed
    bool isInternalRef;
    this(WasmtimeContext c, WasmtimeAnyref other) @nogc nothrow {
        backend = wasmtime_anyref_clone(c.backend, other.backend);
        this.context = c;
    }
    ///Wrapper for wasmtime_anyref_from_raw and wasmtime_anyref_from_i31
    this(WasmtimeContext c, uint32_t raw, bool i31) @nogc nothrow {
        if (i31) backend = wasmtime_anyref_from_i31(c.backend, raw);
        else backend = wasmtime_anyref_from_raw(c.backend, raw);
        this.context = c;
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasmtime_anyref_delete(context.backend, backend);
    }
    uint32_t toRaw() @nogc nothrow {
        return wasmtime_anyref_to_raw(context.backend, backend);
    }
    bool i31GetU(uint32_t* dst) @nogc nothrow {
        return wasmtime_anyref_i31_get_u(context.backend, backend, dst);
    }
    bool i31GetS(int32_t* dst) @nogc nothrow {
        return wasmtime_anyref_i31_get_s(context.backend, backend, dst);
    }
}
class WasmtimeExternref {
    wasmtime_externref_t* backend;
    WasmtimeContext context;    ///Currently it's there due to the functions, might need to be changed
    bool isInternalRef;
    this(WasmtimeContext c, void* data, wasmFinalizerFuncT finalizer) @nogc nothrow {
        backend = wasmtime_externref_new(c.backend, data, finalizer);
        this.context = c;
    }
    this(WasmtimeContext c, uint32_t raw) @nogc nothrow {
        backend = wasmtime_externref_from_raw(c.backend, raw);
        context = c;
    }
    this(WasmtimeExternref other) {
        backend = wasmtime_externref_clone(other.context.backend, other.backend);
        context = other.context;
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasmtime_externref_delete(context.backend, backend);
    }
    void* data() @nogc nothrow {
        return wasmtime_externref_data(context.backend, backend);
    }
    uint32_t toRaw() @nogc nothrow {
        return wasmtime_externref_to_raw(context.backend, backend);
    }
}
alias WasmtimeValunion = wasmtime_valunion_t;
alias WasmtimeValRaw = wasmtime_val_raw_t;
alias WasmtimeVal = wasmtime_val_t;
//alias WasmtimeValkind = wasmtime_valkind_t;
alias WasmtimeFuncCallback = wasmtime_func_callback_t;
alias WasmtimeFuncUncheckedCallback = wasmtime_func_unchecked_callback_t;
/** 
 * Converts a D value to a WasmtimeVal for automatically handled
 * Params:
 *   val = 
 *   context = 
 * Returns: 
 */
pragma(inline, true)
WasmtimeVal convToWasmtimeVal(T)(T val, wasmtime_context_t* context) @nogc nothrow {
    static if (is(T == int) || is(T == uint) || is(T == short) || is(T == ushort) || is(T == byte) || is(T == ubyte) || 
            is(T == char) || is(T == wchar) || is(T == dchar)) {
        return WasmtimeVal(WasmtimeValkind.I32, wasmtime_valunion_t(val));
    } else static if (is(T == long) || is(T == ulong)) {
        return WasmtimeVal(WasmtimeValkind.I64, wasmtime_valunion_t(i64 : val));
    } else static if (is(T == float)) {
        return WasmtimeVal(WasmtimeValkind.F32, wasmtime_valunion_t(f32 : val));
    } else static if (is(T == double)) {
        return WasmtimeVal(WasmtimeValkind.F64, wasmtime_valunion_t(f64 : val));
    } else static if (hasUDA!(T, "WasmCfgStructPkg")) {
        static if (t.sizeof == 4) {
            return WasmtimeVal(WasmtimeValkind.I32, wasmtime_valunion_t(i32 : *cast(int*)(cast(void*)&val)));
        } else static if (t.sizeof == 8) {
            return WasmtimeVal(WasmtimeValkind.I64, wasmtime_valunion_t(i64 : *cast(long*)(cast(void*)&val)));
        } else static assert(0, "Struct must be of exactly the size of 4 or 8 bytes!");
    } else static if (is(T == class) || is(T == interface)) {   //treat classes and interfaces as external reference
        return WasmtimeVal(WasmtimeValkind.Externref, 
                externref : wasmtime_externref_new(context, cast(void*)val, null));
    } else static if (is(T == struct)) {                        //treat structs as memory blobs
        return WasmtimeVal(WasmtimeValkind.Externref, externref : wasmtime_externref_new(context, &val, null));
    }
    //throw new Exception("Type mismatch!");
}
/** 
 * 
 * Params:
 *   val = 
 *   context = 
 * Returns: 
 */
T getFromWasmtimeVal(T)(WasmtimeVal val, wasmtime_context_t* context) @nogc nothrow {
    static if (is(T == int) || is(T == uint) || is(T == short) || is(T == ushort) || is(T == byte) || is(T == ubyte) || 
            is(T == char) || is(T == wchar) || is(T == dchar)) {
        return cast(T)val.of.i32;
    } else static if (is(T == long) || is(T == ulong)) {
        return cast(T)val.of.i64;
    } else static if (is(T == float)) {
        return val.of.f32;
    } else static if (is(T == double)) {
        return val.of.f64;
    } else static if (hasUDA!(T, "WasmCfgStructPkg")) {
        static if (t.sizeof == 4) {
            return *cast(T*)(cast(void*)&val.of.i32);
        } else static if (t.sizeof == 8) {
            return *cast(T*)(cast(void*)&val.of.i64);
        } else static assert(0, "Struct must be of exactly the size of 4 or 8 bytes!");
    } else static if (is(T == class) || is(T == interface)) {    //treat classes and interfaces as external reference
        return cast(T)wasmtime_externref_data(context, val.of.externref);
    } else static if (is(T == struct)) {
        return *cast(T*)wasmtime_externref_data(context, val.of.externref);
    }
    //throw new Exception("Type mismatch!");
}
//enum wasm_valkind_t ToWasmValkind(T) 
class WasmtimeFunc {
    wasmtime_func_t backend;
    WasmtimeContext context;
    WasmtimeFuncCallback callbackRef;   ///Used mainly to stop the GC to collect the generated function.
    static WasmtimeFunc createnoArgs(WasmtimeContext c, WasmtimeFuncCallback callback, void* env, 
            wasmFinalizerFuncT finalizer) nothrow {
        return create(c, new WasmValtypeVec(), new WasmValtypeVec(), callback, env, finalizer);
    }
    static WasmtimeFunc create(WasmtimeContext c, WasmValtypeVec args, WasmValtypeVec ret, 
            WasmtimeFuncCallback callback, void* env, wasmFinalizerFuncT finalizer) nothrow {
        wasmtime_func_t result;
        wasm_functype_t* type = wasm_functype_new(&args.backend, &ret.backend);
        wasmtime_func_new(c.backend, type, callback, env, finalizer, &result);
        return new WasmtimeFunc(c, result);
    }
    /** 
     * Creates a WasmtimeFunc binding for a D function.
     * Params:
     *   c = The context for the function.
     *   dfunc = The D function for binding.
     */
    this(Func)(WasmtimeContext c) {
        import core.stdc.string : memcpy;
        import std.traits:Parameters, ReturnType;
        import std.meta:staticMap;

        extern(C)
        wasm_trap_t* dfuncWrapper(void* env, wasmtime_caller_t* caller, const(wasmtime_val_t*) args, size_t nargs, 
                wasmtime_val_t* results, size_t nresults) nothrow {
            
            staticMap!(Unqual,Parameters!Func) params;
            auto cntxt = wasmtime_caller_context(caller);
            try {
                size_t i;
                foreach (ref key; params) {
                    if (i <= nargs) throw new Exception("Argument number mismatch!");
                    key = getFromWasmtimeVal!(typeof(key))(args[i], cntxt);
                    i++;
                }
            } catch (Exception e) {
                WasmTrap wt = new WasmTrap(typeErrorMsg.idup);
                wt.isInternalRef = true;
                return wt.backend;
            }

            try {
                static if (is(ReturnType!Func == void)) {
                    Func(params);
                    if (nresults != 0) throw new Exception("Return value number mismatch!");
                } else {
                    WasmtimeVal v = convToWasmtimeVal(Func(params), cntxt);
                    if (nresults != 1) throw new Exception("Return value number mismatch!");
                }
            } catch (Exception e) {
                string msg;
                try {
                    msg = e.toString();
                } catch (Exception e2) {
                    msg = excErrorMsg.idup;
                }
                WasmTrap wt = new WasmTrap(msg);
                wt.isInternalRef = true;
                return wt.backend;
            }
            return null;
        }
        context = c;
        callbackRef = &dfuncWrapper;

        staticMap!(Unqual,Parameters!Func) params;
        wasm_valtype_t*[] wasmArgs;
        foreach (ref key; params) {
            wasmArgs ~= wasm_valtype_new();
        }
    }
    //this(O, Func)(WasmtimeContext c) {}
    
    this(WasmtimeContext c, WasmFunctype type, WasmtimeFuncCallback callback, void* env, wasmFinalizerFuncT finalizer) 
            @nogc nothrow {
        context = c;
        wasmtime_func_new(c.backend, type.backend, callback, env, finalizer, &backend);
    }
    this(WasmtimeContext c, WasmFunctype type, WasmtimeFuncUncheckedCallback callback, void* env, 
            wasmFinalizerFuncT finalizer) @nogc nothrow {
        context = c;
        wasmtime_func_new_unchecked(c.backend, type.backend, callback, env, finalizer, &backend);
    }
    this(WasmtimeContext c, void* raw) @nogc nothrow {
        context = c;
        wasmtime_func_from_raw(c.backend, raw, &backend);
    }
    this(WasmtimeContext c, wasmtime_func_t backend) @nogc nothrow {
        context = c;
        this.backend = backend;
    }
    WasmFunctype type() nothrow {
        return new WasmFunctype(wasmtime_func_type(context.backend, &backend));
    }
    WasmtimeError call(WasmtimeVal[] args, WasmtimeVal[] results, ref WasmTrap trap) nothrow {
        wasm_trap_t* trap0;
        wasmtime_error_t* error = wasmtime_func_call(context.backend, &backend, args.ptr, args.length, results.ptr, 
                results.length, &trap0);
        if (trap0) trap = new WasmTrap(trap0);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError callUnchecked(WasmtimeValRaw[] argsnres, ref WasmTrap trap) nothrow {
        wasm_trap_t* trap0;
        wasmtime_error_t* error = wasmtime_func_call_unchecked(context.backend, &backend, argsnres.ptr, argsnres.length, 
                &trap0);
        if (trap0) trap = new WasmTrap(trap0);
        if (error) return new WasmtimeError(error);
        return null;
    }
    void* toRaw() @nogc nothrow {
        return wasmtime_func_to_raw(context.backend, &backend);
    }
    /** 
     * Easy D wrapper around  function calls.
     * Params:
     *   retnum = The number of returned values, can be zero.
     * Returns: A WasmtimeResult struct with the results
     */
    WasmtimeResult opCall(size_t retnum, ...) nothrow {
        WasmtimeResult result;
        WasmtimeVal[] vals;
        result.context = context.backend;
        result.retVal.length = retnum;
        vals.length = _arguments.length;
        for (int i ; i < _arguments.length ; i++) {
            if (_arguments[i] == typeid(int)) {
                vals[i] = convToWasmtimeVal(va_arg!int(_argptr), result.context);
            } else if (_arguments[i] == typeid(short)) {
                vals[i] = convToWasmtimeVal(va_arg!short(_argptr), result.context);
            } else if (_arguments[i] == typeid(byte)) {
                vals[i] = convToWasmtimeVal(va_arg!byte(_argptr), result.context);
            } else if (_arguments[i] == typeid(uint)) {
                vals[i] = convToWasmtimeVal(va_arg!uint(_argptr), result.context);
            } else if (_arguments[i] == typeid(ushort)) {
                vals[i] = convToWasmtimeVal(va_arg!ushort(_argptr), result.context);
            } else if (_arguments[i] == typeid(ubyte)) {
                vals[i] = convToWasmtimeVal(va_arg!ubyte(_argptr), result.context);
            } else if (_arguments[i] == typeid(long)) {
                vals[i] = convToWasmtimeVal(va_arg!long(_argptr), result.context);
            } else if (_arguments[i] == typeid(ulong)) {
                vals[i] = convToWasmtimeVal(va_arg!ulong(_argptr), result.context);
            } else if (_arguments[i] == typeid(float)) {
                vals[i] = convToWasmtimeVal(va_arg!float(_argptr), result.context);
            } else if (_arguments[i] == typeid(double)) {
                vals[i] = convToWasmtimeVal(va_arg!double(_argptr), result.context);
            }
        }
        wasm_trap_t* trap;
        wasmtime_error_t* error = wasmtime_func_call(context.backend, &backend, vals.ptr, vals.length, 
                result.retVal.ptr, result.retVal.length, &trap);
        if (trap) result.trap = new WasmTrap(trap);
        if (error) result.error = new WasmtimeError(error);
        return result;
    }
}
struct WasmtimeResult {
    WasmtimeVal[]   retVal;
    WasmtimeError   error;
    WasmTrap        trap;
    wasmtime_context_t* context;
    T get(T)() @nogc nothrow {
        return getFromWasmtimeVal(retVal, context);
    }
}
class WasmtimeGlobal {
    static wasmtime_error_t* lastError;
    wasmtime_global_t backend;
    WasmtimeContext context;
    this(WasmtimeContext c, WasmGlobaltype type, WasmtimeVal val) @nogc nothrow {
        context = c;
        lastError = wasmtime_global_new(c.backend, type.backend, &val, &backend);
    }
    WasmGlobaltype type() nothrow {
        return new WasmGlobaltype(wasmtime_global_type(context.backend, &backend));
    }
    WasmtimeVal get() nothrow {
        WasmtimeVal result;
        wasmtime_global_get(context.backend, &backend, &result);
        return result;
    }
    WasmtimeError set(WasmtimeVal val) nothrow {
        wasmtime_error_t* error = wasmtime_global_set(context.backend, &backend, &val);
        if (error) return new WasmtimeError(error);
        return null;
    }
}
class WasmtimeInstance {
    static wasm_trap_t* lastTrap;
    static wasmtime_error_t* lastError;
    wasmtime_instance_t backend;
    WasmtimeContext context;
    this(WasmtimeContext c, WasmtimeModule mod, WasmtimeExtern[] imports) @nogc nothrow {
        context = c;
        lastError = wasmtime_instance_new(c.backend, mod.backend, imports.ptr, imports.length, &backend, &lastTrap);
    }
    WasmtimeExtern exportGet(string name) @nogc nothrow {
        WasmtimeExtern result;
        wasmtime_instance_export_get(context.backend, &backend, name.ptr, name.length, &result);
        return result;
    }
    WasmtimeExtern exportGetNth(size_t index, ref string name) @nogc nothrow {
        WasmtimeExtern result;
        char* namePtr;
        size_t nameLen;
        wasmtime_instance_export_nth(context.backend, &backend, index, &namePtr, &nameLen, &result);
        if (namePtr) name = cast(string)namePtr[0..nameLen];
        return result;
    }
}
class WasmtimeLinker {
    wasmtime_linker_t* backend;
    this(WasmEngine engine) @nogc nothrow {
        backend = wasmtime_linker_new(engine.backend);
    }
    this(WasmtimeLinker other) @nogc nothrow {
        backend = wasmtime_linker_clone(other.backend);
    }
    ~this() @nogc nothrow {
        wasmtime_linker_delete(backend);
    }
    void allowShadowing(bool val) @nogc nothrow {
        wasmtime_linker_allow_shadowing(backend, val);
    }
    WasmtimeError define(WasmtimeContext context, string mod, string name, WasmtimeExtern item) nothrow {
        wasmtime_error_t* error = 
                wasmtime_linker_define(backend, context.backend, mod.ptr, mod.length, name.ptr, name.length, &item);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError defineFunc(string mod, string name, WasmFunctype type, WasmtimeFuncCallback cb, void* data, 
            wasmFinalizerFuncT finalizer) nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_func(backend, mod.ptr, mod.length, name.ptr, name.length, 
                type.backend, cb, data, finalizer);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError defineFunc(string mod, string name, WasmFunctype type, WasmtimeFuncUncheckedCallback cb, void* data, 
            wasmFinalizerFuncT finalizer) nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_func_unchecked(backend, mod.ptr, mod.length, name.ptr, 
                name.length, type.backend, cb, data, finalizer);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError defineWASI() nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_wasi(backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError defineInstance(WasmtimeContext store, string name, WasmtimeInstance instance) nothrow {
        wasmtime_error_t* error = 
                wasmtime_linker_define_instance(backend, store.backend, name.ptr, name.length, &instance.backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError instantiate(WasmtimeContext store, WasmtimeModule mod, WasmtimeInstance instance, 
            ref WasmTrap trap) nothrow {
        wasm_trap_t* trap0;
        wasmtime_error_t* error = 
                wasmtime_linker_instantiate(backend, store.backend, mod.backend, &instance.backend, &trap0);
        if (trap0) trap = new WasmTrap(trap0);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError setModule(WasmtimeContext store, string name, WasmtimeModule mod) nothrow {
        wasmtime_error_t* error = 
                wasmtime_linker_module(backend, store.backend, name.ptr, name.length, mod.backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    WasmtimeError getDefault(WasmtimeContext store, string name, WasmtimeFunc func) nothrow {
        wasmtime_error_t* error = 
                wasmtime_linker_get_default(backend, store.backend, name.ptr, name.length, &func.backend);
        if (error) return new WasmtimeError(error);
        return null;
    }
    bool get(WasmtimeContext store, string mod, string name, ref WasmtimeExtern item) @nogc nothrow {
        return wasmtime_linker_get(backend, store.backend, mod.ptr, mod.length, name.ptr, name.length, &item); 
    }
    WasmtimeError instantiatePre(WasmtimeModule mod, wasmtime_instance_pre_t* iP) nothrow {
        wasmtime_error_t* error = 
        wasmtime_linker_instantiate_pre(backend, mod.backend, &iP);
        if (error) return new WasmtimeError(error);
        return null;
    }
}
class WasmtimeMemory {
    static wasmtime_error_t* lastError;
    wasmtime_memory_t backend;
    WasmtimeContext context;
    this(WasmtimeContext store, WasmMemorytype type) @nogc nothrow {
        context = store;
        lastError = wasmtime_memory_new(store.backend, type.backend, &backend);
    }
    WasmMemorytype type() nothrow {
        return new WasmMemorytype(wasmtime_memory_type(context.backend, &backend));
    }
    ubyte* data() @nogc nothrow {
        return wasmtime_memory_data(context.backend, &backend);
    }
    size_t dataSize() @nogc nothrow {
        return wasmtime_memory_data_size(context.backend, &backend);
    }
    ulong size() @nogc nothrow {
        return wasmtime_memory_size(context.backend, &backend);
    }
    WasmtimeError grow(ulong delta, ulong* prevSize) nothrow {
        lastError = wasmtime_memory_grow(context.backend, &backend, delta, prevSize);
        if (lastError) return new WasmtimeError(lastError);
        return null;
    }
}
/* class WasmtimeGuestprofiler {
    wasmtime_guestprofiler_t* backend;
    
    ~this() @nogc nothrow {
        wasmtime_guestprofiler_delete(backend);
    }
} */
class WasmtimeTable {
    static wasmtime_error_t* lastError;
    wasmtime_table_t backend;
    WasmtimeContext context;
    this(WasmtimeContext store, WasmTabletype type, WasmtimeVal* init) @nogc nothrow {
        lastError = wasmtime_table_new(store.backend, type.backend, init, &backend);
    }
    WasmTabletype type() nothrow {
        return new WasmTabletype(wasmtime_table_type(context.backend, &backend));
    }
    bool get(uint index, ref WasmtimeVal val) @nogc nothrow {
        return wasmtime_table_get(context.backend, &backend, index, &val);
    }
    WasmtimeError set(uint index, WasmtimeVal val) nothrow {
        lastError = wasmtime_table_set(context.backend, &backend, index, &val);
        if (lastError) return new WasmtimeError(lastError);
        return null;
    }
    uint size() @nogc nothrow {
        return wasmtime_table_size(context.backend, &backend);
    }
    WasmtimeError grow(uint delta, WasmtimeVal* init, ref uint prevSize) nothrow {
        lastError = wasmtime_table_grow(context.backend, &backend, delta, init, &prevSize);
        if (lastError) return new WasmtimeError(lastError);
        return null;
    }
}
WasmtimeError wat2wasm(const(char)[] wat, ref WasmByteVec ret) nothrow {
    wasmtime_error_t* error = wasmtime_wat2wasm(wat.ptr, wat.length, &ret.backend);
    if (error) return new WasmtimeError(error);
    return null;
}