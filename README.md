# λParse  ![Travis-CI](https://travis-ci.org/MarcusVoelker/LParse.svg?branch=master) [![Hackage](https://img.shields.io/hackage/v/LParse.svg)](https://hackage.haskell.org/package/LParse)

A parser library using monads and arrows. Supports both horizontal and vertical composition of parsers.

# Short Guide

## Creating a parser

A parser is, at its heart, nothing more than a function that takes some input and either returns a result along with some residual, unconsumed input or that fails for some reason and returns an error message.

Since LParse is written in continuation-passing-style, this is modelled with a concept of DoubleContinuations - continuations that not only take one function to continue with, but one function to continue with in the case of a successful computation and one function to continue with in the case of a failure. This, of course, gives rise to classic parser semantics: To concatenate two parsers, the second one is put into the successful continuation of the first one, while for an alternative we put the second parser into the failure continuation of the first one.

These semantics are modelled with Monads and Alternatives, respectively, to make use of the familar syntax of these classes:

* `p1 >> p2` runs `p1` and `p2` in succession and gives the result of `p2` only
* `(,) <$> p1 <*> p2` runs `p1` and `p2` in succession and gives the results of `p1` and `p2` as a pair
* `p1 <|> p2` runs `p1`. On a success, its result is returned, on a fail, `p2` is run. On a success, its result is returned, on a failure, the whole parser fails

The parser can be built from scratch by constructing a parser object with the appropriate function, but a variety of common atomic parsers and parser transformers are provided in `Text.LParse.Prebuilt`.

The above construction is referred to as _horizontal composition_, i.e., running parsers successively on the same input.
The dual concept to this we refer to as _vertical composition_, where the result of one parser is fed into the next one as an input. An application for this could be one parser `lex` that transforms a string into a list of tokens (a lexer) and a second parser `par` that transforms a list of tokens into a syntax tree. Then we could join these to create a parser that directly transforms a string into a syntax tree as `lex >>> par`

As the notation above implies, LParse realises vertical composition with arrows enabling all the other features of arrows, such as the proc notation, to be used with parsers.

## Running a parser

Once you have obtained a parser object that represents your entire parser, you have two options

1. You can supply a success and a failure function. When the parser is run, the appropriate function will be called, either with the result of the parse or an error message

2. You can retrieve the double continuation from the parser and continue to build with it. This is appropriate if your program itself is written in CPS.
