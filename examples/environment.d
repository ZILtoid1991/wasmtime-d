import ldc.attributes;

extern(C): // disable D mangling

@llvmAttr("wasm-import-module", "math") {
    int add(int a, int b);
    int sub(int a, int b);
    int mul(int a, int b);
    int div(int a, int b);
}
@llvmAttr("wasm-import-module", "display") {
    void writeInt(int var);
}

void _start() {
    writeInt(mul(add(4,5), sub(4,5)));
    writeInt(div(add(4,5), sub(4,5)));
}
