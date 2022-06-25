import std.stdio;
import std.regex;
import std.file;
import std.string;
import std.process;
import std.regex;

string replaceShellCommand(Captures!(string) m)
{
    auto command = m["command"].split(" ");
    auto res = command.execute;
    if (res.status != 0)
    {
        throw new Exception("Cannot run %s".format(command.join(" ")));
    }
    return res.output.strip;
}

int main(string[] args)
{
    stderr.writeln(args);
    auto file = args[1];
    if (file == "install")
    {
        auto path = execute(["which", args[0]]);
        if (path.status != 0)
        {
            throw new Exception("cannot get path to %s".format(args[0]));
        }

        auto cmd = ["cp", path.output.strip, ".git/hooks/"];
        writeln(cmd);
        return execute(cmd).status;
    }

    auto commitType = args[2];
    // template for normal commits, commit for amend

    auto sha = args.length == 4 ? args[3] : "";
    switch (commitType)
    {
    case "template":
    case "commit":
        // dfmt off
        file
            .readText
            .replaceAll!(replaceShellCommand)(regex("#\\{(?P<command>.*?)\\}"))
            .toFile(file);
        // dfmt on
        return 0;
    case "message":
        return 0;
    default:
        return 1;
    }
}
