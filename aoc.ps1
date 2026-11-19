<#
.SYNOPSIS
    Top-level runner for the Advent of Code repo. One entry point for all four
    languages (C#, F#, Racket, Rust).

.DESCRIPTION
    Usage:
        ./aoc.ps1 run    <day> <lang> [-Year N] [-Part 1|2] [-Sample]
        ./aoc.ps1 all    <day>        [-Year N] [-Part 1|2] [-Sample]
        ./aoc.ps1 test
        ./aoc.ps1 new    <day>        [-Year N]
        ./aoc.ps1 replay <day> <lang> [-Year N] [-Part 1|2] [-Sample]

    <lang> is one of: csharp, fsharp, racket, rust
    -Year defaults to 2026.

    This file is an outline. Every TODO block describes something to implement.
    Suggested build order: sections 1-3, then `run`, `test`, `all`, and later
    `new` and `replay` (they are Phase 3 items in the plan).
#>

# =============================================================================
# 1. PARAMETERS
# =============================================================================
# TODO: Declare a param() block (it must be the first statement in the script).
#   - $Command : mandatory, position 0, ValidateSet 'run','all','test','new','replay'
#   - $Day     : int, position 1, ValidateRange 1..25 (not needed for 'test')
#   - $Lang    : string, position 2, ValidateSet 'csharp','fsharp','racket','rust'
#                (needed for 'run' and 'replay' only)
#   - $Year    : int, default 2026
#   - $Part    : int, optional, ValidateSet 1,2 (omitted = run both parts)
#   - $Sample  : switch (use samples/ instead of inputs/)
#
# Hints:
#   - [CmdletBinding()] above param() gives you -Verbose for free.
#   - Validate the combinations yourself after param(): e.g. 'run' without
#     $Lang should print the usage text and exit 1.


# =============================================================================
# 2. SETUP
# =============================================================================
# TODO: Make the script behave the same no matter where it is called from.
#   - $RepoRoot = $PSScriptRoot
#   - Set $ErrorActionPreference = 'Stop' so cmdlet failures are not ignored.
#   - Define the list of languages once: $Languages = 'csharp','fsharp','racket','rust'
#
# TODO (optional, for working across computers): resolve the data root.
#   - If $env:AOC_DATA is set, inputs/ and samples/ live under it.
#   - Otherwise they live under $RepoRoot.
#   - The harnesses need the same rule, so either each harness reads AOC_DATA
#     itself, or this script passes the resolved path down. Pick one and be
#     consistent across all four.


# =============================================================================
# 3. HELPER: build the command line for one language
# =============================================================================
# TODO: Write a function, e.g. Get-RunnerCommand, that takes
#       ($Lang, $Day, $Year, $Part, $Sample, $Replay) and returns the
#       executable plus its argument array for that language.
#
#   The harness contract is identical everywhere:
#       <runner> <day> [--year N] [--part 1|2] [--sample] [--replay]
#
#   Only the way each runner is started differs:
#     csharp : dotnet run -c Release --project csharp/Aoc.CSharp -- <harness args>
#     fsharp : dotnet run -c Release --project fsharp/Aoc.FSharp -- <harness args>
#     racket : racket racket/main.rkt <harness args>
#     rust   : cargo run --release --manifest-path rust/Cargo.toml -- <harness args>
#
# Hints:
#   - Build the shared harness args once, then prepend the per-language part.
#   - Return something you can splat:  & $exe @args
#   - Note the `--` separator for dotnet and cargo: everything after it goes
#     to your program, not to the tool.
#   - Add --verbosity quiet (dotnet) and --quiet (cargo) so build chatter does
#     not mix into the output that `all` has to parse.


# =============================================================================
# 4. HELPER: run one language and capture its result lines
# =============================================================================
# TODO: Write a function, e.g. Invoke-Runner, that runs the command from
#       section 3 from $RepoRoot and returns the parsed result lines.
#
#   Every harness prints one line per part in this exact format:
#       year day part answer elapsed_ms
#   Example:
#       2025 1 1 1234567 0.42
#
#   - Capture stdout, split into lines, keep only lines matching the format.
#   - Turn each into an object: Lang, Year, Day, Part, Answer, ElapsedMs.
#   - Check $LASTEXITCODE after the call. On non-zero, show the captured
#     output and return a result that marks this language as failed
#     (do not throw: `all` should still run the other languages).
#
# Hints:
#   - Push-Location $RepoRoot / Pop-Location in a try/finally.
#   - [pscustomobject]@{ ... } makes rows that Format-Table can print.
#   - Answers are strings. Compare them as strings, never as numbers.


# =============================================================================
# 5. COMMAND: run
# =============================================================================
# TODO: Run one day in one language and show its output.
#   - Call the section 4 helper for $Lang.
#   - Print the result lines (or pass the harness output straight through).
#   - Exit with the runner's exit code.


# =============================================================================
# 6. COMMAND: test
# =============================================================================
# TODO: Run every language's sample tests and report one overall result.
#     .NET   : dotnet test aoc.slnx          (covers C# and F#)
#     Racket : raco test racket
#     Rust   : cargo test --manifest-path rust/Cargo.toml
#
#   - Run all three even if an earlier one fails.
#   - Record pass/fail per tool from $LASTEXITCODE.
#   - Print a short summary and exit non-zero if anything failed.
#
# Note: samples are gitignored, so on a machine without them the tests should
#       report "skipped", not fail. That logic belongs in the harness tests,
#       not in this script.


# =============================================================================
# 7. COMMAND: all
# =============================================================================
# TODO: Run one day in all four languages, compare answers, show timings.
#   - Loop over $Languages and call the section 4 helper for each.
#   - Group the result rows by Part.
#   - For each part, check that every language that ran gave the same Answer.
#   - Print a table with one row per language:
#         Lang | Part 1 answer | ms | Part 2 answer | ms
#   - Flag clearly: a mismatch between languages, a language that failed to
#     run, and a language with no solution for this day yet.
#   - Exit non-zero on any mismatch or failure, so this can be used as a check.
#
# Decide: what does a harness do when the day is not implemented in that
#   language? Suggested: print nothing and exit with a distinct code (e.g. 2),
#   so `all` can show "not ported yet" instead of "failed". During December
#   this is the normal state while ports trail behind.
#
# Hints:
#   - Group-Object Part, then Select-Object -Unique on Answer.
#   - The first dotnet/cargo run after a change includes compile time in the
#     wall clock, but ElapsedMs comes from inside the harness, so it is fair.


# =============================================================================
# 8. COMMAND: new   (Phase 3)
# =============================================================================
# TODO: Scaffold a day in all four languages plus its data and notes files.
#
#   Templates: keep one per language in templates/ with placeholders such as
#   {{YEAR}}, {{DAY}} (1) and {{DAY2}} (01). Replace and write to:
#     csharp : csharp/Aoc.CSharp/Y{{YEAR}}/Day{{DAY2}}.cs
#     fsharp : fsharp/Aoc.FSharp/Y{{YEAR}}/Day{{DAY2}}.fs
#     racket : racket/{{YEAR}}/day{{DAY2}}.rkt
#     rust   : rust/src/y{{YEAR}}/day{{DAY2}}.rs
#
#   Registration, per language:
#     csharp : nothing. The [Day(year, day)] attribute in the template is
#              picked up by the source generator.
#     fsharp : add <Compile Include="Y{{YEAR}}/Day{{DAY2}}.fs" /> to the
#              .fsproj ABOVE Program.fs (file order matters in F#), and add
#              the (year, day) entry to the day map in Program.fs.
#     racket : nothing, if main.rkt uses dynamic-require on the path.
#     rust   : add `pub mod day{{DAY2}};` to src/y{{YEAR}}/mod.rs and a
#              `(year, day) =>` arm to the match in main.rs.
#
#   Data and notes (create empty files):
#     inputs/{{YEAR}}/day{{DAY2}}.txt
#     samples/{{YEAR}}/day{{DAY2}}.txt
#     samples/{{YEAR}}/day{{DAY2}}.part1.expected
#     samples/{{YEAR}}/day{{DAY2}}.part2.expected
#     notes/{{YEAR}}/day{{DAY2}}.md        (from the comparison-log template)
#
#   Rules:
#     - Never overwrite an existing file. Skip it and say so.
#     - Create year folders when missing (New-Item -ItemType Directory -Force).
#     - Make the command safe to run twice: check before inserting a line.
#
# Hints:
#   - Put a marker comment where lines get inserted, e.g. `// aoc:new-day` in
#     main.rs and Program.fs, and an XML comment in the .fsproj. Then the
#     insert is "add this line above the marker", which is easy and robust.
#   - '{0:D2}' -f $Day gives the zero-padded day.


# =============================================================================
# 9. COMMAND: replay   (Phase 3)
# =============================================================================
# TODO: Run one day in one language with recording on, then open the viewer.
#   - Same as `run`, but pass --replay to the harness.
#   - The harness writes replays/<year>/dayNN.<lang>.jsonl.
#   - After a successful run, check that the file exists and print its path.
#   - Open the viewer: Start-Process (Join-Path $RepoRoot 'viewer/index.html')
#
# Note: a page opened from disk cannot read local files by itself, so the
#       viewer needs its file picker or drag and drop. Printing the replay
#       path makes it easy to find.
#
# Stretch: a `replay-diff <day> <langA> <langB>` command that records both and
#          reports the first frame where the two replays differ.


# =============================================================================
# 10. DISPATCH
# =============================================================================
# TODO: A switch on $Command that validates the arguments each command needs
#       and calls the matching section above.
#   - Unknown or incomplete usage: print the usage text from the top of this
#     file (Get-Help $PSCommandPath) and exit 1.
#   - Always end with an explicit `exit <code>` so callers can rely on it.
