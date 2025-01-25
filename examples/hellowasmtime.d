import ldc.attributes;

extern(C): // disable D mangling

void hello();

void _start() {
    hello();
}
