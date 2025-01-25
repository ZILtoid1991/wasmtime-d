import ldc.attributes;

extern(C): // disable D mangling

struct TestClass {}

@llvmAttr("wasm-import-module", "classreftest") {
    double foo(TestClass _ref);
    double bar(TestClass _ref, int a, int b);
    TestClass getClassRef();
}

@llvmAttr("wasm-import-module", "math") {
    int add(int a, int b);
    int sub(int a, int b);
    int mul(int a, int b);
    int div(int a, int b);
}
@llvmAttr("wasm-import-module", "display") {
    void writeInt(int var);
    void writeDouble(double var);
}

void _start() {
    auto classRef = getClassRef();
    writeDouble(foo(classRef));
    writeDouble(classRef.bar(11, 31));
}
