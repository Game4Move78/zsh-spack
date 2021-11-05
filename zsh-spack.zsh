# zsh-spack -- Functions and aliases for spack
# https://github.com/Game4Move78/zsh-spack

# Copyright (c) 2021 Patrick Lenihan

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

_spack-find-avail() {
    echo $'name\tversion\tcompiler name\tcompiler version\thash'
    local pkgs=$(spack find --explicit --format $'{name}\t{version}\t{compiler.name}\t{compiler.version}\t{hash}')
    grep -i $* <<< $pkgs
}

_spack-select-spec() {
    if ! specs=$(_spack-find-avail $*); then
        return $?
    fi
    fzf -d $'\t' --select-1 --header-lines=1 <<< $specs
}

_spack-unload-spec() {
    local spec=$(< /dev/stdin)
    local name=$(cut -f1 <<< $spec)
    local ver=$(cut -f2 <<< $spec)
    local cname=$(cut -f3 <<< $spec)
    local cver=$(cut -f4 <<< $spec)
    modname=$(awk "/^module load ${name}-${ver}-${cname}-${cver}-/ {print \$3}" $SPACK_MOD_ENV)
    sed -i.bak --follow-symlinks "/^# ${name}@${ver}%${cname}@${cver} .*/d" $SPACK_MOD_ENV
    sed -i.bak --follow-symlinks "/^module load ${name}-${ver}-${cname}-${cver}-.*/d" $SPACK_MOD_ENV
    module unload $modname > -
    echo "Unloaded module $modname"
}

_spack-load-spec() {
    local spec=$(< /dev/stdin)
    local name=$(cut -f1 <<< $spec)
    local ver=$(cut -f2 <<< $spec)
    local cname=$(cut -f3 <<< $spec)
    local cver=$(cut -f4 <<< $spec)
    spack module tcl loads "${name}@${ver}%${cname}@${cver}" >> $SPACK_MOD_ENV
    modname=$(awk "/^module load ${name}-${ver}-${cname}-${cver}-/ {print \$3}" $SPACK_MOD_ENV)
    module load $modname > -
    echo "Loaded module $modname"
}

spack-unload-pkg() {
    _spack-select-spec $* | _spack-unload-spec
}

spack-load-pkg() {
    _spack-select-spec $* | _spack-load-spec
}

spack-list-loaded() {
    modnames=$(awk "/^module load .+-.+-.+-.+-.+/ {print \$3}" $SPACK_MOD_ENV)
    local specs=()
    while read modname; do
        local name=$(cut -d- -f1 <<< $modname)
        local ver=$(cut -d- -f2 <<< $modname)
        local cname=$(cut -d- -f3 <<< $modname)
        local cver=$(cut -d- -f4 <<< $modname)
        specs+=("${name}@${ver}%${cname}@${cver}")
    done <<< $modnames
    echo $(IFS=$'\t' ; echo "${specs[*]}")
}

if [ -z "$SPACK_MOD_ENV" ]; then
    export SPACK_MOD_ENV="$HOME/.zshenv"
fi

alias spma='spack-load-pkg'
alias spmd='spack-unload-pkg'
alias spmd='spack-list-pkg'
alias spf='spack find'
alias spl='spack list'
