module tutorial::Series2

import ParseTree;
import IO;
import String;

/*
 * Syntax definition
 * - define a grammar for JSON (https://json.org/)
 */
 
start syntax JSON
  = Object;
  
syntax Object
  = "{" {Element ","}* "}"
  ;
  
syntax Element
  = PropName ":" Value; // Fill in

lexical PropName = [\"] ![\"]* [\"];
  
syntax Value
  = String
  | Number
  | Array
  | Object
  | Boolean
  | Null
  ;

syntax Null
  = "null";
  
syntax Boolean
  = "true"  // Fill in
  | "false" // Fill in
  ;  
  
syntax Array
  = "[" {Value ","}* "]"
  ;  
  
lexical String
  = [\"] ![\"]* [\"]; // slightly simplified
  
lexical Number
  = [0-9]+; // Fill in. Hint; think of the pattern for numbers in regular expressions. How do you accept a number in a regex?  

layout Whitespace = [\ \t\n]* !>> [\ \t\n];  
  
// import the module in the console
start[JSON] example() 
  = parse(#start[JSON], 
          "{
          '  \"age\": 42, 
          '  \"name\": \"Joe\",
          '  \"address\": {
          '     \"street\": \"Wallstreet\",
          '     \"number\": 102
          '  },
          '  \"array\": [1,2,3],
          '  \"bool\": true,
          '  \"empty\": null
          '}");    
  


// use visit/deep match to find all element names
// - use concrete pattern matching
// - use "<x>" to convert a String x to str
set[str] propNames(start[JSON] json) {
  return {unquote("<k>") | /(PropName) k := json};
}

// define a recursive transformation mapping JSON to map[str,value] 
// - every Value constructor alternative needs a 'transformation' function
// - define a data type for representing null;

map[str, value] json2map(start[JSON] json) = json2map(json.top);

map[str, value] json2map((JSON)`<Object obj>`)  = json2map(obj);
map[str, value] json2map((Object)`{<{Element ","}* elems>}`) = ( unquote("<k>"):json2value(v) | (Element) `<PropName k>:<Value v>` <- elems );

list[value] json2array((Array)`[<{Value ","}* values>]`) = [json2value(v) | v <- values];

str unquote(str s) = s[1..-1];

value json2value((Value)`<String s>`)    = unquote("<s>");
value json2value((Value)`<Number n>`)    = toInt("<n>");
value json2value((Value)`<Object obj>`)  = json2map(obj);
value json2value((Value)`<Array arr>`)   = json2array(arr);
value json2value((Value)`<Boolean b>`)   = "<b>" == "true";
value json2value((Value)`<Null _>`)      = 0; // Best alternative, otherwise requires adding datatype and changing return signature

// default value json2value(Value v) { throw "No tranformation function for `<v>` defined"; }

test bool example2map() = json2map(example()) == (
  "age": 42,
  "name": "Joe",
  "address" : (
     "street" : "Wallstreet",
     "number" : 102
  ),
  "array": [1,2,3],
  "bool": true,
  "empty": 0
);

