# Bash Style Guide

This guide outlines how to write bash scripts with a style that makes them safe
and predictable. This is a customized version based on [style.ysap.sh](https://style.ysap.sh).

## Preface

This guide will try to be as objective as possible, providing reasoning for why
certain decisions were made. For choices that are purely aesthetic (and may
not be universally agreeable) they will exist in the `Aesthetics` section
below.

Though good style alone won't ensure that your scripts are free from error, it
can certainly help narrow the scope for bugs to exist. This guide attempts to
explicitly state my style choices instead of implicitly relying on a sense or a
"vibe" of how code should be written.

## Aesthetics

### Tabs / Spaces

Spaces

### Columns

Not to exceed 120 characters.

### Semicolons

Avoid using semicolons in scripts unless required in control statements (e.g.,
if, while).

```bash
# wrong
name='dave';
echo "hello $name";

# right
name='dave'
echo "hello $name"
```

The exception to this rule is outlined in the `Block Statements` section below.
Namely, semicolons should be used for control statements like `if` or `while`.

### Functions

**Always use the `function` keyword.** All variables created in a function should
be made local.

```bash
# wrong
foo() {
    i=foo # this is now global, wrong depending on intent
}

# right
function foo() {
    local i=foo # this is local, preferred
}
```

### Block Statements

`then` should be on the same line as `if`, and `do` should be on the same line
as `while`.

```bash
# wrong
if true
then
    ...
fi

# also wrong, though admittedly looks kinda cool
true && {
    ...
}

# right
if true; then
    ...
fi
```

### Spacing

No more than 2 consecutive newline characters (ie. no more than 1 blank line in
a row).

### Comments

No explicit style guide for comments. Don't change someones comments for
aesthetic reasons unless you are rewriting or updating them.

---

## Bashisms

This style guide is for bash. This means when given the choice, always prefer
bash builtins or keywords instead of external commands or `sh(1)` syntax.

### `test(1)`

Use `[[ ... ]]` for conditional testing, not `[ .. ]` or `test ...`

```bash
# wrong
test -d /etc

# also wrong
[ -d /etc ]

# correct
[[ -d /etc ]]
```

See [BashFAQ031](http://mywiki.wooledge.org/BashFAQ/031) for more information.

### Sequences

Use bash builtins for generating sequences

```bash
n=10

# wrong
for f in $(seq 1 5); do
    ...
done

# wrong
for f in $(seq 1 "$n"); do
    ...
done

# right
for f in {1..5}; do
    ...
done

# right
for ((i = 0; i < n; i++)); do
    ...
done
```

### Command Substitution

Use `$(...)` for command substitution.

```bash
foo=`date`  # wrong
foo=$(date) # right
```

### Math / Integer Manipulation

Use `((...))` and `$((...))`.

```bash
a=5
b=4

# wrong
if [[ $a -gt $b ]]; then
    ...
fi

# right
if ((a > b)); then
    ...
fi
```

Do **not** use the `let` command.

### Parameter Expansion

Always prefer parameter expansion over external commands like `echo`, `sed`,
`awk`, etc.

```bash
name='bahamas10'

# wrong
prog=$(basename "$0")
nonumbers=$(echo "$name" | sed -e 's/[0-9]//g')

# right
prog=${0##*/}
nonumbers=${name//[0-9]/}
```

### Listing Files

Do not [parse ls(1)](http://mywiki.wooledge.org/ParsingLs), instead use
bash builtin functions to loop files

```bash
# very wrong, potentially unsafe
for f in $(ls); do
    ...
done

# right
for f in *; do
    ...
done
```

### Determining path of the executable (`__dirname`)

Simply stated, you can't know this for sure. If you are trying to find out the
full path of the executing program, you should rethink your software design.

See [BashFAQ028](http://mywiki.wooledge.org/BashFAQ/028) for more information.

### Arrays and lists

Use bash arrays instead of a string separated by spaces (or newlines, tabs,
etc.) whenever possible

```bash
# wrong
modules='json httpserver jshint'
for module in $modules; do
    npm install -g "$module"
done

# right
modules=(json httpserver jshint)
for module in "${modules[@]}"; do
    npm install -g "$module"
done
```

Of course, in this example it may be better expressed as:

```bash
npm install -g "${modules[@]}"
```

... only if the command supports multiple arguments and you are not interested
in catching individual failures.

### read builtin

Use the bash `read` builtin whenever possible to avoid forking external
commands

Example

```bash
fqdn='computer1.daveeddy.com'

IFS=. read -r hostname domain tld <<< "$fqdn"
echo "$hostname is in $domain.$tld"
# => "computer1 is in daveeddy.com"
```

---

## External Commands

### GNU userland tools

The whole world doesn't run on GNU or on Linux; avoid GNU specific options
when forking external commands like `awk`, `sed`, `grep`, etc. to be as
portable as possible.

When writing bash and using all the powerful tools and builtins bash gives you,
you'll find it rare that you need to fork external commands to do simple string
manipulation.

### Useless Use of Cat Award

Don't use `cat(1)` when you don't need it. If programs support reading from
stdin, pass the data in using bash redirection.

```bash
# wrong
cat file | grep foo

# right
grep foo < file

# also right
grep foo file
```

Prefer using a command line tools builtin method of reading a file instead of
passing in stdin. This is where we make the inference that, if a program says
it can read a file passed by name, it's probably more performant to do that.

---

## Style

### Quoting

Use double quotes for strings that require variable expansion or command
substitution interpolation, and single quotes for all others.

```bash
# right
foo='Hello World'
bar="You are $USER"

# wrong
foo="hello world"

# possibly wrong, depending on intent
bar='You are $USER'
```

All variables that will undergo word-splitting *must* be quoted (1). If no
splitting will happen, the variable may remain unquoted.

```bash
foo='hello world'

if [[ -n $foo ]]; then   # no quotes needed:
                         # [[ ... ]] won't word-split variable expansions

    echo "$foo"          # quotes needed
fi

bar=$foo  # no quotes needed - variable assignment doesn't word-split
```

1. The only exception to this rule is if the code or bash controls the variable
for the duration of its lifetime. For example code like this:

```bash
printf_date_supported=false
if printf '%()T' &>/dev/null; then
    printf_date_supported=true
fi

if $printf_date_supported; then
    ...
fi
```

Even though `$printf_date_supported` undergoes word-splitting in the `if`
statement in that example, quotes are not used because the contents of that
variable are controlled explicitly by the programmer and not taken from a user
or command.

Also, variables like `$$`, `$?`, `$#`, etc. don't required quotes because they
will never contain spaces, tabs, or newlines.

When in doubt; [quote all expansions](http://mywiki.wooledge.org/Quotes).

### Variable Declaration

Avoid uppercase variable names unless they 1. are constants or 2. are exported
to the environment using `export`. Don't use `let` or `readonly` to create
variables. `declare` should *only* be used for associative arrays. `local`
should *always* be used in functions.

```bash
# wrong
declare -i foo=5
let foo++
readonly bar='something'
FOOBAR=baz

# right
i=5
((i++))
bar='something'
export FOOBAR=baz
```

### shebang

Bash is not always located at `/bin/bash`, so use this line:

```bash
#!/usr/bin/env bash
```

Unless you're intentionally targeting a specific environment (e.g. `/bin/bash`
on Linux servers with restricted PATHs).

### Error Checking

`cd`, for example, doesn't always work. Make sure to check for any possible
errors for `cd` (or commands like it) and exit or break if they are present.

```bash
# wrong
cd /some/path # this could fail
rm file       # if cd fails where am I? what am I deleting?

# right
cd /some/path || exit
rm file
```

### Using `set -e`

Don't set `errexit`. Like in C, sometimes you want an error, or you expect
something to fail, and that doesn't necessarily mean you want the program
to exit.

This is a controversial opinion that I have on the surface, but the link below
will show situations where `set -e` can do more harm than good because of its
implications.

### Using `eval`

Never.

It opens your code to code injection and makes static analysis impossible.
Almost every use-case can be solved more safely with arrays, indirect expansion,
or proper quoting.

---

## Common Mistakes

### Using {} instead of quotes.

Using `${f}` is potentially different than `"$f"` because of how word-splitting
is performed. For example.

```bash
for f in '1 space' '2  spaces' '3   spaces'; do
    echo ${f}
done
```

yields:

```
1 space
2 spaces
3 spaces
```

Notice that it loses the amount of spaces. This is due to the fact that the
variable is expanded and undergoes word-splitting because it is unquoted. This
loop results in the 3 following commands being executed:

```bash
echo 1 space
echo 2  spaces
echo 3   spaces
```

The extra spaces are effectively ignored here and only 2 arguments are passed
to the `echo` command in all 3 invocations.

If the variable was quoted instead:

```bash
for f in '1 space' '2  spaces' '3   spaces'; do
    echo "$f"
done
```

yields:

```
1 space
2  spaces
3   spaces
```

The variable `$f` is expanded but doesn't get split at all by bash, so it is
passed as a single string (with spaces) to the `echo` command in all 3
invocations.

Note that, for the most part `$f` is the same as `${f}` and `"$f"` is the same
as `"${f}"`. The curly braces should only be used to ensure the variable name
is expanded properly. For example:

```bash
$ echo "$HOME is $USERs home directory"
/home/dave is  home directory
$ echo "$HOME is ${USER}s home directory"
/home/dave is daves home directory
```

The braces in this example were the difference of `$USER` vs `$USERs` being
expanded.

### Abusing for-loops when while would work better

`for` loops are great for iteration over arguments, or arrays. Newline
separated data is best left to a `while read -r ...` loop.

```bash
users=$(awk -F: '{print $1}' /etc/passwd)
for user in $users; do
    echo "user is $user"
done
```

This example reads the entire `/etc/passwd` file to extract the usernames into
a variable separated by newlines. The `for` loop is then used to iterate over
each entry.

This approach has a lot of issues if used on other files with data that may
contain spaces or tabs.

1. This reads *all* usernames into memory, instead of processing them in a
streaming fashion.
2. If the first field of that file contained spaces or tabs, the for loop would
break on that as well as newlines.
3. This only works *because* `$users` is unquoted in the `for` loop - if
variable expansion only works for your purposes while unquoted this is a good
sign that something isn't implemented correctly.

To rewrite this:

```bash
while IFS=: read -r user _; do
    echo "$user is user"
done < /etc/passwd
```

This will read the file in a streaming fashion, not pulling it all into memory,
and will break on colons extracting the first field and discarding (storing as
the variable `_`) the rest - using nothing but bash builtin commands.

---

## References

- [YSAP](https://ysap.sh)
- [BashGuide](https://mywiki.wooledge.org/BashGuide)
- [BashPitFalls](http://mywiki.wooledge.org/BashPitfalls)
- [Bash Practices](http://mywiki.wooledge.org/BashGuide/Practices)

---

## License

MIT License
