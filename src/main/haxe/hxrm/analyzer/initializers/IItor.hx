package hxrm.analyzer.initializers;

enum IItor {
    InitValue(itor:Itor<Dynamic>);
    InitArray(itor:Itor<Array<{name : String, itor : IItor}>>);
    InitNodeScope(itor:Itor<NodeScope>);
}