-module(cdr_analyzer).
-export([run/0]).

% Entry point — call cdr_analyzer:run() from the shell to start the pipeline
run() ->
    io:format("CDR Analyzer~n"),
    io:format("==============~n").