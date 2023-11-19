//Update the string to whatever the user has typed in
//If the string changes, we restart the search
levenshtein.SetString(keyboard_string);

//Search through the lexicon for near matches
//This method defaults to working for a maximum of 1ms
levenshtein.Search();