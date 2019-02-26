variable "digitalocean_token" {}
variable "digitalocean_ssh_fingerprint" {}
variable "digitalocean_pub_key" {}
variable "digitalocean_private_key" {}

provider "digitalocean" {
  token="${var.digitalocean_token}"
}

resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = "${file("/home/vincent/.ssh/ipad_rsa.pub")}"
}

resource "digitalocean_droplet" "dev" {
  ssh_keys           = [24095233]         # doctl compute ssh-key list
  image              = "ubuntu-18-10-x64"
  region             = "lon1"
  size               = "s-4vcpu-8gb"
  private_networking = true
  backups            = true
  ipv6               = true
  name               = "dev"
  ssh_keys 					 = ["${var.digitalocean_ssh_fingerprint}"]

  # I really hate user-data, don't @ me. This is powerful and works fine for my
  # needs
  provisioner "remote-exec" {
    script = "bootstrap.sh"

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "file" {
    source      = "pull-secrets.sh"
    destination = "/mnt/secrets/pull-secrets.sh"

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /mnt/secrets/pull-secrets.sh",
    ]

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }
}

#I create a floating ip:
resource "digitalocean_floating_ip" "dev" {
  droplet_id = "${digitalocean_droplet.dev.id}"
  region = "${digitalocean_droplet.dev.region}"
}

resource "digitalocean_firewall" "dev" {
  name = "dev"

  droplet_ids = ["${digitalocean_droplet.dev.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "3222"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "udp"
      port_range       = "60000-60010"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

output "public_ip" {
  value = "${digitalocean_droplet.dev.ipv4_address}"
}
