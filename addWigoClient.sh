#!/bin/sh
SERVERGROUP='unset'
while getopts g: option
do
    case "${option}"
        in
        g) SERVERGROUP=${OPTARG};;
    esac
done

echo "My server Group : $SERVERGROUP"

RELEASE=''
if grep --quiet jessie /etc/os-release ; then
    RELEASE='jessie'
elif grep --quiet stretch /etc/os-release ; then
    RELEASE='stretch'
else
    echo "Script not implemeted for this release..."
    cat /etc/os-release
    exit
fi

echo "Working on '$RELEASE' release ..."

PRIVATEIP=0
if nc -z 192.168.10.23 4001 ; then
    PRIVATEIP=1
    echo "Test TCP 192.168.10.23 PORT 4001 => OK"
elif nc -z wigo.virtual-dark.com 4001 ; then
    echo "Test TCP wigo.virtual-dark.com PORT 4001 => OK"
    PRIVATEIP=0
else
    echo "Don't found wigo server..."
    exit
fi

echo "Private ip mode : $PRIVATEIP"

echo "Apt update ..."
export DEBIAN_FRONTEND=noninteractive; apt-get -y --force-yes update


if [ $PRIVATEIP -eq 1 ] ; then
    echo "Update /etc/hosts..."
    grep -q ' wigo.virtual-dark.com' /etc/hosts || echo '192.168.10.23     wigo.virtual-dark.com' >> /etc/hosts
fi

if [ "$RELEASE" = "jessie" ]; then
    echo "Add debian depot for jessie..."
    echo "deb http://deb.carsso.com jessie main" > /etc/apt/sources.list.d/deb.carsso.com.list
    wget -O- http://deb.carsso.com/deb.carsso.com.key | apt-key add -
elif [ "$RELEASE" = "stretch" ]; then
    echo "Add debian depot for stretch..."
    echo "deb http://deb.carsso.com stretch main" > /etc/apt/sources.list.d/deb.carsso.com.list
    wget -O- http://deb.carsso.com/deb.carsso.com.key | apt-key add -
fi

sleep 1
echo "Apt update ..."
export DEBIAN_FRONTEND=noninteractive; apt-get -y --force-yes update


sleep 1
echo "Apt install wigo curl ..."
export DEBIAN_FRONTEND=noninteractive; apt-get -o Dpkg::Options::="--force-confnew" -y --force-yes install wigo curl ntpdate aptitude

sleep 1
echo "Apt upgrade ..."
export DEBIAN_FRONTEND=noninteractive; aptitude safe-upgrade -y


sleep 1
if crontab -l | grep --quiet 'ntp.ovh.net' ; then
    echo "Crontab for ntp.ovh.net already update..."
else
    echo "Add crontab for ntp.ovh.net ..."
    (crontab -l 2>/dev/null; echo "* * * * * /usr/sbin/ntpdate ntp.ovh.net") | crontab -
fi

sleep 1
echo "Add master crt ..."
echo 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZFakNDQXZxZ0F3SUJBZ0lRQmthK3E1WndE
alNaY3RCZ29ZWEVTVEFOQmdrcWhraUc5dzBCQVFzRkFEQVgKTVJVd0V3WURWUVFLREF4M2FXZHZR
SEp2YjNRdVoyY3dIaGNOTVRjd056RTBNREF4TnpFM1doY05NamN3TnpFeQpNREF4TnpFM1dqQVhN
UlV3RXdZRFZRUUtEQXgzYVdkdlFISnZiM1F1WjJjd2dnSWlNQTBHQ1NxR1NJYjNEUUVCCkFRVUFB
NElDRHdBd2dnSUtBb0lDQVFDYmlqQjh1RHVzb3ZLNmxOODBiWHREQ2lqVnFQMGw1T2N6UjJsb2N1
Y1gKRUsveHNuT3o3ZnBxYVN4bjB2RHVhME5xRlgrWjNPdWxCTDRBblhmNWdVL29ROXZmY0NDeVdy
NHVlaWJ5NlB3Zgp1Snc3WUtJaU9MY2QyYnB1bXBqbXdVamVmOEVaYzVEaUdpcEVJOUZzTVQydVFM
djVLaGRpaWxSaFJnYVZZWlg0CmkzS2NOcFAzekE5MG5oV0F0QTJPVzlSb1g3LzFBcHJETHE0VmY2
Tk8zOTNPZG4zL1JMYzVaSFV0cmNJNzVpRFkKdnQxWERyNnE0cVZWaWVwUDAwUGgzdlNsY2VYQ3JC
K212S0plQzlDanU3TlJQUndlV2ZZWWwra0dkYXVWcm0rdApMbXRVT0djVkRXUEN2aHI1V1NqTTBo
elpwNUdrQXFobGF3MEdiU0lsOURsS1JIdnBNSjdSNHYyWDJBZlVVeHByClN2dThmL3pKbUJZTExT
SmcvcEJUaHI5NkFIRzZvUk52UUdpTjB6UHNQNVYzMlY0QXNQdkJ4ZWJPYStqV2RIRkgKK1FKNGp2
MXhGdlhhbTZ2aFJhNzUvalpyVU0wN3pzRkFOWFFud0gzOENZSEk4dkthTGRxUm5uZVBuZ29pSjVv
Qgo5SitPa05HdmlYeUZmait2WDhRMnZaVjQwa1dwajhYTUNBY0JWSDJGZ0RCS0tQY2VWd0kya1hJ
ODBGV1BMMmdXCjgyZWcxTE5PVG0xUmhTWkZYczcxalR2bkI0TVdpa2tWaU9CT2NhcEVqQktjYmZz
WTQ5WGVGdUt6R0o5R3FJZDgKb0pSRFhhK1FQQmlKRXZIek5QWmlPMjVEMXVDQUIzMnpKaG4yak5S
WkR4a2IyVnQ1NHF4V1c1NWtvSzJIWEtXdgoxUUlEQVFBQm8xb3dXREFPQmdOVkhROEJBZjhFQkFN
Q0FxUXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd0V3CkR3WURWUjBUQVFIL0JBVXdBd0VCL3pB
Z0JnTlZIUkVFR1RBWGdoVjNhV2R2TG5acGNuUjFZV3d0WkdGeWF5NWoKYjIwd0RRWUpLb1pJaHZj
TkFRRUxCUUFEZ2dJQkFFNTlKSkgzbHpVRzFnZWhPeEFYdkhXcWxwdGIxdzNNNTRXbwpyaHZsUGs3
N0lXSHJlLzhlem5pU1VYMlg3b1Z6SktZNVY3REJmQUk0YnhCSXhxbzNnSzVtZ2ZORHFucEtzQmpz
CkJrMEpCTitqM0MvRDJqY3hSWnJMMlkxb2M1cWxGZzV2c3BtTmE5NVB5eGNXZ2M3cVRLend0SkRN
Y3JUR05uQ1cKbS9hUkd1Qlozcm9OdC9pbHRTbHpDbDJRQzBTckZZNjQ5RE5SbEZZSlgzNk5jNWp4
SVhMSEV1Y096Nk5qbzY2TApVVzNrL0xPaGpiUzJsR1ByRzFxK1Y1TVpUOG05SHpPMHFYUm5ZektU
WjNwSEN2N1JPUFExUTQ0QWtrMnJYek5tCnFWdlV0bDlhNjBZTmgxbUd5d3ZIaWFUT1NBU0RlWXdz
ZERXdm03V2FRcnpKcTFZL2Q3bnF3cGREZWhFdU9BemkKd1dqenFUR3IxeW1PaHNrZFFCRm9yZ2ND
bGhjaVordCtnZGM4ZGYxUk41TXhIVDYzeG5vdC81cUMwNTlYa29FZgpzZ0FZbWcvSlIwenEyVm45
Rk9BRm5ZNVZ1ZHlsWjhaRmMxSkF1STJzaTJQYXhEY1BzaGVxTzNwQTE3U3A0OHVHCm0xYU5NS3c4
UWlZWFZTakROZDl0cCsxV3JWRWZmMWtVbm5zaG85NkpFMHJTeEpyak5jUnNjRDdGYWozOFRHdGsK
UVEwekl6RGd5cTRTd1o0WHJENXBwcjlBR281S3MxMXMrTDVjajc0SEJyMlNFd3JSMDlJRnFOdXoz
eEVXSHN3VwpaaC8rNGhxNXRkWkQxa1JrcWtJYmg3K2VCZFBUdHp3TURaazZCYzkzK1dBNzUrYWg4
NXR1dFE3RXJNWjROODFDCjc2Mjhwc1V4Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K' | base64 --decode > /var/lib/wigo/master.crt


echo "Add wigo config ..."
echo 'IwojIyBXaGF0IElzIEdvaW5nIE9uCiMKCiMgR2VuZXJhbCBwYXJhbWV0ZXJzCiMKIyBMaXN0ZW5B
ZGRyZXNzICAgICAgICAgICAgIC0+IEFkZHJlc3Mgb24gd2hpY2ggd2lnbyB3aWxsIGxpc3Rlbgoj
IExpc3RlblBvcnQgICAgICAgICAgICAgICAgLT4gUG9ydCBvbiB3aGljaCB3aWdvIHdpbGwgbGlz
dGVuCiMgR3JvdXAgICAgICAgICAgICAgICAgICAgICAtPiBHcm91cCBvZiBjdXJyZW50IG1hY2hp
bmUgKHdlYnNlcnZlciwgbG9hZGJhbGFuY2VyLC4uLikuCiMgQWxpdmVUaW1lb3V0ICAgICAgICAg
ICAgICAtPiBOdW1iZXIgb2Ygc2Vjb25kcyBiZWZvcmUgc2V0dGluZyByZW1vdGUgd2lnbyBpbiBl
cnJvciAKIyAgICAgICAgICAgICAgICAgICAgICAgICAgIElmIHByb3ZpZGVkLCBhIHRhZyBncm91
cCB3aWxsIGJlIGFkZGVkIG9uIE9wZW5UU0RCIHB1dHMKIwpbR2xvYmFsXQpIb3N0bmFtZSAgICAg
ICAgICAgICAgICAgICAgPSAiUExJSyIKR3JvdXAgICAgICAgICAgICAgICAgICAgICAgID0gIiIK
TG9nRmlsZSAgICAgICAgICAgICAgICAgICAgID0gIi92YXIvbG9nL3dpZ28ubG9nIgpQcm9iZXNE
aXJlY3RvcnkgICAgICAgICAgICAgPSAiL3Vzci9sb2NhbC93aWdvL3Byb2JlcyIKUHJvYmVzQ29u
ZmlnRGlyZWN0b3J5ICAgICAgID0gIi9ldGMvd2lnby9jb25mLmQiClV1aWRGaWxlICAgICAgICAg
ICAgICAgICAgICA9ICIvdmFyL2xpYi93aWdvL3V1aWQiCkRhdGFiYXNlICAgICAgICAgICAgICAg
ICAgICA9ICIvdmFyL2xpYi93aWdvL3dpZ28uZGIiCkFsaXZlVGltZW91dCAgICAgICAgICAgICAg
ICA9IDYwCkRlYnVnICAgICAgICAgICAgICAgICAgICAgICA9IGZhbHNlCgpbSHR0cF0KRW5hYmxl
ZCAgICAgICAgICAgICAgICAgICAgID0gZmFsc2UKQWRkcmVzcyAgICAgICAgICAgICAgICAgICAg
ID0gIjAuMC4wLjAiClBvcnQgICAgICAgICAgICAgICAgICAgICAgICA9IDQwMDAKU3NsRW5hYmxl
ZCAgICAgICAgICAgICAgICAgID0gZmFsc2UKU3NsQ2VydCAgICAgICAgICAgICAgICAgICAgID0g
Ii9ldGMvd2lnby9zc2wvaHR0cC5jcnQiClNzbEtleSAgICAgICAgICAgICAgICAgICAgICA9ICIv
ZXRjL3dpZ28vc3NsL2h0dHAua2V5IgpMb2dpbiAgICAgICAgICAgICAgICAgICAgICAgPSAiIgpQ
YXNzd29yZCAgICAgICAgICAgICAgICAgICAgPSAiIgoKW1B1c2hTZXJ2ZXJdCkVuYWJsZWQgICAg
ICAgICAgICAgICAgICAgICA9IGZhbHNlCkFkZHJlc3MgICAgICAgICAgICAgICAgICAgICA9ICIw
LjAuMC4wIgpQb3J0ICAgICAgICAgICAgICAgICAgICAgICAgPSA0MDAxClNzbEVuYWJsZWQgICAg
ICAgICAgICAgICAgICA9IHRydWUKU3NsQ2VydCAgICAgICAgICAgICAgICAgICAgID0gIi9ldGMv
d2lnby9zc2wvd2lnby5jcnQiClNzbEtleSAgICAgICAgICAgICAgICAgICAgICA9ICIvZXRjL3dp
Z28vc3NsL3dpZ28ua2V5IgpBbGxvd2VkQ2xpZW50c0ZpbGUgICAgICAgICAgPSAiL3Zhci9saWIv
d2lnby9hbGxvd2VkX2NsaWVudHMiCkF1dG9BY2NlcHRDbGllbnRzICAgICAgICAgICA9IGZhbHNl
CgpbUHVzaENsaWVudF0KRW5hYmxlZCAgICAgICAgICAgICAgICAgICAgID0gdHJ1ZQpBZGRyZXNz
ICAgICAgICAgICAgICAgICAgICAgPSAid2lnby52aXJ0dWFsLWRhcmsuY29tIgpQb3J0ICAgICAg
ICAgICAgICAgICAgICAgICAgPSA0MDAxClNzbEVuYWJsZWQgICAgICAgICAgICAgICAgICA9IHRy
dWUKU3NsQ2VydCAgICAgICAgICAgICAgICAgICAgID0gIi92YXIvbGliL3dpZ28vbWFzdGVyLmNy
dCIKVXVpZFNpZyAgICAgICAgICAgICAgICAgICAgID0gIi92YXIvbGliL3dpZ28vdXVpZC5zaWci
ClB1c2hJbnRlcnZhbCAgICAgICAgICAgICAgICA9IDEwCgojIE9wZW5UU0RCCiMKIyBZb3UgY2Fu
IHNwZWNpZnkgYW4gT3BlblRTREIgaW5zdGFuY2UgdG8gZ3JhcGggYWxsIHByb2JlcyBtZXRyaWNz
CiMKIyBQYXJhbXMgOgojICAgT3BlblRTREJFbmFibGVkICAgICAgICAgLT4gV2V0aGVyIG9yIG5v
dCBPcGVuVFNEQiBncmFwaGluZyBpcyBlbmFibGVkICh0cnVlL2ZhbHNlKQojICAgT3BlblRTREJB
ZGRyZXNzICAgICAgICAgLT4gSXAgb2YgT3BlblRTREIgaW5zdGFuY2UKIyAgIE9wZW5UU0RCUG9y
dCAgICAgICAgICAgIC0+IFBvcnQgb2YgT3BlblRTREIgaW5zdGFuY2UKIyAgIE9wZW5UU0RCTWV0
cmljUHJlZml4ICAgIC0+IFByZWZpeCBhZGRlZCBiZWZvcmUgbWV0cmljIG5hbWUgKGEgZG90IHdp
bGwgYmUgYWRkZWQgYmV0d2VlbiBwcmVmaXggYW5kIHByb2JlIG5hbWUpCiMKW09wZW5UU0RCXQpF
bmFibGVkICAgICAgICAgICAgICAgICAgICAgPSBmYWxzZQpBZGRyZXNzICAgICAgICAgICAgICAg
ICAgICAgPSBbImxvY2FsaG9zdCJdClNzbEVuYWJsZWQgICAgICAgICAgICAgICAgICA9IGZhbHNl
Ck1ldHJpY1ByZWZpeCAgICAgICAgICAgICAgICA9ICJ3aWdvIgpEZWR1cGxpY2F0aW9uICAgICAg
ICAgICAgICAgPSA2MDAKQnVmZmVyU2l6ZSAgICAgICAgICAgICAgICAgID0gMTAwMDAKCiMgUmVt
b3RlV2lnb3MKIwojIFlvdSBjYW4gY29uZmlndXJlIHJlbW90ZVdpZ29zIHRvIG1vbml0b3JlIHRo
ZW0gZnJvbSB0aGF0IGluc3RhbmNlIG9mIFdpZ28KIwojIENoZWNrSW50ZXJ2YWwgICAgICAtPiBO
dW1iZXIgb2Ygc2Vjb25kcyBiZXR3ZWVuIHJlbW90ZSB3aWdvIGNoZWNrcyAoZG8gbm90IHNldCBh
IHZhbHVlIGxvd2VyIHRoYW4gQWxpdmVUaW1lb3V0LzIpCiMKCltSZW1vdGVXaWdvc10KQ2hlY2tJ
bnRlcnZhbCAgICAgICAgICAgICAgID0gMTAKU3NsRW5hYmxlZAkJICAgICAgICAgICAgPSBmYWxz
ZQpMb2dpbgkJCSAgICAgICAgICAgID0gIiIKUGFzc3dvcmQJCSAgICAgICAgICAgID0gIiIKCiMg
U2ltcGxlIG1vZGUgKHlvdSBqdXN0IGRlZmluZSBob3N0bmFtZSBhbmQgcG9ydCwgd2hpY2ggaXMg
b3B0aW9uYWwpCiMgTGlzdCAgICAgICAgICAgICAgICAgICAgICAgID0gWwojICAgICAiaXAiLCAg
ICAgICAgICAgICAgICAgICAgICAgIC0+IElQIChtYW5kYXRvcnkpICA6IEhvc3RuYW1lIG9mIHJl
bW90ZVdpZ28gdG8gY2hlY2sKIyAgICAgImlwOnBvcnQiLCAgICAgICAgICAgICAgICAgICAtPiBw
b3J0IChvcHRpb25hbCkgOiBQb3J0IHRvIGNvbm5lY3QgdG8gb24gcmVtb3RlIGhvc3QgKGRlZmF1
bHQgaXMgbG9jYWwgTGlzdGVuUG9ydCkKIyBdCiMKTGlzdCAgICAgICAgICAgICAgICAgICAgICAg
ID0gW10KCiMgRnVsbCBtb2RlIChldmVyeSBjb25maWd1cmF0aW9uIHBhcmFtZXRlciBpcyBjdXN0
b21pemFibGUgYnkgcmVtb3RlIHdpZ28pCiMgW1tBZHZhbmNlZExpc3RdXQojICAgIEhvc3RuYW1l
ICAgICAgICAgID0gImlwIiAgICAgIC0+IG1hbmRhdG9yeTogSG9zdG5hbWUgb2YgcmVtb3RlV2ln
byB0byBjaGVjawojICAgIFBvcnQgICAgICAgICAgICAgID0gNDAwMCAgICAgIC0+IG9wdGlvbmFs
IDogUG9ydCBvZiByZW1vdGVXaWdvIHRvIGNoZWNrIChkZWZhdWx0IGlzIGxvY2FsIExpc3RlblBv
cnQpCiMgICAgQ2hlY2tJbnRlcnZhbCAgICAgPSAxMCAgICAgICAgLT4gb3B0aW9uYWwgOiBOdW1i
ZXIgb2Ygc2Vjb25kcyBiZXR3ZWVuIHJlbW90ZSB3aWdvIGNoZWNrcyAoZGVmYXVsdCBpcyBSZW1v
dGVXaWdvc0NoZWNrSW50ZXJ2YWwpCiMgICAgQ2hlY2tSZW1vdGVzRGVwdGggPSAwICAgICAgICAg
LT4gb3B0aW9uYWwgOiBEZXB0aCBsZXZlbCBmb3IgcmVtb3RlV2lnb3Mgb2YgcmVtb3RlV2lnbyBj
aGVja2luZyAoZGVmYXVsdCBpcyAwIC0+IGFsbCBsZXZlbHMpCiMKI1tbQWR2YW5jZWRMaXN0XV0K
IyAgICBIb3N0bmFtZSAgICAgICAgPSAiaXAyIgojICAgIENoZWNrUmVtb3RlcyAgICA9IDEKIwoK
CiMgTm90aWZpY2F0aW9ucwojCiMgWW91IGNhbiBjb25maWd1cmUgbm90aWZpY2F0aW9ucyAoaHR0
cCxlbWFpbCkgd2hlbiBhIHByb2JlL2hvc3Qgc3RhdHVzIGNoYW5nZXMKIwpbTm90aWZpY2F0aW9u
c10KCiMgR2VuZXJhbApNaW5MZXZlbFRvU2VuZCAgICAgICAgICAgICAgPSAyNTAKUmVzY3VlT25s
eSAgICAgICAgICAgICAgICAgID0gZmFsc2UKT25XaWdvQ2hhbmdlICAgICAgICAgICAgICAgID0g
ZmFsc2UKT25Qcm9iZUNoYW5nZSAgICAgICAgICAgICAgID0gZmFsc2UKCiMgSFRUUApIdHRwRW5h
YmxlZCAgICAgICAgICAgICAgICAgPSAwICAgICAgICAgICAgICAgICAgICAgIyAtPiAwOiBkaXNh
YmxlZCwgMTogZW5hYmxlZApIdHRwVXJsICAgICAgICAgICAgICAgICAgICAgPSAiIgoKIyBFTUFJ
TApFbWFpbEVuYWJsZWQgICAgICAgICAgICAgICAgPSAwICAgICAgICAgICAgICAgICAgICAgIyAt
PiAwOiBkaXNhYmxlZCwgMTogZW5hYmxlZCwgMjogb25seSBpZiBodHRwIGZhaWxlZApFbWFpbFNt
dHBTZXJ2ZXIgICAgICAgICAgICAgPSAic210cC5kb21haW4udGxkOjI1IgpFbWFpbFJlY2lwaWVu
dHMgICAgICAgICAgICAgPSBbInVzZXJAZG9tYWluLnRsZCIsInVzZXIyQGRvbWFpbi50bGQiXQpF
ICAgICAgID0gIndpZ29AZG9tYWluLnRsZCIK' | base64 --decode > /etc/wigo/wigo.conf

echo "Get hostname ..."
HOSTNAME="`hostname |tr -d '\n'`"

echo "This hostname : $HOSTNAME ..."

echo "Change name server by $HOSTNAME in file /etc/wigo/wigo.conf ..."
sed -i "s/PLIK/$HOSTNAME/g" /etc/wigo/wigo.conf

echo "Change group server in file /etc/wigo/wigo.conf ..."
if [ $PRIVATEIP -eq 1 ] ; then
    sed -i "s/Group                       = \"\"/Group                       = \"Gateway_Labs_vxlan_5000\"/g" /etc/wigo/wigo.conf
elif [ "$SERVERGROUP" != "unset" ] ; then
    sed -i "s/Group                       = \"\"/Group                       = \"$SERVERGROUP\"/g" /etc/wigo/wigo.conf
else
    sed -i "s/Group                       = \"\"/Group                       = \"TmpZone\"/g" /etc/wigo/wigo.conf
fi


echo "Restart WIGO ..."
/etc/init.d/wigo restart

echo "END ..."
