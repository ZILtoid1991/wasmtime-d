module wasmtime_d.wrapper;

import wasmtime.types;
import wasmtime.funcs;
import wasmtime.staticfuncs;
import core.vararg;
public import wasmtime.types : wasm_byte_t, wasm_valkind_t;
public import wasmtime_nat.enums;
import std.typetuple;
import std.traits;
import std.utf;

/**
 * Template wrapper for Wasm vector types
 */
struct WasmVecTempl(string T, string S) {
    mixin(`alias BackendT = wasm_`~S~`_vec_t;`);
    BackendT backend;
    mixin(`alias BackendST = wasm_`~S~`_t;`);
    static auto createEmpty() @trusted @nogc nothrow {
        WasmVecTempl!(T, S) retval;
        mixin(`wasm_`~S~`_vec_new_empty(&retval.backend);`);
        return retval;
    }
    this(BackendT backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(size_t size) @trusted @nogc nothrow {
        mixin(`wasm_`~S~`_vec_new_uninitialized(&backend, size);`);
    }
    void release() @trusted @nogc nothrow {
        mixin(`wasm_`~S~`_vec_delete(&backend);`);
        backend.data = null;
    }
    static if (T.length) {
        mixin(`alias OutT = `~T~`;`);
        OutT opIndex(size_t index) @nogc nothrow {
            assert(index < backend.size);
            return OutT(backend.data[index]);
        }
        OutT opIndexAssign(OutT value, size_t index) @nogc nothrow {
            assert(index < backend.size);
            backend.data[index] = value.backend;
            value.isInternalRef = true;
            return value;
        }
        mixin(
            `this(wasm_`~S~`_t*[] arr) @trusted @nogc nothrow { wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr); }`
        );
    } else {
        ref BackendST opIndex(size_t index) @nogc nothrow {
            assert(index < backend.size);
            return backend.data[index];
        }
        this(BackendST[] arr) @trusted @nogc nothrow {
            mixin(`wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr);`);
        }
    }
}
/**
 * Wrapper around `wasm_byte_vec_t`. Used to pass data in and out various functions.
 */
alias WasmByteVec = WasmVecTempl!("", "byte");
alias WasmName = WasmByteVec;
/**
 * Wrapper around `wasm_config_t`. Global engine configuration.
 *
 * This structure represents global configuration used when constructing a `wasm_engine_t`. Functions used to modify
 * the object can be found as members of this struct, for convenience sake.
 */
struct WasmConfig {
    wasm_config_t* backend;
    this() @trusted @nogc nothrow {
        backend = wasm_config_new();
    }
    void release() @trusted @nogc nothrow {
        wasm_config_delete(backend);
        backend = null;
    }
    void debugInfoSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_debug_info_set(backend, b);
    }
    void consumeFuelSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_consume_fuel_set(backend, b);
    }
    void epochInterruptionSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_epoch_interruption_set(backend, b);
    }
    void maxWasmStackSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_max_wasm_stack_set(backend, b);
    }
    void wasmThreadsSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_threads_set(backend, b);
    }
    void wasmTailCallSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_tail_call_set(backend, b);
    }
    void wasmReferenceTypesSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_reference_types_set(backend, b);
    }
    void wasmFunctionReferencesSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_function_references_set(backend, b);
    }
    void wasmGCSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_gc_set(backend, b);
    }
    void wasmSIMDSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_simd_set(backend, b);
    }
    void wasmRelaxedSIMDSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_set(backend, b);
    }
    void wasmRelaxedSIMDdeterministicSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_deterministic_set(backend, b);
    }
    void wasmBulkMemorySet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_bulk_memory_set(backend, b);
    }
    void wasmMultiValueSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_multi_value_set(backend, b);
    }
    void wasmMultiMemorySet(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_multi_memory_set(backend, b);
    }
    void wasmMemory64Set(bool b) @trusted @nogc nothrow {
        wasmtime_config_wasm_memory64_set(backend, b);
    }
    void strategySet(wasmtime_strategy_t strategy) @trusted @nogc nothrow {
        wasmtime_config_strategy_set(backend, strategy);
    }
    void parallelCompilationSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_parallel_compilation_set(backend, b);
    }
    void craneliftDebugVerifierSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_cranelift_debug_verifier_set(backend, b);
    }
    void craneliftNANCanonicalizationSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_cranelift_nan_canonicalization_set(backend, b);
    }
    void craneliftOptLevelSet(wasmtime_opt_level_t optLevel) @trusted @nogc nothrow {
        wasmtime_config_cranelift_opt_level_set(backend, optLevel);
    }
    void profilerSet(wasmtime_profiling_strategy_t profiling) @trusted @nogc nothrow {
        wasmtime_config_profiler_set(backend, profiling);
    }
    void staticMemoryForcedSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_static_memory_forced_set(backend, b);
    }
    void staticMemoryMaximumSizeSet(uint64_t maxMem) @trusted @nogc nothrow {
        wasmtime_config_static_memory_maximum_size_set(backend, maxMem);
    }
    void staticMemoryGuardSizeSet(uint64_t stMem) @trusted @nogc nothrow {
        wasmtime_config_static_memory_guard_size_set(backend, stMem);
    }
    void dynamicMemoryGuardSizeSet(uint64_t dynMem) @trusted @nogc nothrow {
        wasmtime_config_dynamic_memory_guard_size_set(backend, dynMem);
    }
    void dynamicMemoryReservedFforGrowthSet(uint64_t memSize) @trusted @nogc nothrow {
        wasmtime_config_dynamic_memory_reserved_for_growth_set(backend, memSize);
    }
    void nativeUnwindInfoSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_native_unwind_info_set(backend, b);
    }
    void cacheConfigLoad(const(char)* config) @trusted @nogc nothrow {
        wasmtime_config_cache_config_load(backend, config);
    }
    void targetSet(const(char)* config) @trusted @nogc nothrow {
        wasmtime_config_target_set(backend, config);
    }
    void craneliftFlagEnable(const(char)* config) @trusted @nogc nothrow {
        wasmtime_config_cranelift_flag_enable(backend, config);
    }
    void craneliftFlagSet(const(char)* key, const(char)* value) @trusted @nogc nothrow {
        wasmtime_config_cranelift_flag_set(backend, key, value);
    }
    void macosUseMachPortsSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_macos_use_mach_ports_set(backend, b);
    }
    void hostMemoryCreatorSet(wasmtime_memory_creator_t* memCreator) @trusted @nogc nothrow {
        wasmtime_config_host_memory_creator_set(backend, memCreator);
    }
    void memoryInitCOWSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_memory_init_cow_set(backend, b);
    }
    void asyncSupportSet(bool b) @trusted @nogc nothrow {
        wasmtime_config_async_support_set(backend, b);
    }
    void asyncStackSizeSet(uint64_t size) @trusted @nogc nothrow {
        wasmtime_config_async_stack_size_set(backend, size);
    }
}
/**
 * Wrapper around `wasm_engine_t`. Compilation environment and configuration.
 * An engine is typically global in a program and contains all the configuration necessary for compiling wasm code.
 * An engine is safe to share between threads. Multiple stores can be created within the same engine with each store
 * living on a separate thread. Typically you'll create one engine for the lifetime of your program.
 */
struct WasmEngine {
    wasm_engine_t* backend;
    this() @trusted @nogc nothrow {
        backend = wasm_engine_new();
    }
    this(WasmConfig cfg) @trusted @nogc nothrow {
        backend = wasm_engine_new_with_config(cfg.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_engine_delete(backend);
        backend = null;
    }
    void incrementEpoch() @trusted @nogc nothrow {
        wasmtime_engine_increment_epoch(backend);
    }
}
/**
 * Wrapper around `wasm_store_t`. A collection of instances and wasm global items. It corresponds to the concept of an
 * embedding store.
 */
struct WasmStore {
    static WasmStore defStore;
    wasm_store_t* backend;
    static void createDefWasmStore(WasmEngine engine) @safe @nogc nothrow {
        defStore = WasmStore(engine);
    }
    this(WasmEngine engine) @trusted @nogc nothrow {
        backend = wasm_store_new(engine.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_store_delete(backend);
        backend = null;
    }
}
/**
 * Wrapper around `wasm_valtype_t`. An object representing the type of a value.
 */
struct WasmValtype {
    wasm_valtype_t* backend;
    package this(wasm_valtype_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    package this(const(wasm_valtype_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_valtype_t*)backend;
    }
    this(wasm_valkind_t kind) @trusted @nogc nothrow {
        backend = wasm_valtype_new(kind);
    }
    this(WasmValtype other) @trusted @nogc nothrow {
        backend = wasm_valtype_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_valtype_delete(backend);
        backend = null;
    }
    wasm_valkind_t kind() @trusted @nogc nothrow {
        return wasm_valtype_kind(backend);
    }
}
/**
 * A list of wasm_valtype_t values.
 */
alias WasmValtypeVec = WasmVecTempl!("WasmValtype", "valtype");
struct WasmFunctype {
    wasm_functype_t* backend;
    this(wasm_functype_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_functype_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_functype_t*)backend;
    }
    this(WasmValtypeVec params, WasmValtypeVec results) @trusted @nogc nothrow {
        backend = wasm_functype_new(&params.backend, &results.backend);
    }
    this(WasmFunctype other) @trusted @nogc nothrow {
        backend = wasm_functype_copy(other.backend);
    }
    this(WasmExterntype other) @trusted @nogc nothrow {
        backend = wasm_externtype_as_functype(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_functype_delete(backend);
        backend = null;
    }
    WasmValtypeVec params() @trusted @nogc nothrow {
        return WasmValtypeVec(*cast(wasm_valtype_vec_t*)wasm_functype_params(backend));
    }
    WasmValtypeVec results() @trusted @nogc nothrow {
        return WasmValtypeVec(*cast(wasm_valtype_vec_t*)wasm_functype_results(backend));
    }
}
alias WasmFunctypeVec = WasmVecTempl!("WasmFunctype", "functype");
struct WasmGlobaltype {
    wasm_globaltype_t* backend;
    this(wasm_globaltype_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_globaltype_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_globaltype_t*)backend;
    }
    this(WasmValtype type, wasm_mutability_t mutability) @trusted @nogc nothrow {
        backend = wasm_globaltype_new(type.backend, mutability);
    }
    this(wasm_valtype_t* type, wasm_mutability_t mutability) @trusted @nogc nothrow {
        backend = wasm_globaltype_new(type, mutability);
    }
    this(WasmGlobaltype other) @trusted @nogc nothrow {
        backend = wasm_globaltype_copy(other.backend);
    }
    this(WasmExterntype other) @trusted @nogc nothrow {
        backend = wasm_externtype_as_globaltype(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_globaltype_delete(backend);
        backend = null;
    }
    WasmValtype content() @trusted @nogc nothrow {
        return WasmValtype(cast(wasm_valtype_t*)wasm_globaltype_content(backend));
    }
    wasm_mutability_t mutability() @trusted @nogc nothrow {
        return wasm_globaltype_mutability(backend);
    }
}
alias WasmGlobaltypeVec = WasmVecTempl!("WasmGlobaltype", "globaltype");
alias WasmLimits = wasm_limits_t;
struct WasmTabletype {
    wasm_tabletype_t* backend;
    this(wasm_tabletype_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_tabletype_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_tabletype_t*)backend;
    }
    this(WasmValtype type, const WasmLimits limits) @trusted @nogc nothrow {
        backend = wasm_tabletype_new(type.backend, &limits);
    }
    this(WasmTabletype other) @trusted @nogc nothrow {
        backend = wasm_tabletype_copy(other.backend);
    }
    this(WasmExterntype other) @trusted @nogc nothrow {
        backend = wasm_externtype_as_tabletype(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_tabletype_delete(backend);
        backend = null;
    }
    WasmValtype element() @safe @nogc nothrow {
        return WasmValtype(wasm_tabletype_element(backend));
    }
    const(WasmLimits) limits() @trusted @nogc nothrow {
        return *wasm_tabletype_limits(backend);
    }
}
alias WasmTabletypeVec = WasmVecTempl!("WasmTabletype", "tabletype");
struct WasmMemorytype {
    wasm_memorytype_t* backend;
    this(wasm_memorytype_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_memorytype_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_memorytype_t*)backend;
    }
    this(const WasmLimits limits) @trusted @nogc nothrow {
        backend = wasm_memorytype_new(&limits);
    }
    this(const(WasmLimits)* limits) @trusted @nogc nothrow {
        backend = wasm_memorytype_new(limits);
    }
    this(WasmMemorytype other) @trusted @nogc nothrow {
        backend = wasm_memorytype_copy(other.backend);
    }
    this(WasmExterntype other) @trusted @nogc nothrow {
        backend = wasm_externtype_as_memorytype(other.backend);
    }
    this(ulong min, bool maxPresent, ulong max, bool is64) @trusted @nogc nothrow {
        backend = wasmtime_memorytype_new(min, maxPresent, max, is64);
    }
    void release() @trusted @nogc nothrow {
        wasm_memorytype_delete(backend);
        backend = null;
    }
    WasmLimits limits() @trusted @nogc nothrow {
        return *wasm_memorytype_limits(backend);
    }
    ulong min() @trusted @nogc nothrow {
        return wasmtime_memorytype_minimum(backend);
    }
    bool max(ref ulong result) @trusted @nogc nothrow {
        return wasmtime_memorytype_maximum(backend, &result);
    }
    bool is64() @trusted @nogc nothrow {
        return wasmtime_memorytype_is64(backend);
    }
    bool isShared() @trusted @nogc nothrow {
        return wasmtime_memorytype_isshared(backend);
    }
}
alias WasmMemorytypeVec = WasmVecTempl!("WasmMemorytype", "memorytype");
struct WasmExterntype {
    wasm_externtype_t* backend;
    this(wasm_externtype_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_externtype_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_externtype_t*)backend;
    }
    this(WasmFunctype other) @trusted @nogc nothrow {
        backend = wasm_functype_as_externtype(other.backend);
    }
    this(WasmGlobaltype other) @trusted @nogc nothrow {
        backend = wasm_globaltype_as_externtype(other.backend);
    }
    this(WasmTabletype other) @trusted @nogc nothrow {
        backend = wasm_tabletype_as_externtype(other.backend);
    }
    this(WasmMemorytype other) @trusted @nogc nothrow {
        backend = wasm_memorytype_as_externtype(other.backend);
    }
    this(WasmExterntype other) @trusted @nogc nothrow {
        backend = wasm_externtype_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_externtype_delete(backend);
        backend = null;
    }
    WasmExternkind kind() @trusted @nogc nothrow {
        return cast(WasmExternkind)wasm_externtype_kind(backend);
    }
}
alias WasmExterntypeVec = WasmVecTempl!("WasmExterntype", "externtype");
struct WasmImporttype {
    wasm_importtype_t* backend;
    this(wasm_importtype_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_importtype_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_importtype_t*)backend;
    }
    this(WasmName mod, WasmName name, WasmExterntype kind) @trusted @nogc nothrow {
        backend = wasm_importtype_new(&mod.backend, &name.backend, kind.backend);
    }
    this(WasmImporttype other) @trusted @nogc nothrow {
        backend = wasm_importtype_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_importtype_delete(backend);
        backend = null;
    }
    WasmName mod() @trusted @nogc nothrow {
        return WasmName(*cast(wasm_byte_vec_t*)wasm_importtype_module(backend));
    }
    WasmName name() @trusted @nogc nothrow {
        return WasmName(*cast(wasm_byte_vec_t*)wasm_importtype_name(backend));
    }
    WasmExterntype type() @trusted @nogc nothrow {
        return WasmExterntype(wasm_importtype_type(backend));
    }
}
alias WasmImporttypeVec = WasmVecTempl!("WasmImporttype", "importtype");
struct WasmExporttype {
    wasm_exporttype_t* backend;
    this(wasm_exporttype_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_exporttype_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_exporttype_t*)backend;
    }
    this(WasmName name, WasmExterntype kind) @trusted @nogc nothrow {
        backend = wasm_exporttype_new(&name.backend, kind.backend);
    }
    this(WasmExporttype other) @trusted @nogc nothrow {
        backend = wasm_exporttype_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_exporttype_delete(backend);
        backend = null;
    }
    WasmExterntype type() @trusted @nogc nothrow {
        return WasmExterntype(wasm_exporttype_type(backend));
    }
}
alias WasmExporttypeVec = WasmVecTempl!("WasmExporttype", "exporttype");
alias WasmVal = wasm_val_t;
alias WasmValVec = WasmVecTempl!("", "val");
struct WasmRef {
    wasm_ref_t* backend;
    this(wasm_ref_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_copy(other.backend);
    }
    this(WasmTrap other) @trusted @nogc nothrow {
        backend = wasm_trap_as_ref(other.backend);
    }
    this(WasmForeign other) @trusted @nogc nothrow {
        backend = wasm_foreign_as_ref(other.backend);
    }
    this(WasmModule other) @trusted @nogc nothrow {
        backend = wasm_module_as_ref(other.backend);
    }
    this(WasmFunction other) @trusted @nogc nothrow {
        backend = wasm_func_as_ref(other.backend);
    }
    this(WasmGlobal other) @trusted @nogc nothrow {
        backend = wasm_global_as_ref(other.backend);
    }
    this(WasmTable other) @trusted @nogc nothrow {
        backend = wasm_table_as_ref(other.backend);
    }
    this(WasmMemory other) @trusted @nogc nothrow {
        backend = wasm_memory_as_ref(other.backend);
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_as_ref(other.backend);
    }
    this(WasmInstance other) @trusted @nogc nothrow {
        backend = wasm_instance_as_ref(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_ref_delete(backend);
        backend = null;
    }
    bool same(WasmRef other) @trusted @nogc nothrow const {
        return wasm_ref_same(other.backend, backend);
    }
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_ref_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_ref_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_ref_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
struct WasmFrame {
    wasm_frame_t* backend;
    this(wasm_frame_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_frame_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_frame_t*)backend;
    }
    this(WasmFrame other) @trusted @nogc nothrow {
        backend = wasm_frame_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_frame_delete(backend);
        backend = null;
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
struct WasmTrap {
    wasm_trap_t* backend;
    this(wasm_trap_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_trap_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_trap_t*)backend;
    }
    this(WasmTrap other) @trusted @nogc nothrow {
        backend = wasm_trap_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_trap_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_trap(other.backend);
    }
    this(WasmStore store, WasmMessage msg) @trusted @nogc nothrow {
        backend = wasm_trap_new(store.backend, &msg.backend);
    }
    this(const(char)* msg, size_t msgLen) @trusted @nogc nothrow {
        backend = wasmtime_trap_new(msg, msgLen);
    }
    this(string msg) @trusted @nogc nothrow {
        backend = wasmtime_trap_new(msg.ptr, msg.length);
    }
    bool same(const WasmTrap other) @trusted @nogc nothrow const {
        return wasm_trap_same(backend, other.backend);
    }
    alias opEquals = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_trap_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_trap_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_trap_set_host_info_with_finalizer(backend, info, finalizer);
    }
    bool code(ref wasmtime_trap_code_t code) @trusted @nogc nothrow {
        return wasmtime_trap_code(backend, &code);
    }
}
struct WasmForeign {
    wasm_foreign_t* backend;
    this(wasm_foreign_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_foreign_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_foreign_t*)backend;
    }
    this(WasmForeign other) @trusted @nogc nothrow {
        backend = wasm_foreign_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_foreign_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_foreign(other.backend);
    }
    this(WasmStore store) @trusted @nogc nothrow {
        backend = wasm_foreign_new(store.backend);
    }
    bool same(const WasmForeign other) @trusted @nogc nothrow const {
        return wasm_foreign_same(backend, other.backend);
    }
    alias opEquals = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_foreign_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_foreign_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_foreign_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
struct WasmModule {
    wasm_module_t* backend;
    this(wasm_module_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_module_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_module_t*)backend;
    }
    this(WasmModule other) @trusted @nogc nothrow {
        backend = wasm_module_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        if (!isInternalRef) wasm_module_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_module(other.backend);
    }
    this(WasmStore store, WasmSharedModule origin) @trusted @nogc nothrow {
        backend = wasm_module_obtain(store.backend, origin.backend);
    }
    this(WasmStore st, WasmByteVec binary) @trusted @nogc nothrow {
        backend = wasm_module_new(st.backend, &binary.backend);
    }
    bool same(WasmModule other) @trusted @nogc nothrow const {
        return wasm_module_same(backend, other.backend);
    }
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_module_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_module_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_module_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmSharedModule share() @trusted @nogc nothrow {
        return WasmSharedModule(wasm_module_share(backend));
    }
    bool validate(WasmStore st, WasmByteVec binary) @trusted @nogc nothrow {
        return wasm_module_validate(st.backend, &binary.backend);
    }
    WasmImporttypeVec imports() @trusted @nogc nothrow {
        WasmImporttypeVec result = WasmImporttypeVec.createEmpty();
        wasm_module_imports(backend, &result.backend);
        return result;
    }
    WasmExporttypeVec exports() @trusted @nogc nothrow {
        WasmExporttypeVec result = WasmExporttypeVec.createEmpty();
        wasm_module_exports(backend, &result.backend);
        return result;
    }
    WasmByteVec serialize() @trusted @nogc nothrow {
        WasmByteVec result = WasmByteVec.createEmpty();
        wasm_module_serialize(backend, &result.backend);
        return result;
    }
    static WasmModule deserialize(WasmStore st, WasmByteVec binary) @trusted @nogc nothrow {
        WasmModule result = WasmModule.createEmpty();
        result.backend = wasm_module_deserialize(st.backend, &binary.backend);
        return result;
    }
}
struct WasmSharedModule {
    wasm_shared_module_t* backend;
    this(wasm_shared_module_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_shared_module_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_shared_module_t*)backend;
    }
    void release() @trusted @nogc nothrow {
        wasm_shared_module_delete(backend);
        backend = null;
    }
}
alias WasmFuncCallback = wasm_func_callback_t;
struct WasmFunction {
    wasm_func_t* backend;
    this(wasm_func_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_func_t)* backend) @safe @nogc nothrow {
        this.backend = cast(wasm_func_t*)backend;
    }
    this(WasmFunction other) @trusted @nogc nothrow {
        backend = wasm_func_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_func_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_func(other.backend);
    }
    this(WasmStore st, WasmFunctype type, wasm_func_callback_t callback) @trusted @nogc nothrow {
        this.backend = wasm_func_new(st.backend, type.backend, callback);
        refcount = callback;
    }
    this(WasmStore st, WasmFunctype type, wasm_func_callback_with_env_t callback, void* env,
            wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        this.backend = wasm_func_new_with_env(st.backend, type.backend, callback, env, finalizer);
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_as_func(other.backend);
    }
    bool same(WasmFunction other) @trusted @nogc nothrow const {
        return wasm_func_same(backend, other.backend);
    }
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_func_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_func_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_func_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmFunctype type() @trusted @nogc nothrow {
        return WasmFunctype(wasm_func_type(backend));
    }
    size_t paramArity() @trusted @nogc nothrow {
        return wasm_func_param_arity(backend);
    }
    size_t resultArity() @trusted @nogc nothrow {
        return wasm_func_result_arity(backend);
    }
    WasmTrap _call(WasmValVec args, WasmValVec res) @trusted @nogc nothrow {
        wasm_trap_t* result = wasm_func_call(backend, &args.backend, &res.backend);
        if (result is null) return null;
        return WasmTrap(result);
    }
    WasmResult opCall(T...)(T args) @trusted @nogc nothrow {
        const argsNum = T.length;
        WasmValVec vals = WasmValVec(argsNum);
        WasmResult result = WasmResult(WasmValVec.createEmpty, null);
        int i;
        static foreach (arg ; args) {
            vals[i] = wasmToVal(arg);
            i++;
        }
        WasmValVec argsToFunc = WasmValVec(vals);
        result.trap = _call(argsToFunc, result.returnVal);
        return result;
    }
}
///Special to this implementation, used when returning from WASM functions.
struct WasmResult {
    WasmValVec      returnVal;///Contains the return value vector itself.
    WasmTrap        trap;///Contains any trap that has been encountered during the execution of the function, null otherwise.
}
///UDA, structs marked with it will be packed into a WASM val as a single integer. Struct must be of size 4 or 8, but
///sometimes 16 is also accepted, depending on API usage.
///Note that client languages might not be compatible with it, but otherwise can be useful when speed is important.
struct WasmCfgStructPkg {}
///UDA, structs marked with it will be packed field-by-field.
struct WasmCfgStructByField {}
/**
 * Returns the given type from the given WasmVal.
 */
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
    } else static assert(0, "Unsupported type!");
    assert(0, "Type mismatch!");
}
/**
 * Converts D value to wasmval automatically.
 */
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
    } else static assert(0, "Unsupported type!");
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
        WasmTrap wt = WasmTrap(typeErrorMsg.idup);
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
struct WasmGlobal {
    wasm_global_t* backend;
    this(wasm_global_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_global_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_global_t*)backend;
    }
    this(WasmGlobal other) @trusted @nogc nothrow {
        backend = wasm_global_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_global_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_global(other.backend);
    }
    this(WasmStore st, WasmGlobaltype type, WasmVal val) @trusted @nogc nothrow {
        backend = wasm_global_new(st.backend, type.backend, &val);
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_as_global(other.backend);
    }
    bool same(const WasmGlobal other) @trusted @nogc nothrow const {
        return wasm_global_same(backend, other.backend);
    }
    alias opEqual = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_global_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_global_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_global_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmGlobaltype type() @trusted @nogc nothrow {
        return WasmGlobaltype(wasm_global_type(backend));
    }
    void set(WasmVal v) @trusted @nogc nothrow {
        wasm_global_set(backend, &v);
    }
    void set(T)(T value) @trusted @nogc nothrow  {
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
    WasmVal get() @trusted @nogc nothrow {
        WasmVal v;
        wasm_global_get(backend, &v);
        return v;
    }
}
struct WasmTable {
    wasm_table_t* backend;
    this(wasm_table_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_table_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_table_t*)backend;
    }
    this(WasmTable other) @trusted @nogc nothrow {
        backend = wasm_table_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_table_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_table(other.backend);
    }
    this(WasmStore st, WasmTabletype type, WasmRef init) @trusted @nogc nothrow{
        backend = wasm_table_new(st.backend, type.backend, init.backend);
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_as_table(other.backend);
    }
    bool same(const WasmTable other) @trusted @nogc nothrow const {
        return wasm_table_same(backend, other.backend);
    }
    alias opEqual = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_table_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_table_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_table_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmTabletype type() @trusted @nogc nothrow {
        return WasmTabletype(wasm_table_type(backend));
    }
    WasmRef opIndex(wasm_table_size_t index) @trusted @nogc nothrow {
        WasmRef result = WasmRef(wasm_table_get(backend, index));
        return result;
    }
    WasmRef opIndexAssign(WasmRef value, wasm_table_size_t index) @trusted @nogc nothrow {
        wasm_table_set(backend, index, value.backend);
        return value;
    }
    wasm_table_size_t length() @trusted @nogc nothrow {
        return wasm_table_size(backend);
    }
    void grow(wasm_table_size_t delta, WasmRef init) @trusted @nogc nothrow {
        wasm_table_grow(backend, delta, init.backend);
    }
}
struct WasmMemory {
    wasm_memory_t* backend;
    this(wasm_memory_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_memory_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_memory_t*)backend;
    }
    this(WasmMemory other) @trusted @nogc nothrow {
        backend = wasm_memory_copy(other.backend);
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_memory(other.backend);
    }
    this(WasmStore st, WasmMemorytype type) @trusted @nogc nothrow {
        backend = wasm_memory_new(st.backend, type.backend);
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_as_memory(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_memory_delete(backend);
        backend = null;
    }
    bool same(const WasmMemory other) @trusted @nogc nothrow const {
        return wasm_memory_same(backend, other.backend);
    }
    alias opEquals = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_memory_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_memory_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_memory_set_host_info_with_finalizer(backend, info, finalizer);
    }
    WasmMemorytype type() @trusted @nogc nothrow {
        return WasmMemorytype(wasm_memory_type(backend));
    }
    char* data() @trusted @nogc nothrow {
        return wasm_memory_data(backend);
    }
    size_t dataLength() @trusted @nogc nothrow {
        return wasm_memory_data_size(backend);
    }
    char[] dataArray() @trusted @nogc nothrow {
        return wasm_memory_data(backend)[0..wasm_memory_data_size(backend)];
    }
    void grow(wasm_memory_pages_t delta) @trusted @nogc nothrow {
        wasm_memory_grow(backend, delta);
    }
}
struct WasmExtern {
    wasm_extern_t* backend;
    this(wasm_extern_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_extern_t)* backend) @trusted @nogc nothrow {
        this.backend = cast(wasm_extern_t*)backend;
    }
    this(WasmExtern other) @trusted @nogc nothrow {
        backend = wasm_extern_copy(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasm_extern_delete(backend);
        backend = null;
    }
    this(WasmRef other) @trusted @nogc nothrow {
        backend = wasm_ref_as_extern(other.backend);
    }
    this(WasmFunction other) @trusted @nogc nothrow {
        backend = wasm_func_as_extern(other.backend);
    }
    this(WasmGlobal other) @trusted @nogc nothrow {
        backend = wasm_global_as_extern(other.backend);
    }
    this(WasmTable other) @trusted @nogc nothrow {
        backend = wasm_table_as_extern(other.backend);
    }
    this(WasmMemory other) @trusted @nogc nothrow {
        backend = wasm_memory_as_extern(other.backend);
    }
    WasmExternkind kind() @trusted @nogc nothrow {
        return cast(WasmExternkind)wasm_extern_kind(backend);
    }
    WasmExterntype type() @trusted @nogc nothrow {
        return WasmExterntype(wasm_extern_type(backend));
    }
    bool same(const WasmExtern other) @trusted @nogc nothrow const {
        return wasm_extern_same(backend, other.backend);
    }
    alias opEquals = same;
    void* getHostInfo() @trusted @nogc nothrow const {
        return wasm_extern_get_host_info(backend);
    }
    void setHostInfo(void* info) @trusted @nogc nothrow {
        wasm_extern_set_host_info(backend, info);
    }
    void setHostInfo(void* info, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasm_extern_set_host_info_with_finalizer(backend, info, finalizer);
    }
}
alias WasmExternVec = WasmVecTempl!("WasmExtern", "extern");
struct WasmInstance {
    wasm_instance_t* backend;
    this(wasm_instance_t* backend) @nogc nothrow {
        this.backend = backend;
    }
    this(const(wasm_instance_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_instance_t*)backend;
    }
    this(WasmInstance other) @nogc nothrow {
        backend = wasm_instance_copy(other.backend);
    }
    void release() @nogc nothrow {
        wasm_instance_delete(backend);
        backend = null;
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
struct WasiConfig {
    wasi_config_t* backend;
    this() @trusted @nogc nothrow {
        backend = wasi_config_new();
    }
    void setArgv(int argc, const(char*)* argv) @trusted @nogc nothrow {
        wasi_config_set_argv(backend, argc, argv);
    }
    void inheritArgv() @trusted @nogc nothrow {
        wasi_config_inherit_argv(backend);
    }
    void setEnv(int envc, const(char*)* names, const(char*)* values) @trusted @nogc nothrow {
        wasi_config_set_env(backend, envc, names, values);
    }
    void inheritEnv() @trusted @nogc nothrow {
        wasi_config_inherit_env(backend);
    }
    void setStdinFile(const(char)* path) @trusted @nogc nothrow {
        wasi_config_set_stdin_file(backend, path);
    }
    void setStdinBytes(WasmByteVec binary) @trusted @nogc nothrow {
        wasi_config_set_stdin_bytes(backend, &binary.backend);
    }
    void inheritStdin() @trusted @nogc nothrow {
        wasi_config_inherit_stdin(backend);
    }
    void setStdoutFile(const(char)* path) @trusted @nogc nothrow {
        wasi_config_set_stdout_file(backend, path);
    }
    void inheritStdout() @trusted @nogc nothrow {
        wasi_config_inherit_stdout(backend);
    }
    void setStderrFile(const(char)* path) @trusted @nogc nothrow {
        wasi_config_set_stderr_file(backend, path);
    }
    void inheritStderr() @trusted @nogc nothrow {
        wasi_config_inherit_stderr(backend);
    }
    void preopenDir(const(char)* path, const(char)* guestPath) @trusted @nogc nothrow {
        wasi_config_preopen_dir(backend, path, guestPath);
    }
}
struct WasmtimeError {
    wasmtime_error_t* backend;
    this(wasmtime_error_t* backend) @safe @nogc nothrow {
        this.backend = backend;
    }
    this(const(char)* msg) @trusted @nogc nothrow {
        backend = wasmtime_error_new(msg);
    }
    void release() @trusted @nogc nothrow {
        wasmtime_error_delete(backend);
        backend = null;
    }
    WasmMessage message() @trusted @nogc nothrow const {
        wasm_name_t msg;
        wasmtime_error_message(backend, &msg);
        return WasmMessage(msg);
    }
    bool exitStatus(int* status) @trusted @nogc nothrow {
        return wasmtime_error_exit_status(backend, status);
    }
    WasmFrameVec trace() @trusted @nogc nothrow {
        wasm_frame_vec_t result;
        wasmtime_error_wasm_trace(backend, &result);
        return WasmFrameVec(result);
    }
version (WASMTIME_D_FORCE_NOGC) {
} else {
    this(string msg) @trusted nothrow {
        import std.string;
        backend = wasmtime_error_new(toStringz(msg));
    }
    string toString() @safe nothrow const {
        auto msg = message();
        return cast(string)msg.backend.data[0..msg.backend.size].idup;
    }
}
}
struct WasmtimeModule {
    wasmtime_module_t* backend;
    static WasmtimeError create(WasmEngine engine, ubyte[] wasm, ref WasmtimeModule mod) @trusted @nogc nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_new(engine.backend, wasm.ptr, wasm.length, &creation);
        if (error) return WasmtimeError(error);
        if (creation) mod = WasmtimeModule(creation);
        return WasmtimeError.init;
    }
    static WasmtimeError create(WasmEngine engine, char[] wasm, ref WasmtimeModule mod) @trusted @nogc nothrow {
        return create(engine, cast(ubyte[])wasm, mod);
    }
    static WasmtimeError deserialize(WasmEngine engine, ubyte[] wasm, ref WasmtimeModule mod) @trusted @nogc nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_deserialize(engine.backend, wasm.ptr, wasm.length, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) mod = new WasmtimeModule(creation);
        return null;
    }
    static WasmtimeError deserializeFromFile(WasmEngine engine, const(char)* path, ref WasmtimeModule mod) @trusted
            @nogc nothrow {
        wasmtime_module_t* creation;
        wasmtime_error_t* error = wasmtime_module_deserialize_file(engine.backend, path, &creation);
        if (error) return new WasmtimeError(error);
        if (creation) mod = new WasmtimeModule(creation);
        return null;
    }
    static WasmtimeError validate(WasmEngine engine, ubyte[] wasm) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_module_validate(engine.backend, wasm.ptr, wasm.length);
        if (error) return new WasmtimeError(error);
        return null;
    }
    package this(wasmtime_module_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(WasmtimeModule other) @trusted @nogc nothrow {
        backend = wasmtime_module_clone(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasmtime_module_delete(backend);
        backend = null;
    }
    WasmImporttypeVec imports() @trusted @nogc nothrow {
        WasmImporttypeVec result = WasmImporttypeVec.createEmpty();
        wasmtime_module_imports(backend, &result.backend);
        return result;
    }
    WasmExporttypeVec exports() @trusted @nogc nothrow {
        WasmExporttypeVec result = WasmExporttypeVec.createEmpty();
        wasmtime_module_exports(backend, &result.backend);
        return result;
    }
    WasmtimeError serialize(ref WasmByteVec _out) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_module_serialize(backend, &_out.backend);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    void*[2] imageRange() @trusted @nogc nothrow {
        void*[2] result;
        wasmtime_module_image_range(backend, &result[0], &result[1]);
        return result;
    }
}
struct WasmtimeSharedmemory {
    wasmtime_sharedmemory_t* backend;
    static WasmtimeError create(WasmEngine engine, WasmMemorytype ty, out WasmtimeSharedmemory _out) @trusted @nogc
            nothrow {
        wasmtime_sharedmemory_t* creation;
        wasmtime_error_t* error = wasmtime_sharedmemory_new(engine.backend, ty.backend, &creation);
        if (error) return WasmtimeError(error);
        if (creation) _out = WasmtimeSharedmemory(creation);
        return WasmtimeError.init;
    }
    package this(wasmtime_sharedmemory_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    this(WasmtimeSharedmemory other) @trusted @nogc nothrow {
        backend = wasmtime_sharedmemory_clone(other.backend);
    }
    void release() @trusted @nogc nothrow {
        wasmtime_sharedmemory_delete(backend);
        backend = null;
    }
    WasmMemorytype type() @trusted @nogc nothrow {
        return WasmMemorytype(wasmtime_sharedmemory_type(backend));
    }
    ubyte[] data() @trusted @nogc nothrow {
        return wasmtime_sharedmemory_data(backend)[0..wasmtime_sharedmemory_data_size(backend)];
    }
    size_t size() @trusted @nogc nothrow {
        return wasmtime_sharedmemory_size(backend);
    }
    WasmtimeError grow(size_t delta, size_t* prevSize) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_sharedmemory_grow(backend, delta, prevSize);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
}
struct WasmtimeStore {
    wasmtime_store_t* backend;
    this(WasmEngine engine, void* data, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        backend = wasmtime_store_new(engine.backend, data, finalizer);
    }
    void release() @trusted @nogc nothrow {
        wasmtime_store_delete(backend);
        backend = null;
    }
    WasmtimeContext context() @trusted @nogc nothrow {
        return WasmtimeContext(wasmtime_store_context(backend));
    }
    void limiter(int64_t memorySize, int64_t tableElements, int64_t instances, int64_t tables, int64_t memories)
            @trusted @nogc nothrow {
        wasmtime_store_limiter(backend, memorySize, tableElements, instances, tables, memories);
    }
    void epochDeadlineCallback(wasmSEDCFuncT func, void *data, wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        wasmtime_store_epoch_deadline_callback(backend, func, data, finalizer);
    }
}
struct WasmtimeContext {
    wasmtime_context_t* backend;
    this(wasmtime_context_t* backend) @trusted @nogc nothrow {
        this.backend = backend;
    }
    void release() @trusted @nogc nothrow {
        wasmtime_context_gc(backend);
        backend = null;
    }
    void* getData() @trusted @nogc nothrow {
        return wasmtime_context_get_data(backend);
    }
    void setData(void* data) @trusted @nogc nothrow {
        wasmtime_context_set_data(backend, data);
    }
    WasmtimeError setWasi(WasiConfig cfg) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_context_set_wasi(backend, cfg.backend);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError setFuel(uint64_t fuel) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_context_set_fuel(backend, fuel);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError getFuel(uint64_t* fuel) @trusted @nogc nothrow {
        wasmtime_error_t* error = wasmtime_context_get_fuel(backend, fuel);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    void setEpochDeadline(uint64_t ticsBeyondCurrent) @trusted @nogc nothrow {
        wasmtime_context_set_epoch_deadline(backend, ticsBeyondCurrent);
    }
}
alias WasmtimeExtern = wasmtime_extern_t;
WasmExterntype externType(WasmtimeExtern ext, WasmtimeContext context) @trusted @nogc nothrow {
    return WasmExterntype(wasmtime_extern_type(context.backend, &ext));
}
WasmExterntype externType(WasmtimeExtern* ext, WasmtimeContext context) @trusted @nogc nothrow {
    return WasmExterntype(wasmtime_extern_type(context.backend, ext));
}
struct WasmtimeAnyref {
    wasmtime_anyref_t* backend;
    WasmtimeContext context;    ///Currently it's there due to the functions, might need to be changed
    bool isInternalRef;
    this(WasmtimeContext c, WasmtimeAnyref other) @trusted @nogc nothrow {
        backend = wasmtime_anyref_clone(c.backend, &other.backend);
        this.context = c;
    }
    ///Wrapper for wasmtime_anyref_from_raw and wasmtime_anyref_from_i31
    this(WasmtimeContext c, uint32_t raw, bool i31) @trusted @nogc nothrow {
        if (i31) backend = wasmtime_anyref_from_i31(c.backend, raw);
        else backend = wasmtime_anyref_from_raw(c.backend, raw);
        this.context = c;
    }
    void release() @trusted @nogc nothrow {
        if (!isInternalRef) wasmtime_anyref_delete(context.backend, backend);
        backend = null;
    }
    uint32_t toRaw() @trusted @nogc nothrow {
        return wasmtime_anyref_to_raw(context.backend, backend);
    }
    bool i31GetU(uint32_t* dst) @trusted @nogc nothrow {
        return wasmtime_anyref_i31_get_u(context.backend, backend, dst);
    }
    bool i31GetS(int32_t* dst) @trusted @nogc nothrow {
        return wasmtime_anyref_i31_get_s(context.backend, backend, dst);
    }
}
alias WasmtimeValunion = wasmtime_valunion_t;
alias WasmtimeValRaw = wasmtime_val_raw_t;
alias WasmtimeVal = wasmtime_val_t;
alias WasmtimeFuncCallback = wasmtime_func_callback_t;
alias WasmtimeFuncUncheckedCallback = wasmtime_func_unchecked_callback_t;
/**
 * Converts a D value to a WasmtimeVal for automatically handled
 * Params:
 *   val = The value to be converted.
 *   context = Context for Externref values, etc.
 * Returns: A WasmtimeVal on success.
 */
pragma(inline, true)
WasmtimeVal convToWasmtimeVal(T)(T val, wasmtime_context_t* context) @system @nogc nothrow {
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
        static if (T.sizeof == 4) {
            return WasmtimeVal(WasmtimeValkind.U32, wasmtime_valunion_t(u32 : *cast(int*)(cast(void*)&val)));
        } else static if (T.sizeof == 8) {
            return WasmtimeVal(WasmtimeValkind.U64, wasmtime_valunion_t(u64 : *cast(long*)(cast(void*)&val)));
        } else static if (T.sizeof == 16) {
            return WasmtimeVal(WasmtimeValkind.V128,
                    wasmtime_valunion_t(v128 : *cast(wasmtime_v128*)(cast(void*)&val)));
        } else static assert(0, "Struct must be of exactly the size of 4, 8, or 16 bytes!");
    } else static if (is(T == class) || is(T == interface)) {   //treat classes and interfaces as external reference
        // return WasmtimeVal(WasmtimeValkind.Externref, wasmtime_valunion_t(
                // externref : wasmtime_externref_new(context, cast(void*)val, null)));
        WasmtimeVal result;
        result.kind = WasmtimeValkind.Externref;
        assert(wasmtime_externref_new(context, cast(void*)val, null, &result.of.externref));
        return result;
    } else static if (is(T == struct)) {                        //treat structs as memory blobs
        WasmtimeVal result;
        result.kind = WasmtimeValkind.Externref;
        assert(wasmtime_externref_new(context, cast(void*)val, null, &result.of.externref));
        return result;
    }
    //throw new Exception("Type mismatch!");
}
/**
 * Converts a Wasmtime value to the given T type.
 * Params:
 *   val = The value to be converted.
 *   context = Context for any Externref, etc. kind of values.
 * Returns: A value of type T which the closest matches the type held by val.
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
        static if (T.sizeof == 4) {
            return *cast(T*)(cast(void*)&val.of.i32);
        } else static if (T.sizeof == 8) {
            return *cast(T*)(cast(void*)&val.of.i64);
        } else static if (T.sizeof == 16) {
            return *cast(T*)(cast(void*)&val.of.v128);
        } else static assert(0, "Struct must be of exactly the size of 4, 8, or 16 bytes!");
    } else static if (is(T == class) || is(T == interface)) {    //treat classes and interfaces as external reference
        return cast(T)wasmtime_externref_data(context, &val.of.externref);
    } else static if (is(T == struct)) {
        return *cast(T*)wasmtime_externref_data(context, &val.of.externref);
    }
    //throw new Exception("Type mismatch!");
}
pragma(inline, true)
wasm_valtype_t* toWasmValtype(T)() @nogc nothrow {
    static if (is(T == int) || is(T == uint) || is(T == short) || is(T == ushort) || is(T == byte) || is(T == ubyte) ||
            is(T == char) || is(T == wchar) || is(T == dchar)) {
        return wasm_valtype_new(wasm_valkind_enum.WASM_I32);
    } else static if (is(T == long) || is(T == ulong)) {
        return wasm_valtype_new(wasm_valkind_enum.WASM_I64);
    } else static if (is(T == float)) {
        return wasm_valtype_new(wasm_valkind_enum.WASM_F32);
    } else static if (is(T == double)) {
        return wasm_valtype_new(wasm_valkind_enum.WASM_F64);
    } else static if (hasUDA!(T, "WasmCfgStructPkg")) {
        static if (t.sizeof == 4) {
            return *cast(T*)(cast(void*)&val.of.i32);
        } else static if (t.sizeof == 8) {
            return *cast(T*)(cast(void*)&val.of.i64);
        } else static assert(0, "Struct must be of exactly the size of 4 or 8 bytes!");
    } else static if (is(T == struct) || is(T == class) || is(T == interface)) {
        return wasm_valtype_new(wasm_valkind_enum.WASM_EXTERNREF);
    }
}
struct WasmtimeFunc {
    wasmtime_func_t backend;
    WasmtimeContext context;
    WasmtimeFuncCallback callbackRef;   ///Used mainly to stop the GC to collect the generated function.
    static WasmtimeFunc createnoArgs(WasmtimeContext c, WasmtimeFuncCallback callback, void* env,
            wasmFinalizerFuncT finalizer) @safe @nogc nothrow {
        return create(c, WasmValtypeVec(), WasmValtypeVec(), callback, env, finalizer);
    }
    static WasmtimeFunc create(WasmtimeContext c, WasmValtypeVec args, WasmValtypeVec ret,
            WasmtimeFuncCallback callback, void* env, wasmFinalizerFuncT finalizer) @safe @nogc nothrow {
        wasmtime_func_t result;
        wasm_functype_t* type = wasm_functype_new(&args.backend, &ret.backend);
        wasmtime_func_new(c.backend, type, callback, env, finalizer, &result);
        return WasmtimeFunc(c, result);
    }
version (WASMTIME_D_FORCE_NOGC) {
    /**
     * Creates a WasmtimeFunc binding for a D function.
     * Template params:
     *   Func = The D function that needs a binding to generated for.
     * Params:
     *   c = The context for the function.
     *   env = Environment for the function (currently unused).
     *   finalizer = Finalizer function pointer.
     */
    static WasmtimeFunc createFuncBinding(alias Func)(WasmtimeContext c,
            void* env = null, wasmFinalizerFuncT finalizer = null) @nogc @trusted nothrow {
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
                    if (i >= nargs) throw new Exception("Argument number mismatch!");
                    key = getFromWasmtimeVal!(typeof(key))(args[i], cntxt);
                    i++;
                }
            } catch (Exception e) {
                // WasmTrap wt = new WasmTrap(Func.stringof);
                WasmTrap wt = new WasmTrap(typeErrorMsg.idup);
                wt.isInternalRef = true;
                return wt.backend;
            }

            try {
                static if (is(ReturnType!Func == void)) {
                    Func(params);
                    if (nresults != 0) throw new Exception("Return value number mismatch!");
                } else static if (is(ReturnType!Func == struct) && hasUDA!(ReturnType!Func, "WasmCfgStructByField")){
                    auto v = Func(params);
                    size_t i;
                    static foreach (field ; v.tupleof) {
                        if (nresults <= i) throw new Exception("Return value number mismatch!");
                        results[i] = convToWasmtimeVal(v.field, cntxt);
                        i++;
                    }
                    if (nresults != i) throw new Exception("Return value number mismatch!");
                } else {
                    WasmtimeVal v = convToWasmtimeVal(Func(params), cntxt);
                    if (nresults != 1) throw new Exception("Return value number mismatch!");
                    results[0] = v;
                }
            } catch (Exception e) {
                string msg;
                try {
                    msg = e.toString();
                } catch (Exception e2) {
                    msg = excErrorMsg.idup;
                }
                WasmTrap wt = WasmTrap(msg);
                wt.isInternalRef = true;
                return wt.backend;
            }
            return null;
        }
        WasmtimeFunc result = WasmtimeFunc();
        result.context = c;
        result.callbackRef = &dfuncWrapper;

        staticMap!(Unqual,Parameters!Func) params;
        wasm_valtype_t*[] wasmArgs, wasmRes;
        wasm_valtype_vec_t wasmArgsV, wasmResV;
        foreach (ref key; params) {
            wasmArgs ~= toWasmValtype!(typeof(key))();
        }
        if (wasmArgs.length) wasm_valtype_vec_new(&wasmArgsV, wasmArgs.length, wasmArgs.ptr);
        else wasm_valtype_vec_new_empty(&wasmArgsV);
        static if (is(ReturnType!Func == void)) {
            wasm_valtype_vec_new_empty(&wasmResV);
        } else {
            wasmRes ~= toWasmValtype!(ReturnType!Func)();
            wasm_valtype_vec_new(&wasmResV, wasmRes.length, wasmRes.ptr);
        }
        wasm_functype_t* funcType = wasm_functype_new(&wasmArgsV, &wasmResV);
        wasmtime_func_new(c.backend, funcType, result.callbackRef, env, finalizer, &result.backend);
        return result;
    }
    /**
     * Creates a WasmtimeFunc binding for a method of a D class. The class itself is treated as an `externref` (or
     * `JSclass`) type on the WASM side.
     * Template params:
     *   Func = The D function that needs a binding to generated for.
     * Params:
     *   c = The context for the function.
     *   env = Environment for the function (currently unused).
     *   finalizer = Finalizer function pointer.
     * Note: It is currently unknown if the D WASM ABI even has the `externref` type, let alone how it is initiated.
     */
    static WasmtimeFunc createMethodBinding(alias Func)(WasmtimeContext c,
            void* env = null, wasmFinalizerFuncT finalizer = null) @nogc @trusted nothrow {
        import std.traits:Parameters, ReturnType;
        import std.meta:staticMap;

        alias ClassType = __traits(parent, Func);
        extern(C)
        wasm_trap_t* dfuncWrapper(void* env, wasmtime_caller_t* caller, const(wasmtime_val_t*) args, size_t nargs,
                wasmtime_val_t* results, size_t nresults) nothrow {

            staticMap!(Unqual,Parameters!Func) params;
            auto cntxt = wasmtime_caller_context(caller);
            ClassType c;
            try {
                if (!nargs) throw new Exception("Argument number mismatch!");
                c = getFromWasmtimeVal!ClassType(args[0], cntxt);
                size_t i = 1;
                foreach (ref key; params) {
                    if (i >= nargs) throw new Exception("Argument number mismatch!");
                    key = getFromWasmtimeVal!(typeof(key))(args[i], cntxt);
                    i++;
                }
            } catch (Exception e) {
                // WasmTrap wt = new WasmTrap(Func.stringof);
                WasmTrap wt = WasmTrap(typeErrorMsg.idup);
                wt.isInternalRef = true;
                return wt.backend;
            }

            try {
                static if (is(ReturnType!Func == void)) {
                    __traits(child, c, Func)(params);
                    if (nresults != 0) throw new Exception("Return value number mismatch!");
                } else static if (is(ReturnType!Func == struct) && hasUDA!(ReturnType!Func, "WasmCfgStructByField")){
                    auto v = __traits(child, c, Func)(params);
                    size_t i;
                    static foreach (field ; v.tupleof) {
                        if (nresults <= i) throw new Exception("Return value number mismatch!");
                        results[i] = convToWasmtimeVal(v.field, cntxt);
                        i++;
                    }
                    if (nresults != i) throw new Exception("Return value number mismatch!");
                } else {
                    WasmtimeVal v = convToWasmtimeVal(__traits(child, c, Func)(params), cntxt);
                    if (nresults != 1) throw new Exception("Return value number mismatch!");
                    results[0] = v;
                }
            } catch (Exception e) {
                string msg;
                try {
                    msg = e.toString();
                } catch (Exception e2) {
                    msg = excErrorMsg.idup;
                }
                WasmTrap wt = WasmTrap(msg);
                wt.isInternalRef = true;
                return wt.backend;
            }
            return null;
        }
        WasmtimeFunc result;
        result.context = c;
        result.callbackRef = &dfuncWrapper;

        staticMap!(Unqual,Parameters!Func) params;
        wasm_valtype_t*[] wasmArgs, wasmRes;
        wasm_valtype_vec_t wasmArgsV, wasmResV;
        wasmArgs ~= toWasmValtype!ClassType();
        foreach (ref key; params) {
            wasmArgs ~= toWasmValtype!(typeof(key))();
        }
        if (wasmArgs.length) wasm_valtype_vec_new(&wasmArgsV, wasmArgs.length, wasmArgs.ptr);
        else wasm_valtype_vec_new_empty(&wasmArgsV);
        static if (is(ReturnType!Func == void)) {
            wasm_valtype_vec_new_empty(&wasmResV);
        } else {
            wasmRes ~= toWasmValtype!(ReturnType!Func)();
            wasm_valtype_vec_new(&wasmResV, wasmRes.length, wasmRes.ptr);
        }
        wasm_functype_t* funcType = wasm_functype_new(&wasmArgsV, &wasmResV);
        wasmtime_func_new(c.backend, funcType, result.callbackRef, env, finalizer, &result.backend);
        return result;
    }
} else {
    /**
     * Creates a WasmtimeFunc binding for a D function.
     * Template params:
     *   Func = The D function that needs a binding to generated for.
     * Params:
     *   c = The context for the function.
     *   env = Environment for the function (currently unused).
     *   finalizer = Finalizer function pointer.
     */
    static WasmtimeFunc createFuncBinding(alias Func)(WasmtimeContext c,
            void* env = null, wasmFinalizerFuncT finalizer = null) @trusted nothrow {
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
                    if (i >= nargs) throw new Exception("Argument number mismatch!");
                    key = getFromWasmtimeVal!(typeof(key))(args[i], cntxt);
                    i++;
                }
            } catch (Exception e) {
                // WasmTrap wt = new WasmTrap(Func.stringof);
                WasmTrap wt = new WasmTrap(typeErrorMsg.idup);
                wt.isInternalRef = true;
                return wt.backend;
            }

            try {
                static if (is(ReturnType!Func == void)) {
                    Func(params);
                    if (nresults != 0) throw new Exception("Return value number mismatch!");
                } else static if (is(ReturnType!Func == struct) && hasUDA!(ReturnType!Func, "WasmCfgStructByField")){
                    auto v = Func(params);
                    size_t i;
                    static foreach (field ; v.tupleof) {
                        if (nresults <= i) throw new Exception("Return value number mismatch!");
                        results[i] = convToWasmtimeVal(v.field, cntxt);
                        i++;
                    }
                    if (nresults != i) throw new Exception("Return value number mismatch!");
                } else {
                    WasmtimeVal v = convToWasmtimeVal(Func(params), cntxt);
                    if (nresults != 1) throw new Exception("Return value number mismatch!");
                    results[0] = v;
                }
            } catch (Exception e) {
                string msg;
                try {
                    msg = e.toString();
                } catch (Exception e2) {
                    msg = excErrorMsg.idup;
                }
                WasmTrap wt = WasmTrap(msg);
                wt.isInternalRef = true;
                return wt.backend;
            }
            return null;
        }
        WasmtimeFunc result = WasmtimeFunc();
        result.context = c;
        result.callbackRef = &dfuncWrapper;

        staticMap!(Unqual,Parameters!Func) params;
        wasm_valtype_t*[] wasmArgs, wasmRes;
        wasm_valtype_vec_t wasmArgsV, wasmResV;
        foreach (ref key; params) {
            wasmArgs ~= toWasmValtype!(typeof(key))();
        }
        if (wasmArgs.length) wasm_valtype_vec_new(&wasmArgsV, wasmArgs.length, wasmArgs.ptr);
        else wasm_valtype_vec_new_empty(&wasmArgsV);
        static if (is(ReturnType!Func == void)) {
            wasm_valtype_vec_new_empty(&wasmResV);
        } else {
            wasmRes ~= toWasmValtype!(ReturnType!Func)();
            wasm_valtype_vec_new(&wasmResV, wasmRes.length, wasmRes.ptr);
        }
        wasm_functype_t* funcType = wasm_functype_new(&wasmArgsV, &wasmResV);
        wasmtime_func_new(c.backend, funcType, result.callbackRef, env, finalizer, &result.backend);
        return result;
    }
    /**
     * Creates a WasmtimeFunc binding for a method of a D class. The class itself is treated as an `externref` (or
     * `JSclass`) type on the WASM side.
     * Template params:
     *   Func = The D function that needs a binding to generated for.
     * Params:
     *   c = The context for the function.
     *   env = Environment for the function (currently unused).
     *   finalizer = Finalizer function pointer.
     * Note: It is currently unknown if the D WASM ABI even has the `externref` type, let alone how it is initiated.
     */
    static WasmtimeFunc createMethodBinding(alias Func)(WasmtimeContext c,
            void* env = null, wasmFinalizerFuncT finalizer = null) @trusted nothrow {
        import std.traits:Parameters, ReturnType;
        import std.meta:staticMap;

        alias ClassType = __traits(parent, Func);
        extern(C)
        wasm_trap_t* dfuncWrapper(void* env, wasmtime_caller_t* caller, const(wasmtime_val_t*) args, size_t nargs,
                wasmtime_val_t* results, size_t nresults) nothrow {

            staticMap!(Unqual,Parameters!Func) params;
            auto cntxt = wasmtime_caller_context(caller);
            ClassType c;
            try {
                if (!nargs) throw new Exception("Argument number mismatch!");
                c = getFromWasmtimeVal!ClassType(args[0], cntxt);
                size_t i = 1;
                foreach (ref key; params) {
                    if (i >= nargs) throw new Exception("Argument number mismatch!");
                    key = getFromWasmtimeVal!(typeof(key))(args[i], cntxt);
                    i++;
                }
            } catch (Exception e) {
                // WasmTrap wt = new WasmTrap(Func.stringof);
                WasmTrap wt = WasmTrap(typeErrorMsg.idup);
                wt.isInternalRef = true;
                return wt.backend;
            }

            try {
                static if (is(ReturnType!Func == void)) {
                    __traits(child, c, Func)(params);
                    if (nresults != 0) throw new Exception("Return value number mismatch!");
                } else static if (is(ReturnType!Func == struct) && hasUDA!(ReturnType!Func, "WasmCfgStructByField")){
                    auto v = __traits(child, c, Func)(params);
                    size_t i;
                    static foreach (field ; v.tupleof) {
                        if (nresults <= i) throw new Exception("Return value number mismatch!");
                        results[i] = convToWasmtimeVal(v.field, cntxt);
                        i++;
                    }
                    if (nresults != i) throw new Exception("Return value number mismatch!");
                } else {
                    WasmtimeVal v = convToWasmtimeVal(__traits(child, c, Func)(params), cntxt);
                    if (nresults != 1) throw new Exception("Return value number mismatch!");
                    results[0] = v;
                }
            } catch (Exception e) {
                string msg;
                try {
                    msg = e.toString();
                } catch (Exception e2) {
                    msg = excErrorMsg.idup;
                }
                WasmTrap wt = WasmTrap(msg);
                wt.isInternalRef = true;
                return wt.backend;
            }
            return null;
        }
        WasmtimeFunc result;
        result.context = c;
        result.callbackRef = &dfuncWrapper;

        staticMap!(Unqual,Parameters!Func) params;
        wasm_valtype_t*[] wasmArgs, wasmRes;
        wasm_valtype_vec_t wasmArgsV, wasmResV;
        wasmArgs ~= toWasmValtype!ClassType();
        foreach (ref key; params) {
            wasmArgs ~= toWasmValtype!(typeof(key))();
        }
        if (wasmArgs.length) wasm_valtype_vec_new(&wasmArgsV, wasmArgs.length, wasmArgs.ptr);
        else wasm_valtype_vec_new_empty(&wasmArgsV);
        static if (is(ReturnType!Func == void)) {
            wasm_valtype_vec_new_empty(&wasmResV);
        } else {
            wasmRes ~= toWasmValtype!(ReturnType!Func)();
            wasm_valtype_vec_new(&wasmResV, wasmRes.length, wasmRes.ptr);
        }
        wasm_functype_t* funcType = wasm_functype_new(&wasmArgsV, &wasmResV);
        wasmtime_func_new(c.backend, funcType, result.callbackRef, env, finalizer, &result.backend);
        return result;
    }
}

    this(WasmtimeContext c, WasmFunctype type, WasmtimeFuncCallback callback, void* env, wasmFinalizerFuncT finalizer)
            @trusted @nogc nothrow {
        context = c;
        wasmtime_func_new(c.backend, type.backend, callback, env, finalizer, &backend);
    }
    this(WasmtimeContext c, WasmFunctype type, WasmtimeFuncUncheckedCallback callback, void* env,
            wasmFinalizerFuncT finalizer) @trusted @nogc nothrow {
        context = c;
        wasmtime_func_new_unchecked(c.backend, type.backend, callback, env, finalizer, &backend);
    }
    this(WasmtimeContext c, void* raw) @trusted @nogc nothrow {
        context = c;
        wasmtime_func_from_raw(c.backend, raw, &backend);
    }
    this(WasmtimeContext c, wasmtime_func_t backend) @trusted @nogc nothrow {
        context = c;
        this.backend = backend;
    }
    WasmFunctype type() @trusted @nogc nothrow {
        return WasmFunctype(wasmtime_func_type(context.backend, &backend));
    }
    WasmtimeError call(WasmtimeVal[] args, WasmtimeVal[] results, ref WasmTrap trap) @trusted @nogc nothrow {
        wasm_trap_t* trap0;
        wasmtime_error_t* error = wasmtime_func_call(context.backend, &backend, args.ptr, args.length, results.ptr,
                results.length, &trap0);
        if (trap0) trap = WasmTrap(trap0);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError callUnchecked(WasmtimeValRaw[] argsnres, ref WasmTrap trap) @trusted @nogc nothrow {
        wasm_trap_t* trap0;
        wasmtime_error_t* error = wasmtime_func_call_unchecked(context.backend, &backend, argsnres.ptr, argsnres.length,
                &trap0);
        if (trap0) trap = WasmTrap(trap0);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
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
    WasmtimeResult opCall(T...)(size_t retnum, T args) nothrow {
        WasmtimeResult result;
        WasmtimeVal[] vals;
        result.context = context.backend;
        result.retVal.length = retnum;
        vals.length = T.length;
        int i;
        static foreach (arg ; args) {
            alias localT = typeof(arg);
            vals[i].kind = toWasmValtype!localT;
            vals[i].of = convToWasmtimeVal(arg, context);
            i++;
        }
        wasm_trap_t* trap;
        wasmtime_error_t* error = wasmtime_func_call(context.backend, &backend, vals.ptr, vals.length,
                result.retVal.ptr, result.retVal.length, &trap);
        if (trap) result.trap = WasmTrap(trap);
        if (error) result.error = WasmtimeError(error);
        return result;
    }
    /// Returns the extern associated with this function.
    WasmtimeExtern toExtern() @safe @nogc nothrow {
        WasmtimeExtern result;
        result.kind = WasmExternkind.Func;
        result.of.func = backend;
        return result;
    }
}
///Implementation native stuct, with no C API equilavance.
///Created to make return value handling easier.
struct WasmtimeResult {
    WasmtimeVal[]   retVal;
    WasmtimeError   error;
    WasmTrap        trap;
    wasmtime_context_t* context;
    T get(T)() @trusted @nogc nothrow {
        static if (hasUDA!(T, "WasmCfgStructByField")) {
            T result;
            size_t cntr;
            static foreach (ref field ; result.tupleof) {
                field = getFromWasmtimeVal!(typeof(field))(retVal[0], context);
                cntr++;
            }
            return result;
        } else {
            return getFromWasmtimeVal!T(retVal[0], context);
        }
    }
    T getNth(T)(size_t n) @trusted @nogc nothrow {
        return getFromWasmtimeVal!T(retVal[n], context);
    }
}
struct WasmtimeGlobal {
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
/**
 * Builds up the correct environment requried by the module.
 * Params:
 *   mod = The module that needs the environment.
 *   symbols = The imported symbols. First dimension is module name, second is symbol name.
 * Returns: An array with the elements from `symbols` ordered in a way required by the module.
 */
WasmtimeExtern[] buildCorrectEnvironment(WasmtimeModule mod, WasmtimeExtern[string][string] symbols) {
    WasmtimeExtern[] result;
    WasmImporttypeVec imports = mod.imports;
    for (sizediff_t i ; i < imports.backend.size ; i++) {
        wasm_importtype_t* imp = imports.backend.data[i];
        auto modName = wasm_importtype_module(imp), name = wasm_importtype_name(imp);
        result ~= symbols[modName.data[0..modName.size]][name.data[0..name.size]];
    }
    return result;
}
struct WasmtimeInstance {
    static wasm_trap_t* lastTrap;
    static wasmtime_error_t* lastError;
    wasmtime_instance_t backend;
    WasmtimeContext context;
    this(WasmtimeContext c, WasmtimeModule mod, WasmtimeExtern[] imports) @nogc nothrow {
        context = c;
        lastError = wasmtime_instance_new(c.backend, mod.backend, imports.ptr, imports.length, &backend, &lastTrap);
    }
    package this(WasmtimeContext c, wasmtime_instance_t backend) @nogc nothrow {
        context = c;
        this.backend = backend;
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
struct WasmtimeLinker {
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
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError defineFunc(string mod, string name, WasmFunctype type, WasmtimeFuncCallback cb, void* data,
            wasmFinalizerFuncT finalizer) nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_func(backend, mod.ptr, mod.length, name.ptr, name.length,
                type.backend, cb, data, finalizer);
        if (error) return new WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError defineFunc(string mod, string name, WasmFunctype type, WasmtimeFuncUncheckedCallback cb, void* data,
            wasmFinalizerFuncT finalizer) nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_func_unchecked(backend, mod.ptr, mod.length, name.ptr,
                name.length, type.backend, cb, data, finalizer);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError defineWASI() nothrow {
        wasmtime_error_t* error = wasmtime_linker_define_wasi(backend);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError defineInstance(WasmtimeContext store, string name, out WasmtimeInstance instance) nothrow {
        wasmtime_error_t* error =
                wasmtime_linker_define_instance(backend, store.backend, name.ptr, name.length, &instance.backend);
        if (error) return WasmtimeError(error);
        //instance = new WasmtimeInstance(store, result);
        return WasmtimeError.init;
    }
    WasmtimeError instantiate(WasmtimeContext store, WasmtimeModule mod, out WasmtimeInstance instance,
            ref WasmTrap trap) nothrow {
        wasm_trap_t* trap0;
        wasmtime_instance_t result;
        wasmtime_error_t* error = wasmtime_linker_instantiate(backend, store.backend, mod.backend, &result, &trap0);
        if (trap0) trap = new WasmTrap(trap0);
        if (error) return new WasmtimeError(error);
        instance = WasmtimeInstance(store, result);
        return WasmtimeError.init;
    }
    WasmtimeError setModule(WasmtimeContext store, string name, WasmtimeModule mod) nothrow {
        wasmtime_error_t* error =
                wasmtime_linker_module(backend, store.backend, name.ptr, name.length, mod.backend);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    WasmtimeError getDefault(WasmtimeContext store, string name, WasmtimeFunc func) nothrow {
        wasmtime_error_t* error =
                wasmtime_linker_get_default(backend, store.backend, name.ptr, name.length, &func.backend);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
    bool get(WasmtimeContext store, string mod, string name, ref WasmtimeExtern item) @nogc nothrow {
        return wasmtime_linker_get(backend, store.backend, mod.ptr, mod.length, name.ptr, name.length, &item);
    }
    WasmtimeError instantiatePre(WasmtimeModule mod, wasmtime_instance_pre_t* iP) nothrow {
        wasmtime_error_t* error =
        wasmtime_linker_instantiate_pre(backend, mod.backend, &iP);
        if (error) return WasmtimeError(error);
        return WasmtimeError.init;
    }
}
struct WasmtimeMemory {
    static wasmtime_error_t* lastError;
    static WasmtimeError lastError_D;
    wasmtime_memory_t backend;
    WasmtimeContext context;
    this(WasmtimeContext store, WasmMemorytype type) @nogc nothrow {
        context = store;
        lastError = wasmtime_memory_new(store.backend, type.backend, &backend);
    }
    this(WasmtimeContext store, wasmtime_memory_t backend) @nogc nothrow {
        context = store;
        this.backend = backend;
    }
    WasmMemorytype type() nothrow {
        return WasmMemorytype(wasmtime_memory_type(context.backend, &backend));
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
        if (lastError) return lastError_D = WasmtimeError(lastError);
        return WasmtimeError.init;
    }
}
/* class WasmtimeGuestprofiler {
    wasmtime_guestprofiler_t* backend;

    ~this() @nogc nothrow {
        wasmtime_guestprofiler_delete(backend);
    }
} */
struct WasmtimeTable {
    static wasmtime_error_t* lastError;
    wasmtime_table_t backend;
    WasmtimeContext context;
    this(WasmtimeContext store, WasmTabletype type, WasmtimeVal* init) @nogc nothrow {
        lastError = wasmtime_table_new(store.backend, type.backend, init, &backend);
    }
    WasmTabletype type() nothrow {
        return WasmTabletype(wasmtime_table_type(context.backend, &backend));
    }
    bool get(uint index, ref WasmtimeVal val) @nogc nothrow {
        return wasmtime_table_get(context.backend, &backend, index, &val);
    }
    WasmtimeError set(uint index, WasmtimeVal val) nothrow {
        lastError = wasmtime_table_set(context.backend, &backend, index, &val);
        if (lastError) return WasmtimeError(lastError);
        return WasmtimeError.init;
    }
    uint size() @nogc nothrow {
        return wasmtime_table_size(context.backend, &backend);
    }
    WasmtimeError grow(uint delta, WasmtimeVal* init, ref uint prevSize) nothrow {
        lastError = wasmtime_table_grow(context.backend, &backend, delta, init, &prevSize);
        if (lastError) return WasmtimeError(lastError);
        return WasmtimeError.init;
    }
}
WasmtimeError wat2wasm(const(char)[] wat, ref WasmByteVec ret) @trusted @nogc nothrow {
    wasmtime_error_t* error = wasmtime_wat2wasm(wat.ptr, wat.length, &ret.backend);
    if (error) return WasmtimeError(error);
    return WasmtimeError.init;
}
