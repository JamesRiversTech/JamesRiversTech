#!/bin/bash

# SUID Binary Privilege Escalation Scanner
# GTFOBins exploitable binaries embedded - no external file needed
# Educational purposes only - use on systems you own or have permission to test

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

OUTPUT_FILE="vulnerable_suids_$(date +%s).txt"

# GTFOBins exploitable binaries - embedded list
read -r -d '' GTFOBINS_LIST << 'EOF'
aa-exec
ab
agetty
alpine
ar
arj
arp
as
ascii-xfr
ash
aspell
atobm
awk
base32
base64
basenc
basez
bash
bc
bridge
busctl
busybox
bzip2
cabal
capsh
cat
chmod
choom
chown
chroot
clamscan
cmp
column
comm
cp
cpio
cpulimit
csh
csplit
csvtool
cupsfilter
curl
cut
dash
date
dd
debugfs
dialog
diff
dig
distcc
dmsetup
docker
dosbox
ed
efax
elvish
emacs
env
eqn
espeak
expand
expect
file
find
fish
flock
fmt
fold
gawk
gcore
gdb
genie
genisoimage
gimp
grep
gtester
gzip
hd
head
hexdump
highlight
hping3
iconv
install
ionice
ip
ispell
jjs
join
jq
jrunscript
julia
ksh
ksshell
kubectl
ld.so
less
links
logsave
look
lua
make
mawk
minicom
more
mosquitto
msgattrib
msgcat
msgconv
msgfilter
msgmerge
msguniq
multitime
mv
nasm
nawk
ncftp
nft
nice
nl
nm
nmap
node
nohup
ntpdate
od
openssl
openvpn
pandoc
paste
perf
perl
pexec
pg
php
pidstat
pr
ptx
python
rc
readelf
restic
rev
rlwrap
rsync
rtorrent
run-parts
rview
rvim
sash
scanmem
sed
setarch
setfacl
setlock
shuf
soelim
softlimit
sort
sqlite3
ss
ssh-agent
ssh-keygen
ssh-keyscan
sshpass
start-stop-daemon
stdbuf
strace
strings
sysctl
systemctl
tac
tail
taskset
tbl
tclsh
tee
terraform
tftp
tic
time
timeout
troff
ul
unexpand
uniq
unshare
unsquashfs
unzip
update-alternatives
uudecode
uuencode
vagrant
varnishncsa
view
vigr
vim
vimdiff
vipw
w3m
watch
wc
wget
whiptail
xargs
xdotool
xmodmap
xmore
xxd
xz
yash
zsh
zsoelim
EOF

echo -e "${BLUE}[*] SUID Binary Privilege Escalation Scanner${NC}"
echo -e "${BLUE}[*] Scanning system for SUID binaries...${NC}\n"

# Find all SUID binaries and store in array
mapfile -t FOUND_SUIDS < <(find / -type f -perm -4000 2>/dev/null)

# Load GTFOBins list into array
mapfile -t GTFOBINS < <(echo "$GTFOBINS_LIST")

echo -e "${YELLOW}[*] Comparing $(printf '%s\n' "${#FOUND_SUIDS[@]}") SUID binaries against GTFOBins list...${NC}\n"

VULNERABLE_COUNT=0

# For each SUID binary found
for suid_path in "${FOUND_SUIDS[@]}"; do
    # Extract just the binary name
    binary_name=$(basename "$suid_path")
    
    # Check if this binary is in our GTFOBins list
    for gtfo_binary in "${GTFOBINS[@]}"; do
        # Remove any whitespace and compare
        gtfo_binary=$(echo "$gtfo_binary" | xargs)
        
        if [ "$binary_name" = "$gtfo_binary" ]; then
            echo -e "${RED}[!] VULNERABLE: ${NC}$suid_path"
            echo "$suid_path" >> "$OUTPUT_FILE"
            ((VULNERABLE_COUNT++))
            break
        fi
    done
done

echo -e "\n${GREEN}[+] Scan complete!${NC}"
echo -e "${YELLOW}[*] Found $VULNERABLE_COUNT potentially vulnerable SUID binaries${NC}"

if [ $VULNERABLE_COUNT -gt 0 ]; then
    echo -e "${BLUE}[*] Results saved to: $OUTPUT_FILE${NC}\n"
    echo -e "${RED}[!] Vulnerable binaries found:${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    while IFS= read -r vulnerable_path; do
        echo -e "${RED}→ $vulnerable_path${NC}"
    done < "$OUTPUT_FILE"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "${RED}[!] Review these binaries on GTFOBins for exploitation methods${NC}\n"
fi

# Show statistics
TOTAL_SUIDS=${#FOUND_SUIDS[@]}
if [ $TOTAL_SUIDS -gt 0 ]; then
    RISK_PERCENT=$(( (VULNERABLE_COUNT * 100) / TOTAL_SUIDS ))
else
    RISK_PERCENT=0
fi

echo -e "${BLUE}[*] Statistics:${NC}"
echo -e "    Total SUID binaries found: $TOTAL_SUIDS"
echo -e "    Potentially vulnerable: $VULNERABLE_COUNT"
echo -e "    Risk percentage: $RISK_PERCENT%" 
