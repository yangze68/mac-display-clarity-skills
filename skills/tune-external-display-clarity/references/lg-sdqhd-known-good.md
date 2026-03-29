# LG SDQHD Known Good

This reference captures the verified working case from this workspace.

## Target Display

- Name: `LG SDQHD`
- Vendor ID: `7789`
- Product ID: `23542`
- Vendor ID hex: `1e6d`
- Product ID hex: `5bf6`

## Native Panel Characteristics

- Native resolution: `2560x2880`
- Desired apparent mode: `1600x1800`
- Desired scale: `2`
- Desired refresh rate: `60Hz`
- Desired depth: `8`

## Important Files

- Override:
  `/Library/Displays/Contents/Resources/Overrides/DisplayVendorID-1e6d/DisplayProductID-5bf6`
- Global gate:
  `/Library/Preferences/com.apple.windowserver.plist`
- System current-mode store:
  `/Library/Preferences/com.apple.windowserver.displays.plist`
- User current-mode store:
  `~/Library/Preferences/ByHost/com.apple.windowserver.displays.*.plist`

## Verified Override Payload

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>DisplayProductID</key>
	<integer>23542</integer>
	<key>DisplayVendorID</key>
	<integer>7789</integer>
	<key>scale-resolutions</key>
	<array>
		<data>AAALQAAAC0A=</data>
		<data>AAAWgAAAFoA=</data>
		<data>AAAWgAAAFoAAAAAJACAAAA==</data>
	</array>
</dict>
</plist>
```

## Verified Active Mode Fields

For the correct LG SDQHD display UUID inside `windowserver.displays`, the working mode used these values:

- `Wide = 1600`
- `High = 1800`
- `Scale = 2`
- `Hz = 60`
- `Depth = 8`
- `IsLink = false`
- `IsVRR = false`

## Practical Lesson

In this case, the override file by itself was not enough.

The display only looked right after the target UUID inside `windowserver.displays` also matched the desired mode.
