# Helping variables
$botSubDomain = $env:botSubDomain
$azureLocation = $env:azureLocation
$projectPrefix = $env:projectPrefix
$resourceGroupName = $projectPrefix +"_rg"

$AKSClusterName = "recBotAKSCluster"
# TODO: remove this and make better
$PASSWORD_WIN="AbcABC123!@#123456"

$AKSmgResourceGroup = "MC_"+$resourceGroupName+"_"+"$AKSClusterName"+"_"+$azureLocation
$publicIpName = "myRecBotPublicIP"

$acrName = $env:acrName

Write-Output "(Got from ENV): RG: $resourceGroupName, MC rg: $AKSmgResourceGroup, location: $azureLocation"
Write-Output "Environment Azure CL: $(az --version)"

# Create the resource group
Write-Output "About to create resource group: $resourceGroupName"
az group create -l $azureLocation -n $resourceGroupName

# Create Application Insights for the recording bot
Write-Output "About to create Application Insights for rec bot."
az extension add --name application-insights
az monitor app-insights component create -a "botAI" -l $azureLocation -g $resourceGroupName
$appInsightsKey = az monitor app-insights component show --app "botAI" -g $resourceGroupName --query 'instrumentationKey'
Write-Output "Got app insights key: $appInsightsKey"


# Create the AKS Cluster
Write-Output "About to create AKS cluster: $resourceGroupName"
az aks create --resource-group $resourceGroupName --name $AKSClusterName --node-count 1 --enable-addons monitoring --generate-ssh-keys --kubernetes-version 1.23.3 --windows-admin-password $PASSWORD_WIN --windows-admin-username azureuser --vm-set-type VirtualMachineScaleSets --network-plugin azure --service-principal $env:SP_ID --client-secret $env:SP_SECRET

# Add the Windows Node pool
Write-Output "About to create AKS windows pool: $resourceGroupName"
az aks nodepool add --resource-group $resourceGroupName --cluster-name $AKSClusterName --os-type Windows --name scale --node-count 1 --node-vm-size Standard_D4s_v3

# Create the Azure Container Registry to hold the bot's docker image (if not already there)
Write-Output "About to create ACR: $acrName"
az acr create --resource-group $resourceGroupName --name $acrName --sku Basic --admin-enabled true

Write-Output "Updating AKS cluster with ACR"
az aks update -n $AKSClusterName -g $resourceGroupName --attach-acr $acrName

# Move the Public IP address to MC_ resource group.
# This is needed in order for the load balancer to get assigned with the Public IP, otherwise you might end up in a "pending" state.
Write-Output "Move Public IP resource to MC_ resource group"
$publicIpAddressId = az network public-ip show --resource-group $resourceGroupName --name $publicIpName --query 'id'
az resource move --destination-group $AKSmgResourceGroup --ids $publicIpAddressId

# Starting with basic setup
Write-Output "Getting AKS credentials for cluster: $AKSClusterName"
az aks get-credentials --resource-group $resourceGroupName --name $AKSClusterName

# Make sure everything is clean before doing things
# on first run this will give errors, but when running it again it will restore things to initial state.

# Uninstall via helm the bot
helm uninstall teams-recording-bot --namespace teams-recording-bot
# Delete certificates namespace
kubectl delete ns cert-manager
# Delete ngix ingress
kubectl delete ns ingress-nginx
# make sure the secret is updated - so delete it if there
kubectl delete secrets bot-application-secrets --namespace teams-recording-bot

Write-Output "About to create cert-manager namespace"
kubectl create ns cert-manager

Write-Output "Updating helm repo"
helm repo add jetstack https://charts.jetstack.io
helm repo update

Write-Output "Installing cert-manager"
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.8.2 --set nodeSelector."kubernetes\.io/os"=linux --set webhook.nodeSelector."kubernetes\.io/os"=linux --set cainjector.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.nodeSelector."kubernetes\.io/os"=linux --set startupapicheck.timeout=5m --set installCRDs=true

Write-Output "Waiting for cert-manager to be ready"
kubectl wait pod -n cert-manager --for condition=ready --timeout=60s --all

Write-Output "Installing cluster issuer"
kubectl apply -f 00_RecordingBot/deploy/cluster-issuer.yaml
# Write-Output "Sleeping for 30 secs before retrying
Start-Sleep -Seconds 30
kubectl apply -f 00_RecordingBot/deploy/cluster-issuer.yaml

# Setup Ingress
Write-Output "Creating ingress-nginx namespace"
kubectl create namespace ingress-nginx

# Create a Public Ip on the MC_RESOURCEGROUP_AKSCLUSTERNAME_AZUREREGION Resource group
Write-Output "About get public ip: $publicIpName (this should have been created on the previous step)"
$publicIpAddress = az network public-ip show --resource-group $AKSmgResourceGroup --name $publicIpName --query 'ipAddress'
Write-Output "Got public ip: $publicIpAddress"

Write-Output "Adding helm repositories"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable
helm repo update

Write-Output "Installing ingress-nginx"
helm install nginx-ingress ingress-nginx/ingress-nginx --create-namespace --namespace ingress-nginx --set controller.replicaCount=1 --set controller.nodeSelector."kubernetes\.io/os"=linux --set controller.service.enabled=false --set controller.admissionWebhooks.enabled=false --set controller.config.log-format-stream="" --set controller.extraArgs.tcp-services-configmap=ingress-nginx/teams-recording-bot-tcp-services --set controller.service.loadBalancerIP=$publicIpAddress

# Setup AKS namespace for teams-recording-bot
Write-Output "Creating teams-recording-bot namespace and bot secret that holds BOT_ID, BOT_SECRET, BOT_NAME, Cognitive Service Key and Middleware End Point"
Write-Output "Botname is: $env:botName and Persistance end point is: $env:persistenceEndPoint, Application Insights Key is: $appInsightsKey    and applicationId=$env:BOT_ID --from-literal=applicationSecret=$env:BOT_SECRET --from-literal=botName=$env:botName --from-literal=azureCognitiveKey=$env:azureCognitiveKey --from-literal=persistenceEndPoint=$env:persistenceEndPoint --from-literal=azureCognitiveRegion=$azureLocation --from-literal=appInsightsKey=$appInsightsKey"

kubectl create ns teams-recording-bot
kubectl create secret generic bot-application-secrets --namespace teams-recording-bot --from-literal=applicationId=$env:BOT_ID --from-literal=applicationSecret=$env:BOT_SECRET --from-literal=botName=$env:botName --from-literal=azureCognitiveKey=$env:azureCognitiveKey --from-literal=persistenceEndPoint=$env:persistenceEndPoint --from-literal=azureCognitiveRegion=$azureLocation --from-literal=appInsightsKey=$appInsightsKey

# Setup Helm for recording bot
Write-Output "Setting up helm for teams-recording-bot for bot domain: $botSubDomain and Public IP: $publicIpAddress"
Write-Output "Make sure there is an A record for this...mapping your bot subdomain with your Public IP"

helm install teams-recording-bot 00_RecordingBot/deploy/teams-recording-bot --namespace teams-recording-bot --create-namespace --set host=$botSubDomain --set public.ip=$publicIpAddress --set image.domain="$acrName.azurecr.io" --set image.tag=1.0.0

# Validate certificate, wait a minute or two
# Write-Output "Sleeping for 5 mins before running validation."
Start-Sleep -Seconds 300
kubectl get cert -n teams-recording-bot
$certValidation = kubectl get cert -n teams-recording-bot

if ($certValidation -like '*True*')
{
    Write-Output "Certification Validation valid...Yiipiiiii..."
}
else
{
    Write-Output "Certification Validation failed..."
    Write-Output "it might need some more time, or something went wrong..."
    Write-Output "try manually executing: kubectl get cert -n teams-recording-bot in a few minutes."
    Write-Output "if this doesn't work check your A record settings..."
    exit -1
}
