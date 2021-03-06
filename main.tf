# Configure the Oracle Cloud Infrastructure provider with an API Key
provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

# This runs a main.tf file in the /modules/compartment folder
# that creates a new compartment on the tenancy
module "create_compartment" {
  source = "./modules/compartment"
}

module "setup_networking" {
  subnet_count = 2 #how many subnets you want created
  source = "./modules/networking"
  created_compartment_id = "${module.create_compartment.compartment_id}"
  tenancy_ocid = "${var.tenancy_ocid}"
  availability_domains = "${data.oci_identity_availability_domains.ADs.availability_domains}"
}


# Get a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.compartment_ocid}"
}

# Get info about the tenancy
data "oci_identity_tenancy" "this_tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
  # name = "${tenancy_id["name"]}"

  # bucket_namespace = "$${tenancy_id["name"]}"
  # filter {
  #   name = "name"
  #   bucket_namespace = ["${oci_identity_tenancy.this_tenancy.name}"]
  # }
}

data "oci_objectstorage_bucket_summaries" "buckets1" {
  compartment_id = "${var.compartment_ocid}"
  namespace = "${data.oci_identity_tenancy.this_tenancy.name}"

  # filter {
  #   name = "name"
  #   values = ["${oci_objectstorage_bucket.bucket1.name}"]
  # }
}

# Output the result

# created output for debugging
output "AVAILABILITY DOMAINS" {
  value = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain], "name")}"
}

output "compartment_id" {
  value = "${module.create_compartment.compartment_id}"
}

output "show-ads" {
  value = "${data.oci_identity_availability_domains.ADs.availability_domains}"
}

output "buckets" {
  value = "${data.oci_objectstorage_bucket_summaries.buckets1.bucket_summaries}"
}

output "this_tenancy" {
  value = "${data.oci_identity_tenancy.this_tenancy.name}"
}