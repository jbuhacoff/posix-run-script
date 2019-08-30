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

# Quick install

Without cloning the repository, you can just download and install the script:

```
curl --silent --show-error -o /usr/bin/rs https://raw.githubusercontent.com/jbuhacoff/posix-run-script/master/src/main/script/rs.sh
chmod 755 /usr/bin/rs
```

# Install from source

If you have `make`, do this:

```
make install
```

If you don't have `make`, do this instead:

```
cp src/main/script/rs.sh /usr/bin/rs
chmod 755 /usr/bin/rs
```

# Configure

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

# Execute remotely

You can execte a script on a remote server using the `--connect` or `--connect-env`
options. The `--connect` option requires a parameter that specifies how to connect
to the remote server, for example `ssh user@host`. The `--connect-env` option looks
for an environment variable `RS_CONNECT` to find the same information so you can define
it once instead of on each command.

For the following examples to work, the script must be found in the local
`RS_PATH` and you must have SSH access to the remote server:

```
rs --connect 'ssh user@host' script/to/run
rs -c 'ssh user@host' script/to/run
```

```
export RS_CONNECT='ssh user@host'
rs --connect-env script/to/run
rs -C script/to/run
```

The script is piped to the remote system using the specified connect command and
executed on the remote system.
