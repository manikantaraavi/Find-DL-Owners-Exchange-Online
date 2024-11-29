# Check if Exchange Online PowerShell module is installed
if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
  Write-Host "Exchange Online PowerShell module is not installed. Installing now..." -ForegroundColor Yellow
  Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}

# Import the Exchange Online PowerShell module
Import-Module ExchangeOnlineManagement

# Check if already connected to Exchange Online
$connected = $false
try {
  $null = Get-EXOMailbox -ResultSize 1 -ErrorAction Stop
  $connected = $true
}
catch {
  Write-Host "Not connected to Exchange Online. Connecting now..." -ForegroundColor Yellow
  try {
      Connect-ExchangeOnline
      $connected = $true
  }
  catch {
      Write-Error "Failed to connect to Exchange Online. Error: $_"
      return
  }
}

function Get-DLOwnership {
  param(
      [Parameter(Mandatory = $true)]
      [string]$UserEmailAddress
  )

  try {
      # Get user details
      $user = Get-EXOMailbox -Identity $UserEmailAddress -ErrorAction Stop
      if (!$user) {
          Write-Error "User not found: $UserEmailAddress"
          return
      }

      Write-Host "Checking DL ownership for user: $UserEmailAddress" -ForegroundColor Green
      
      # Get all distribution groups
      $allDLs = Get-DistributionGroup -ResultSize Unlimited
      $ownedDLs = @()

      foreach ($dl in $allDLs) {
          try {
              # Get detailed DL information
              $dlDetail = Get-DistributionGroup -Identity $dl.DistinguishedName
              
              # Check multiple ownership attributes
              $isOwner = $false
              
              # Check ManagedBy attribute
              if ($dlDetail.ManagedBy -contains $user.DistinguishedName) {
                  $isOwner = $true
              }
              
              # Check PrimarySmtpAddress
              if ($dlDetail.ManagedBy -contains $user.PrimarySmtpAddress) {
                  $isOwner = $true
              }
              
              # Check UserPrincipalName
              if ($dlDetail.ManagedBy -contains $user.UserPrincipalName) {
                  $isOwner = $true
              }

              # Check Display Name
              if ($dlDetail.ManagedBy -contains $user.DisplayName) {
                  $isOwner = $true
              }

              # Check Alias
              if ($dlDetail.ManagedBy -contains $user.Alias) {
                  $isOwner = $true
              }

              if ($isOwner) {
                  $dlInfo = [PSCustomObject]@{
                      'DL Name' = $dl.DisplayName
                      'DL Email' = $dl.PrimarySmtpAddress
                      'Member Count' = (Get-DistributionGroupMember -Identity $dl.DistinguishedName).Count
                      'Created Date' = $dl.WhenCreated
                      'Managed By' = $dlDetail.ManagedBy -join '; '
                  }
                  $ownedDLs += $dlInfo
                  Write-Host "Found DL: $($dl.DisplayName)" -ForegroundColor Green
              }
          }
          catch {
              Write-Warning "Error checking DL $($dl.DisplayName): $_"
              continue
          }
      }

      # Output results
      if ($ownedDLs.Count -gt 0) {
          Write-Host "`nFound" $ownedDLs.Count "Distribution Lists owned by user" $UserEmailAddress -ForegroundColor Green
          $ownedDLs | Format-Table -AutoSize
      }
      else {
          Write-Host "`nNo Distribution Lists found where $UserEmailAddress is an owner." -ForegroundColor Yellow
      }

      # Export to CSV if there are results
      if ($ownedDLs.Count -gt 0) {
          $exportPath = ".\DL_Ownership_$($UserEmailAddress.Split('@')[0])_$(Get-Date -Format 'yyyyMMdd').csv"
          $ownedDLs | Export-Csv -Path $exportPath -NoTypeInformation
          Write-Host "`nResults exported to: $exportPath" -ForegroundColor Green
      }
  }
  catch {
      Write-Error "An error occurred: $_"
  }
}

# Replace with the email address you want to check
Get-DLOwnership -UserEmailAddress "username@domain.com"

# Disconnect from Exchange Online when done
Disconnect-ExchangeOnline -Confirm:$false