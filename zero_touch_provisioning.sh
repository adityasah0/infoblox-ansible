#!/bin/bash
PLAY_BOOK="/root/Final_Files/NIOS_with_floating_ip_os_server_facts.yml"
EXIT_STATUS=$?
source /root/Final_Files/admin-openrc.sh
ansible-playbook $PLAY_BOOK

if [ "${EXIT_STATUS}" -eq 0 ]

	then 
		sleep 5

DHCP_REF_VALUE_FOR_GRID_MASTER="$(curl -s -k -u admin:infoblox -H 'content-type: application/json' -X GET "https://"$1"/wapi/v2.7/member:dhcpproperties?_return_fields=enable_dhcp"|grep member | awk '{print $NF}' | cut -d'"' -f2  |head -1)"
echo "${DHCP_REF_VALUE_FOR_GRID_MASTER}"
DHCP_REF_VALUE_FOR_MEMBER1="$(curl -s -k -u admin:infoblox -H 'content-type: application/json' -X GET "https://"$1"/wapi/v2.7/member:dhcpproperties?_return_fields=enable_dhcp"|grep member | awk '{print $NF}' | cut -d'"' -f2  |tail -1)"
DNS_REF_VALUE_FOR_GRID_MASTER="$(curl -s -k -u admin:infoblox -H 'content-type: application/json' -X GET "https://"$1"/wapi/v2.7/member:dns?_return_fields=enable_dns"|grep member| awk '{print $NF}' |cut -d'"' -f2 |head -1)"
DNS_REF_VALUE_FOR_MEMBER1="$(curl -s -k -u admin:infoblox -H 'content-type: application/json' -X GET "https://"$1"/wapi/v2.7/member:dns?_return_fields=enable_dns"|grep member| awk '{print $NF}' |cut -d'"' -f2 | tail  -1)"

DHCP_REF_ARRAY=("${DHCP_REF_VALUE_FOR_GRID_MASTER}" "${DHCP_REF_VALUE_FOR_MEMBER1}" )
DNS_REF_ARRAY=("${DNS_REF_VALUE_FOR_GRID_MASTER}" "${DNS_REF_VALUE_FOR_MEMBER1}" )

 for i in "${DHCP_REF_ARRAY[@]}"
        do
                curl -s -k -u  admin:infoblox -H 'content-type: application/json' -X PUT "https://"$1"/wapi/v2.7/"${i}"?_return_as_object=1" -d '{"enable_dhcp":true}'
        done
 for i in "${DNS_REF_ARRAY[@]}"
        do
                curl -s -k -u admin:infoblox -H 'content-type: application/json' -X PUT "https://"$1"/wapi/v2.7/"${i}"?_return_as_object=1&_return_fields=enable_dns" -d '{"enable_dns":true}'

        done
        echo -e "\x1b[45;19m *** Infoblox Grid is deployed *** \x1b[m"
else
        echo -e "\033[0;31m *** Infoblox Grid deployment failed *** \033[0;31m"

fi


