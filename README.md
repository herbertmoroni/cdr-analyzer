# Overview

CDR Analyzer is a console-based data analysis pipeline written in Erlang. It processes a
real-world Call Detail Record dataset and produces an investigation summary printed to the
terminal — activity rankings, tower statistics, and duration classification.

The domain irony is real — CDR data analyzed in the language that literally powers telecom
switches worldwide.

The CDR dataset analyzed here is literally the kind of data a real kidnapping investigation
uses — cell tower pings, timestamps, movement patterns. This is a toy pipeline over real
forensic data, in the language that would power the real version of that system at scale.
In mission-critical scenarios like smart cities and kidnapping response, Erlang's guarantees
matter: many sources streaming simultaneously, always-on processing, isolated failures, and
real-time classification.

[Software Demo Video](http://youtube.link.goes.here)

# Development Environment

* Erlang/OTP 29.0.2
* Visual Studio Code with the Erlang extension by Pierrick Gourlain

# Useful Websites

* [Erlang Official Downloads](https://www.erlang.org/downloads)
* [Erlang Standard Library Reference Manual](https://www.erlang.org/doc/apps/stdlib/index.html)
* [Erlang by Example](https://erlangbyexample.org/)

# Future Work

{Make a list of things that you need to fix, improve, and add in the future.}
* Item 1
* Item 2
* Item 3