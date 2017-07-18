module algorithm.searching;

import std.algorithm.searching;
import std.functional;
import std.range;

/++
    Determines whether all elements of a range satisfy a condition
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
    Determines whether any element of a range satisfies a condition
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
    Determines whether a range contains a specified element
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
