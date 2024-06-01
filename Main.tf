terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = var.malgus[0]
  region      = var.malgus[1]
  zone        = var.malgus[2]
  credentials = var.malgus[3]
}


# add compute instance to the VPC
resource "google_compute_instance" "task2" {
  name         = var.malgus[9]
  machine_type = var.malgus[10]
  zone         = var.malgus[2]

boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
    # true by default
    auto_delete = true
  }

  network_interface {
    network    = var.malgus[6]
    subnetwork = var.malgus[7]

    access_config {
      // Ephemeral public IP
    }
  }

tags = ["http-server"]

metadata_startup_script = file("startup.sh")

#The instance will not work unless a network is attached to it first  
depends_on = [google_compute_network.task2_vpc,
google_compute_subnetwork.task2_subnet, google_compute_firewall.rules]
}

# Create a Google VPC 
resource "google_compute_network" "task2_vpc" {
  project                 = var.malgus[0]
  name                    = var.malgus[6]
  auto_create_subnetworks = false
  mtu                     = 1460
}

# add subnet to the VPC
resource "google_compute_subnetwork" "task2_subnet" {
  name          = var.malgus[7]
  ip_cidr_range = var.ip_cidr_range
  region        = var.malgus[1]
  network       = google_compute_network.task2_vpc.id
}

# firewall rule to allow traffic on port 80
resource "google_compute_firewall" "rules" {
  name    = var.malgus[8]
  network = google_compute_network.task2_vpc.id

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.source_ranges
  priority      = 1000
}

#Variables
variable "malgus" {
  type = list(string)
  description = "Grouping all the variables"
  default =  ["project-armaggaden-may11","us-east1","us-east1-b",
  "project-armaggaden-may11-2cff6047c441.json","US",
  "https://storage.googleapis.com/", "task2-network", "task2-subnet",
  "firewall-rule","task2-instance","e2-medium"] 
}

variable "ip_cidr_range" {
  type        = string
  description = "IP CIDR range for the subnet"
  default     = "10.178.0.0/24" #11
}

variable "ports" {
  type        = list(string)
  description = "Ports to open on the firewall"
  default     = ["22", "80", "443"] #12
}

variable "source_ranges" {
  type        = list(string)
  description = "Source ranges to allow traffic from"
  default     = ["0.0.0.0/0"] #13
}



