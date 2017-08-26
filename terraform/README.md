# Laptop backup

some locations on this laptop are not backed up or synchronized with any other machine.

this brings up some infrastructure in order to:

tar, compress and encrypt

upload to s3

verify backups with hashdeep

# ignoring useless files

most directories end up with many large useless files

how do we ignore these gracefully - just spply the fles we want?

tar -T backup.bento --create -J > bento.tar.xz

gpg --default-key "N550JV (Laptop Backup) <sam@samsquire.com>" --recipient "Restoration (Laptop Restore) <sam@samsquire.com>" --encrypt backup.tar.xz

#

"bento package-files" -> runs tree -L 1, you put an "i" or "x" for files you want or not

then run tree -L 2 with the file inclusions/exclusions applied and repeat the exercise

result is a list of files that should be backed up

hash, tar, compress the files
upload to s3
test the package

