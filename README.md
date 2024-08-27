# grvl

dual data pavement. 

a digital tape machine – joyfully abandoning transparency. recorded sound is treated as raw, unadulterated data (like loose sediment), subject to multiple layers of erosion in the time & amplitude domains, clicks & all. you might hate it.

a spiritual successor to [anaphora](https://github.com/andr-ew/prosody#anaphora) & [dirge](https://github.com/andr-ew/prosody#dirge), a strange cousin of [ndls](https://github.com/andr-ew/ndls)

**! explore with care !** loud sounds may result from multiple extreme settings.

## hardware

**required**

- [norns](https://github.com/p3r7/awesome-monome-norns)

**also supported**

- [grid](https://monome.org/docs/grid/) (128 or 64)
- arc (2 or 4 rings)
- [crow](https://monome.org/docs/crow/)
- midi mapping

## install

in the maiden [REPL](https://monome.org/docs/norns/image/wifi_maiden-images/install-repl.png), type:

```
;install https://github.com/andr-ew/grvl/releases/download/latest/complete-source-code.zip
```

## grid UI

![diagram of the grid interface. text description forthcoming](/lib/doc/grvl_grid.png)

## norns UI

- E1: page/channel focus
- E2-E3: various
- K2-K3: record, hold to clear
- K1 (hold): survey

## arc UI

| ch 1   | ch 1     | ch 2   | ch 2     |
| ------ | -------- | ------ | -------- |
| lvl    | old      | lvl    | old      |
| pm frq | pm depth | pm frq | pm depth |
| start  | end      | start  | end      |
| end    | rate     | end    | rate     |

horizontal & vertical orientation via arc focus component, hold two keys to flip

## patcher

grvl has 4 modulation sources that can be patched to any parameter on grid, norns, or arc. to map a parameter, hold one of the four source keys on the grid and tap or turn your desired destination.

possible modulation sources are:
 - crow input 1/2
 - lfo 1/2
 - midi note

by default, the sources are set as follows, and can be re-assigned in the params menu:
- **source 1:** crow in 1
- **source 2:** crow in 2
- **source 3:** lfo 1
- **source 4:** lfo 2
