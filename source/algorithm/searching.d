module algorithm.searching;

import std.algorithm.searching;
import std.conv : to;
import std.functional : binaryFun, toDelegate;
import std.range;

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
