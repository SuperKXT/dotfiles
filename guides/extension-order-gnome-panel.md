# Changing the order and placement of extensions in Gnome Panel

-   go to `~/.local/share/gnome-shell/extensions/{{extension_id}}`
-   open up `extension.js` in a text editor
-   find `addToStatusArea` and change the arguments to include positions

```ts
	// Ignore the first two arguments. Add `position` and `placement` if missing
	addToStatusArea(_, _, position: number, placement: ‘left’ | ‘right’)
```
