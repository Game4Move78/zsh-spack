# Requirements

The following should be installed and on your PATH

1. [fzf](https://github.com/junegunn/fzf) for selecting from multiple items

# Installation

## Oh My Zsh

1. Clone this repository into `$ZSH_CUSTOM/plugins` (by default `~/.oh-my-zsh/custom/plugins`)

    ```sh
    git clone https://github.com/Game4Move78/zsh-spack ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-spack
    ```

2. Add the plugin to the list of plugins for Oh My Zsh to load (inside `~/.zshrc`):

    ```sh
    plugins=( 
        # other plugins...
        zsh-spack
    )
    ```
