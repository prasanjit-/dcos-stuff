# ELASTICSEARCH WITH XPACK & LDAP AUTHENTICATION


We have the following goals:

- 1. Build a DC/OS cluster
- 2. Build LDAP server with some dummy users 
- 3. Validate that LDAP is working
- 4. Create custom yaml for #5
- 5. Install Elasticsearch with the base64-encoded custom yaml and xpack enabled.
- 6. Validate Elasticsearch Authentication with LDAP.


The following shell script stands up an LDAP server and an LDAP frontend using public images. And for the elasticsearch docker image we have built a custom image with the elasticsearch.yml and roles_mapping.yml which are available in this repo for reference. The below shell-script will pretty much do everything for you.

```
#!/bin/bash -e
#Runs LDAP Server 
docker run --name ldap-service --hostname example.org --detach -p 389:389 -p 636:636 osixia/openldap:1.2.1

# Runs Admin Panel
docker run --name phpldapadmin-service -p 6480:80 -p 6443:443 --hostname phpldapadmin-service --link ldap-service:ldap-host --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host --detach osixia/phpldapadmin:0.7.1
PHPLDAP_IP=$(docker inspect -f "{{ .NetworkSettings.IPAddress }}" phpldapadmin-service)

#Print Credentials
echo "Go to: https://localhost:6443"
echo "Login DN: cn=admin,dc=example,dc=org"
echo "Password: admin"

#Runs the elasticsearch-xpack with ldap Auth (superuser is 'admin' / password is 'admin')
docker run --name elastic --link ldap-service -d -p9200:9200 -p9300:9300 servergurus/elasticsearch-xpack-ldap


```

- To validate the elasticsearch ldap authentication:

The below command will verify the authentication:

```
curl -u admin:admin http://localhost:9200/_cluster/health
```

The below command displays the authorization level of the user:
```
curl -u admin:admin -X GET "localhost:9200/_xpack/security/_authenticate"
```

The below command fetches a search result:
```
curl -XGET 'http://admin:admin@localhost:9200/_count?pretty' -d '
{
    "query": {
        "match_all": {}
    }
}
'
```
