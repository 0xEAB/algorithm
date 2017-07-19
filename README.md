# algorithm

A simple and developer-friendly algorithm library for the D programming language.


## Ideas

- Function names ...
    * should state what the function is used for and what its result is.
    * don't need to explain how the function does it's job as long as this is not important to know.
    * shouldn't be too generic.
    * If two functions are used for different tasks, they shouldn't have the same name - even if the tasks are related.
- Provide good examples.
    * Comments help to understand what happens.
    * Unit tests should provide hands-on usage examples.
- Things shouldn't be more complicated than necessary.


## std.algorithm

This library relies on phobos' [std.algorithm](https://github.com/dlang/phobos/tree/master/std/algorithm) for many tasks in order to avoid reinventing the square wheel.


## License

This is free and unencumbered software released into the public domain.
For more information, please read the [license file](LICENSE) or refer to <http://unlicense.org>
