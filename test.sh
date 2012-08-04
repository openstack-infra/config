find . -iname '*.pp' | xargs puppet parser validate --modulepath=`pwd`/modules
for f in `find . -iname *.erb` ; do
    erb -x -T '-' $f | ruby -c
done

if [ ! -d applytest ] ; then
    mkdir applytest
fi

csplit -sf applytest/puppetapplytest manifests/site.pp '/^$/' {*}
sed -i -e 's/^[^[:space:]]/#&/g' applytest/puppetapplytest*
find applytest -name 'puppetapplytest*' -print -exec cat {} \; -exec puppet apply --modulepath=./modules:/etc/puppet/modules -v --noop --debug {} \; >/dev/null
