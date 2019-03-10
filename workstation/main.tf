variable "do_token"{
  default = "ccc001bafa9f6ddf32c8b6ebaab769e39a5a9899bdd71e5d2482020dd7bbd2b5"
}
variable "pub_key"{
  default = "~/.ssh/id_rsa.pub"
}
variable "pvt_key"{
  default = "~/.ssh/id_rsa"
}
variable "ssh_do_fingerprint" {
  default = "ef:c2:72:18:48:73:44:4c:5f:6e:a7:57:ec:0a:5b:d6"
}
variable "size" {
  default ="s-4vcpu-8gb" 
}

provider "digitalocean" {
	token = "${var.do_token}"
}

resource "digitalocean_droplet" "dev" {
  ssh_keys           = [24130634]         # doctl compute ssh-key list
  image              = "ubuntu-18-04-x64"
  region             = "lon1"
  size               = "s-4vcpu-8gb"
  private_networking = true
  backups            = true
  ipv6               = true
  name               = "dev"

	connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }

  # I really hate user-data, don't @ me. This is powerful and works fine for my
  # needs
  provisioner "remote-exec" {
    script = "bootstrap.sh"
    connection {
      type        = "ssh"
      private_key = "${file(var.pvt_key)}"
      user        = "root"
      timeout     = "2m"
    }
  }

 provisioner "file" {
    source      = "pull-secrets.sh"
    destination = "/mnt/secrets/pull-secrets.sh"

    connection {
      type        = "ssh"
      private_key = "${file(var.pvt_key)}"
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
      private_key = "${file(var.pvt_key)}"
      user        = "root"
      timeout     = "2m"
    }
  }
  
 
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
