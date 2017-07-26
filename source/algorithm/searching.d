module algorithm.searching;

import algorithm.mutation : cloneReversed;
import std.algorithm.searching;
import std.conv : to;
import std.functional : binaryFun, toDelegate;
import std.range;
import std.traits : isNarrowString;

/++
    Determines whether all elements of the given range satisfy a condition
 +/
bool all(T, Range)(Range r, bool delegate(T element) condition)
        if (isInputRange!Range)
{
    foreach (x; r)
        if (!condition(x))
            return false;

    return true;
}
/++ ditto +/
bool all(T, Range)(Range r, bool function(T element) condition)
        if (isInputRange!Range)
{
    return r.all!T(toDelegate(condition));
}
/++ ditto +/
alias appliesToAll = all;

/++ Examples: +/
@system unittest
{
    // This functions checks if its input is a positive number
    bool isPositive(int input)
    {
        return (input >= 0);
    }

    // array01 only contains positive values
    int[] array01 = [0, 1, 2];
    // array02 contains positive and negative values
    int[] array02 = [0, 1, -2];

    // All elements in array01 are positive
    assert(array01.all!int(&isPositive));

    // Not all elements in array02 are actually positive
    assert(!array02.all!int(&isPositive));

    // Instead of a function an anonymous delegate is passed as callback here
    // Note: The compiler is able auto-detect type T in this case.
    bool result03 = array01.all(delegate(int element) {
        // Is the value smaller than 3?
        return (element < 3);
    });
    // All elements of array01 are smaller than 3
    assert(result03);
}

/++
    Determines whether any element of the given range satisfies a condition
+/
bool any(T, Range)(Range r, bool delegate(T element) condition)
        if (isInputRange!Range)
{
    foreach (x; r)
        if (condition(x))
            return true;

    return false;
}
/++ ditto +/
bool any(T, Range)(Range r, bool function(T element) condition)
        if (isInputRange!Range)
{
    return r.any!T(toDelegate(condition));
}
/++ ditto +/
alias appliesToAny = any;

/++ Examples: +/
@system unittest
{
    // This functions checks if its input is a positive number
    bool isPositive(int input)
    {
        return (input >= 0);
    }

    // array01 only contains negative and positive values
    int[] array01 = [-2, -1, 0];
    // array02 contains onyl negative values
    int[] array02 = [-2, -1, -3];

    // At least one element in array01 is positive
    assert(array01.any!int(&isPositive));

    // Not a single element in array02 is positive
    assert(!array02.any!int(&isPositive));

    // Instead of a function an anonymous delegate is passed as callback here
    // Note: The compiler is able auto-detect type T in this case.
    bool result03 = array01.any(delegate(int element) {
        // Is the value smaller than -1?
        return (element < -1);
    });
    // At least one element of array01 are smaller than -1
    assert(result03);
}

/++
    Returns:
        The common beginning/prefix of two ranges
        This can also be an empty range if there is no common prefix.
 +/
alias commonPrefix = std.algorithm.searching.commonPrefix;
/++ ditto +/
alias commonStart = commonPrefix;

/++ Examples: +/
@safe unittest
{
    string a = "getCursorPosition()";
    string b = "getCursorState()";
    string c = "getScreenSize()";

    // both a and b start with "getCursor"
    assert(a.commonPrefix(b) == "getCursor");
    // both a and c start with "get"
    assert(a.commonPrefix(c) == "get");
    // a and "setBackgroundColor" have no common prefix
    assert(a.commonPrefix("setBackgroundColor") == "");
}
/++ ditto +/
@safe unittest
{
    int[] primes = [3, 5, 7, 11, 13, 17, 19, 23];
    int[] oddNum = [3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23];

    // both prime and oddNum start with 3, 5 and 7
    assert(oddNum.commonStart(primes) == [3, 5, 7]);
    // oddNum and the passed array have  
    assert(oddNum.commonStart([1, 2, 3]) == []);
}

/++
    Returns:
        The common ending/suffix of two ranges
        This can also be an empty range if there is no common suffix.
 +/
@safe auto commonSuffix(R1, R2)(R1 r1, R2 r2)
        if (is(typeof(binaryFun!pred(r1.front, r2.front)))
            || (isNarrowString!R1 && isNarrowString!R2))
{
    auto output = r1.cloneReversed().commonPrefix(r2.cloneReversed());
    return output.cloneReversed();
}
/++ ditto +/
alias commonEnding = commonSuffix;

/++ Examples: +/
@safe unittest
{
    string a = "getScreenSize()";
    string b = "getDefaultFontSize()";
    string c = "getCursorPosition()";

    assert(a.commonSuffix(b) == "Size()");
    assert(a.commonSuffix(c) == "()");
    assert(a.commonSuffix("eab") == "");
}

/++
    Determines whether the given range contains a specified element
 +/
bool contains(Range, T)(Range r, scope T element)
        if (is(typeof(find!"a == b"(r, element))))
{
    return r.canFind(element);
}
/++ Examples: +/
@system unittest
{
    int[] array = [];
    int e1 = 1, e2 = 20, e3 = 300;

    // Append e1 to the array
    array ~= e1;
    // Append e2 to the array
    array ~= e2;

    // The array contains e1
    assert(array.contains(e1));
    // The array contains the integer value 20
    assert(array.contains(20));
    // The array doesn't contain e3
    assert(!array.contains(e3));
    // The array doesn't contain the integer value 0xEB
    assert(!array.contains(0xEB));
}
/++ ditto +/
@system unittest
{
    int[][] array0 = [];
    int[] sub1 = [0, 1];
    int[] sub2 = [0, 2];
    int[] sub3 = [0, 3];

    // Append sub01 to array0
    array0 ~= sub1;
    // Append sub02 to array0
    array0 ~= sub2;

    // array0 contains sub1
    assert(array0.contains(sub1));
    // array0 contains sub2
    assert(array0.contains(sub2));
    // array0 doesn't contain sub
    assert(!array0.contains(sub3));
    // array0 contains an array containing the integer values 0 and 1
    assert(array0.contains([0, 1]));
}
/++ ditto +/
@system unittest
{
    // A class that represents a human
    class Human
    {
        string name;

        public this(string name)
        {
            this.name = name;
        }
    }

    Human[] array = [];
    auto human1 = new Human("Tom");
    auto human2 = new Human("Timea");
    auto human3 = new Human("Walter");

    // Append Tom to the array
    array ~= human1;
    // Append Timea to the array
    array ~= human2;

    // The array contains Tom
    assert(array.contains(human1));
    // The array contain Timea
    assert(array.contains(human2));
    // The array doesn't contain Walter
    assert(!array.contains(human3));
    // The array doesn't contain a new Human also named Tom
    // That's because classes are reference types
    assert(!array.contains(new Human("Tom")));
}

/++
    Checks whether a range has "balanced parantheses".
    "Balanced" means in this case that each pair of parantheses
    must have both an opening and a closing bracket. 

    Params:
    lPar = opening bracket
    rPar = closing bracket
    maxNestingLevel = The maximum allowed nesting level
 +/
alias checkParenthesesPairs = balancedParens;

/++ Examples: +/
@system unittest
{
    string s1 = "(1 + 1) * 2 = 4";
    assert(s1.checkParenthesesPairs('(', ')'));

    // A closing bracket is missing in s2
    string s2 = "if ((pos.X > 0) && (pos.Y > 0)";
    assert(!s2.checkParenthesesPairs('(', ')'));

    string s3 = s2 ~ ')';
    assert(checkParenthesesPairs(s3, '(', ')'));

    // s3 contains nested parantheses
    // maxNestingLevel = 0 means no nesting allowed
    assert(!s3.checkParenthesesPairs('(', ')', 0));
}

/++
    Determines whether the given range ends with the given element
 +/
@safe bool endsWith(Range, T)(Range doesThisEnd, T withThis)
        if (isBidirectionalRange!Range
            && is(typeof(binaryFun!"a == b"(doesThisEnd.front, withThis)) : bool))
{
    return std.algorithm.searching.endsWith(doesThisEnd, withThis);
}

/++ Examples: +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" ends with an 'f'
    char c = 'f';
    assert(word.endsWith(c));

    // "Oachkatzlschwoaf" doesn't end with an 'O'
    assert(!word.endsWith('O'));
}

/++
    Determines whether the given range ends with all the elements from another one in the same order
 +/
@safe bool endsWith(Range, Rn)(Range doesThisEnd, Rn withThese)
        if (isBidirectionalRange!Range && isInputRange!Rn
            && is(typeof(binaryFun!"a == b"(doesThisEnd.front, withThese.front)) : bool))
{
    return std.algorithm.searching.endsWith(doesThisEnd, withThese);
}

/++ Examples: +/
@safe unittest
{
    int[] primes = [3, 5, 7, 11, 13, 17, 19, 23];

    // primes ends with 19 and 23
    int[] num = [19, 23];
    assert(primes.endsWith(num));
    // primes enda with 17, 19 and 23
    assert(primes.endsWith([17, 19, 23]));

    // primes doesn't end with 22, 24 and 26
    assert(!primes.endsWith([22, 24, 26]));

    // primes doesn't end with 23 and then 19
    // Note: wrong order
    assert(!primes.endsWith([23, 19]));
}
/++ ditto +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" ends with "af"
    char[] arr = ['a', 'f'];
    assert(word.endsWith(arr));

    // "Oachkatzlschwoaf" ends with "schwoaf"
    assert(word.endsWith("schwoaf"));

    // "Oachkatzlschwoaf" doesn't end with "fa"
    // Note: wrong order
    assert(!word.endsWith(['f', 'a']));
}

/++
    Determines whether the given range ends with any element of another range
 +/
@safe bool endsWithAny(Range, Rn)(Range doesThisEnd, Rn withAnyOfThese)
        if (isBidirectionalRange!Range && isInputRange!Rn
            && (is(typeof(binaryFun!"a == b"(doesThisEnd.front, withAnyOfThese.front))
            : bool) || is(typeof(binaryFun!"a == b"(doesThisEnd.front,
            withAnyOfThese.front.front)) : bool)))
{
    foreach (x; withAnyOfThese)
        if (doesThisEnd.endsWith(x))
            return true;

    return false;
}
/++ ditto +/
@safe bool endsWithAny(Range, Rn...)(Range doesThisEnd, Rn withAnyOfThese)
        if (isBidirectionalRange!Range && Rn.length > 1)
{
    foreach (x; withAnyOfThese)
        if (doesThisEnd.endsWith(x))
            return true;

    return false;
}

/++ Examples: +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" doesn't end with 'F'
    // but it ends with 'f'
    assert(word.endsWithAny(['F', 'f']));
    assert(word.endsWithAny('F', 'f'));

    // "Oachkatzlschwoaf" ends with 'f'
    assert(word.endsWithAny(['f', 'z']));
    assert(word.endsWithAny('f', 'z'));

    // "Oachkatzlschwoaf" does neither end with "abc"
    // nor with "Oachkatzl"
    // but it ends with "schwoaf"
    assert(word.endsWithAny(["abc", "Oachkatzl", "schwoaf"]));
    assert(word.endsWithAny("abc", "Oachkatzl", "schwoaf"));

    // "Oachkatzlschwoaf" does neither end with "abc"
    // nor with "xyz"
    assert(!word.endsWithAny(["abc", "xyz"]));
    assert(!word.endsWithAny("abc", "xyz"));
}

/++
    Returns:
        the zero-based index of the argument that the given range starts with
        <0 ... no match found
 +/
int endsWithNth(Range, Rn...)(Range thisEnds, Rn withTheNthOfThese)
        if (isBidirectionalRange!Range && Rn.length > 1
            && is(typeof(std.algorithm.searching.startsWith!"a == b"(thisEnds,
            withTheNthOfThese[0])) : bool) && is(typeof(std.algorithm.searching.startsWith!"a == b"(thisEnds,
            withTheNthOfThese[1 .. $])) : uint))
{
    immutable int r = cast(int)(std.algorithm.searching.endsWith(thisEnds, withTheNthOfThese));
    return (r - 1);
}
/++ ditto +/
int endsWithNth(Range, Rn)(Range thisEnds, Rn withTheNthOfThese)
        if (isInputRange!Range && isInputRange!Rn
            && (is(typeof(binaryFun!"a == b"(thisEnds.front, withTheNthOfThese.front))
            : bool) || is(typeof(binaryFun!"a == b"(thisEnds.front,
            withTheNthOfThese.front.front)) : bool)))
{
    // HACK: this patchy workaround function might not return the same results as the variadic one above

    foreach (idx, var; withTheNthOfThese)
        if (thisEnds.endsWith(var))
            return idx;

    return -1;
}

/++ Examples: +/
@safe unittest
{
    int[] arr = [11, 22, 33];

    // arr ends with 33
    // 33 has the index 2 in the given range
    assert(arr.endsWithNth(0, 22, 33, 11, 44) == 2);
    assert(arr.endsWithNth([0, 22, 33, 11, 44]) == 2);

    // arr ends with 33
    // 33 has the index 1 in the given range
    assert(arr.endsWithNth(0, 33) == 1);
    assert(arr.endsWithNth([0, 33]) == 1);

    // arr ends with 33
    // 33 isn't part of the given range
    assert(arr.endsWithNth(11, 22) < 0);
    assert(arr.endsWithNth([11, 22]) < 0);
}
/++ ditto +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" ends with 'f'
    // 'O' is the 0th element
    assert(word.endsWithNth('f', 'F') == 0);
    char[] arr = ['f', 'F'];
    assert(word.endsWithNth(arr) == 0);

    // "Oachkatzlschwoaf" doesn't end with "schweif"
    // but it ends with "schwoaf" that has the index 1
    assert(word.endsWithNth("schweif", "schwoaf", "schwaif") == 1);
    assert(word.endsWithNth(["scheif", "schwoaf", "schwaif"]) == 1);

    // "Oachkatzlschwoaf" does neither end with "schoaf"
    // nor with "doaf"
    assert(word.endsWithNth("schoaf", "doaf") < 0);
    assert(word.endsWithNth(["schoaf", "doaf"]) < 0);
}

/++
    Determines the zero-based index of the first occurrence of a specified element in a range
 +/
ptrdiff_t indexOf(Range, T)(Range r, T element)
        if (isInputRange!Range && is(typeof(binaryFun!"a == b"(r.front, element)) : bool))
{
    return r.countUntil(element);
}

/++ Examples: +/
@system unittest
{
    char[] array = ['a', 'b', 'a', 'b', 'c'];
    // Index:       0    1    2    3    4

    // The index of the first occurrence of 'b' in the array is 1
    assert(array.indexOf('b') == 1);
    // The index of the first occurrence of 'c' in the array is 4
    assert(array.indexOf('c') == 4);
    // The array doesn't contain 'z'.
    // indexOf() returns -1
    assert(array.indexOf('z') < 0);
}

/++
    Determines whether the given range starts with the given element
 +/
@safe bool startsWith(Range, T)(Range doesThisStart, T withThis)
        if (isInputRange!Range
            && is(typeof(binaryFun!"a == b"(doesThisStart.front, withThis)) : bool))
{
    return std.algorithm.searching.startsWith(doesThisStart, withThis);
}

/++ Examples: +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" begins with an 'O'
    char c = 'O';
    assert(word.startsWith(c));

    // "Oachkatzlschwoaf" doesn't begin with an 'f'
    assert(!word.startsWith('f'));
}

/++
    Determines whether the given range starts with all the elements from another one in the same order
 +/
@safe bool startsWith(Range, Rn)(Range doesThisStart, Rn withThese)
        if (isInputRange!Range && isInputRange!Rn
            && is(typeof(binaryFun!"a == b"(doesThisStart.front, withThese.front)) : bool))
{
    return std.algorithm.searching.startsWith(doesThisStart, withThese);
}

/++ Examples: +/
@safe unittest
{
    int[] primes = [3, 5, 7, 11, 13, 17, 19, 23];

    // primes starts with 3 and 5
    int[] num = [3, 5];
    assert(primes.startsWith(num));
    // primes starts with 3, 5 and 7
    assert(primes.startsWith([3, 5, 7]));

    // primes doesn't start with 1, 2 and 3
    assert(!primes.startsWith([1, 2, 3]));

    // primes doesn't start with 5 and then 3
    // Note: wrong order
    assert(!primes.startsWith([5, 3]));
}
/++ ditto +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" begins with "Oa"
    char[] arr = ['O', 'a'];
    assert(word.startsWith(arr));

    // "Oachkatzlschwoaf" begins with "Oachkatzl"
    assert(word.startsWith("Oachkatzl"));

    // "Oachkatzlschwoaf" doesn't begin with "aO"
    // Note: wrong order
    assert(!word.startsWith(['a', 'O']));
}

/++
    Determines whether the given range begins with any element of another range
 +/
@safe bool startsWithAny(Range, Rn)(Range doesThisStart, Rn withAnyOfThese)
        if (isInputRange!Range && isInputRange!Rn
            && (is(typeof(binaryFun!"a == b"(doesThisStart.front, withAnyOfThese.front))
            : bool) || is(typeof(binaryFun!"a == b"(doesThisStart.front,
            withAnyOfThese.front.front)) : bool)))
{
    foreach (x; withAnyOfThese)
        if (doesThisStart.startsWith(x))
            return true;

    return false;
}
/++ ditto +/
@safe bool startsWithAny(Range, Rn...)(Range doesThisStart, Rn withAnyOfThese)
        if (isInputRange!Range && Rn.length > 1)
{
    foreach (x; withAnyOfThese)
        if (doesThisStart.startsWith(x))
            return true;

    return false;
}

/++ Examples: +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" doesn't begin with 'o'
    // but it begins with 'O'
    assert(word.startsWithAny(['o', 'O']));
    assert(word.startsWithAny('o', 'O'));

    // "Oachkatzlschwoaf" begins with 'O'
    assert(word.startsWithAny(['O', 'z']));
    assert(word.startsWithAny('O', 'z'));

    // "Oachkatzlschwoaf" does neither begin with "abc"
    // nor with "schwoaf"
    // but it begins with "Oach"
    assert(word.startsWithAny(["abc", "schwoaf", "Oach"]));
    assert(word.startsWithAny("abc", "schwoaf", "Oach"));

    // "Oachkatzlschwoaf" does neither begin with "abc"
    // nor with "xyz"
    assert(!word.startsWithAny(["abc", "xyz"]));
    assert(!word.startsWithAny("abc", "xyz"));
}

/++
    Returns:
        the zero-based index of the argument that the given range starts with
        <0 ... no match found
 +/
int startsWithNth(Range, Rn...)(Range thisStarts, Rn withTheNthOfThese)
        if (isInputRange!Range && Rn.length > 1
            && is(typeof(std.algorithm.searching.startsWith!"a == b"(thisStarts,
            withTheNthOfThese[0])) : bool) && is(typeof(std.algorithm.searching.startsWith!"a == b"(thisStarts,
            withTheNthOfThese[1 .. $])) : uint))
{
    immutable int r = cast(int)(std.algorithm.searching.startsWith(thisStarts, withTheNthOfThese));
    return (r - 1);
}
/++ ditto +/
int startsWithNth(Range, Rn)(Range thisStarts, Rn withTheNthOfThese)
        if (isInputRange!Range && isInputRange!Rn
            && (is(typeof(binaryFun!"a == b"(thisStarts.front, withTheNthOfThese.front))
            : bool) || is(typeof(binaryFun!"a == b"(thisStarts.front,
            withTheNthOfThese.front.front)) : bool)))
{
    // HACK: this patchy workaround function might not return the same results as the variadic one above

    foreach (idx, var; withTheNthOfThese)
        if (thisStarts.startsWith(var))
            return idx;

    return -1;
}

/++ Examples: +/
@safe unittest
{
    int[] arr = [11, 22, 33];

    // arr starts with 11
    // 11 has the index 3 in the given range
    assert(arr.startsWithNth(0, 22, 33, 11, 44) == 3);
    assert(arr.startsWithNth([0, 22, 33, 11, 44]) == 3);

    // arr starts with 11
    // 11 has the index 1 in the given range
    assert(arr.startsWithNth(0, 11) == 1);
    assert(arr.startsWithNth([0, 11]) == 1);

    // arr starts with 11
    // 11 isn't part of the given range
    assert(arr.startsWithNth(33, 22) < 0);
    assert(arr.startsWithNth([33, 22]) < 0);
}
/++ ditto +/
@safe unittest
{
    string word = "Oachkatzlschwoaf";

    // "Oachkatzlschwoaf" begins with 'O'
    // 'O' is the 0th element
    assert(word.startsWithNth('O', 'o') == 0);
    char[] arr = ['O', 'o'];
    assert(word.startsWithNth(arr) == 0);

    // "Oachkatzlschwoaf" doesn't begin with "Eich"
    // but it begins with "Oach" that has the index 1
    assert(word.startsWithNth("Eich", "Oach", "Aich") == 1);
    assert(word.startsWithNth(["Eich", "Oach", "Aich"]) == 1);

    // "Oachkatzlschwoaf" does neither begin with "Owl"
    // nor with "One"
    assert(word.startsWithNth("Owl", "One") < 0);
    assert(word.startsWithNth(["Owl", "One"]) < 0);
}
