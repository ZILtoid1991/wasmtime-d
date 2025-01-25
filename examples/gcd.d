import ldc.attributes;

extern(C): // disable D mangling

int gcd(int a, int b) {
    if (b == 0) return a;
    else return gcd(b, a % b);
}
// needed or else won't get compiled
void _start() {

}
