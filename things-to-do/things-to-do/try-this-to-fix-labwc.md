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