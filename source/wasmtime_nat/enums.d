module wasmtime_nat.enums;

import wasmtime.types;

//Enums with nicer, D-style formatting.

/** 
 * Boolean flag for whether a global is mutable or not. 
 */
enum WasmMutability : wasm_mutability_t {
    CONST       =       wasm_mutability_enum.WASM_CONST,
    VAR         =       wasm_mutability_enum.WASM_VAR
}
/** 
 * Different kinds of types supported in wasm. 
 */
enum WasmValkind : wasm_valkind_t {
    I32         =       wasm_valkind_enum.WASM_I32,
    I64         =       wasm_valkind_enum.WASM_I64,
    F32         =       wasm_valkind_enum.WASM_F32,
    F64         =       wasm_valkind_enum.WASM_F64,
    ExternRef   =       wasm_valkind_enum.WASM_EXTERNREF,
    FuncRef     =       wasm_valkind_enum.WASM_FUNCREF,
}
/** 
 * Classifier for `wasm_externtype_t`/`WasmExterntype`. 
 * This is returned from `wasm_extern_kind()`/`WasmExtern.kind()` and `wasm_externtype_kind`/`WasmExterntype.kind` to determine what kind of type is wrapped
 */
enum WasmExternkind : wasm_externkind_t {
    Func        =       wasm_externkind_enum.WASM_EXTERN_FUNC,
    Global      =       wasm_externkind_enum.WASM_EXTERN_GLOBAL,
    Table       =       wasm_externkind_enum.WASM_EXTERN_TABLE,
    Memory      =       wasm_externkind_enum.WASM_EXTERN_MEMORY,
}
/** 
 * Different ways that Wasmtime can compile WebAssembly.
 */
enum WasmtimeStrategy : wasmtime_strategy_t {
    ///Automatically picks the compilation backend, currently always defaulting to Cranelift.
    Auto        =       wasmtime_strategy_enum.WASMTIME_STRATEGY_AUTO,
    ///Indicates that Wasmtime will unconditionally use Cranelift to compile WebAssembly code.
    Cranelift   =       wasmtime_strategy_enum.WASMTIME_STRATEGY_CRANELIFT,
}
/** 
 * Different ways Wasmtime can optimize generated code.
 */
enum WasmtimeOptLevel : wasmtime_opt_level_t {
    ///Generated code will not be optimized at all. 
    None        =       wasmtime_opt_level_enum.WASMTIME_OPT_LEVEL_NONE,
    ///Generated code will be optimized purely for speed. 
    Speed       =       wasmtime_opt_level_enum.WASMTIME_OPT_LEVEL_SPEED,
    ///Generated code will be optimized, but some speed optimizations are disabled if they cause the generated code to 
    ///be significantly larger. 
    SpeedAndSize=       wasmtime_opt_level_enum.WASMTIME_OPT_LEVEL_SPEED_AND_SIZE,
}
/** 
 * Different ways to profile JIT code. 
 */
enum WasmtimeProfilingStrategy : wasmtime_profiling_strategy_t {
    ///No profiling is enabled at runtime. 
    None        =       wasmtime_profiling_strategy_enum.WASMTIME_PROFILING_STRATEGY_NONE,
    ///Linux's "jitdump" support in perf is enabled and when Wasmtime is run under perf necessary calls will be made 
    ///to profile generated JIT code. 
    JITDump     =       wasmtime_profiling_strategy_enum.WASMTIME_PROFILING_STRATEGY_JITDUMP,
    ///Support for VTune will be enabled and the VTune runtime will be informed, at runtime, about JIT code.
    ///Note that this isn't always enabled at build time. 
    VTune       =       wasmtime_profiling_strategy_enum.WASMTIME_PROFILING_STRATEGY_VTUNE,
    ///inux's simple "perfmap" support in perf is enabled and when Wasmtime is run under perf necessary calls will be 
    ///made to profile generated JIT code. 
    PerfMap     =       wasmtime_profiling_strategy_enum.WASMTIME_PROFILING_STRATEGY_PERFMAP,
}
/** 
 * Trap codes for instruction traps. 
 */
enum WasmtimeTrapCode : wasmtime_trap_code_t {
    ///The current stack space was exhausted.
    StackOverflow       =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_STACK_OVERFLOW,
    ///An out-of-bounds memory access. 
    MemoryOutOfBounds   =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_MEMORY_OUT_OF_BOUNDS,
    ///A wasm atomic operation was presented with a not-naturally-aligned linear-memory address. 
    HeapMisaligned      =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_HEAP_MISALIGNED,
    ///An out-of-bounds access to a table. 
    TableOutOfBounds    =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_TABLE_OUT_OF_BOUNDS,
    ///An out-of-bounds access to a table. 
    IndirectCallToNull  =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_INDIRECT_CALL_TO_NULL,
    ///Signature mismatch on indirect call. 
    BadSignature        =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_BAD_SIGNATURE,
    ///An integer arithmetic operation caused an overflow. 
    IntegerOverflow     =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_INTEGER_OVERFLOW,
    ///An integer division by zero. 
    IntegerDivisionByZero=  wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_INTEGER_DIVISION_BY_ZERO,
    ///Failed float-to-int conversion. 
    BadConversionToInteger= wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_BAD_CONVERSION_TO_INTEGER,
    ///Code that was supposed to have been unreachable was reached.
    UnreachableCodeReached= wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_UNREACHABLE_CODE_REACHED,
    ///Execution has potentially run too long and may be interrupted. 
    Interrupt           =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_INTERRUPT,
    ///Execution has run out of the configured fuel amount. 
    CodeOutOfFuel       =   wasmtime_trap_code_enum.WASMTIME_TRAP_CODE_OUT_OF_FUEL,
}