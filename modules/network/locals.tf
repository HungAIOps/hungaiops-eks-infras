locals {
  _az_count = length(var.availability_zones)

  # Number of bits needed to carve _az_count equal pieces out of one pool
  # e.g. 2 AZs -> 1 bit, 3-4 AZs -> 2 bits, 5-8 AZs -> 3 bits
  _subnet_bits = ceil(log(local._az_count, 2))

  # Two top-level pools: quarter 0 = public, quarter 1 = private-app
  _public_subnet_pool      = cidrsubnet(var.vpc_cidr, 2, 0)
  _private_app_subnet_pool = cidrsubnet(var.vpc_cidr, 2, 1)

  _auto_public_subnet_cidrs = [
    for i in range(local._az_count) : cidrsubnet(local._public_subnet_pool, local._subnet_bits, i)
  ]

  _auto_private_app_subnet_cidrs = [
    for i in range(local._az_count) : cidrsubnet(local._private_app_subnet_pool, local._subnet_bits, i)
  ]

  public_subnet_cidrs = local._auto_public_subnet_cidrs

  private_app_subnet_cidrs = local._auto_private_app_subnet_cidrs
}