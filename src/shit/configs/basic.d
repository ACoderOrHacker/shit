/++
 + Basic configuraion helpers
 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/
module shit.configs.basic;
@safe:
export:

public import std.json;
import std.file : readText;
import std.stdio : File;

/++ 
 + Read json into a JSONValue
 + Params:
 +   path = The json file path
 + Returns: The root json object
 +/
JSONValue readJSON(string path)
{
    return parseJSON(readText(path));
}

/++ 
 + Write json object to a file
 + Params:
 +   path = The file path to write json
 +   value = The JSON value
 +/
void writeJSON(string path, JSONValue value)
{
    File f = File(path, "w");
    f.write(value.toPrettyString);
    f.close();
}