# Dotfiles

Use `./init.sh` to initialize the environment.

## Special steps

Some folders require some extra steps

### aerospace

Before using aerospace for the first time, you should build the config file:

```bash
cd ~/.config/aerospace/
./build.sh
```


### git

If you plan to use the git identities, you should generate the `identities.inc` file:

```bash
cd ~/.config/git
./build_identities.sh
```
