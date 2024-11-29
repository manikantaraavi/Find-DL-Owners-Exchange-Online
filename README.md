# Exchange Distribution List Ownership

This PowerShell script helps you find the owners of distribution lists (DLs) in Exchange Online.

## Features

*   Connects to Exchange Online using modern authentication.
*   Retrieves all distribution lists or a specific DL.
*   Checks multiple attributes (e.g., `ManagedBy`) to determine ownership.
*   Handles errors gracefully and logs them to the console.
*   Exports the results to a CSV file for easy analysis.

## Usage

1.  Save the script as `get-user-info.ps1`.
2.  Open PowerShell and navigate to the directory where you saved the script.
3.  Run the script: `.\get-user-info.ps1`
4.  Enter your Exchange Online credentials when prompted.
5.  The script will output the results to the console and export them to a CSV file.

## Customization

*   In the last line of the script, the user needs to change 'username@domain.com' to the email address of the target user they want to check the DL ownership for.
*   Modify the `$exportPath` variable to change the location or name of the CSV file.
*   Adjust the script to check for additional ownership attributes if needed.

## Notes

*   The script requires the Exchange Online Management PowerShell module.
*   Ensure that the account you use to connect has the necessary permissions to access distribution list information.
*   The script handles potential errors when checking DLs, such as when a DL cannot be found.
*   The results are exported to a CSV file named `DL_Ownership_{username}_{date}.csv`.

## Contributing

Feel free to contribute to this project by submitting pull requests or reporting issues.