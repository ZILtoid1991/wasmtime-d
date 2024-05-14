module wasmtime_nat.wrapper;
///Note to self on dtors: in some cases, they might cause issues, other times they'll be fine.
import wasmtime.types;
import wasmtime.funcs;
public import wasmtime.types : wasm_byte_t, wasm_valkind_t;
public import wasmtime_nat.enums;
/** 
 * Wrapper around `wasm_byte_vec_t`. Used to pass data in and out various functions.
 */
class WasmByteVec {
    wasm_byte_vec_t backend;
    ///Primarily used by the library wrapper for creating the wrapper around this type
    this(wasm_byte_vec_t backend) @nogc nothrow @safe {
        this.backend = backend;
    }
    this() @nogc nothrow {
        wasm_byte_vec_new_empty(&backend);
    }
    this(size_t size) @nogc nothrow {
        wasm_byte_vec_new_uninitialized(&backend, size);
    }
    this(wasm_byte_t[] arr) @nogc nothrow {
        wasm_byte_vec_new(&backend, arr.sizeof, arr.ptr);
    }
    this(WasmByteVec other) @nogc nothrow {
        wasm_byte_vec_copy(&backend, &other.backend);
    }
    ~this() @nogc nothrow {
        wasm_byte_vec_delete(&backend);
    }
    ref wasm_byte_t opIndex(size_t index) @nogc nothrow {
        return backend.data[index];
    }
}
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
    wasm_store_t* backend;
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
class WasmValtypeVec {
    wasm_valtype_vec_t backend;
    this(wasm_valtype_vec_t backend) @nogc nothrow @safe {
        this.backend = backend;
    }
    this() @nogc nothrow {
        wasm_valtype_vec_new_empty(&backend);
    }
    this(size_t size) @nogc nothrow {
        wasm_valtype_vec_new_uninitialized(&backend, size);
    }
    this(wasm_valtype_t*[] arr) @nogc nothrow {
        wasm_valtype_vec_new(&backend, arr.sizeof, arr.ptr);
    }
    this(WasmValtypeVec other) @nogc nothrow {
        wasm_valtype_vec_copy(&backend, &other.backend);
    }
    ~this() @nogc nothrow {
        wasm_valtype_vec_delete(&backend);
    }
    WasmValtype opIndex(size_t index) nothrow const {
        return new WasmValtype(backend.data[index]);
    }
    WasmValtype opIndexAssign(WasmValtype value, size_t index) nothrow {
        backend.data[index] = value.backend;
        value.isInternalRef = true;
        return value;
    }
}
class WasmFunctype {
    wasm_functype_t* backend;
    bool isInternalRef;
    package this(wasm_functype_t* backend) @nogc nothrow {
        this.backend = backend;
        isInternalRef = true;
    }
    package this(const(wasm_functype_t)* backend) @nogc nothrow {
        this.backend = cast(wasm_functype_t*)backend;
        isInternalRef = true;
    }
    this(WasmValtypeVec params, WasmValtypeVec results) @nogc nothrow {
        backend = wasm_functype_new(&params.backend, &results.backend);
    }
    this(WasmFunctype other) @nogc nothrow {
        backend = wasm_functype_copy(other.backend);
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
class WasmFunctypeVec {
    wasm_functype_vec_t backend;
    this(wasm_functype_vec_t backend) @nogc nothrow @safe {
        this.backend = backend;
    }
    this() @nogc nothrow {
        wasm_functype_vec_new_empty(&backend);
    }
    this(size_t size) @nogc nothrow {
        wasm_functype_vec_new_uninitialized(&backend, size);
    }
    this(wasm_valtype_t*[] arr) @nogc nothrow {
        wasm_functype_vec_new(&backend, arr.sizeof, arr.ptr);
    }
    this(WasmFunctypeVec other) @nogc nothrow {
        wasm_functype_vec_copy(&backend, &other.backend);
    }
    ~this() @nogc nothrow {
        wasm_functype_vec_delete(&backend);
    }
    WasmFunctype opIndex(size_t index) nothrow const {
        return new WasmFunctype(backend.data[index]);
    }
    WasmFunctype opIndexAssign(WasmFunctype value, size_t index) nothrow {
        backend.data[index] = value.backend;
        value.isInternalRef = true;
        return value;
    }
}
class WasmGlobaltype {
    wasm_globaltype_t* backend;
    bool isInternalRef;
    this(WasmValtype type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type.backend, mutability);
    }
    this(wasm_valtype_t* type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type, mutability);
    }
    this(WasmGlobaltype other) @nogc nothrow {
        backend = wasm_globaltype_copy(other.backend);
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
class WasmGlobaltypeVec {
    wasm_globaltype_vec_t backend;
    this(wasm_globaltype_vec_t backend) @nogc nothrow @safe {
        this.backend = backend;
    }
    this() @nogc nothrow {
        wasm_globaltype_vec_new_empty(&backend);
    }
    this(size_t size) @nogc nothrow {
        wasm_globaltype_vec_new_uninitialized(&backend, size);
    }
    this(wasm_globaltype_t*[] arr) @nogc nothrow {
        wasm_globaltype_vec_new(&backend, arr.sizeof, arr.ptr);
    }
    this(WasmFunctypeVec other) @nogc nothrow {
        wasm_globaltype_vec_copy(&backend, &other.backend);
    }
    ~this() @nogc nothrow {
        wasm_globaltype_vec_delete(&backend);
    }
    WasmGlobaltype opIndex(size_t index) nothrow const {
        return new WasmGlobaltype(backend.data[index]);
    }
    WasmGlobaltype opIndexAssign(WasmGlobaltype value, size_t index) nothrow {
        backend.data[index] = value.backend;
        value.isInternalRef = true;
        return value;
    }
}
alias WasmLimits = wasm_limits_t;
class WasmTabletype {
    wasm_tabletype_t* backend;
    bool isInternalRef;
    this(WasmValtype type, const WasmLimits limits) @nogc nothrow {
        backend = wasm_tabletype_new(type.backend, limits);
    }
    this(WasmTabletype other) @nogc nothrow {
        backend = wasm_tabletype_copy(other.backend);
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
class WasmTabletypeVec {
    wasm_tabletype_vec_t backend;
    this(wasm_tabletype_vec_t backend) @nogc nothrow @safe {
        this.backend = backend;
    }
    this() @nogc nothrow {
        wasm_tabletype_vec_new_empty(&backend);
    }
    this(size_t size) @nogc nothrow {
        wasm_tabletype_vec_new_uninitialized(&backend, size);
    }
    this(wasm_tabletype_t*[] arr) @nogc nothrow {
        wasm_tabletype_vec_new(&backend, arr.sizeof, arr.ptr);
    }
    this(WasmFunctypeVec other) @nogc nothrow {
        wasm_tabletype_vec_copy(&backend, &other.backend);
    }
    ~this() @nogc nothrow {
        wasm_tabletype_vec_delete(&backend);
    }
    WasmGlobaltype opIndex(size_t index) nothrow const {
        return new WasmTabletype(backend.data[index]);
    }
    WasmTabletype opIndexAssign(WasmTabletype value, size_t index) nothrow {
        backend.data[index] = value.backend;
        value.isInternalRef = true;
        return value;
    }
}