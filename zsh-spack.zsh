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
    echo $'name\tversion\tcompiler name\tcompiler version\tvariants\tarchitecture\thash'
    spack find --format $'{name}\t{version}\t{compiler.name}\t{compiler.version}\t{variants}\t{arch}\t{hash}' $*
}

_spack-select-tsv() {
    if ! specs=$(_spack-find-avail $*); then
        return 1
    fi
    fzf -d $'\t' --select-1 --header-lines=1 <<< $specs
}

_spack-tsv-spec() {
    while read tsv; do
        local name=$(cut -f1 <<< $tsv)
        local ver=$(cut -f2 <<< $tsv)
        local cname=$(cut -f3 <<< $tsv)
        local cver=$(cut -f4 <<< $tsv)
        local vars=$(cut -f5 <<< $tsv)
        local arch=$(cut -f6 <<< $tsv)
        echo "${name}@${ver}%${cname}@${cver}${vars} arch=${arch}"
    done
}

_spack-tsv-modname() {
    while read tsv; do
        local name=$(cut -f1 <<< $tsv)
        local hash=$(cut -f7 <<< $tsv)
        spack module tcl find "${name}/${hash}"
    done
}

_spack-unload-tsv() {
    while read tsv; do
        local modname=$(_spack-tsv-modname <<< $tsv)
        local spec=$(_spack-tsv-spec <<< $tsv)
        sed -i.bak --follow-symlinks "/^# $spec\$/d" $SPACK_MOD_ENV
        sed -i.bak --follow-symlinks "/^module load $modname\$/d" $SPACK_MOD_ENV
        module unload $modname > /dev/null
        echo "Unloaded module $modname"
    done
}

_spack-load-tsv() {
    while read tsv; do
        local modname=$(_spack-tsv-modname <<< $tsv)
        local spec=$(_spack-tsv-spec <<< $tsv)
        local name=$(cut -f1 <<< $tsv)
        local hash=$(cut -f7 <<< $tsv)
        spack module tcl loads "${name}/${hash}" >> $SPACK_MOD_ENV
        module load $modname > /dev/null
        echo "Loaded module $modname"
    done
}

spack-unload-pkg() {
    _spack-select-tsv $* | _spack-unload-tsv
}

spack-load-pkg() {
    _spack-select-tsv $* | _spack-load-tsv
}

spack-list-loaded() {
    modnames=$(awk "/^module load .+-.+-.+-.+-.+/ {print \$3}" $SPACK_MOD_ENV)
    if [ -z "$modnames"]; then
        return 0
    fi
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
    touch $SPACK_MOD_ENV
fi

alias spma='spack-load-pkg'
alias spmd='spack-unload-pkg'
alias spml='spack-list-loaded'
alias spf='spack find'
alias spl='spack list'
