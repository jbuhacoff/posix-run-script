---
title: posix-run-script
---

# Summary

This package provides a script wrapper that searches for scripts in a `:`-separated list
of directories and runs the first match.

It is useful in situations where multiple people share a repository of scripts. Because
scripts don't need to be compiled and installed, and because each user or contributor may
have the repository stored at a different location on their system, it is useful to simply
define the location of scripts in an environment variable. This also allows procedures
to be shared which are copy-paste-executable by referring to a command line with this 
wrapper and the name of the script to run with its options.  

# Install

```
make install
```

You can create your own script directory and initialize your terminal with `RS_PATH`
each time you login:

```
mkdir -p /etc/profile.d
cat >/etc/profile.d/rs_path.sh <<EOF
#!/bin/sh
export RS_PATH=~/script
EOF
```

# Example 

User A has a script folder at `~/scripts`, with `RS_PATH=~/scripts` in the
user's environment. User B has a clone of the same script folder at
`/usr/share/scripts` and a second script folder at `~/dev/newscripts`, with
`RS_PATH=~/dev/newscripts:/usr/share/scripts` in the user's environment.

If the shared script folder contains a script `project1/doit.sh` then both
users could copy-paste-execute a line from a procedure document like this:

```
rs project1/doit [options...]
```

All path components in script names are relative to the directory in the search paths,
giving flexibility to organize and namespace the scripts within a repository.

Furthermore, the script name is not required to include the extension and the script files
do not need to have the executable bit set. 

# Search path

To customize the search path, export `RS_PATH` with a `:`-separated list of 
directories to search:

```
export RS_PATH=/path/to/scripts1:/path/to/scripts2
```

The directories will be searched in the order specified in `RS_PATH` and the
first match will be used.

# Locate a file

If it seems the wrong library or the wrong version of a library is being loaded,
you can check it with the `--locate` or `-l` option on the command line:

```
rs --locate <script>
rs -l <script>
```

It will print out the path wherever `<script>` is found and exit 0, or it will print
an error message to stderr and exit with a non-zero status. 

