-module(rebar_packages).

-export([get_packages/1]).

-include("rebar.hrl").

-spec get_packages(rebar_state:t()) -> {dict:dict(), tuple()}.
get_packages(State) ->
    RebarDir = rebar_state:get(State, global_rebar_dir, filename:join(os:getenv("HOME"), ".rebar")),
    PackagesFile = filename:join(RebarDir, "packages"),
    case ec_file:exists(PackagesFile) of
        true ->
            try
                {ok, Binary} = file:read_file(PackagesFile),
                {List, Graph} = binary_to_term(Binary),
                {List, Graph}
            catch
                _:_ ->
                    ?ERROR("Bad packages index, try to fix with `rebar update`~n", []),
                    {[], rlx_depsolver:new_graph()}
            end;
        false ->
            {[], rlx_depsolver:new_graph()}
    end.
