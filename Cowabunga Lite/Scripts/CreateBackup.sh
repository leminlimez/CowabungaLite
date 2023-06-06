#!/bin/sh

# Rory Madden 2023

if [ $# -ne 2 ]; then
	echo "Usage: $0 <indir> <outdir>"
	exit 1
fi

if [ ! -d "$1" ]; then
	echo "$1 is not a directory"
	exit 1
fi

rm -rf "$2"
mkdir -p "$2"

# NOTE: Manifest.mbdb tracks the locations and SHA1 hashes of each file in the backup
output_file="$2/Manifest.mbdb"

# Manifest.mbdb file header
printf 'mbdb\x05\x00' >>$output_file

for domain in "$1"/*; do
	if [ -d "$domain" ]; then
		justDomain=$(printf %s $(basename "$domain"))

		find "$domain" ! -name ".*" | while read file; do
			path=${file#$domain/}
			path=${path#$domain}
			path2=$(printf "%s" "$path" | sed 's/ConfigProfileDomain/SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles/g')
            pathFixed=$(printf "%s" "$path2" | sed 's/hiddendot/./g')

			# Write domain name string to Manifest.mbdb
			printf "%04x" $(printf "$justDomain" | wc -c) | xxd -r -p >>$output_file
			printf "$justDomain" >>$output_file

			printf "Domain: %s, Path: %s" $justDomain ${pathFixed:-N/A}

			# Write path string to Manifest.mbdb
			printf "%04x" $(printf "$pathFixed" | wc -c) | xxd -r -p >>$output_file
			printf "$pathFixed" >>$output_file

			if [ -f "$file" ]; then
				printf "FFFF0014" | xxd -r -p >>$output_file
				# Write file hash to Manifest.mbdb
				fileHash=$(shasum "$file" | awk '{print $1}')
				printf $fileHash | xxd -r -p >>$output_file
				printf "FFFF81FF0000000000000000000001F5000001F5" | xxd -r -p >>$output_file
				printf "%08x%08x%08x" $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM | xxd -r -p >>$output_file
                if [-n "$WINDIR"]; then
                    printf "%016x" $(stat --format %s "$file") | xxd -r -p >>$output_file
                else
                    printf "%016x" $(stat -f %z "$file") | xxd -r -p >>$output_file
                fi
				printf "0400" | xxd -r -p >>$output_file

				printf " - written structure to Manifest.mbdb"

				# Rename file to its domain-path hash
				hash=$(printf "$justDomain-$pathFixed" | shasum | awk '{print $1}')
				newfile="$2/$hash"
				cp "$file" "$newfile"

				printf ", copied and renamed file to hash\n"
			elif [ -d "$file" ]; then
				printf "FFFFFFFFFFFF41FF0000000000000000000001F5000001F5" | xxd -r -p >>$output_file
				printf "%08x%08x%08x" $RANDOM$RANDOM $RANDOM$RANDOM $RANDOM$RANDOM | xxd -r -p >>$output_file
				printf "000000000000" | xxd -r -p >>$output_file
				printf "00000400" | xxd -r -p >>$output_file

				printf " - written structure to Manifest.mbdb\n"
			fi
		done
	fi
done

# Generate remaining files

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>' >$2/Info.plist

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BackupState</key>
	<string>new</string>
	<key>Date</key>
	<date>1970-01-01T00:00:00Z</date>
	<key>IsFullBackup</key>
	<false/>
	<key>SnapshotState</key>
	<string>finished</string>
	<key>UUID</key>
	<string>00000000-0000-0000-0000-000000000000</string>
	<key>Version</key>
	<string>2.4</string>
</dict>
</plist>' >$2/Status.plist

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BackupKeyBag</key>
	<data>
	VkVSUwAAAAQAAAAFVFlQRQAAAAQAAAABVVVJRAAAABDud41d1b9NBICR1BH9JfVtSE1D
	SwAAACgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAV1JBUAAA
	AAQAAAAAU0FMVAAAABRY5Ne2bthGQ5rf4O3gikep1e6tZUlURVIAAAAEAAAnEFVVSUQA
	AAAQB7R8awiGR9aba1UuVahGPENMQVMAAAAEAAAAAVdSQVAAAAAEAAAAAktUWVAAAAAE
	AAAAAFdQS1kAAAAoN3kQAJloFg+ukEUY+v5P+dhc/Welw/oucsyS40UBh67ZHef5ZMk9
	UVVVSUQAAAAQgd0cg0hSTgaxR3PVUbcEkUNMQVMAAAAEAAAAAldSQVAAAAAEAAAAAktU
	WVAAAAAEAAAAAFdQS1kAAAAoMiQTXx0SJlyrGJzdKZQ+SfL124w+2Tf/3d1R2i9yNj9z
	ZCHNJhnorVVVSUQAAAAQf7JFQiBOS12JDD7qwKNTSkNMQVMAAAAEAAAAA1dSQVAAAAAE
	AAAAAktUWVAAAAAEAAAAAFdQS1kAAAAoSEelorROJA46ZUdwDHhMKiRguQyqHukotrxh
	jIfqiZ5ESBXX9txi51VVSUQAAAAQfF0G/837QLq01xH9+66vx0NMQVMAAAAEAAAABFdS
	QVAAAAAEAAAAAktUWVAAAAAEAAAAAFdQS1kAAAAol0BvFhd5bu4Hr75XqzNf4g0fMqZA
	ie6OxI+x/pgm6Y95XW17N+ZIDVVVSUQAAAAQimkT2dp1QeadMu1KhJKNTUNMQVMAAAAE
	AAAABVdSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAo2N2DZarQ6GPoWRgTiy/t
	djKArOqTaH0tPSG9KLbIjGTOcLodhx23xFVVSUQAAAAQQV37JVZHQFiKpoNiGmT6+ENM
	QVMAAAAEAAAABldSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAofe2QSvDC2cV7
	Etk4fSBbgqDx5ne/z1VHwmJ6NdVrTyWi80Sy869DM1VVSUQAAAAQFzkdH+VgSOmTj3yE
	cfWmMUNMQVMAAAAEAAAAB1dSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAo7kLY
	PQ/DnHBERGpaz37eyntIX/XzovsS0mpHW3SoHvrb9RBgOB+WblVVSUQAAAAQEBpgKOz9
	Tni8F9kmSXd0sENMQVMAAAAEAAAACFdSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kA
	AAAo5mxVoyNFgPMzphYhm1VG8Fhsin/xX+r6mCd9gByF5SxeolAIT/ICF1VVSUQAAAAQ
	rfKB2uPSQtWh82yx6w4BoUNMQVMAAAAEAAAACVdSQVAAAAAEAAAAA0tUWVAAAAAEAAAA
	AFdQS1kAAAAo5iayZBwcRa1c1MMx7vh6lOYux3oDI/bdxFCW1WHCQR/Ub1MOv+QaYFVV
	SUQAAAAQiLXvK3qvQza/mea5inss/0NMQVMAAAAEAAAACldSQVAAAAAEAAAAA0tUWVAA
	AAAEAAAAAFdQS1kAAAAoD2wHX7KriEe1E31z7SQ7/+AVymcpARMYnQgegtZD0Mq2U55u
	xwNr2FVVSUQAAAAQ/Q9feZxLS++qSe/a4emRRENMQVMAAAAEAAAAC1dSQVAAAAAEAAAA
	A0tUWVAAAAAEAAAAAFdQS1kAAAAocYda2jyYzzSKggRPw/qgh6QPESlkZedgDUKpTr4Z
	Z8FDgd7YoALY1g==
	</data>
	<key>Lockdown</key>
	<dict/>
	<key>SystemDomainsVersion</key>
	<string>20.0</string>
	<key>Version</key>
	<string>9.1</string>
</dict>
</plist>' >$2/Manifest.plist
