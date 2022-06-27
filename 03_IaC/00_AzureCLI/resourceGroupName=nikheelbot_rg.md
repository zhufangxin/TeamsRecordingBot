resourceGroupName=rjbotin_rg
AKSmgResourceGroup=MC_rjbotin_rg_recBotAKSCluster_centralus
botSubDomain=rjbotin.nikheel.works
azureLocation=centralus
projectPrefix=rjbotin
AKSClusterName="recBotAKSCluster"
SP_ID=0a97ed60-9d08-4331-97c9-f1cbf7bf78aa
SP_SECRET=_Vl8Q~9l8IXOUSmHFiRJ_RtiE.ZSjJRIZ2NVjaal
appInsightsKey="6cae6481-7960-4c0a-9602-33e91532b428"
publicIpName="myRecBotPublicIP"
acrName=rjbotinacr
publicIpAddressId="20.118.234.111"
az aks get-credentials --resource-group $resourceGroupName --name $AKSClusterName
set +H
PASSWORD_WIN="AbcABC123!@#123456"

helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.3 --set nodeSelector."beta\.kubernetes\.io/os"=linux --set webhook.nodeSelector."beta\.kubernetes\.io/os"=linux --set cainjector.nodeSelector."beta\.kubernetes\.io/os"=linux --set installCRDs=true


helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.3 --set nodeSelector."kubernetes\.io/os"=linux --set webhook.nodeSelector."kubernetes\.io/os"=linux --set cainjector.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.timeout=5m --set installCRDs=true

https://github.com/cert-manager/cert-manager/issues/4646

kubectl debug node/aksscale000000 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0
node-debugger-aksscale000000-qdlxt
kubectl port-forward node-debugger-aksscale000000-qdlxt 2022:22