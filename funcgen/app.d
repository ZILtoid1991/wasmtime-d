module funcgen.app;

import std.stdio;
import std.algorithm : countUntil;

int main(string[] args) {
    try {
        writeln("Symbol converter for BindBC.");
        if (args.length != 3) {
            writeln("Usage: [sourceName] [targetName]");
            return -1;
        }
        File input = File(args[1]);
        File output = File(args[2], "wb");
        string symbolDefA = "extern(C) { \n", symbolDefG = "__gshared { \n", 
            symbolLoad = "package void loadFuncs(SharedLib lib) { \n";
        foreach (key; input.byLine) {
            writeln("Processing ", key);
            size_t slicePos = countUntil(key, ' ');
            char[] retType = key[0..slicePos];
            key = key[slicePos+1..$];
            slicePos = countUntil(key, '(');
            char[] funcName = key[0..slicePos];
            key = key[slicePos..$];
            symbolDefA ~= `    alias p`~funcName~` = `~retType~` function`~key~"\n";
            symbolDefG ~= `    p`~funcName~` `~funcName~";\n";
            symbolLoad ~= `    bindSymbol_stdcall(lib, `~funcName~`, "`~funcName~"\");\n";
        }
        symbolDefA ~= "}\n";
        symbolDefG ~= "}\n";
        symbolLoad ~= "}\n";
        output.write(symbolDefA);
        output.write(symbolDefG);
        output.write(symbolLoad);
    } catch(Throwable t) {
        writeln(t);
    }
    return 0;
}