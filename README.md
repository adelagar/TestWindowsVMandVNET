# TestWindowsVMandVNET
A simple template written both in JSON and Bicep to deploy a test Windows Virtual Machine with a Virtual Network. 

The solution will provide the ability to deploy your preferred Windows Server version and a sku size. You can choose the address prefix for the Virtual Network with three subnets.
An Availability Set and a Network Security Group (NSG) are also being applied with the depolyemnt. The NSG has two TCP ports open. The first is TCP 3389 for Remote Desktop and TCP 5986 for WinRM. 
Please note you will have to enable Winrm within the host OS and we recommend using HTTPS (5986).

We provide the solution "as is" with no guarantees. This solution accelerator is provided for the wider Azure cloud ecosystem to use and edit as needed.
Enjoy.

