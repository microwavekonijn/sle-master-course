module Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Form 
  = form: "form" Str title "{" Question* questions "}"; 

lexical Str = [\"]![\"]* [\"];

lexical Bool = "true" | "false";

lexical Int = [0-9]+; 

// boolean, integer, string
syntax Type
  = "string"
  | "boolean"
  | "integer"
  ;


// TODO: answerable question, computed question, block, if-then-else
syntax Question 
  = ifThen: "if" "(" Expr cond ")" Question then () !>> "else"
  | answerableQuestion: Str question Name name ":" Type type
  | computedQuestion: Str question Name name (":" Type type)? "=" Expr comp
  | block: "{" Question* questions "}"
  | ifThenElse: "if" "(" Expr cond ")" Question then "else" Question else
  ;

lexical Name = [a-z][a-zA-Z0-9_]*;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr
  = left  or:  Expr l "||"  Expr r
  > left  and: Expr l "&&"  Expr r
  > left (eq:  Expr l "=="  Expr r
  |       neq: Expr l "!="  Expr r)
  > left (gt:  Expr l "\>"  Expr r
  |       gte: Expr l "\>=" Expr r
  |       lt:  Expr l "\<"  Expr r
  |       lte: Expr l "\<=" Expr r)
  > left (add: Expr l "+"   Expr r
  |       sub: Expr l "-"   Expr r)
  > left (mul: Expr l "*"   Expr r
  |       div: Expr l "/"   Expr r)
  >       not:        "!"   Expr r
  >       par: "(" Expr e ")"
  >       var: Id name \ "true" \"false"
  |       lit: Bool | Int | Str
  ;
// TODO: Add parenthesis
