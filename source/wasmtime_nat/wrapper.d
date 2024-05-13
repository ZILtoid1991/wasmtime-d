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
    void debug_info_set(bool b) @nogc nothrow {
        wasmtime_config_debug_info_set(backend, b);
    }
    void consume_fuel_set(bool b) @nogc nothrow {
        wasmtime_config_consume_fuel_set(backend, b);
    }
    void epoch_interruption_set(bool b) @nogc nothrow {
        wasmtime_config_epoch_interruption_set(backend, b);
    }
    void max_wasm_stack_set(bool b) @nogc nothrow {
        wasmtime_config_max_wasm_stack_set(backend, b);
    }
    void wasm_threads_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_threads_set(backend, b);
    }
    void wasm_tail_call_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_tail_call_set(backend, b);
    }
    void wasm_reference_types_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_reference_types_set(backend, b);
    }
    void wasm_function_references_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_function_references_set(backend, b);
    }
    void wasm_gc_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_gc_set(backend, b);
    }
    void wasm_simd_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_simd_set(backend, b);
    }
    void wasm_relaxed_simd_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_set(backend, b);
    }
    void wasm_relaxed_simd_deterministic_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_relaxed_simd_deterministic_set(backend, b);
    }
    void wasm_bulk_memory_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_bulk_memory_set(backend, b);
    }
    void wasm_multi_value_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_multi_value_set(backend, b);
    }
    void wasm_multi_memory_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_multi_memory_set(backend, b);
    }
    void wasm_memory64_set(bool b) @nogc nothrow {
        wasmtime_config_wasm_memory64_set(backend, b);
    }
    void strategy_set(wasmtime_strategy_t strategy) @nogc nothrow {
        wasmtime_config_strategy_set(backend, strategy);
    }
    void parallel_compilation_set(bool b) @nogc nothrow {
        wasmtime_config_parallel_compilation_set(backend, b);
    }
    void cranelift_debug_verifier_set(bool b) @nogc nothrow {
        wasmtime_config_cranelift_debug_verifier_set(backend, b);
    }
    void cranelift_nan_canonicalization_set(bool b) @nogc nothrow {
        wasmtime_config_cranelift_nan_canonicalization_set(backend, b);
    }
    void cranelift_opt_level_set(wasmtime_opt_level_t optLevel) @nogc nothrow {
        wasmtime_config_cranelift_opt_level_set(backend, optLevel);
    }
    void profiler_set(wasmtime_profiling_strategy_t profiling) @nogc nothrow {
        wasmtime_config_profiler_set(backend, profiling);
    }
    void static_memory_forced_set(bool b) @nogc nothrow {
        wasmtime_config_static_memory_forced_set(backend, b);
    }
    void static_memory_maximum_size_set(uint64_t maxMem) @nogc nothrow {
        wasmtime_config_static_memory_maximum_size_set(backend, maxMem);
    }
    void static_memory_guard_size_set(uint64_t stMem) @nogc nothrow {
        wasmtime_config_static_memory_guard_size_set(backend, stMem);
    }
    void dynamic_memory_guard_size_set(uint64_t dynMem) @nogc nothrow {
        wasmtime_config_dynamic_memory_guard_size_set(backend, dynMem);
    }
    void dynamic_memory_reserved_for_growth_set(uint64_t memSize) @nogc nothrow {
        wasmtime_config_dynamic_memory_reserved_for_growth_set(backend, memSize);
    }
    void native_unwind_info_set(bool b) @nogc nothrow {
        wasmtime_config_native_unwind_info_set(backend, b);
    }
    void cache_config_load(const(char)* config) @nogc nothrow {
        wasmtime_config_cache_config_load(backend, config);
    }
    void target_set(const(char)* config) @nogc nothrow {
        wasmtime_config_target_set(backend, config);
    }
    void cranelift_flag_enable(const(char)* config) @nogc nothrow {
        wasmtime_config_cranelift_flag_enable(backend, config);
    }
    void cranelift_flag_set(const(char)* key, const(char)* value) @nogc nothrow {
        wasmtime_config_cranelift_flag_set(backend, key, value);
    }
    void macos_use_mach_ports_set(bool b) @nogc nothrow {
        wasmtime_config_macos_use_mach_ports_set(backend, b);
    }
    void host_memory_creator_set(wasmtime_memory_creator_t* memCreator) @nogc nothrow {
        wasmtime_config_host_memory_creator_set(backend, memCreator);
    }
    void memory_init_cow_set(bool b) @nogc nothrow {
        wasmtime_config_memory_init_cow_set(backend, b);
    }
    void async_support_set(bool b) @nogc nothrow {
        wasmtime_config_async_support_set(backend, b);
    }
    void async_stack_size_set(uint64_t size) @nogc nothrow {
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