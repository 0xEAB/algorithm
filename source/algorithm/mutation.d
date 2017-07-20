module algorithm.mutation;

import algorithm.searching;
import std.algorithm.mutation;
import std.range;
import std.traits : isArray;

/++
    Returns:
        a clone of the given range
 +/
@safe Range clone(Range)(Range source) if (isInputRange!Range)
{
    return source.dup;
}
/++
    Returns:
        a clone of the given associative array
 +/
@safe Te[Tidx] clone(Te, Tidx)(Te[Tidx] source)
{
    return source.dup; /*
    Te[Tidx] output;

    foreach (idx, var; source)
        output[idx] = var;

    return output;*/
}

/++ Examples: +/
@safe unittest
{
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];

    // Clone is a clone of the array
    int[] clone = array.clone();

    // Both have the same length.
    assert(clone.length == array.length);
    // The clone contains the same elements as its source array
    foreach (idx, val; clone)
        assert(array[idx] == val);

    // But it is not the same reference
    assert(array.ptr != clone.ptr);
}
/++ ditto +/
@safe unittest
{
    int[string] associativeArray = ["one" : 122, "two" : 233, "three" : 344];

    // Clone is a clone of the associative array
    auto clone = associativeArray.clone();

    // Both have the same length.
    assert(clone.length == associativeArray.length);

    // The clone contains the same elements as its source array
    foreach (idx, val; clone)
        assert(associativeArray[idx] == val);
}

/++
    Returns:
        a type-casted clone of the given range
 +/
@safe T[] cloneCasted(T, Range)(Range source) if (isInputRange!Range)
{
    auto output = new T[source.length];

    foreach (idx, var; source)
        output[idx] = cast(T) var;

    return output;
}

/++
    Returns:
        a type-casted clone of the given associative array
 +/
@safe Tnew[Tidx] cloneCasted(Tnew, Told, Tidx)(Told[Tidx] source)
{
    Tnew[Tidx] output;

    foreach (idx, var; source)
        output[idx] = cast(Tnew) var;

    return output;
}

/++ Examples: +/
@safe unittest
{
    // The source array's element type is integer
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];

    // The clone's elements are chars
    char[] clone = array.cloneCasted!char();

    // Both have the same length.
    assert(clone.length == array.length);

    // The clone contains the same elements as its source array
    foreach (idx, val; clone)
        assert(array[idx] == val);
}
/++ ditto +/
@safe unittest
{
    // The source array's element type is integer
    int[string] associativeArray = ["one" : 122, "two" : 233, "three" : 344];

    // The clone's elements are long integers
    // The index's type remains unchanged
    long[string] clone = associativeArray.cloneCasted!long();

    // Both have the same length.
    assert(clone.length == associativeArray.length);

    // The clone contains the same elements as its source array
    foreach (idx, val; clone)
        assert(associativeArray[idx] == val);
}

/++
    Returns:
        a reversed clone of the given range
 +/
@safe auto cloneReversed(Range)(Range source) if (isInputRange!Range)
{
    auto v = source.dup;
    v.reverse();
    return v;
}
/++ Examples: +/
@safe unittest
{
    string s = "Oachkatzlschwoaf";

    // a reversed clone of s is stored in r
    string r = s.cloneReversed();
    assert(r == "faowhcslztakhcaO");

    ptrdiff_t i = 0;
    ptrdiff_t j = (r.length + -1);
    while (j >= 0)
    {
        assert(s[i] == r[j]);

        i++;
        j--;
    }
}

/++
    Copies the content of $(D source) into $(D target), performs type-casting
    and does not care about existing elements. They will get overriden.

    Returns:
        The unfilled, remaining part of $(D target)

    See_Also:
        algorithm.mutation.copyInto
 +/
@safe auto copyCastedInto(TargetType, SourceRange, TargetRange)(SourceRange source,
        TargetRange target) if (isArray!SourceRange && isArray!TargetRange)
{
    const targetLength = target.length;
    const sourceLength = source.length;
    assert(targetLength >= sourceLength, "Cannot copy a source range into a smaller target range.");

    foreach (idx, var; source)
        target[idx] = cast(TargetType) var;

    return target[sourceLength .. $];
}

/++ Examples: +/
@safe unittest
{
    int[] array0 = [100, 200, 300, 400];
    long[] array1 = [99, 98, 97];

    // The elements of array1 are copied into array0
    // Their type gets casted to int
    array1.copyCastedInto!int(array0);
    // As array1 has 3 elements,
    // the first 3 elements of array0 got replaced by those from array1.
    assert(array0 == [99, 98, 97, 400]);
}
/++ ditto +/
@safe unittest
{
    long[] array = [122, 233, 344];
    int[] buffer = new int[](5);

    // The elements of the array are copied into the buffer.
    // free represents the unfilled, remaining part of the buffer.
    int[] free = array.copyCastedInto!int(buffer);
    assert(buffer == [122, 233, 344, int.init, int.init]);

    // 12.5 and 23.5 are type-casted and copied into free
    [12.5, 23.5].copyCastedInto!int(free);
    // As free is part of the buffer, the type-casted values of 12.5 and 23.5 are now in the buffer.
    assert(buffer == [122, 233, 344, cast(int) 12.5, cast(int) 23.5]);
}

/+
    Copies the content of $(D source) into $(D target).
    This function does not care about existing elements. They will get overriden.

    Returns:
        The unfilled, remaining part of $(D target)

    See_Also:
        algorithm.mutation.copyCastInto
        std.algorithm.copy
 +/
public alias copyInto = copy;

/++ Examples: +/
@safe unittest
{
    int[] array = [122, 233, 344];
    int[] buffer = new int[](5);

    // The elements of the array are copied into the buffer.
    // free represents the unfilled, remaining part of the buffer.
    int[] free = array.copyInto(buffer);
    assert(buffer == [122, 233, 344, int.init, int.init]);

    // 455 and 566 are copied into free
    [455, 566].copyInto(free);
    // As free is part of the buffer, 455 and 566 are now in the buffer.
    assert(buffer == [122, 233, 344, 455, 566]);
}
/++ ditto +/
@safe unittest
{
    int[] array0 = [10, 20, 30, 40];
    int[] array1 = [50, 60, 70];

    // The elements of array1 are copied into array0.
    array1.copyInto(array0);
    // As array1 has 3 elements,
    // the first 3 elements of array0 get replaced by those from array1.
    assert(array0 == [50, 60, 70, 40]);
}
/++ ditto +/
@safe unittest
{
    long[] array0 = [100, 200, 300, 400];
    int[] array1 = [99, 98, 97];

    // The elements of array1 are copied into array0.
    // Their are accepted because long supports assignment from int.
    array1.copyInto(array0);

    // int doesn't support assignment from long.
    // Therefore, this wouldn't work:
    //    array0.copyInto(array1);
    // Type-casting is required,
    // use .copyCastedInto in this case:
    //    array0.copyCastedInto!int(array1);
    // Note: The line above does also not work
    //          because array1 (target) is smaller than array0 (source).

    // As array1 has 3 elements,
    // the first 3 elements of array0 got replaced by those from array1.
    assert(array0 == [99, 98, 97, 400]);
}

/++
    Removes the nth element from the given range
    and replaces the refernce with the new shortened range.
    
    The state of the original range is undefined afterwards.
 +/
Range removeNth(Range)(ref Range r, ptrdiff_t n)
        if (isInputRange!Range && !is(T == char))
{
    r = r.remove(n);
    return r;
}
/++ ditto +/
char[] removeNth(ref char[] r, ptrdiff_t n)
{
    // HACK: std.algorithm.remove() does *not* work for char[]
    auto c = r.cloneCasted!int();

    c = c.remove(n);

    r = c.cloneCasted!char();
    return r;
}

/++ Examples: +/
@system unittest
{
    int[] array = [100, 200, 300, 400];
    // Index:       0    1    2    3

    // The 2nd element is removed
    array.removeNth(2);

    // The array's reference gets replaced
    // by a new one that doesn't contain the removed element.
    assert(!array.contains(300));
    // Therefore, it is 1 element shorter.
    assert(array == [100, 200, 400]);
    assert(array.length == 3);
}
/++ ditto +/
@system unittest
{
    char[] array = ['a', 'b', 'c', 'd'];
    // Index:        0    1    2    3

    // The 2nd element gets removed
    array.removeNth(2);

    // The array's reference gets replaced
    // by a new one that doesn't contain the removed element.
    assert(!array.contains('c'));
    // Therefore, it is 1 element shorter.
    assert(array == ['a', 'b', 'd']);
    assert(array.length == 3);
}

/++
    Removes all occurences of an element from the given range
    and replaces the reference with the new shortened range.

    The state of the original range is undefined afterwards.
 +/
Range removeAllOf(T, Range)(ref Range r, T element)
        if (isInputRange!Range && !is(T == char))
{
    auto index = r.indexOf(element);

    while (index >= 0)
    {
        r = remove(r, index);
        index = r.indexOf(element);
    }

    return r;
}
/++ ditto +/
char[] removeAllOf(T)(ref char[] r, T element)
{
    // HACK: std.algorithm.remove() does *not* work for char[]
    int[] c = cloneCasted!int(r);

    c.removeAllOf(cast(int) element);

    r = c.cloneCasted!char();
    return r;
}

/++ Examples: +/
@system unittest
{
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];

    // All elements with the value 10 get removed
    array.removeAllOf(10);

    // The array's reference gets replaced
    // by a new one that doesn't contain any of the removed elements.
    assert(!array.contains(10));
    // Therefore, it is shorter.
    assert(array.length == 6);
}
/++ ditto +/
@system unittest
{
    char[] array = ['a', 'b', 'c', 'a', 'b', 'c'];

    // All elements with the value 'b' get removed
    array.removeAllOf('b');

    // The array's reference gets replaced
    // by a new one that doesn't contain any of the removed elements.
    assert(!array.contains('b'));
    // Therefore, it is shorter.
    assert(array.length == 4);
}

/++
    Removes the first occurence of an element from the given range
    and replaces the reference with the new shortened range.

    The state of the original range is undefined afterwards.
 +/
Range removeFirstOf(T, Range)(ref Range r, T element)
        if (isInputRange!Range && !is(T == char))
{
    auto index = r.indexOf(element);
    assert(index >= 0, "Cannot remove an element from a range that does not contain it.");

    r = r.remove(index);
    return r;
}
/++ ditto +/
char[] removeFirstOf(T)(ref char[] r, T element)
{
    // HACK: std.algorithm.remove() does *not* work for char[]

    auto index = r.indexOf(element);
    assert(index >= 0, "Cannot remove an element from a range that does not contain it.");

    int[] c = r.cloneCasted!int();
    c = c.remove(index);

    r = c.cloneCasted!char();
    return r;
}

/++ Examples: +/
@system unittest
{
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];

    // The first element with the value 10 gets removed
    array.removeFirstOf(20);

    // only the first one
    assert(array.contains(20));

    // The array's reference got replaced
    // by a new one that doesn't contain the removed element.
    assert(array == [10, 30, 40, 10, 20, 30, 40]);

    // Therefore, it is 1 element shorter.
    assert(array.length == 7);
}
/++ ditto +/
@system unittest
{
    char[] array = ['a', 'b', 'c', 'a', 'b', 'c'];

    // The first element with the value 'b' gets removed
    array.removeFirstOf('b');

    // only the first one
    assert(array.contains('b'));

    // The array's reference got replaced
    // by a new one that doesn't contain the removed element.
    assert(array == ['a', 'c', 'a', 'b', 'c']);

    // Therefore, it is 1 element shorter.
    assert(array.length == 5);
}

/++
    Creates a char[] copy of the given string
 +/
@safe char[] toCharArray(string s)
{
    return s.dup;
}
/++ Examples: +/
@safe unittest
{
    string str = "Timea";

    char[] arr = str.toCharArray();

    assert(arr == ['T', 'i', 'm', 'e', 'a']);
}

/++
    Creates a string copy of the given char[]
 +/
@safe string toString(char[] array)
{
    return array.idup;
}
/++ Examples: +/
@safe unittest
{
    char[] arr = ['T', 'i', 'm', 'e', 'a'];

    string str = arr.toString();

    assert(str == "Timea");
}
