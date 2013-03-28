def devstack_params(change, params):
    if change.branch == 'stable/diablo':
        params['NODE_LABEL'] = 'devstack-oneiric'

def python27_params(change, params):
    if (hasattr(change, 'branch') and
        change.branch == 'stable/diablo'):
        params['NODE_LABEL'] = 'oneiric'
