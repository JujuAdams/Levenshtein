/// Levenshtein() constructor
/// 
/// Creates a Levenshtein distance search handler. The returned struct contains the following
/// methods:
/// 
/// .SetLexiconArray(array)
///   Sets the dictionary to fuzzy match against.
/// 
/// .SetString(string)
///   Sets the search string. Changing the search string will restart the search.
/// 
/// .GetString()
///   Returns the string being used to search.
/// 
/// .Search([maxTime=1ms])
///   Searches through the dictionary incrementally. The optional "maxTime" parameter controls
///   how long this method will execute before pausing. You may need to call .Search() many times
///   to complete the search process.
/// 
/// .GetWordArray()
///   Returns an array of words that have been fuzzy matched to the input string. The maximum
///   number of results is set by .SetMaxResults(). The array is sorted in order of distance such
///   that the word in array position 0 is closest to the input string.
/// 
/// .GetFinished()
///   Returns if the search is finished.
/// 
/// .GetProgress()
///   Returns a number from 0 to 1 indicating how much of the search has been completed. A value
///   of 0 indicates no progress has been made and a value of 1 indicates that the search has
///   finished.
/// 
/// .SetMaxResults(value)
///   Sets the maximum number of results to return. Defaults to 10
/// 
/// .GetMaxResults()
///   Returns the maximum number of results.
/// 
/// .GetResultArray()
///   Returns an array of results. The number of elements in this array is determined by the "max
///   results" value, see .SetMaxResults(). Each element in the array is a struct that contains two
///   variables: .word is the string from the dictionary that has been matched, .distance is the
///   Levenshtein distance from the input string to the returned word. If the dictionary is smaller
///   than the maximum number of results then some entries in the returned array may contain a word
///   that is an empty string and a distance that is <infinity>. This function should be used to
///   return detailed information about the found words. It is normally preferable to use the
///   simpler .GetWordArray() method above.

function Levenshtein() constructor
{
    __lexiconArray  = [];
    __string        = "";
    __maxResults    = 10;
    
    __wordArray = [];
    
    __Clear();
    
    static __Clear = function()
    {
        __index    = 0;
        __finished = false;
        
        __wordArrayDirty = true;
        array_resize(__wordArray, 0);
        
        //Create a spare result
        //We'll re-use this struct for incoming results when processing the lexicon
        //This reduces garbage collector pressue / reallocating tons of memory
        __spareResult = {
            word: "",
            distance: infinity,
        };
        
        //Pre-allocate memory for results
        __resultArray = array_create(__maxResults);
        
        var _i = 0;
        repeat(__maxResults)
        {
            __resultArray[@ _i] = {
                word: "",
                distance: infinity,
            };
            
            ++_i;
        }
    }
    
    static SetLexiconArray = function(_array)
    {
        __Clear();
        __lexiconArray = _array;
    }
    
    static SetString = function(_string)
    {
        if (_string != __string)
        {
            __Clear();
            __string = _string;
        }
    }
    
    static GetString = function()
    {
        return __string;
    }
    
    static SetMaxResults = function(_value)
    {
        if (_value != __maxResults)
        {
            __Clear();
            __maxResults = _value;
        }
    }
    
    static GetMaxResults = function()
    {
        return __maxResults;
    }
    
    static Search = function(_maxTime = 1)
    {
        _maxTime *= 1000;
        
        var _string       = __string;
        var _lexiconArray = __lexiconArray;
        var _resultArray  = __resultArray;
        
        var _index = __index;
        var _size = array_length(__lexiconArray);
        var _sizePlusOne = _size + 1;
        
        //Poke the spare result into the results array
        var _lastIndex   = __maxResults;
        var _spareResult = __spareResult;
        array_push(_resultArray, _spareResult);
        
        var _time = get_timer();
        while(true)
        {
            if (_index >= _size)
            {
                __finished = true;
                __wordArrayDirty = true;
                break;
            }
            
            var _word     = _lexiconArray[_index];
            var _distance = __Distance(_string, _word);
            
            _spareResult.word     = _word;
            _spareResult.distance = _distance + (_index / _sizePlusOne); //Increase the distance marginally to encourage stable sort
            
            array_sort(_resultArray, function(_a, _b)
            {
                return sign(_a.distance - _b.distance);
            });
            
            _spareResult = _resultArray[_lastIndex];
            
            ++_index;
            
            if (get_timer() - _time >= _maxTime) break;
        }
        
        __index = _index;
        
        //Remove the spare result from the results array so it doesn't show up in GetResultsArray()
        __spareResult = _resultArray[_lastIndex];
        array_pop(_resultArray);
    }
    
    static GetFinished = function()
    {
        return __finished;
    }
    
    static GetProgress = function()
    {
        return __index / array_length(__lexiconArray);
    }
    
    static GetResultArray = function()
    {
        return __resultArray;
    }
    
    static GetWordArray = function()
    {
        if (__wordArrayDirty)
        {
            if (__finished) __wordArrayDirty = false;
            
            array_resize(__wordArray, 0);
            
            var _i = 0;
            repeat(__maxResults)
            {
                var _result = __resultArray[_i];
                if (not is_infinity(_result.distance))
                {
                    array_push(__wordArray, _result.word);
                }
                
                ++_i;
            }
        }
        
        return __wordArray;
    }
    
    static __Distance = function(_a, _b)
    {
        static _column = [];
        
        //Presume simple Latin character set
        var _aLength = string_byte_length(_a);
        var _bLength = string_byte_length(_b);
        
        var _y = 0;
        repeat(_aLength + 1)
        {
            _column[_y] = _y;
            ++_y;
        }
        
        var _x = 1;
        repeat(_bLength)
        {
            _column[0] = _x;
            var _prevDiag = _x-1;
            
            var _y = 1;
            repeat(_aLength)
            {
                var _diag = _column[_y];
                _column[_y] = min(_diag + 1, _column[_y-1] + 1, _prevDiag + (string_byte_at(_a, _y) != string_byte_at(_b, _x)));
                _prevDiag = _diag;
                
                ++_y;
            }
            
            ++_x;
        }
        
        return _column[_aLength];
    }
}