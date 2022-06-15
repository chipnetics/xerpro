# XERpro - XER to Prolog Schedule Optimization

A small utility to generate a knowledge base and algorithm to use in SWI-Prolog, for optimization of the project schedules (.xer files) output by the scheduling software "Oracle Primavera".

# Project Motivation

Imperative programming-language options (C, C++, Go, V) for optimization of schedules are relatively error-prone and considerable length/complexity.  Functional programming however can lay out the "state" of optimization wherein the interpretter can seek the solution, and do the hard work.

XERpro is a small utility written in the V programming language that will parse a .xer file for the relationships and activity information and generate a corresponding .pl (Prolog) script to consult.  

As part of this code-generation it also generates some predicates that can be queried to find optimal paths between two activities.

# Compiling from Source

XERpro is written in the V programming language and will compile under Windows, Linux, and MacOS.

V is syntactically similar to Go, while equally fast as C.  You can read about V [here](https://vlang.io/).

XERpro source is in `xerpro.v`, so after installing the [latest V compiler](https://github.com/vlang/v/releases/), it's as easy as executing the below.  _Be sure that the V compiler root directory is part of your PATH environment._

```
git clone https://github.com/chipnetics/xerpro
cd src
v build xerpro.v
```
Alternatively, if you don't have git installed:

1. Download the bundled source [here](https://github.com/chipnetics/xertools/archive/refs/heads/main.zip)
2. Unzip to a local directory
3. Navigate to src directory and run `v build xerpro.v`

Please see the [V language documentation](https://github.com/vlang/v/blob/master/doc/docs.md) for further help if required.

# Usage

**Input:** A .xer file from Oracle Primavera

**Output:** A corresponding .pl (Prolog) script.  If the name of the schedule is foo.xer, the Prolog script will be named foo.pl.

**Command Line Arguments** 

```
Options:
  -f, --xer <string>        specify the XER for analysis
  -h, --help                display this help and exit
  --version                 output version information and exit
```
**Example usage**

`./xerpro -f foo.xer` | or if uncompiled, `v run xerpro.v -f foo.xer`

---

# Predicates

### named_path/3

> named_path(Start,Finish,Path) will find the path between Start and Finish, where Start and Finish are the activity IDs.

---

# Work in progress

This utility is a heavy WIP, and is largely experimental.  Prolog is a rather difficult language (for myself) and a whole different way of thinking.  The Prolog script has only been tested in SWI-Prolog. This project is a combination of self-learning augmented with a real-world purpose.  **Contributions are very welcome to progress it along faster.**

