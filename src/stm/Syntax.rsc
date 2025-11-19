module stm::Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Machine = "machine" Id name State* states "end";

syntax State = "state" Id name Trans* transitions "end";

syntax Trans = Id event "=\>" Id target;


data AMachine = machine(str name, list[AState], loc src = |tmp://|);

data AState = state(str name, list[ATrans] transitions, loc src = |tmp://|);

data ATrans = trans(str event, str target, loc src = |tmp://|);

AMachine cst2ast(start[Machine] m) = cst2ast(m.top);

AMachine cst2ast(m:(Machine)`machine <Id x> <State* ss> end`)
    = machine("<x>", [ cst2ast(s) | State s <- ss ], src=m.src);

AState cst2ast(s:(State)`state <Id x> <Trans* ts> end`)
    = state("<x>", [ cst2ast(t) | Trans t <- ts], src=s.src);

ATrans cst2ast(tr:(Trans)`<Id e> =\> <Id t>`)
    = trans("<e>", "<t>", src=tr.src);
