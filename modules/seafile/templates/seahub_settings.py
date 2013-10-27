# this is generated here
# github.com/haiwen/seafile/blob/master/scripts/setup-seafile-mysql.py#L968
# note the spelling _SECREC_ in SECREC_KEY
SECREC_KEY = $seafile_secrec_key

DATABASES = {
    'default': {
        # this defaults to django.db.backends.mysql, not sure what do to here
        'ENGINE': 'django.db.backends.mysql',
        'NAME': $seafile_seahub-db,
        'USER': $seafile_db_user,
        'PASSWORD': $seafile_db_password,
        'HOST': $seafile_db_host,
        # default is 3306
        'PORT': $seafile_db_port,
        'OPTIONS': {
            'init_command': 'SET storage_engine=INNODB',
        }
    }
}

