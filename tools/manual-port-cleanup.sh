#
# Script to help with manual removal of leaked ports on bridge.o.o.
#
# Removes any DOWN ports in the CLOUD/REGION that have remained after
# sleeping for a few minutes
#

CLOUD=${CLOUD:-openstackjenkins-ovh}
REGION=${REGION:-BHS1}

export OS_CLIENT_CONFIG_FILE=/etc/openstack/all-clouds.yaml
OSC="openstack --os-cloud=$CLOUD --os-region=$REGION"

first=$(mktemp)
second=$(mktemp)

echo "Getting $CLOUD/$REGION initial port status"
$OSC port list -c ID -c Status -f value | grep DOWN | awk '{print $1}' > $first
echo "Done"

echo "Pausing"
sleep 180

echo "Getting updated port status"
$OSC port list -c ID -c Status -f value | grep DOWN | awk '{print $1}' > $second
echo "Done"

ports=$(comm -12 <(sort $first) <(sort $second))

port_count=$(wc -l <<< $ports)
echo $port_count

i=1
for port in $ports; do
    echo "Remove port $port [$i/$port_count]"
    $OSC port delete $port
    i=$((i+1))
done

rm $first
rm $second

echo "Cleanup done"
