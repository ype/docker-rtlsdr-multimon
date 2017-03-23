# Mutlimon-ng in Docker

[ype/docker-rtlsdr-multimon](https://github.com/ype/docker-rtlsdr-multimon) is a docker container for multimon-ng. Multimon-ng is a tool for decoding the following digital transmission modes:

- POCSAG512, POCSAG1200, POCSAG2400
- FLEX
- EAS
- UFSK1200, CLIPFSK, AFSK1200, AFSK2400, AFSK2400_2, AFSK2400_3
- HAPN4800
- FSK9600
- DTMF
- ZVEI1, ZVEI2, ZVEI3, DZVEI, PZVEI
- EEA, EIA, CCIR
- MORSE, CW

see [EliasOenal/multimon-ng](https://github.com/EliasOenal/multimon-ng) for multimon-ng repository

## Build image manually

To build your own version do the follow:

```
git clone https://github.com/ype/docker-rtlsdr-multimon
cd docker-rtlsdr-multimon

docker build -t name_you_want/for_your_docker_image ./Dockerfile
```

## Pull prebuilt image

```
docker pull envoi/docker-rtlsdr-multimon
```

# Running

## Show multimon-ng help and delete container

```
docker run -it --rm --name docker-rtlsdr-multimon --device=/dev/bus/usb envoi/docker-rtlsdr-multimon multimon-ng -h
```

## A basic example

Launch container with bash console

```
docker run -it --name docker-rtlsdr-multimon --device=/dev/bus/usb envoi/docker-rtlsdr-multimon /bin/bash
## opt: remove container on exit
### docker run --rm -it --name docker-rtlsdr-multimon --device=/dev/bus/usb envoi/docker-rtlsdr-multimon /bin/bash
## opt: add -p host_port:80 or uncomment command show below to enable viewing of logs using lighttpd
### docker run -it -p 8080:80 --name docker-rtlsdr-multimon --device=/dev/bus/usb envoi/docker-rtlsdr-multimon /bin/bash
```

### Once inside the container

Here are some example commands you could run if you feel like it.

#### Setting rtl_fm frequency to a variable

```
FREQ="$(echo -e '153.35M')"
rtl_fm -f "$FREQ" -s 22050 | ...

### OR
#### FREQ_RANGE="$(echo -e '153.0M:154.0M:12k')"
### rtl_fm -f "$FREQ_RANGE" -s 22050 | ...
```

```
# the *M* following the below value of 153.35 denotes Megahertz [MHz]
FREQ="153.35M"

DATETIMESTAMP="$(date '+%F_%H%M%S')"

rtl_fm -f "$FREQ" -s 22050 2>/var/www/pager/"$DATETIMESTAMP"_rtl_fm-multimon_stderr.log \
	| multimon-ng -t raw -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -a FLEX -f alpha /dev/stdin \
		1>>/var/www/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt \
		2>>/var/www/pager/"$DATETIMESTAMP"_rtl_fm-multimon_stderr.log &
```

## VIEWING OUTPUT

### LOCAL: In Container

From inside your container you can simply use the `tail` or `more` commands to view multimon's output

To watch the last 200 lines of output from multimon in realtime, you can use:

```
tail -200f /var/www/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt
```

Or if you feel like paging through all the output generated thus far (*defn* paging is a bash term for moving through text file one line at a time using a 'terminal pager')

```
more /var/www/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt
```

### REMOTE: in Browser
view from browser using lighttpd to serve http://host_ip:8080/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt *note: host_ip is the machine running docker*


```
/etc/init.d/lighttpd restart
```

navigate to http://host_ip:8080/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt in your browser of choice

### REMOTE: while loop of curl magicness

do some curl magic and watch the data pour in remotely

```
while true; do
	clear;
	curl -sL 'http://192.168.0.21:8080/pager/"$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".txt' \
		| tail -15f; # `-15f` tells `tail` to show the last 15 lines from output
	sleep 30;
done
```

### Further Reading

#### Base Image used for docker-rtlsdr-dump1090
For further details about the image in this repo, see [ype/docker-rtlsdr-base](https://github.com/ype/docker-rtlsdr-base), which is the base docker image used for docker-rtlsdr-dump1090.
