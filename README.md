# NoMacroBars

A simple Ashita v4 addon that prevents the default game macro bars (macro palettes) from appearing when holding down the **Ctrl** or **Alt** keys.

## Purpose

This is particularly useful when using the **tHotBar** addon (or similar custom UI replacements), as it prevents the default UI from overlapping with your custom bars, creating a cleaner interface.

## How it works

It patches specific memory addresses that determine if the macro bar should be visible based on key hold duration, effectively forcing the game to think the keys haven't been held long enough to trigger the display. 

## Installation

Place the `nomacrobars` folder into your Ashita `addons` directory and load it via the Ashita launcher or by typing `/addon load nomacrobars` in-game.

## Notes

This addon is not compatible with the `macrofix` addon, as they both attempt to patch the same memory addresses. If you are using `macrofix`, you should disable the `nomacrobars` addon.
