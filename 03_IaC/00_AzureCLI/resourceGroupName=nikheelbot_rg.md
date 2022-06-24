resourceGroupName=itrvwbt_rg
AKSmgResourceGroup=MC_itrvwbt_rg_recBotAKSCluster_eastus
botSubDomain=itrvwbt.nikheel.works
azureLocation=eastus
projectPrefix=itrvwbt
AKSClusterName="recBotAKSCluster"
SP_ID=0a97ed60-9d08-4331-97c9-f1cbf7bf78aa
SP_SECRET=_Vl8Q~9l8IXOUSmHFiRJ_RtiE.ZSjJRIZ2NVjaal
appInsightsKey="8732cb22-7438-481f-91f0-0bcca6c94f7a"
publicIpName="myRecBotPublicIP"
acrName=itrvwbtacr
set +H
PASSWORD_WIN="AbcABC123!@#123456"

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.3 --set nodeSelector."beta\.kubernetes\.io/os"=linux --set webhook.nodeSelector."beta\.kubernetes\.io/os"=linux --set cainjector.nodeSelector."beta\.kubernetes\.io/os"=linux --set installCRDs=true


helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.3 --set nodeSelector."kubernetes\.io/os"=linux --set webhook.nodeSelector."kubernetes\.io/os"=linux --set cainjector.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.timeout=5m --set installCRDs=true

https://github.com/cert-manager/cert-manager/issues/4646