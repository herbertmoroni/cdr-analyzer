-module(cdr_analyzer).
-export([run/0, menu/0]).
%-export([run/0]).


%%% ==========================================================================
%%% Entry Point
%%% ==========================================================================

run() ->
    io:format("CDR Analyzer~n"),
    io:format("==============~n"),
    io:format("Records loaded: ~p~n", [length(cdr_data:records())]),
    CallerRanking = rank_callers(cdr_data:records()),
    print_caller_ranking(CallerRanking),
    io:format("~n"),
    TowerStats = rank_towers(cdr_data:records()),
    print_tower_ranking(TowerStats),
    io:format("~n"),
    DurationStats = classify_durations(cdr_data:records()),
    print_duration_classification(DurationStats).


%%% ==========================================================================
%%% Caller Ranking
%%% ==========================================================================

%% Returns [{Origin, CallCount}] sorted by CallCount descending
rank_callers(AllRecords) ->
    CallsPerCaller = lists:foldl(fun count_call_per_caller/2, #{}, AllRecords),
    SortedCallers = lists:sort(fun sort_descending/2, maps:to_list(CallsPerCaller)),
    SortedCallers.

%% Default of 1 handles the first occurrence; subsequent calls increment
count_call_per_caller({Origin, _Destination, _Date, _Time, _Duration, _Tower, _Neighborhood, _Lat, _Lng}, CallerMap) ->
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
count_call_per_tower({_Origin, _Destination, _Date, _Time, Duration, Tower, _Neighborhood, _Lat, _Lng}, TowerMap) ->
    maps:update_with(Tower, fun({Count, Total}) -> {Count + 1, Total + Duration} end, {1, Duration}, TowerMap).

%% Uses integer division (div), so AvgDuration is truncated, not rounded
compute_tower_average(Tower, {CallCount, TotalDuration}, Acc) ->
    AvgDuration = TotalDuration div CallCount,
    [{Tower, CallCount, AvgDuration} | Acc].

sort_towers_descending({_TowerA, CallCountA, _AvgA}, {_TowerB, CallCountB, _AvgB}) ->
    CallCountA > CallCountB.

% print_tower_ranking(TowerStats) ->
%     io:format("Towers Ranked by Call Volume~n"),
%     io:format("-----------------------------~n"),
%     lists:foreach(fun({Tower, CallCount, AvgDuration}) ->
%         io:format("  Tower ~s  ~p calls  avg ~ps~n", [Tower, CallCount, AvgDuration])
%     end, TowerStats).

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

classify_one_call({_Origin, _Destination, _Date, _Time, Duration, _Tower, _Neighborhood, _Lat, _Lng}, {Short, Medium, Long}) ->
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
%%% Menu
%%% =============================================================================

%% Interactive menu loop — recursively calls itself after each choice
%% except when the user selects Exit, which ends the recursion
menu() ->
    io:format("~n1. Caller Ranking~n2. Tower Ranking~n3. Duration Classification~n4. Run All~n5. Exit~n"),
    io:format("Choose an option: "),

    % io:fread reads input from the terminal and parses it as an integer (~d)
    {ok, [Choice]} = io:fread("", "~d"),

    case Choice of
        1 ->
            print_caller_ranking(rank_callers(cdr_data:records())),
            menu();
        2 ->
            print_tower_ranking(rank_towers(cdr_data:records())),
            menu();
        3 ->
            print_duration_classification(classify_durations(cdr_data:records())),
            menu();
        4 ->
            run(),
            menu();
        5 ->
            io:format("Goodbye~n");
        % catches anything that isn't 1-5, including invalid input
        _ ->
            io:format("Invalid option~n"),
            menu()
    end.