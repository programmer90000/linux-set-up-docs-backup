Bar often require polling data from system files (i.e. /sys or /proc). To this
end, SFWBar provides a scanner infrastructure. Scanners allow reading system
files and extract multiple data points from them in a single pass. This ensures
that multiple data items are consistent and resources are not wasted reading the
same file multiple times.::


  File("/proc/swaps",NoGlob) {
    SwapTotal = RegEx("[\t ]([0-9]+)")
    SwapUsed = RegEx("[\t ][0-9]+[\t ]([0-9]+)")
  }
  Exec("getweather.sh") {
    WeatherTemp = Json(".forecast.today.degrees")
  }
  ExecClient("stdbuf -oL foo.sh BAR BAZ", "foo") {
    Foo_foo = Json(".foo")
    Foo_bar = Json(".bar")
  }

Scanner declarations consist of a scanner source and one or more parsers used to
populate the scanner variables.

The sources are:

File(<name>, <flags>)
        Read data from a file

Exec(<command>)
        Read data from an output of a shell command

ExecClient(<command> [,<trigger>)
        Read data from an executable, this source will wait for any output from
        the standard output of the executable. Once available (i.e. the program
        flushes its output) the source will populate the variables and emit a
        trigger event.  This source accepts two parameters, command to execute
        and an id. The id can be used to write to the standard input of the 
        executable via ClientSend (provided that the executable takes standard
        input) and to identify a trigger emitted upon variable updates.
        USE RESPONSIBLY: If a trigger causes the client to receive new data
        (i.e. by triggering a ClientSend command that in turn triggers response
        from the source, you can end up with an infinite loop.
        (see alsa.widget and rfkill-wifi.widget as examples).

SocketClient(<address> [,<trigger>)
        Read data from a socket, this source will read a bust of data
        using it to populate the variables and emit a trigger event once done.
        This source accepts two parameters, a socket address and an id. The
        id is used to address the socket via ClientSend and to identify a
        trigger emitted upon variable updates.
        USE RESPONSIBLY: If a trigger causes the client to receive new data
        (i.e. by triggering a ClientSend command that in turn triggers response
        from the source, you can end up with an infinite loop.

MpdClient(<address> [,<trigger>)
        Read data from Music Player Daemon IPC (data is polled whenever MPD
        responds to an 'idle player' event).  MpdClient emits trigger "mpd".
        (see mpd-int.widget as an example)

SwayClient(<command> [,<trigger>)
        Receive updates on Sway state, updates are the json objects sent by
        sway, wrapped into an object with a name of the event i.e.
        ``window: { sway window change object }``.
        SwayClient emits trigger "sway".
        (see sway-lang.widget as an example).


The `File` source also accepts further optional arguments specifying how
scanner should handle the source, these can be:

NoGlob
          specifies that SFWBar shouldn't attempt to expand the pattern in 
          the file name. If this flag is not specified, the file source will
          attempt to read from all files matching a filename pattern.

CheckTime
          indicates that the program should only update the variables from 
          this file when file modification date/time changes.

Scanner variables are extracted from sources using parsers, currently the following
parsers are supported:

Grab([Aggregator])
  specifies that the data is copied from the file verbatim

RegEx(Pattern[,Aggregator])
  extracts data using a regular expression parser, the variable is assigned
  data from the first capture buffer

Json(Path[,Aggregator])
  extracts data from a json structure. The path starts with a separator
  character, which is followed by a path with elements separated by the
  same character. The path can contain numbers to indicate array indices
  i.e. ``.data.node.1.string`` and key checks to filter arrays, i.e.
  ``.data.node.[key="blah"].value``

Optional aggregators specify how multiple occurrences of numeric data are
treated. The following aggregators are supported:

First
  Variable should be set to the first occurrence of the pattern in the source

Last
  Variable should be set to the last occurrence of the pattern in the source

Sum
  Variable should be set to the sum of all occurrences of the pattern in the
  source

Product
  Variable should be set to the product of all occurrences of the pattern in
  the source

For string values, Sum and Product aggregators are treated as Last.
Each scanner variable holds the following information:

.val
  current numeric value of the variable
.pval
  previous value of the variable
.time
  time elapsed between observing .pval and .val
.age
  time elapsed since variable was last updated
.count
  a number of time the pattern has been matched
  during the last scan
.str
  a string value of the variable (can also be accessed by using $ prefix).

If a suffix is omitted for a scanner variable, the .val suffix is assumed.

Intermediate scanner variables can be declared using a toplevel ``set`` keyword
I.e. ::

  set MyExpr = VarA + VarB * VarC + Val($Complex
  ...
  value = Str(MyExpr,2)

In the above example, value of the MyExpr variable will be calculated and
the result will be used in computing the value expression. Intermediate
variables have type and have all of the fields of a scan variable (i.e. val,
pval, time etc). They can be used the same way as scan variables.