# spacerace-gs
Code for the ERT Spacerace Ground Station

# Configuration de la Xbee
## Pour Ground-Station :

 1. Upload le fichier de configuration [profile-GSSR.xpro](https://github.com/ERT-SR-GS/spacerace-gs/blob/main/profile_GSSR.xpro) avec le logiciel XCTU.
 2. Changer le **ATDL** (Destination address Low) pour celle de l'avionics que vous voulez connecter. (Voir liste des adresses ci-dessous)

## Pour Avionics :
1. Upload le fichier de configuration [profile-GSSR.xpro](https://github.com/ERT-SR-GS/spacerace-gs/blob/main/profile_GSSR.xpro) avec le logiciel XCTU.
2. Changer le **ATNI** (Node Identifier) pour le nom de votre team (par exemple "Vostok")
3. Changer le **ATDL** (Destination address Low) pour celle de la GS. (Voir liste des adresses ci-dessous)

## Liste des Adresses :
|Name|Address High (ATDH)|Address Low (ATDL)|
|--|--|--|
|GS|0013 A200|41CE 3F60|
|Echo|0013 A200| *TO COMPLETE* |
|Vostok|0013 A200|41CE 3E8B|
|Cosmos|0013 A200| *TO COMPLETE* |
