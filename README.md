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

<!-- [Software Demo Video](http://youtube.link.goes.here) -->

# Development Environment

Erlang is a functional, concurrent programming language that runs on the BEAM virtual
machine. This project uses only the Erlang standard library — no external dependencies.

* Erlang/OTP 29.0.2
* Visual Studio Code with the Erlang extension by Pierrick Gourlain

# Useful Websites

# Useful Websites

* [Erlang Standard Library Reference Manual](https://www.erlang.org/doc/apps/stdlib/index.html)
* [CDR Analysis 101 — What Call Detail Records Reveal in Investigations](https://www.penlink.com/blog/cdr-analysis-101-what-call-detail-records-can-reveal-in-complex-cases/)
* [CDR Analysis and Cell Tower Mapping for Legal Cases](https://bdforensics.com/specialized-forensics-and-security/call-detail-record-analysis)
* [Analyzing Call Detail Records with Connected Data](https://policinginsight.com/feature/analyzing-call-detail-records-with-connected-data/)

# Future Work

* Implement caller ranking by total number of calls
* Implement tower ranking by call volume and average duration
* Add duration classification — short, medium, and long calls
