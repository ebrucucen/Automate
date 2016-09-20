function Set-AzureRMStorageExtended {
  param(  
    $filedefault,
    $containerName, 
    $shareName,
    $pathShareName,
    $blobname,
    $storageAccountResourceGroupName,
    $storageAccountName,
    $skuName)

  #Setup-AzureRmSubscription

  $storageAccount= (Get-AzureRmStorageAccount -StorageAccountName $storageAccountName -ResourceGroupName $storageAccountResourceGroupName -ErrorAction SilentlyContinue)
  if($null -eq $storageAccount){
    $storageAccount=New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -Location $location -SkuName $skuName -Verbose
  }
  #A. with container:   
  $container=(Get-AzureStorageContainer -Name $containerName -Context ($storageAccount.Context) -ErrorAction SilentlyContinue)
  if($null -eq $container){
    $container=New-AzureStorageContainer -Name $containerName  -Context ($storageAccount.Context) -Permission Blob
  }
  $result=Set-AzureStorageBlobContent -File $filedefault -Container $containerName -Blob $blobname -Context ($storageAccount.Context)
  $blob = Get-AzureStorageBlob -Context $context -Blob $blobname -Container $containerName
  
  #Check
  $blob.ICloudBlob.StorageUri.PrimaryUri

  #B. with share:
  $share= Get-AzureStorageShare -Context ($storageAccount.Context) -Name $shareName -ErrorAction SilentlyContinue
  
  if($null -eq $share){  
    $share=New-AzureStorageShare -Name $shareName -Context ($storageAccount.Context) 
    $directory=New-AzureStorageDirectory -Context ($storageAccount.Context) -Path $sharePathName -ShareName $shareName
  }
  $filename=Split-Path $filedefault -Leaf
  $destination=Join-Path -Path $directory $filename 
  
  $result=Set-AzureStorageFileContent -Share $share -Source $filedefault -Path $destination
  $file=Get-AzureStorageFile -ShareName $share -Path $destination -Context ($storageAccount.Context)
  
  #Check
  $file.storageUri.primaryUri
}  

Set-AzureRMStorageExtended
