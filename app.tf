resource "null_resource" "web_app" {
  # Changes to any number of app servers requires re-provisioning
  triggers = {
    web_app_instances = "${join(",", module.server["server-apache"].public_dns)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = element(module.server["server-apache"].public_ip, 0)
    user = "ubuntu"
    private_key = data.terraform_remote_state.ssh-keys.outputs.private_key
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh",
    ]
  }
}
