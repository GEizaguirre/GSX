#! /bin/bash

tar -xpf /back/usermng.bck.d/passwd.tar /etc/passwd
tar -xpf /back/usermng.bck.d/shadow.tar /etc/shadow
tar -xpf /back/usermng.bck.d/group.tar /etc/group
tar -xpf /back/usermng.bck.d/gshadow.tar /etc/gshadow
tar -xpf /back/usermng.bck.d/subuid.tar /etc/subuid
tar -xpf /back/usermng.bck.d/subgid.tar /etc/subgid

exit 0
