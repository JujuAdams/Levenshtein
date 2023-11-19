//Create a string matching handler
levenshtein = new Levenshtein();

//Give the handler a "lexicon" (dictionary) to work from
levenshtein.SetLexiconArray(WordArray());

//Start with a basic search term
keyboard_string = "GameMaker";