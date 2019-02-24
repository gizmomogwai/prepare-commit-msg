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

string replaceEnvironmentVariable(Captures!(string) m)
{
    auto p = m["property"];
    if (p !in environment)
    {
        throw new Exception("Cannot find environment variable %s".format(p));
    }
    return environment.get(p);
}

int main(string[] args)
{
    auto file = args[1];
    if (file == "install")
    {
        return execute(["cp", args[0], ".git/hooks/"]).status;
    }

    auto commitType = args[2];
    // template for normal commits, commit for amend

    auto sha = args.length == 4 ? args[3] : "";
    if (commitType == "template")
    {
        // dfmt off
        file
            .readText
            .replaceAll!(replaceEnvironmentVariable)(regex("#\\{env\\[(?P<property>.*?)\\]\\}"))
            .replaceAll!(replaceShellCommand)(regex("#\\{(?P<command>.*?)\\}"))
            .toFile(file);
        // dfmt on
        return 0;
    }
    return 1;
}
