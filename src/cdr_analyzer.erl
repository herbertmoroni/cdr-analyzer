-module(cdr_analyzer).
-export([run/0]).
-include("cdr.hrl").


%%% ==========================================================================
%%% Entry Point
%%% ==========================================================================

%% The only job of run/0 is to start the interactive menu
run() ->
    menu().


%%% ==========================================================================
%%% Caller Ranking
%%% ==========================================================================

%% Returns [{Origin, CallCount}] sorted by CallCount descending
rank_callers(AllRecords) ->
    CallsPerCaller = lists:foldl(fun count_call_per_caller/2, #{}, AllRecords),
    SortedCallers = lists:sort(fun sort_descending/2, maps:to_list(CallsPerCaller)),
    SortedCallers.

%% Default of 1 handles the first occurrence; subsequent calls increment
count_call_per_caller(#cdr{origin = Origin}, CallerMap) ->
    maps:update_with(Origin, fun(Count) -> Count + 1 end, 1, CallerMap).

sort_descending({_OriginA, CountA}, {_OriginB, CountB}) ->
    CountA > CountB.

print_caller_ranking(SortedCallers) ->
    io:format("Callers Ranked by Activity~n"),
    io:format("--------------------------~n"),
    lists:foreach(fun({Origin, CallCount}) ->
        io:format("  Caller ~p  ~p calls~n", [Origin, CallCount])
    end, SortedCallers).


%%% =============================================================================
%%% Tower Ranking
%%% =============================================================================

%% Returns [{Tower, CallCount, AvgDuration}] sorted by CallCount descending
rank_towers(AllRecords) ->
    CallsPerTower = lists:foldl(fun count_call_per_tower/2, #{}, AllRecords),
    TowerStats = maps:fold(fun compute_tower_average/3, [], CallsPerTower),
    lists:sort(fun sort_towers_descending/2, TowerStats).

%% Default of {1, Duration} handles the first occurrence; subsequent calls accumulate both
count_call_per_tower(#cdr{tower = Tower, duration = Duration}, TowerMap) ->
    maps:update_with(Tower, fun({Count, Total}) -> {Count + 1, Total + Duration} end, {1, Duration}, TowerMap).

%% Uses integer division (div), so AvgDuration is truncated, not rounded
compute_tower_average(Tower, {CallCount, TotalDuration}, Acc) ->
    AvgDuration = TotalDuration div CallCount,
    [{Tower, CallCount, AvgDuration} | Acc].

sort_towers_descending({_TowerA, CallCountA, _AvgA}, {_TowerB, CallCountB, _AvgB}) ->
    CallCountA > CallCountB.

%% Recursively prints each tower's stats — base case stops on empty list
print_tower_ranking([]) ->
    ok;
print_tower_ranking([{Tower, CallCount, AvgDuration} | RemainingTowers]) ->
    io:format("  Tower ~s  ~p calls  avg ~ps~n", [Tower, CallCount, AvgDuration]),
    print_tower_ranking(RemainingTowers).


%%% =============================================================================
%%% Duration Classification
%%% =============================================================================

%% Returns {ShortCount, MediumCount, LongCount}
classify_durations(AllRecords) ->
    lists:foldl(fun classify_one_call/2, {0, 0, 0}, AllRecords).

classify_one_call(#cdr{duration = Duration}, {Short, Medium, Long}) ->
    case Duration of
        D when D < 60  -> {Short + 1, Medium, Long};
        D when D < 180 -> {Short, Medium + 1, Long};
        _              -> {Short, Medium, Long + 1}
    end.

print_duration_classification({Short, Medium, Long}) ->
    io:format("Call Duration Classification~n"),
    io:format("----------------------------~n"),
    io:format("  Short  (under 60s)   ~p calls~n", [Short]),
    io:format("  Medium (60s - 180s)  ~p calls~n", [Medium]),
    io:format("  Long   (over 180s)   ~p calls~n", [Long]).


%%% =============================================================================
%%% Process Demo — Concurrency via Message Passing
%%% =============================================================================

%% Spawns a separate process to classify one call's duration
%% Demonstrates Erlang's core identity: isolated processes communicating by messages
classify_with_process(#cdr{duration = Duration} = Record) ->
    % self() must be captured HERE, in the parent process, before spawning
    % inside the fun, self() would return the worker's own Pid, not the parent's
    ParentPid = self(),
    WorkerPid = spawn(fun() -> classify_worker(Duration, ParentPid) end),

    % blocks here until a message matching {classification, _} arrives
    receive
        {classification, Label} ->
            io:format("  Caller ~p classified as ~s by process ~p~n",
                      [Record#cdr.origin, Label, WorkerPid])
    end.

%% Runs inside the spawned process — classifies, then sends result back
classify_worker(Duration, CallerPid) ->
    Label = case Duration of
        D when D < 60  -> "short";
        D when D < 180 -> "medium";
        _              -> "long"
    end,
    % ! is the send operator — sends a message to CallerPid's mailbox
    CallerPid ! {classification, Label}.


%%% =============================================================================
%%% Menu
%%% =============================================================================

%% Interactive menu loop — recursively calls itself after each choice
%% except when the user selects Exit, which ends the recursion
menu() ->
    io:format("~n1. Caller Ranking~n2. Tower Ranking~n3. Duration Classification~n4. Run All~n5. Process Demo~n6. Exit~n"),
    io:format("Choose an option: "),

    % io:fread can fail on non-numeric input — caught below instead of crashing
    case io:fread("", "~d") of
        {ok, [Choice]} ->
            handle_choice(Choice);
        {error, _Reason} ->
            io:format("Invalid input — please enter a number~n"),
            menu();
        eof ->
            io:format("Goodbye~n")
    end.

%% Separated from menu/0 so the input parsing and the choice handling
%% each stay focused on one responsibility
handle_choice(1) ->
    print_caller_ranking(rank_callers(cdr_data:records())),
    menu();
handle_choice(2) ->
    print_tower_ranking(rank_towers(cdr_data:records())),
    menu();
handle_choice(3) ->
    print_duration_classification(classify_durations(cdr_data:records())),
    menu();
handle_choice(4) ->
    print_caller_ranking(rank_callers(cdr_data:records())),
    io:format("~n"),
    print_tower_ranking(rank_towers(cdr_data:records())),
    io:format("~n"),
    print_duration_classification(classify_durations(cdr_data:records())),
    menu();
handle_choice(5) ->
    classify_with_process(hd(cdr_data:records())),
    menu();
handle_choice(6) ->
    io:format("Goodbye~n");
% catches any number that isn't 1-6
handle_choice(_) ->
    io:format("Invalid option~n"),
    menu().