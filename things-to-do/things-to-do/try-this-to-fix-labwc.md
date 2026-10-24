Inside `rc.xml`, I have the following code. I think this is causing LabWC to freeze. Remove the code inside `windowRules`:
```
    <windowRules>
        <windowRule identifier="*">
            <action name="Maximize"/>
        </windowRule>
        <windowRule identifier="">
            <action name="ResizeTo" width="" height="" />
            <action name="AutoPlace" policy="automatic" />
        </windowRule>
        <windowRule identifier="" serverDecoration="no"/>
    </windowRules>
```

If it works, remove it from rc.xml in the repo. Make a new file inside `things-to-do/` to add custom window rules to LabWC. Write in the file that I can't use `*` as an identifier and that I can't leave the identifier empty

# Answer from Gemini

The reason your mouse cursor freezes when using this rc.xml file comes down to a problematic block inside your <windowRules> section near the bottom:
<windowRules>
    <windowRule identifier="*">
        <action name="Maximize"/>
    </windowRule>
    <windowRule identifier="">
        <action name="ResizeTo" width="" height="" />
        <action name="AutoPlace" policy="automatic" />
    </windowRule>
    <windowRule identifier="" serverDecoration="no"/>
</windowRules>

Why it causes a freeze:
* Universal Maximize (identifier="*"): Telling every single window to force-maximize upon creation causes an aggressive layout loop where every popup, panel layer, dialog, menu, or newly spawned client immediately fights to take up the full screen.
* Malformed Empty Rules (identifier=""): The rules with blank identifiers combined with empty parameters (like <action name="ResizeTo" width="" height="" />) cause parsing failures or endless internal layout calculations within labwc. This overwhelms the Wayland compositor compositor thread, rendering input devices—specifically the mouse cursor—completely unresponsive.
How to Fix It
Replace the entire <windowRules> section at the bottom of your rc.xml with a clean, safe version (or remove it entirely if you don't need automated rules):
    <windowRules>
        <!-- Remove or fix any global wildcards causing infinite loops -->
    </windowRules>

If you want specific rules for certain applications later, make sure you target a valid app ID (e.g., identifier="org.mozilla.firefox"), rather than using * or empty strings with invalid arguments.
Once you update or clear out the <windowRules> block, save the file and restart labwc—your mouse cursor will behave normally again.




1. Purpose of the Window Rules Block
In labwc (and its Openbox heritage), the <windowRules> section is designed to automate window management behaviors based on specific application identifiers or classes.
Just like CSS selectors style web elements, labwc window rules let you target specific windows (using their app ID or title as an identifier) and apply automated actions when those windows are created or mapped. Typical valid use cases include:
* Forcing a specific game or media player to open fullscreen.
* Removing server-side decorations (titlebars/borders) from specific floating panels or floating terminals.
* Automatically assigning certain applications to specific workspaces.
2. Why Your Specific Block Causes a Freeze
Your specific <windowRules> configuration triggers a combination of infinite layout loops, compositor thread starvation, and null-pointer/parsing crashes that lock up input processing:
<windowRules>
    <!-- Rule A: Forces every window to maximize -->
    <windowRule identifier="*">
        <action name="Maximize"/>
    </windowRule>
   
    <!-- Rule B: Empty identifier with broken resize parameters -->
    <windowRule identifier="">
        <action name="ResizeTo" width="" height="" />
        <action name="AutoPlace" policy="automatic" />
    </windowRule>
   
    <!-- Rule C: Malformed syntax / empty identifier with attribute -->
    <windowRule identifier="" serverDecoration="no"/>
</windowRules>

Breakdown of the Failures:
* The Universal Maximize Loop (identifier="*"):
   By telling every single window, popup, tooltip, menu, and internal compositor layer to Maximize upon creation, you trap labwc in a recursive layout loop. When a window maximizes, it triggers geometry changes; labwc tries to enforce the rule again, spawning endless resize/reposition events.
* Invalid Parameter Parsing (width="" height=""):
   The <action name="ResizeTo" width="" height="" /> rule passes completely empty values to the window geometry handler. When labwc attempts to parse a null string into a pixel dimension for rendering, it can cause an internal exception or infinite calculation loop.
* Blank Identifiers (identifier=""):
   Targeting an empty string identifier forces the compositor to evaluate unnamed, unmapped system surfaces or internal pointer elements against invalid actions.
When the Wayland compositor gets flooded by conflicting, recursive maximize commands and invalid layout calculations, its main event loop locks up. Because mouse movement and clicks depend on the compositor processing input events smoothly, a locked event loop results in a completely frozen mouse cursor.