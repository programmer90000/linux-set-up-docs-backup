
**Table of contents**
* [5. A plugin is enabled but does nothing](#5-a-plugin-is-enabled-but-does-nothing)


#### 5. A plugin is enabled but does nothing

Plugins that cause an error (throw an exception) when Wayfire attempts to load them will be discarded. Despite this, they will still show up as "enabled" in WCM (as WCM only looks at the configuration file). You can verify if this happened by looking at Wayfire's logs -- look for any error message that says ``[src/core/plugin-loader.cpp:167] Failed to load plugin`` (logs are usually appended to the system logs when running a graphical session or displayed in the terminal if running Wayfire from the command line). The most likely cause is trying to run a newly installed or updated plugin without restarting Wayfire (in most cases this is required), or an actual bug in the plugin. Simply try restarting Wayfire and try again.
