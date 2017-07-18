module algorithm.mutation;

import algorithm.searching;
import std.algorithm.mutation;
import std.range;
import std.traits : isArray;

/++
    Creates a clone of a range
 +/
@safe Range clone(T, Range)(Range r) if (isInputRange!Range)
{
    auto output = new T[r.length];
    output[0 .. r.length] = r;
    return output;
}

/++ Examples: +/
@safe unittest
{
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];
    int[] clone = array.clone!int();

    assert(clone.length == array.length);

    foreach (idx, val; clone)
        assert(array[idx] == val);
}

/++
    Creates a type-casted clone of a range
 +/
@safe T[] cloneCast(T, Range)(Range r) if (isInputRange!Range)
{
    auto output = new T[r.length];

    foreach (idx, var; r)
        output[idx] = cast(T) var;

    return output;
}

/++ Examples: +/
@safe unittest
{
    int[] array = [10, 20, 30, 40, 10, 20, 30, 40];
    char[] clone = array.cloneCast!char();

    assert(clone.length == array.length);

    foreach (idx, val; clone)
        assert(array[idx] == val);
}

/++
    Copies the content of $(D source) into $(D target), performs type-casting
    and does not care about existing elements. They will get overriden.

    See_Also: algorithm.mutation.copyOverrideInto
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

    array1.copyCastOverrideInto!int(array0);

    assert(array0 == ['a', 'b', 'c', 40]);
}

alias copyInto = copy;

/++
    Copies the content of $(D source) into $(D target)
    and does not care about existing elements. They will get overriden.

    See_Also: std.algorithm.copy
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

    array1.copyOverrideInto(array0);

    assert(array0 == [50, 60, 70, 40]);
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

    array.removeAllOf(10);
    assert(!array.contains(10));
    assert(array.length == 6);
}
/++ ditto +/
@system unittest
{
    char[] array = ['a', 'b', 'c', 'a', 'b', 'c'];

    array.removeAllOf('b');
    assert(!array.contains('b'));
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

    array.removeFirstOf(20);
    assert(array.contains(20));
    assert(array.length == 7);
}
/++ ditto +/
@system unittest
{
    char[] array = ['a', 'b', 'c', 'a', 'b', 'c'];

    array.removeFirstOf('b');
    assert(array.contains('b'));
    assert(array.length == 5);
}
