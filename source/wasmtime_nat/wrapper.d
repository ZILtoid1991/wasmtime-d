module wasmtime_nat.wrapper;
///Note to self on dtors: in some cases, they might cause issues, other times they'll be fine.
import wasmtime.types;
import wasmtime.funcs;
public import wasmtime.types : wasm_byte_t, wasm_valkind_t;
public import wasmtime_nat.enums;

class WasmVecTempl(string T, string S) {
    mixin(
        `wasm_`~S~`_vec_t backend;` ~ 
        `this(wasm_`~S~`_vec_t backend) @nogc nothrow @safe { this.backend = backend; }`~
        `this() @nogc nothrow { wasm_`~S~`_vec_new_empty(&backend); }`~
        `this(size_t size) @nogc nothrow { wasm_`~S~`_vec_new_uninitialized(&backend, size); }`~
        `~this() @nogc nothrow { wasm_`~S~`_vec_delete(&backend); }`
    );
    static if (T.length) {
        mixin(
            `this(wasm_`~S~`_t*[] arr) @nogc nothrow { wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr); }`
        );
        mixin(
            T~` opIndex(size_t index) nothrow const { return new `~T~`(backend.data[index]); }`~T~
            ` opIndexAssign(`~T~` value, size_t index) nothrow { 
            backend.data[index] = value.backend;
            value.isInternalRef = true;
            return value;}`
        );
    } else {
        mixin(`this(wasm_`~S~`_t[] arr) @nogc nothrow { wasm_`~S~`_vec_new(&backend, arr.sizeof, arr.ptr); }`);
        mixin(`ref wasm_`~S~`_t opIndex(size_t index) @nogc nothrow { return backend.data[index]; }`);
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
alias WasmValtypeVec = WasmVecTempl!("WasmValtype", "valtype");
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
    this(WasmExternkind other) @nogc nothrow {
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
    this(WasmValtype type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type.backend, mutability);
    }
    this(wasm_valtype_t* type, wasm_mutability_t mutability) @nogc nothrow {
        backend = wasm_globaltype_new(type, mutability);
    }
    this(WasmGlobaltype other) @nogc nothrow {
        backend = wasm_globaltype_copy(other.backend);
    }
    this(WasmExternkind other) @nogc nothrow {
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
    this(WasmValtype type, const WasmLimits limits) @nogc nothrow {
        backend = wasm_tabletype_new(type.backend, &limits);
    }
    this(WasmTabletype other) @nogc nothrow {
        backend = wasm_tabletype_copy(other.backend);
    }
    this(WasmExternkind other) @nogc nothrow {
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
    this(WasmLimits limits) @nogc nothrow {
        backend = pwasm_memorytype_new(limits);
    } 
    this(WasmMemorytype other) @nogc nothrow {
        backend = wasm_memorytype_copy(other.backend);
    }
    this(WasmExternkind other) @nogc nothrow {
        backend = wasm_externtype_as_memorytype(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_tabletype_delete(backend);
    }
    WasmLimits limits() @nogc nothrow {
        return wasm_memorytype_limits(backend);
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
        if (!isInternalRef) pwasm_externtype_delete(backend);
    }
    WasmExternkind kind() @nogc nothrow {
        wasm_externtype_kind(backend);
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
    this(WasmName mod, WasmName name, WasmExterntype kind) @nogc nothrow {
        backend = wasm_importtype_new(&mod.backend, &mane.backend, kind.backend);
    }
    this(WasmImporttype other) @nogc nothrow {
        this.backend = wasm_importtype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_importtype_delete(backend);
    }
    WasmName mod() @nogc nothrow {
        return new WasmName(wasm_importtype_module(backend));
    }
    WasmName name() @nogc nothrow {
        return new WasmName(wasm_importtype_name(backend));
    }
    WasmExterntype type() @nogc nothrow {
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
    this(WasmName mod, WasmName name, WasmExterntype kind) @nogc nothrow {
        backend = wasm_exporttype_new(&mod.backend, &mane.backend, kind.backend);
    }
    this(WasmExporttype other) @nogc nothrow {
        this.backend = wasm_exporttype_copy(other.backend);
    }
    ~this() @nogc nothrow {
        if (!isInternalRef) wasm_exporttype_delete(backend);
    }
    WasmName mod() @nogc nothrow {
        return new WasmName(wasm_exporttype_module(backend));
    }
    WasmName name() @nogc nothrow {
        return new WasmName(wasm_exporttype_name(backend));
    }
    WasmExterntype type() @nogc nothrow {
        return new WasmExterntype(wasm_exporttype_type(backend));
    }
}
alias WasmExporttypeVec = WasmVecTempl!("WasmExporttype", "exporttype");
alias WasmVal = wasm_val_t;
alias WasmValVec = WasmVecTempl!("", "val");