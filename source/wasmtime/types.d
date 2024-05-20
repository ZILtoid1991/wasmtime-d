module wasmtime.types;

import core.stdc.stddef;
import core.stdc.stdint;
//import core.stdc.stdbool;
import core.stdc.string;

alias byte_t = char;
alias float32_t = float;
alias float64_t = double;

///Not found in the original specs, added by me since it's a very common thing in the library.
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasmFinalizerFuncT = extern(C) nothrow void function(void*);
///Not found in original specs, added in order to get around issues of the D compiler not liking this long definition
///inside another function pointer. Used in function `wasmtime_store_epoch_deadline_callback()`.
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasmSEDCFuncT = extern(C) nothrow wasmtime_error_t* function(wasmtime_context_t* context, void* data, 
        uint64_t* epoch_deadline_delta, wasmtime_update_deadline_kind_t* update_kind);

alias wasm_byte_t = byte_t;

struct wasm_byte_vec_t { 
    size_t size;
    wasm_byte_t * data; 
}

alias wasm_name_t = wasm_byte_vec_t;

struct wasm_config_t {}

struct wasm_engine_t {}

struct wasm_store_t {}

struct wasm_shared_module_t {}

alias wasm_mutability_t = uint8_t;

enum wasm_mutability_enum : wasm_mutability_t {
    WASM_CONST,
    WASM_VAR,
}

struct wasm_limits_t {
    uint32_t min;
    uint32_t max;
}

static const uint32_t wasm_limits_max_default = 0xffffffff;

struct wasm_valtype_t {}
struct wasm_valtype_vec_t { 
    size_t size; 
    wasm_valtype_t ** data; 
    }

alias wasm_valkind_t = uint8_t;

enum wasm_valkind_enum : wasm_valkind_t {
    WASM_I32,
    WASM_I64,
    WASM_F32,
    WASM_F64,
    WASM_EXTERNREF = 128,
    WASM_FUNCREF,
}

struct wasm_functype_t {}

struct wasm_functype_vec_t {
    size_t size;
    wasm_functype_t ** data;
}

struct wasm_globaltype_t {}

struct wasm_globaltype_vec_t { 
    size_t size; 
    wasm_globaltype_t ** data; 
}

struct wasm_tabletype_t {}

struct wasm_tabletype_vec_t { 
    size_t size; 
    wasm_tabletype_t ** data; 
}

struct wasm_memorytype_t {}

struct wasm_memorytype_vec_t { 
    size_t size; 
    wasm_memorytype_t ** data; 
}

struct wasm_externtype_t {}

struct wasm_externtype_vec_t { 
    size_t size; 
    wasm_externtype_t ** data; 
}

alias wasm_externkind_t = uint8_t;

enum wasm_externkind_enum {
    WASM_EXTERN_FUNC,
    WASM_EXTERN_GLOBAL,
    WASM_EXTERN_TABLE,
    WASM_EXTERN_MEMORY,
}

struct wasm_importtype_t {}

struct wasm_importtype_vec_t { 
    size_t size; 
    wasm_importtype_t ** data; 
}

struct wasm_exporttype_t {}

struct wasm_exporttype_vec_t { 
    size_t size; 
    wasm_exporttype_t ** data; 
}

struct wasm_ref_t {}

struct wasm_val_t {
    wasm_valkind_t kind;
    union OF {
        int32_t i32;
        int64_t i64;
        float32_t f32;
        float64_t f64;
        wasm_ref_t* _ref;
    }
    OF of;
}

struct wasm_val_vec_t { 
    size_t size; 
    wasm_val_t * data; 
}

struct wasm_frame_t {}

struct wasm_frame_vec_t { 
    size_t size; 
    wasm_frame_t ** data; 
}

alias wasm_message_t = wasm_name_t;

struct wasm_trap_t {}

struct wasm_foreign_t {}

struct wasm_module_t {}

struct wasm_func_t {}
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasm_func_callback_t = 
        extern(C) nothrow wasm_trap_t* function(const(wasm_val_vec_t)* args, wasm_val_vec_t* results);
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasm_func_callback_with_env_t = 
        extern(C) nothrow wasm_trap_t* function(void* env, const(wasm_val_vec_t)* args, wasm_val_vec_t* results);

struct wasm_global_t {}

struct wasm_table_t {}

alias wasm_table_size_t = uint32_t;

struct wasm_memory_t {}

alias wasm_memory_pages_t = uint32_t;

static const size_t MEMORY_PAGE_SIZE = 0x10000;

struct wasm_extern_t {}

struct wasm_extern_vec_t { 
    size_t size; 
    wasm_extern_t ** data; 
}

struct wasm_instance_t {}

struct wasi_config_t {}

struct wasmtime_error_t {}

alias wasmtime_strategy_t = uint8_t;

enum wasmtime_strategy_enum : wasmtime_strategy_t {
    WASMTIME_STRATEGY_AUTO,
    WASMTIME_STRATEGY_CRANELIFT,
}

alias wasmtime_opt_level_t = uint8_t;

enum wasmtime_opt_level_enum : wasmtime_opt_level_t {
    WASMTIME_OPT_LEVEL_NONE,
    WASMTIME_OPT_LEVEL_SPEED,
    WASMTIME_OPT_LEVEL_SPEED_AND_SIZE,
}

alias wasmtime_profiling_strategy_t = uint8_t;

enum wasmtime_profiling_strategy_enum : wasmtime_profiling_strategy_t {
    WASMTIME_PROFILING_STRATEGY_NONE,
    WASMTIME_PROFILING_STRATEGY_JITDUMP,
    WASMTIME_PROFILING_STRATEGY_VTUNE,
    WASMTIME_PROFILING_STRATEGY_PERFMAP,
}
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasmtime_memory_get_callback_t = 
        extern(C) nothrow uint8_t* function(void* env, size_t* byte_size, size_t* maximum_byte_size);
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasmtime_memory_grow_callback_t = extern(C) nothrow wasmtime_error_t* function(void* env, size_t new_size);

struct wasmtime_linear_memory_t {
    void* env;
    wasmtime_memory_get_callback_t get_memory;
    wasmtime_memory_grow_callback_t grow_memory;
    //extern(C) void function(void*) finalizer;
    wasmFinalizerFuncT finalizer;
}
///Note: Handle any potential exceptions on D side, let's not make issues from throwing in these kind of functions towards
///code that isn't equiped to handle it!
alias wasmtime_new_memory_callback_t = extern(C) nothrow wasmtime_error_t* function(void* env, 
    const(wasm_memorytype_t*) ty, size_t minimum, size_t maximum, size_t reserved_size_in_bytes, 
    size_t guard_size_in_bytes, wasmtime_linear_memory_t* memory_ret);

struct wasmtime_memory_creator_t {
    void* env;
    wasmtime_new_memory_callback_t new_memory;
    //extern(C) void function(void *) finalizer;
    wasmFinalizerFuncT finalizer;
}

struct wasmtime_module_t {}

struct wasmtime_sharedmemory_t {}

struct wasmtime_store_t {}

struct wasmtime_context_t {}

alias wasmtime_update_deadline_kind_t = uint8_t;

struct wasmtime_func_t {
    uint64_t store_id;
    size_t index;
}

struct wasmtime_table_t {
    uint64_t store_id;
    size_t index;
}

struct wasmtime_memory_t {
    uint64_t store_id;
    size_t index;
}

struct wasmtime_global_t {
    uint64_t store_id;
    size_t index;
}

alias wasmtime_extern_kind_t = uint8_t;

union wasmtime_extern_union_t {
    wasmtime_func_t func;
    wasmtime_global_t global;
    wasmtime_table_t table;
    wasmtime_memory_t memory;
    wasmtime_sharedmemory_t* sharedmemory;
}

struct wasmtime_extern_t {
    wasmtime_extern_kind_t kind;
    wasmtime_extern_union_t of;
}

struct wasmtime_anyref_t {}

struct wasmtime_externref_t {}

alias wasmtime_valkind_t = uint8_t;

alias wasmtime_v128 = uint8_t[16];

union wasmtime_valunion_t {
    int32_t i32;
    int64_t i64;
    float32_t f32;
    float64_t f64;
    wasmtime_anyref_t* anyref;
    wasmtime_externref_t* externref;
    wasmtime_func_t funcref;
    wasmtime_v128 v128;
}

union wasmtime_val_raw_t {
    int32_t i32;
    int64_t i64;
    float32_t f32;
    float64_t f64;
    wasmtime_v128 v128;
    uint32_t anyref;
    uint32_t externref;
    void *funcref;
}

struct wasmtime_val_t {
    wasmtime_valkind_t kind;
    wasmtime_valunion_t of;
}

struct wasmtime_caller_t {}

alias wasmtime_func_callback_t = extern(C) nothrow wasm_trap_t* function(void* env, wasmtime_caller_t* caller, 
        const(wasmtime_val_t*) args, size_t nargs, wasmtime_val_t* results, size_t nresults);

alias wasmtime_func_unchecked_callback_t = extern(C) nothrow wasm_trap_t* function(void* env, wasmtime_caller_t* caller, 
        wasmtime_val_raw_t* args_and_results, size_t num_args_and_results);

struct wasmtime_instance_t {
    uint64_t store_id;
    size_t index;
}

struct wasmtime_instance_pre_t {}

struct wasmtime_linker_t {}

struct wasmtime_guestprofiler_t {}

struct wasmtime_guestprofiler_modules_t {
    const(wasm_name_t)* name;
    const(wasmtime_module_t)* mod;
}

alias wasmtime_trap_code_t = uint8_t;

enum wasmtime_trap_code_enum : wasmtime_trap_code_t {
    WASMTIME_TRAP_CODE_STACK_OVERFLOW,
    WASMTIME_TRAP_CODE_MEMORY_OUT_OF_BOUNDS,
    WASMTIME_TRAP_CODE_HEAP_MISALIGNED,
    WASMTIME_TRAP_CODE_TABLE_OUT_OF_BOUNDS,
    WASMTIME_TRAP_CODE_INDIRECT_CALL_TO_NULL,
    WASMTIME_TRAP_CODE_BAD_SIGNATURE,
    WASMTIME_TRAP_CODE_INTEGER_OVERFLOW,
    WASMTIME_TRAP_CODE_INTEGER_DIVISION_BY_ZERO,
    WASMTIME_TRAP_CODE_BAD_CONVERSION_TO_INTEGER,
    WASMTIME_TRAP_CODE_UNREACHABLE_CODE_REACHED,
    WASMTIME_TRAP_CODE_INTERRUPT,
    WASMTIME_TRAP_CODE_OUT_OF_FUEL,
}

alias wasmtime_func_async_continuation_callback_t = extern(C) bool function(void* env);

struct wasmtime_async_continuation_t {
    wasmtime_func_async_continuation_callback_t callback;
    void* env;
    wasmFinalizerFuncT finalizer;
}

alias wasmtime_func_async_callback_t = extern(C) void function(void* env, wasmtime_caller_t* caller, 
        const(wasmtime_val_t)* args, size_t nargs, wasmtime_val_t* results, size_t nresults, wasm_trap_t** trap_ret, 
        wasmtime_async_continuation_t* continuation_ret);

struct wasmtime_call_future_t {}

alias wasmtime_stack_memory_get_callback_t = extern(C) uint8_t* function(void* env, size_t* out_len);

struct wasmtime_stack_memory_t {
    void *env;
    wasmtime_stack_memory_get_callback_t get_stack_memory;
    wasmFinalizerFuncT finalizer;
}

alias wasmtime_new_stack_memory_callback_t = extern(C) wasmtime_error_t* function(void* env, size_t size, 
        wasmtime_stack_memory_t* stack_ret);

struct wasmtime_stack_creator_t {
    void *env;
    wasmtime_new_stack_memory_callback_t new_stack;
    wasmFinalizerFuncT finalizer;
}

static assert(wasmtime_valunion_t.sizeof == 16, "should be 16-bytes large");
static assert(wasmtime_valunion_t.alignof == 8,"should be 8-byte aligned");
static assert(wasmtime_val_raw_t.sizeof == 16, "should be 16 bytes large");
static assert(wasmtime_val_raw_t.alignof == 8, "should be 8-byte aligned");

static assert(float.sizeof == uint32_t.sizeof, "incompatible float type");
static assert(double.sizeof == uint64_t.sizeof, "incompatible double type");
static assert(intptr_t.sizeof == uint32_t.sizeof || intptr_t.sizeof == uint64_t.sizeof, "incompatible pointer type");