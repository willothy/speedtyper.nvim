# ⌨️ Speedtyper

>Practise typing while bored.

## 📺 Showcase

<p align="center">
  <h4 align="center">⌛ Countdown game mode</h4>
</p>

https://github.com/NStefan002/speedtyper.nvim/assets/100767853/b42ed6ee-648d-4fd8-be4a-e3f3611319ef

<br>

<p align="center">
  <h4 align="center">🌧️ Rain game mode</h4>
</p>

https://github.com/NStefan002/speedtyper.nvim/assets/100767853/e84e05e9-d3f1-4fd1-91d9-4d31b5bef7e7


<!-- _[GIF version](https://github.com/NStefan002/speedtyper.nvim/assets/100767853/207f0573-86f4-4d27-bf58-90d62a1a1b3e)_ -->



   ## ⚡️ Features

- **Different game modes:**
    1) _countdown_ :
        - **Objective:** Type as much words as possible before the time runs out.
        - **Customize Game Duration**
        - **Feedback**: Receive instant updates on your words per minute (WPM) and accuracy.
    2) _stopwatch_ :
        - **Objective:** Type an entire page of text as fast and as accurate as possible.
        - **Feedback**: Receive instant updates on your words per minute (WPM) and accuracy.
    3) _rain_ :
        - **Objective:** Words fall from the top of the screen, type them before they hit the bottom.
        - **Choose the number of lives**
        - **Customize rain speed**

    **Coming soon:** _code snippets_: Enhance your coding speed and accuracy by typing various code snippets.
- **Languages**: Currently only supports English and Serbian.
- **Play Offline**: No need to connect to the internet. <!-- **_Coming soon:_** Online mode with a larger variety of words. -->
- **Distraction-Free Typing**: Temporarily disable [cmp](https://github.com/hrsh7th/nvim-cmp) to focus on the game.


## ✨ Recommended
- [dressing.nvim](https://github.com/stevearc/dressing.nvim)
- patched fonts

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/speedtyper.nvim",
    cmd = "Speedtyper",
    opts = {
    -- your config
    }
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use {
    "NStefan002/speedtyper.nvim",
    config = function()
        require('speedtyper').setup({
            -- your config
        })
    end
}
```

## ⚙ Default configuration

<details>
<summary>Full list of options with their default values</summary>

```lua
{
    window = {
        height = 5, -- integer >= 5 | float in range (0, 1)
        width = 0.55, -- integer | float in range (0, 1)
        border = "rounded", -- "none" | "single" | "double" | "rounded" | "shadow" | "solid"
    },
    language = "en", -- "en" | "sr" currently only only supports English and Serbian
    game_modes = { -- prefered settings for different game modes
        -- type until time expires
        countdown = {
            time = 30,
        },
        -- type until you complete one page
        stopwatch = {
            hide_time = true, -- hide time while typing
        },
        -- NOTE: window height and width will be the same
        rain = {
            throttle = 7, -- increase speed every x seconds
            lives = 3,
        },
    },
}
```

</details>

## 🧰 Commands

|   Command   |         Description        |
|-------------|----------------------------|
|  `:Speedtyper`  | Select the game mode and enjoy playing! |

## 🤝 Contributing

PRs and issues are always welcome.

## ✅☑️ TODO
See _[this](https://github.com/NStefan002/speedtyper.nvim/blob/main/TODO.md)_.

## 🎭 Inspiration

* [monkeytype](https://monkeytype.com/)

## 👀 Checkout similar projects

* **Neovim based:**
    - [duckytype.nvim](https://github.com/kwakzalver/duckytype.nvim)
* **Other:**
    - [SpeedTyper.dev](https://www.speedtyper.dev/)  Somehow I didn't know about this one until the day I made speedtyper.nvim public... My bad 😅
    - [toipe](https://github.com/Samyak2/toipe)
