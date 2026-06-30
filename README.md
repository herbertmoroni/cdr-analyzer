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

## How to Run

1. Open a terminal in the project's `src` folder
2. Start the Erlang shell: `erl`
3. Compile both modules: `c(cdr_data). c(cdr_analyzer).`
4. Start the program: `cdr_analyzer:run().`
5. Choose an option from the interactive menu (1–7)

# Useful Websites

* [Erlang by Example](https://www.erlang.org/blog/core-erlang-by-example/)
* [CDR Analysis 101 — What Call Detail Records Reveal in Investigations](https://www.penlink.com/blog/cdr-analysis-101-what-call-detail-records-can-reveal-in-complex-cases/)
* [Analyzing Call Detail Records with Connected Data](https://policinginsight.com/feature/analyzing-call-detail-records-with-connected-data/)

# Future Work

* Add CSV file ingestion instead of embedding records directly in the source — 
  would require manual line parsing since Erlang has no built-in CSV library
* Expand the process demo to classify multiple calls concurrently using a pool 
  of worker processes instead of one call at a time
* Add geographic clustering analysis using the latitude/longitude fields already 
  present in each record
* Add `-spec` type annotations for Dialyzer static analysis

# AI Disclosure

I used Claude (Anthropic) to debug issues — such as a process identity bug involving closures and `self()` — and to discuss design tradeoffs like module structure, records versus tuples, and the concurrency model. I used AI to proofread this README since English is not my first language.

All design decisions, code review, and final implementation choices were mine.
