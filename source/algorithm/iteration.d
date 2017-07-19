module algorithm.iteration;

import std.algorithm;
import std.functional : toDelegate;
import std.range;

/++
    Where
 +/
Range where(T, Range)(Range r, bool delegate(T element) condition)
        if (isInputRange!Range)
{
    Range output = [];

    foreach (x; r)
        if (condition(x))
            output ~= x;

    return output;
}
/++ ditto +/
Range where(T, Range)(Range r, bool function(T element) condition)
        if (isInputRange!Range)
{
    return r.where(toDelegate(&condition));
}

/++ Examples: ++/
@system unittest
{
    import algorithm.searching : contains, startsWith;

    // A class that represents a person
    class Person
    {
        public string name;

        public this(string name)
        {
            this.name = name;
        }
    }

    Person[] array = [];
    auto person1 = new Person("Tom");
    auto person2 = new Person("Timea");
    auto person3 = new Person("Walter");

    // Append the humans to the array
    array ~= person1;
    array ~= person2;
    array ~= person3;

    auto filtered = array.where!(Person, Person[])(delegate(Person p) {
        // Determine whether the person's name begins with a 'T'
        return p.name.startsWith('T');
    });

    // filtered contains only those persons that have a name begining with 'T'
    // this includes Tom and Timea but not Walter.
    assert(filtered == [person1, person2]);
    assert(!filtered.contains(person3));
}
