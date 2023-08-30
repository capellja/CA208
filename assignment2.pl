% Defines the groups and the teams they consist of.
group(a, [team1, team2, team3, team4, team5]).
group(b, [team6, team7, team8, team9, team10]).
group(c, [team11, team12, team13, team14, team15]).
group(d, [team16, team17, team18, team19, team20]).
group(e, [team21, team22, team23, team24, team25]).
group(f, [team26, team27, team28, team29, team30]).

% Generates all possible fixtures (home and away games) for a given group.
fixtures(Group, Fixtures) :-
    findall((Home, Away), 
    (member(Home, Group),
     member(Away, Group),
      Home @< Away),AllFixtures),
    sort(AllFixtures, Fixtures).

% Assigns a day to each fixture and checks that no more than 3 matches are played in a single day.
fixture_days([], _, _, []).
fixture_days([(HomeTeam, AwayTeam)|Fixtures], Day, Scheduled, [(HomeTeam, AwayTeam, Day)|DayFixtures]) :-
    % Check that neither of the teams have played a match in the last 3 days.
    % If they have, the function will return false and backtrack to find another day.

    \+ (member((HomeTeam, _, PreviousDay), Scheduled), Day - PreviousDay < 4),
    \+ (member((_, AwayTeam, PreviousDay), Scheduled), Day - PreviousDay < 4),
    fixture_days(Fixtures, Day, [(HomeTeam, AwayTeam, Day)|Scheduled], DayFixtures).

% If no day is found for a fixture, try again with the next day.
fixture_days(Fixtures, Day, Scheduled, DayFixtures) :-
    NextDay is Day + 1,
    fixture_days(Fixtures, NextDay, Scheduled, DayFixtures).

% Calls fixture_days for each fixture and generates the final schedule.
add_days(Fixtures, Day, Schedule) :- fixture_days(Fixtures, Day, [], Schedule).

% Generates a schedule for a group by calling fixtures and add_days.
schedule_group(Group, Schedule, StartDay, EndDay) :-
    group(Group, Teams),
    fixtures(Teams, Fixtures),
    add_days(Fixtures, StartDay, Schedule),

    % Maximum amount of matches per day is 3.
    NumOfFixtures is length(Fixtures),
    MaxFixturesPerDay is 3,
    LastDay is Day + ceil(NumOfFixtures / MaxFixturesPerDay).

% Generates the schedule for all groups by calling schedule_group for each group.
schedule(Schedule) :-
    schedule_groups(['a', 'b', 'c', 'd', 'e', 'f'], 1, [], Schedule),
    print_schedule(Schedule).


% This function recursively calls schedule_group for each group and appends the results to an accumulator.
schedule_groups([], _, Acc, Acc).
schedule_groups([Group|Groups], StartDay, Acc, Schedule) :-
    schedule_group(Group, GroupSchedule, StartDay, EndDay),
    append(Acc, GroupSchedule, NewAcc),
    schedule_groups(Groups, EndDay, NewAcc, Schedule).

% Print out the schedule.
print_schedule([]).
print_schedule([(Home, Away, Day)|Rest]) :-
    format("--------------------------~n"),
    format("Day ~d: ~15w vs ~15w~n", [Day, Home, Away]),
    print_schedule(Rest).