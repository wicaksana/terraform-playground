# storage account for boot diagnostics
# resource "azurerm_storage_account" "storage_acct" {
#   name                     = "diag2134csxc4"
#   location                 = azurerm_resource_group.rg.location
#   resource_group_name      = azurerm_resource_group.rg.name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

resource "azurerm_windows_virtual_machine" "dc" {
  name                  = "${var.project_name}-dc"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  admin_username        = var.admin
  admin_password        = var.password
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_D4s_v6"
  patch_mode            = "AutomaticByPlatform"  # "patch_mode" must always be set to "AutomaticByPlatform" when "source_image_reference" points to a hotpatch enabled image

  os_disk {
    name                 = "${var.project_name}-dc-os-disk"
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-core"
    version   = "latest"
  }

  # boot_diagnostics {
  #   storage_account_uri = azurerm_storage_account.storage_acct.primary_blob_endpoint
  # }
}