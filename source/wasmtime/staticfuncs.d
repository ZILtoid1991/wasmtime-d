module wasmtime.staticfuncs;

public import wasmtime.types;
public import wasmtime.funcs;

import core.stdc.string;
import core.stdc.stdint;

//static functions that are inlined on the original
pragma(inline, true)
void wasm_name_new_from_string(wasm_name_t* _out, const char* s) {
    wasm_byte_vec_new(_out, strlen(s), s);
}
pragma(inline, true)
void wasm_name_new_from_string_nt(wasm_name_t* _out, const char* s) {
    wasm_byte_vec_new(_out, strlen(s) + 1, s);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_i32() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_I32);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_i64() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_I64);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_f32() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_F32);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_f64() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_F64);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_externref() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_EXTERNREF);
}
pragma(inline, true)
wasm_valtype_t* wasm_valtype_new_funcref() {
    return wasm_valtype_new(wasm_valkind_enum.WASM_FUNCREF);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_0_0() {
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new_empty(&params);
    wasm_valtype_vec_new_empty(&results);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_1_0(wasm_valtype_t* p) {
    wasm_valtype_t*[1] ps = [p];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 1, ps.ptr);
    wasm_valtype_vec_new_empty(&results);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_2_0(wasm_valtype_t* p1, wasm_valtype_t* p2) {
    wasm_valtype_t*[2] ps = [p1, p2];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 2, ps.ptr);
    wasm_valtype_vec_new_empty(&results);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_3_0(wasm_valtype_t* p1, wasm_valtype_t* p2, wasm_valtype_t* p3) {
    wasm_valtype_t*[3] ps = [p1, p2, p3];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 3, ps.ptr);
    wasm_valtype_vec_new_empty(&results);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_0_1(wasm_valtype_t* r) {
    wasm_valtype_t*[1] rs = [r];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new_empty(&params);
    wasm_valtype_vec_new(&results, 1, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_1_1(wasm_valtype_t* p, wasm_valtype_t* r) {
    wasm_valtype_t*[1] ps = [p];
    wasm_valtype_t*[1] rs = [r];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 1, ps.ptr);
    wasm_valtype_vec_new(&results, 1, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_2_1(wasm_valtype_t* p1, wasm_valtype_t* p2, wasm_valtype_t* r) {
    wasm_valtype_t*[2] ps = [p1, p2];
    wasm_valtype_t*[1] rs = [r];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 2, ps.ptr);
    wasm_valtype_vec_new(&results, 1, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_3_1(wasm_valtype_t* p1, wasm_valtype_t* p2, wasm_valtype_t* p3, wasm_valtype_t* r) {
    wasm_valtype_t*[3] ps = [p1, p2, p3];
    wasm_valtype_t*[1] rs = [r];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 3, ps.ptr);
    wasm_valtype_vec_new(&results, 1, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_0_2(wasm_valtype_t* r1, wasm_valtype_t* r2) {
    wasm_valtype_t*[2] rs = [r1, r2];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new_empty(&params);
    wasm_valtype_vec_new(&results, 2, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_1_2(wasm_valtype_t* p, wasm_valtype_t* r1, wasm_valtype_t* r2) {
    wasm_valtype_t*[1] ps = [p];
    wasm_valtype_t*[2] rs = [r1, r2];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 1, ps.ptr);
    wasm_valtype_vec_new(&results, 2, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_2_2(wasm_valtype_t* p1, wasm_valtype_t* p2, wasm_valtype_t* r1, wasm_valtype_t* r2) {
    wasm_valtype_t*[2] ps = [p1, p2];
    wasm_valtype_t*[2] rs = [r1, r2];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 2, ps.ptr);
    wasm_valtype_vec_new(&results, 2, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
wasm_functype_t* wasm_functype_new_3_2(wasm_valtype_t* p1, wasm_valtype_t* p2, wasm_valtype_t* p3,
        wasm_valtype_t* r1, wasm_valtype_t* r2) {
    wasm_valtype_t*[3] ps = [p1, p2, p3];
    wasm_valtype_t*[2] rs = [r1, r2];
    wasm_valtype_vec_t params, results;
    wasm_valtype_vec_new(&params, 3, ps.ptr);
    wasm_valtype_vec_new(&results, 2, rs.ptr);
    return wasm_functype_new(&params, &results);
}
pragma(inline, true)
void wasm_val_init_ptr(ref wasm_val_t _out, void* p) {
    _out.kind = wasm_valkind_enum.WASM_I64;
    _out.of.i64 = cast(intptr_t)p;
}
pragma(inline, true)
void* wasm_val_ptr(const(wasm_val_t)* val) {
    return cast(void*)(cast(intptr_t)val.of.i64);
}

