module app;

import bindbc.loader;
import wasmtime.loader;
import std.stdio;
import std.string;

int main(string[] args) {
    writeln("Testing the loading of wasmtime");
    if (args.length == 1) return 1;
    if (args.length == 3) writeln(loadWasmtime(toStringz(args[1]), args[$-1] == "min"));
    else writeln(loadWasmtime(args[$-1] == "min"));
    writeln("Errors encountered: \n");
    if (errorCount) {
        foreach(const(ErrorInfo) ei ; errors()) {
            writeln(ei.error().fromStringz(), ";", ei.message().fromStringz(), ";");
        }
    } else {
        writeln("None");
    }
    return 0;
}