#------------------------------------------------------------------------------------------------------------------------------------------
#Description: This script is used to create Instance in aws
#usage: Intializing a new Terraform template --> terraform init
#       Customising deploument with variables --> terraform plan     OR         --> terraform plan -var="variable=value" (for including variables straight from the command line)
#       plan,apply or destroy                --> terraform apply      OR    --> terraform apply value (if we have stored  for any output value )
#output: Create Instance
#Owner: routhu kumar
#tester:
#---------------------------------------------------------------------------------------------------------------------------------------------


provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "this" {
  count=var.no_of_vms
  ami                  = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone      = var.availability_zone
  cpu_core_count       = var.cpu_core_count
  cpu_threads_per_core = var.cpu_threads_per_core
  disable_api_stop = var.disable_api_stop
  disable_api_termination = var.disable_api_termination
  ebs_optimized = var.ebs_optimized
  get_password_data = var.get_password_data
  hibernation = var.hibernation
  host_id = var.host_id 
  host_resource_group_arn = var.host_resource_group_arn
  iam_instance_profile = var.iam_instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_type        = var.instance_type
  ipv6_address_count          = var.ipv6_address_count
  ipv6_addresses              = var.ipv6_addresses
  key_name             = var.key_name
  monitoring = var.monitoring
  placement_group = var.placement_group 
  placement_partition_number = var.placement_partition_number
  private_ip = var.private_ip 
  secondary_private_ips       = var.secondary_private_ips
  security_groups = var.security_groups 
  source_dest_check = var.source_dest_check 
  subnet_id              = var.subnet_id
  tenancy = var.tenancy 
  user_data = var.user_data
  user_data_base64 = var.user_data_base64 
  user_data_replace_on_change = var.user_data_replace_on_change  
  vpc_security_group_ids = var.vpc_security_group_ids
  tags        = merge({ "Name" = var.name }, var.tags)
  volume_tags = var.enable_volume_tags ? merge({ "Name" = var.name }, var.volume_tags) : null
  
  
  dynamic private_dns_name_options{
    for_each = var.private_dns_name_options
    content {
      enable_resource_name_dns_aaaa_record = lookup(private_dns_name_options.value,enable_resource_name_dns_aaaa_record,null)
      enable_resource_name_dns_a_record = lookup(private_dns_name_options.value,enable_resource_name_dns_a_record,null)
      hostname_type=lookup(private_dns_name_options.value,hostname_type,null)
    }
    
  }
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      tags                  = lookup(root_block_device.value, "tags", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      tags                  = lookup(ebs_block_device.value, "tags", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = length(var.capacity_reservation_specification) > 0 ? [var.capacity_reservation_specification] : []
    content {
      capacity_reservation_preference = try(capacity_reservation_specification.value.capacity_reservation_preference, null)

      dynamic "capacity_reservation_target" {
        for_each = try([capacity_reservation_specification.value.capacity_reservation_target], [])
        content {
          capacity_reservation_id                 = try(capacity_reservation_target.value.capacity_reservation_id, null)
          capacity_reservation_resource_group_arn = try(capacity_reservation_target.value.capacity_reservation_resource_group_arn, null)
        }
      }
    }
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

maintenance_options {
  auto_recovery = var.auto_recovery
}

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "optional")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", "1")
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", null)
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      network_card_index = lookup(network_interface.value, "network_card_index", 0)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  dynamic "launch_template" {
    for_each = var.launch_template != null ? [var.launch_template] : []
    content {
      id      = lookup(var.launch_template, "id", null)
      name    = lookup(var.launch_template, "name", null)
      version = lookup(var.launch_template, "version", null)
    }
  }

   enclave_options {
    enabled = var.enclave_options_enabled
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }


  
}


