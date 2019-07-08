#!/bin/bash
#
# This script backups an OS X system to an external volume, effectively
# cloning it. It is based on [0], [1] and [2] for OS X and [3] and [4] for
# Linux. One could also use commercial tools like SuperDuper! or Carbon Copy
# Cloner. The latter website has an interesting list[5] on what files to
# exclude when cloning.
#
# Exclusions (from CCC[5]), see rsync_excludes_osx.txt
#
# rsync(1) flags used / not used:
#
# included in --archive:
#
# --recursive: traverse all directories
# --links: keep symlinks
# --perms: preserve perms
# --times: preserve mod times
# --owner: preserve owner (super-user only)
# --group: preserve group
# --devices: preserve device files (super-user only)
# --specials: preserve special files
#
# also preserve:
#
# --hard-links: preserve hard links (this is expensive?)
# --fileflags: preserve file-flags
# --acls: preserve ACLs (implies --perms)
# --xattrs: preserve extended attributes
# --hfs-compression: preserve HFS compression if supported
# --protect-decmpfs: preserve HFS compression as xattrs
# --crtimes: preserve create times (newness)
#
# and fix performance/consistency:
#
# --one-file-system: don't cross FSs
# --delete: delete extraneous files from destination dirs
# --progress: show progress
# --inplace: faster for local  <http://superuser.com/questions/109780/how-to-speed-up-rsync>
#
# do not use:
#
# --executability: preserve executability (included in --perms)
# --relative: ???
# --update: don't use update because we don't expect newer files on destination
# --numeric-ids: should we or not???
#
# Sources:
# [0] https://gist.github.com/1145450
# [1] http://rajeev.name/2008/09/01/automated-osx-backups-with-launchd-and-rsync/
# [2] http://nicolasgallagher.com/mac-osx-bootable-backup-drive-with-rsync/
# [3] https://wiki.archlinux.org/index.php/Full_System_Backup_with_rsync
# [4] http://xpt.sourceforge.net/techdocs/nix/disk/general/disk16-CloneOrBackupDisks/single/
# [5] http://help.bombich.com/kb/explore/some-files-and-folders-are-automatically-excluded-from-a-backup-task

PROG=$0

# Set tool paths
RSYNC=/usr/local/bin/rsync
MOUNT=/sbin/mount
BASENAME=/usr/bin/basename
AWK=/usr/bin/awk
GREP=/usr/bin/grep
DF=/bin/df
TAIL=/usr/bin/tail
TIME=/usr/bin/time
SLEEP=/bin/sleep
ECHO=/bin/echo
# Mac OS X programs
TMUTIL=/usr/bin/tmutil
BLESS=/usr/sbin/bless


# Set backup targets
SRC="/"
DST="/Volumes/Backup/"
RSYNC_EXC="$HOME/.backupignore"

# Check if $SRC is readable and $DST is writeable
if [ ! -r "$SRC" ]; then
 ${ECHO} "$PROG: Source '$SRC' not readable - Cannot start the sync process"
 exit;
fi
if [ ! -w "$DST" ]; then
 ${ECHO} "$PROG: Destination '$DST' not writeable - Cannot start the sync process"
 exit;
fi

# Check if destination is in output of mount(2), because it should be an
# external disk
DSTBASE=$(${BASENAME} "${DST}")
DISKID=$(${MOUNT} | ${GREP} "${DSTBASE}" | ${AWK} '{print$1}')
if [ ! "${DSTBASE}" -o ! "${DISKID}" ]; then
 ${ECHO} "$PROG: Destination '$DST' not found in mount(2) - are you sure this is an external disk?"
 exit;
fi

# Check if df -k $DST output is unequal to df -k / output
# From <http://stackoverflow.com/questions/8110530/check-disk-space-for-current-directory-in-bash>
DFDST=$(${DF} -k "${DST}" | ${TAIL} -n 1)
DFSRC=$(${DF} -k "${SRC}" | ${TAIL} -n 1)
DFROOT=$(${DF} -k / | ${TAIL} -n 1)
if [ "${DFDST}" = "${DFSRC}" ]; then
 ${ECHO} "$PROG: Destination and source seem to be on the same disk, aborting..."
 exit;
fi
if [ "${DFDST}" = "${DFROOT}" ]; then
 ${ECHO} "$PROG: Destination is same on same disk as /? aborting..."
 exit;
fi

# User should be root
if [ $USER != "root" ]; then
  ${ECHO} "$PROG: Should be run as root - Cannot start the sync process"
  exit;
fi

if [ -x ${TMUTIL} ]; then
  # Shutdown time machine if it's running
  ${ECHO} "$PROG: Temporarily disabling Time Machine"
  ${TMUTIL} disable
fi

${ECHO} "$PROG: everything ok! Running backup from '$SRC' to '$DST' in 1 second..."
${SLEEP} 1

# Extra verbosity flags, if required
VRBFLAGS=" --dry-run -v --progress "
VRBFLAGS=" -v --progress "

# Run backup
${TIME} ${RSYNC} \
  ${VRBFLAGS} \
  --archive \
  --hard-links \
  --fileflags \
  --acls \
  --hfs-compression \
  --protect-decmpfs \
  --crtimes \
  --one-file-system \
  --delete \
  --inplace \
  --exclude-from="${RSYNC_EXC}" "${SRC}" "${DST}"

${ECHO} "$PROG: backup completed"

if [ -x ${TMUTIL} ]; then
  # Re-enable time machine
  ${ECHO} "$PROG: Re-enabling Time Machine"
  ${TMUTIL} enable
fi

if [ -x ${BLESS} -a -e "${DST}"/System/Library/CoreServices ]; then
  # Make the backup bootable
  ${BLESS} -folder "${DST}"/System/Library/CoreServices
fi

exit 0
