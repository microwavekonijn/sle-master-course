module stm::Resolve

import stm::Syntax;
import ParseTree;


alias RefGraph = tuple[Def def, Use use, UseDef useDef];

alias Def = rel[str name, loc def];

alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

RefGraph resolve(start[Machine] m) = resolve(m.top);

RefGraph resolve(Machine m) {
    RefGraph g = <{}, {}, {}>;

    for (State s <- m.states) {
        g.def += {<"<s.name>", s.name.src>};
    }

    for (/(Trans)`<Id e> =\> <Id t>` := m) {
        g.use += {<t.src, "<t>">};
    }

    g.useDef = g.use o g.def;

    return g;
}
