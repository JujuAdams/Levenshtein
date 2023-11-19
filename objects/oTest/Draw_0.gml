//Display results
var _string = "";
_string += "Levenshtein Distance fuzzy string matching\n";
_string += "Juju Adams 2023-11-19\n";
_string += "\n";
_string += "Type to search for a word\n";
_string += "Input = \"" + levenshtein.GetString() + "\"\n";
_string += "\n";
_string += "Progress = " + string(floor(100*levenshtein.GetProgress())) + "%\n";
_string += "Finished = " + (levenshtein.GetFinished()? "<true>" : "<false>") + "\n";
_string += "Results = \"" + string(levenshtein.GetWordArray()) + "\"\n";
draw_text(10, 10, _string);