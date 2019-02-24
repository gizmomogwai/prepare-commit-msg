import std.stdio;

void main(string[] args)
{
    stderr.writeln(args);
    auto commitMessage = args[1];
    auto commitType = args[2];
    auto sha = args.length == 4 ? args[3] : "";
}
