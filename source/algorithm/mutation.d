module algorithm.mutation;

import algorithm.searching;
import std.algorithm.mutation;
import std.range;
import std.traits : isArray;

/++
    Creates a clone of a range
 +/
@safe Range clone(Range)(Range source) if (isInputRange!Range)
{
    return source.dup;
}
/++ Creates a clone of an associative array +/
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
    Creates a type-casted clone of a range
 +/
@safe T[] cloneCast(T, Range)(Range source) if (isInputRange!Range)
{
    auto output = new T[source.length];

    foreach (idx, var; source)
        output[idx] = cast(T) var;

    return output;
}

/++
    Creates a type-casted clone of an associative array
 +/
@safe Tnew[Tidx] cloneCast(Tnew, Told, Tidx)(Told[Tidx] source)
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
    char[] clone = array.cloneCast!char();

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
    long[string] clone = associativeArray.cloneCast!long();

    // Both have the same length.
    assert(clone.length == associativeArray.length);

    // The clone contains the same elements as its source array
    foreach (idx, val; clone)
        assert(associativeArray[idx] == val);
}

/++
    Copies the content of $(D source) into $(D target), performs type-casting
    and does not care about existing elements. They will get overriden.

    See_Also:
        algorithm.mutation.copyOverrideInto
 +/
@safe void copyCastOverrideInto(TargetType, SourceRange, TargetRange)(
        SourceRange source, TargetRange target)
        if (isArray!SourceRange && isArray!TargetRange)
{
    const targetLength = target.length;
    const sourceLength = source.length;
    assert(targetLength >= sourceLength, "Cannot copy a source range into a smaller target range.");

    foreach (idx, var; source)
        target[idx] = cast(TargetType) var;
}

/++ Examples: +/
@safe unittest
{
    int[] array0 = [10, 20, 30, 40];
    char[] array1 = ['a', 'b', 'c'];

    // The elements of array1 are copied into array0
    // Their type gets casted to int
    array1.copyCastOverrideInto!int(array0);
    // As array1 has 3 elements,
    // the first 3 elements of array0 get replaced by those from array1.
    assert(array0 == ['a', 'b', 'c', 40]);
}

/++
    See_Also:
        std.algorithm.copy
 +/
public alias copyInto = copy;

/++
    Copies the content of $(D source) into $(D target)
    and does not care about existing elements. They will get overriden.

    See_Also:
        std.algorithm.copy
 +/
@safe void copyOverrideInto(SourceRange, TargetRange)(SourceRange source, TargetRange target)
        if (isArray!SourceRange && isArray!TargetRange
            && is(typeof(TargetRange.init[] = SourceRange.init[])))
{
    const targetLength = target.length;
    const sourceLength = source.length;
    assert(targetLength >= sourceLength, "Cannot copy a source range into a smaller target range.");

    target[0 .. sourceLength] = source;
}

/++ Examples: +/
@safe unittest
{
    int[] array0 = [10, 20, 30, 40];
    int[] array1 = [50, 60, 70];

    // The elements of array1 are copied into array0.
    array1.copyOverrideInto(array0);
    // As array1 has 3 elements,
    // the first 3 elements of array0 get replaced by those from array1.
    assert(array0 == [50, 60, 70, 40]);
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
    auto c = r.cloneCast!int();

    c = c.remove(n);

    r = c.cloneCast!char();
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
    int[] c = cloneCast!int(r);

    c.removeAllOf(cast(int) element);

    r = c.cloneCast!char();
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

    int[] c = r.cloneCast!int();
    c = c.remove(index);

    r = c.cloneCast!char();
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
