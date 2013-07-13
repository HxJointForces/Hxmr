package hxrm.extensions.properties.initializers;

import hxrm.analyzer.NodeScope;

enum IItor {
    InitValue(itor:Itor<Dynamic>);
    InitArray(itor:Itor<Array<{name : String, itor : IItor}>>);
    InitNodeScope(itor:Itor<NodeScope>);
}